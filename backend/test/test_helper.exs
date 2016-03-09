ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Backend.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Backend.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Backend.Repo)

