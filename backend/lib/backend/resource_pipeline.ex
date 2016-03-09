defmodule Backend.ResourcePipeline do
  require Logger

  import Plug.Conn
  import Phoenix.Controller, only: [render: 3, render: 4]
  import Backend.Router.Helpers

  alias Backend.Geo
  alias Backend.Repo

  import Ecto
  import Ecto.Changeset, only: [change: 1, change: 2]
  import Ecto.Query, only: [from: 1, from: 2]

  def build_resource(conn, opts) do
    resource_module = opts[:resource]
    resource_name = opts[:resource_name] || resource_module |> to_string |> String.split(".") |> List.last |> String.downcase

    # TODO: action dependent
    %{params: %{ ^resource_name => geo_params }} = conn

    changeset = Geo.changeset(%Geo{}, geo_params)

    assign(conn, :resource_name, resource_name)
    |> assign(:resource, changeset)
  end

  def persist_resource(conn, _opts) do
    case Repo.insert(conn.assigns.resource) do
      {:ok, model} ->
        conn
        |> put_status(:created)
        |> assign(:resource, change(model))
        # |> put_resp_header("location", v1_geo_path(conn, :show, geo))

      {:error, changes} ->
        conn
        |> put_status(:unprocessable_entity)
        |> assign(:resource, changes)
    end
  end

  def respond_with conn do
    do_respond_with conn, conn.assigns.resource_name, conn.assigns.resource
  end

  defp do_respond_with conn, _name, %{valid?: false} = changeset do
    render(conn, Backend.ChangesetView, "error.json", changeset: changeset)
  end

  defp do_respond_with conn, name, changes do
    render(conn, "show.json", [{:"#{name}", changes.model}])
  end
end
