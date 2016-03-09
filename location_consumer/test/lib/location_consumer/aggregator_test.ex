defmodule LocationConsumer.AggregatorTest do
  use ExUnit.Case
  require Logger
  # defmodule Shared do
  # defmacro genserver do
  #   quote do

  defmacro assert_receive_count(num, wait_coeff) do
    # coeff = round( (wait_coeff - 100)/(num - 1) ) - 1
    # f = &(wait_coeff - coeff * (&1-1))
    vars = for i <- 1..num, do: {Macro.var(:"msg_#{i}", nil), wait_coeff}
    quote do
      unquote(
        Enum.map(vars, fn {var, time} ->
          quote do: assert_receive(unquote(var), unquote(time))
        end)
      )
      unquote(quote do
        Enum.each unquote(vars), &IO.puts("\nmsg: #{inspect &1}")
      end)
    end
  end

  # defmodule Worker do
  defmodule Shared do
    defmacro gen_server do
      quote do
        require Logger
        use GenServer
        import Process, only: [send_after: 3]

        def perform(pid, item) do
          GenServer.call(pid, {:process, item})
        end

        def start_link key do
          GenServer.start_link __MODULE__, key
        end

        def init key do
          :random.seed :os.timestamp
          {:ok, key}
        end

        def handle_call {:process, item}, {pid, _tag}, key do
          wait_time  = :random.uniform(1500)
          Logger.debug "calling remote #{inspect {pid, key, wait_time, item}}"
          send_after pid, {:sync, item.id, key, wait_time}, wait_time
          {:reply, item, key}
        end
      end
    end
  end

  defmodule Locator, do: (require Shared; Shared.gen_server)
  defmodule Altitude, do: (require Shared; Shared.gen_server)

  setup do
    pool_args = fn module ->
      [
        name: {:local, Module.concat(module, Pool)},
        worker_module: module,
        size: 10,
        max_overflow: 10
      ]
    end
    {:ok, pb_1} = :poolboy.start_link pool_args.(Locator), :loc
    {:ok, pb_2} = :poolboy.start_link pool_args.(Altitude), :alt
    {:ok, sink} = GenEvent.start_link
    {:ok, source} = GenEvent.start_link
    {:ok, _} = LocationConsumer.Aggregator.start_link source, sink, [
      modules: [Locator, Altitude],
      buffer_size: 10
    ]
    {:ok, %{source: source, sink: sink, pb_1: pb_1, pb_2: pb_2}}
  end

  test "poolboy basics" do
    pool_name = Module.concat Locator, Pool
    return = :poolboy.transaction pool_name, fn(worker)->
      Locator.perform(worker, %{id: "foo"})
    end
    pid_1 = :poolboy.checkout pool_name
    pid_2 = :poolboy.checkout pool_name
    assert pid_1 != pid_2
    Logger.debug "pids: #{inspect {pid_1, pid_2}}"
    # assert %{processed: true} = return
    assert_receive {:sync, id, :loc, _}, 6001
    assert id == return.id
  end

  test "syncronizing streams", %{source: source, sink: sink} do
    here = self()
    spawn_link fn ->
      GenEvent.stream(sink)
      |> Stream.each(fn(item)-> send here, item end)
      |> Stream.run
    end
    :timer.sleep 200
    for i <- 1..110 do
      GenEvent.ack_notify source, %{id: i}
      # GenEvent.notify source, %{id: i}
    end
    Logger.error ">>>\n\n test action end \n\n<<<"
    # NOTE: On finite streams
    #       it receives at most source-count - buffer-size
    start = :erlang.monotonic_time(:milli_seconds)
    assert_receive_count 100, 1500
    stop = :erlang.monotonic_time(:milli_seconds)
    diff = stop - start
    IO.puts "\n===========\ntime effective #{diff} ============"
  end

end
