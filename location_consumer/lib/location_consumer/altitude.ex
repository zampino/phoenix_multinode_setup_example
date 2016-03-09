defmodule LocationConsumer.Altitude do
  require Logger
  use GenServer
  import Process, only: [send_after: 3]

  def perform(pid, item) do
    GenServer.call(pid, {:process, item})
  end

  # CALLBACKS

  def start_link _opts \\ [] do
    GenServer.start_link __MODULE__, :ok
  end

  def init :ok do
    :random.seed :os.timestamp
    {:ok, :alt}
  end

  def handle_call {:process, item}, {pid, _tag}, key do
    wait_time = :random.uniform(1500)
    Logger.debug "calling remote #{inspect {pid, key, wait_time, item}}"
    send_after pid, {:sync, item.id, key, wait_time}, wait_time
    {:reply, item, key}
  end
end
