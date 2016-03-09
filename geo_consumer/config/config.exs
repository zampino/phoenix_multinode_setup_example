# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :geo_consumer, GeoConsumer.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "WDSaP6Yf0H7JYBAOmC+VcCqCJVBEM30tUBS0p9iWYC7gzGFC5lljFXFND93RXJlh",
  render_errors: [accepts: ~w(html json)],
  check_origin: false,
  pubsub: [name: :ext_pub_sub,
           adapter: Phoenix.PubSub.Redis,
           pool: 1]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
