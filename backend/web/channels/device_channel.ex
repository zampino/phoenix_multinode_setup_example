defmodule Backend.DeviceChannel do
  use Backend.Web, :channel
  require Logger

  def join("device:connect", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (device:lobby).
  def handle_in("coord", msg, socket) do
    Logger.debug "[Backend.DeviceChannel] coord: #{inspect msg}"
    payload = %{
      coord: [msg["lat"], msg["long"]],
      id: :crypto.rand_bytes(10) |> Base.hex_encode32(case: :lower),
    }
    Backend.Endpoint.broadcast_from! self, "geo:foo", "coord", payload
    GenEvent.ack_notify {:global, :location_consumer_source}, payload

    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
