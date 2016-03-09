defmodule GeoConsumer.GeoChannel do
  use GeoConsumer.Web, :channel
  alias Phoenix.PubSub
  require Logger

  # intercept ["coord"]

  def join("geo:foo", payload, socket) do
    Logger.debug "[GeoChannel] join process #{inspect {self, socket}}"
    # GeoConsumer.Endpoint.subscribe self, "geo:foo" # , link: true
    # PubSub.subscribe(:ext_pub_sub, self, "geo:foo")

    if authorized?(payload) do
      # socket.channel_pid
      # case PubSub.subscribe :ext_pub_sub, self, "geo:coord", link: true do
      #   :ok -> {:ok, socket}
      #   {:error, reason} -> {:error, reason}
      # end
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("foo", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (geo:coord:lobby).
  def handle_in(msg, payload, socket) do
    # broadcast socket, "shout", payload
    Logger.info "[GeoChannel] -- handle_in: #{inspect {msg, payload}}"
    {:noreply, socket}
  end

  def handle_info msg, socket do
    Logger.info "[GeoChannel] -- handle_info: #{inspect msg}"
    # push socket, event, payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out("coord", payload, socket) do
    # push socket, event, payload
    Logger.info "[GeoChannel] --> intercepting with handle out: #{inspect payload}"
    push socket, "coord", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
