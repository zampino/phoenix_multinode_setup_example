use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :backend, Backend.Endpoint,
  http: [port: 4001],
  server: false,
  pubsub: [name: :ext_pub_sub, adapter: false]

# Print only warnings and errors during test
config :logger, level: :debug

# Configure your database
config :backend, Backend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "amantini",
  password: "amantini",
  database: "backend_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
