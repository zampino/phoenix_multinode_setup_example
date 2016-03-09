defmodule Backend.V1.GeoControllerTest do
  use Backend.ConnCase
  require Logger

  alias Backend.Geo
  @valid_attrs %{coords: "some content", lat: 120.5, long: 120.5, tag: "some content"}
  @invalid_attrs %{lat: 120.0, tag: "but I give you a tag"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    Repo.insert! struct(Geo, @valid_attrs)
    Repo.insert! struct(Geo, @valid_attrs)

    conn = get conn, v1_geo_path(conn, :index)
    assert json_response(conn, 200)["count"] == 2
  end

  # test "shows chosen resource", %{conn: conn} do
  #   geo = Repo.insert! %Geo{}
  #   conn = get conn, v1_geo_path(conn, :show, geo)
  #   assert json_response(conn, 200)["data"] == %{"id" => geo.id,
  #     "tag" => geo.tag,
  #     "coords" => geo.coords,
  #     "lat" => geo.lat,
  #     "long" => geo.long}
  # end

  # test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, v1_geo_path(conn, :show, -1)
  #   end
  # end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, v1_geo_path(conn, :create), geo: @valid_attrs

    Logger.debug(inspect json_response(conn, 201))

    assert json_response(conn, 201)["data"]["id"]
    assert json_response(conn, 201)["data"]["lat"]
    assert json_response(conn, 201)["data"]["long"]

    assert Repo.get_by(Geo, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, v1_geo_path(conn, :create), geo: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
  #
  # test "updates and renders chosen resource when data is valid", %{conn: conn} do
  #   geo = Repo.insert! %Geo{}
  #   conn = put conn, v1_geo_path(conn, :update, geo), geo: @valid_attrs
  #   assert json_response(conn, 200)["data"]["id"]
  #   assert Repo.get_by(Geo, @valid_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   geo = Repo.insert! %Geo{}
  #   conn = put conn, v1_geo_path(conn, :update, geo), geo: @invalid_attrs
  #   assert json_response(conn, 422)["errors"] != %{}
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   geo = Repo.insert! %Geo{}
  #   conn = delete conn, v1_geo_path(conn, :delete, geo)
  #   assert response(conn, 204)
  #   refute Repo.get(Geo, geo.id)
  # end
end
