defmodule GeoConsumer.Subscriber do
  use GenServer
  require Logger
  alias  Phoenix.PubSub

  def start_link do
    GenServer.start_link __MODULE__, :ok
  end

  def init :ok do
    state = %{}
    case GeoConsumer.Endpoint.subscribe self, "geo:foo", link: true do
      :ok -> {:ok, state}
      {:error, reason} -> {:error, reason}
    end
  end

  def handle_info msg, state do
    Logger.debug "[GeoConsumer.Subscriber] -- #{inspect {msg, state}}\n"
    {:noreply, state}
  end
end
