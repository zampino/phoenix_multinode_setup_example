defmodule Backend.Dispatcher do
  require Logger
  alias Phoenix.PubSub

  def init [topics: topics] do
    topics
  end

  def call(%{assigns: %{resource: %{valid?: false}}} = conn, _topics) do
    Logger.warn "resource invalid"
    conn
  end

  def call(%{assigns: %{resource: resource}} = conn, topics) do
    # Logger.warn "dispatching #{inspect resource}\n"

    model = case resource.model.id do
      nil -> resource.changes
      _ -> resource.model
    end

    payload = %{coord: [model.lat, model.long]}
    local_pub_sub = Process.whereis :ext_pub_sub

    Enum.each topics, &broadcast(local_pub_sub, &1, payload)

    conn
  end

  def broadcast(nil, topic, payload), do: :ok

  def broadcast(pid, topic, payload) do
    # Logger.info "[Backend.Dispatcher] broadcast #{inspect {pid, topic, payload}}"
    Backend.Endpoint.broadcast_from! pid, topic, "coord", payload
  end
end
