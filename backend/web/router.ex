defmodule Backend.Router do
  use Backend.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    # plug :versioning
  end

  scope "/", Backend do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/api", Backend do
    pipe_through :api

    scope "/v1", V1, as: :v1 do
      # post "/geos", GeoController, :create
      resources "geos", GeoController, only: [:index, :create]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Backend do
  #   pipe_through :api
  # end
end
