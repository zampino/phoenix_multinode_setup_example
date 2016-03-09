defmodule LocationConsumer.LocStreamChannel do
  use LocationConsumer.Web, :channel
  require Logger

  def join("loc_stream:channel", payload, socket) do
    Process.send_after self, :register_stream, 100
    {:ok, socket}
  end

  def handle_info(:register_stream, socket) do
    spawn_link __MODULE__, :receive_loc, [socket]
    Logger.debug "just registered: #{inspect {Process.alive?(Process.whereis(:sink)), socket}}"
    {:noreply, socket}
  end

  def receive_loc(socket) do
    GenEvent.stream(:sink)
    |> Stream.each(fn(event)->
      # TODO: cache lost events 
      # if event.id == 75, do: 1/0
      Logger.debug "event arrived: #{inspect event}"
      push socket, "loc", event
    end)
    |> Stream.run
  end
end
