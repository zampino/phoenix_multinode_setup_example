defmodule Backend.V1.GeoController do
  use Backend.Web, :controller
  alias Backend.Geo

  plug :scrub_params, "geo" when action in [:create, :update]
  plug :build_resource, [resource: Geo] when action in [:create]
  # plug :persist_resource when action in [:create]
  plug Backend.Dispatcher, [topics: ["geo:foo"]] when action in [:create]
  plug Backend.LocationNotifier when action in [:create]

  def create(conn, _params) do
    respond_with conn
  end

  def index(conn, _params) do
    geos = Repo.all(Geo)
    count = from(g in Geo, select: count(g.id)) |> Repo.one!
    render(conn, "index.json", geos: geos, count: count)
  end
  #
  # def show(conn, %{"id" => id}) do
  #   geo = Repo.get!(Geo, id)
  #   render(conn, "show.json", geo: geo)
  # end
  #
  # def update(conn, %{"id" => id, "geo" => geo_params}) do
  #   geo = Repo.get!(Geo, id)
  #   changeset = Geo.changeset(geo, geo_params)
  #
  #   case Repo.update(changeset) do
  #     {:ok, geo} ->
  #       render(conn, "show.json", geo: geo)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Backend.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   geo = Repo.get!(Geo, id)
  #
  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(geo)
  #
  #   send_resp(conn, :no_content, "")
  # end
end
