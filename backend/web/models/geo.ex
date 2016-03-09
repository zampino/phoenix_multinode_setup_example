defmodule Backend.Geo do
  use Backend.Web, :model

  schema "geos" do
    field :tag, :string
    field :coords, :string
    field :lat, :float
    field :long, :float

    timestamps
  end

  @required_fields ~w(lat long)
  @optional_fields ~w(tag coords)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
