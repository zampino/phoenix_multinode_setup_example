defmodule Backend.LocationNotifier do
  require Logger

  def init(_opts), do: []

  def call(%{assigns: %{resource: %{valid?: false}}} = conn, _topics) do
    Logger.warn "resource invalid"
    conn
  end

  def call(%{assigns: %{resource: resource}}=conn, _opts) do
    model = case resource.model.id do
      nil -> resource.changes
      _ -> resource.model
    end

    payload = %{
      id: :crypto.rand_bytes(10) |> Base.hex_encode32(case: :lower),
      coord: [model.lat, model.long]
    }

    # stupid check for testing
    GenEvent.ack_notify {:global, :location_consumer_source}, payload
    conn
  end
end
