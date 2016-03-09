defmodule LocationConsumer.Aggregator do
  require Logger
  defstruct [:sink, :buffer_size, buffer: :queue.new]
  @default_buffer_size 50

  def start_link(source, sink, options \\ []) do
    :proc_lib.start_link __MODULE__, :init, [source, sink, options]
  end

  def init(source, sink, options) do
    Process.flag :trap_exit, true

    Logger.debug "starting #{inspect {self, source, sink, options}}"

    :proc_lib.init_ack {:ok, self()}

    Enum.reduce(options[:modules], GenEvent.stream(source), fn(module, stream)->
      merge_pool(stream, module)
    end)
    |> Stream.map(fn item -> Logger.debug "passing through #{inspect item}"; item end)
    |> Stream.into(struct __MODULE__, [sink: sink, buffer_size: options[:buffer_size] || @default_buffer_size])
    |> Stream.run()
  end

  def merge_pool(stream, module) do
    pool_name = Module.concat module, Pool
    stream
    |> Stream.map(fn(item)-> {item, :poolboy.checkout(pool_name)} end)
    |> Stream.map(fn {item, worker} -> {
        module.perform(worker, item),
        worker
      }
    end)
    |> Stream.map(fn {item, worker} ->
      :poolboy.checkin(pool_name, worker)
      item
    end)
  end

  defmodule Element do
    defstruct [:id, loc: nil, alt: nil]
    def new(%Element{}=item), do: item
    def new(item), do: struct Element, item
    def ready(elm), do: (elm.loc && elm.alt)
  end

  def into(aggregator) do
    processor = fn
      (aggregator, {:cont, elm}) -> listen(aggregator, elm)
      (_aggregator, :done) -> raise("done?") #aggregator
      (_, :halt) -> :ok #IEx.pry# raise("halted?") #:ok
    end
    {aggregator, processor}
  end

  def listen(%{
    buffer: {r, f}=buffer,
    buffer_size: size
    }=aggregator, item) when length(r) + length(f) < size do
    %{aggregator | buffer: :queue.in(Element.new(item), buffer)}
  end

  def listen(%{buffer: buffer}=aggregator, item) do
    {{:value, last}, buffer} = :queue.in(Element.new(item), buffer) |> :queue.out
    id = last.id
    receive do
      {:sync, ^id, type, data} ->
        Logger.info "++ received on item #{inspect {id, type}}"
        last = Map.put last, type, data
        process(aggregator, buffer, last)
      # x -> Logger.info "received unespected #{inspect x}"
    after
      100 ->
        Logger.info ">> passing on item #{id}}"
        listen %{aggregator | buffer: buffer}, last
    end
  end

  def process(%{sink: sink} = aggregator, buffer, last) do
    if Element.ready(last) do
      Logger.debug("-- sending to sink: #{last.id}")
      GenEvent.ack_notify sink, last
      %{aggregator | buffer: buffer}
    else
      listen %{aggregator | buffer: buffer}, last
    end
  end
end

defimpl Collectable, for: LocationConsumer.Aggregator do
  defdelegate into(acc), to: LocationConsumer.Aggregator
end
