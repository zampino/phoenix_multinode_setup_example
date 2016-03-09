defmodule Backend.V1.GeoView do
  use Backend.Web, :view

  def render("index.json", %{geos: geos, count: count}) do
    %{count: count, data: render_many(geos, Backend.V1.GeoView, "geo.json")}
  end

  def render("show.json", %{geo: geo}) do
    %{data: render_one(geo, Backend.V1.GeoView, "geo.json")}
  end

  def render("geo.json", %{geo: _geo}) do
    # %{id: geo.id,
    #   tag: geo.tag,
    #   coords: geo.coords,
    #   lat: geo.lat,
    #   long: geo.long}
    %{status: :ok}
  end
end
