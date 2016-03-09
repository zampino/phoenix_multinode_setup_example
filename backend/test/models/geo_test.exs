defmodule Backend.GeoTest do
  use Backend.ModelCase

  alias Backend.Geo

  @valid_attrs %{coords: "some content", lat: "120.5", long: "120.5", tag: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Geo.changeset(%Geo{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Geo.changeset(%Geo{}, @invalid_attrs)
    refute changeset.valid?
  end
end
