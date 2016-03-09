defmodule GeoConsumer.PageController do
  use GeoConsumer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
