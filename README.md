# Usage

 ```
 tsung -f random_ll[_ws].xml -l ./log start
 ```

 and to start node-aware applications (see location_consumer/network.config)

 ```
 MIX_ENV=prod PORT=3000 elixir --name lc@amantini.local --erl '-config network.config' -S mix phoenix.server
 ```

 and the other nodes accordingly (omitting --erl flag)
