defmodule LocationConsumer do
  use Application

  alias LocationConsumer.Locator
  alias LocationConsumer.Altitude
  alias LocationConsumer.Aggregator
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      apply(:poolboy, :child_spec, poolboy_config(Locator)),
      apply(:poolboy, :child_spec, poolboy_config(Altitude)),
      worker(GenEvent, [[name: {:global, :location_consumer_source}]], id: :source_worker),
      worker(GenEvent, [[name: :sink]], id: :sink_worker),
      worker(Aggregator, [{:global, :location_consumer_source}, :sink, [modules: [Locator, Altitude], buffer_size: 50]], []),
      supervisor(LocationConsumer.Endpoint, []),
    ]

    opts = [strategy: :one_for_all, name: LocationConsumer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp poolboy_config(module) do
    pool_name = Module.concat(module, Pool)
    [
      pool_name,
      [
        name: {:local, pool_name},
        worker_module: module,
        size: 50,
        max_overflow: 25
      ]
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LocationConsumer.Endpoint.config_change(changed, removed)
    :ok
  end
end
