-module(random_ll).
-export([r_lat/1, r_long/1]).

r_lat({_Pid, _DynVar})->
  io_lib:format("~.4f", [52.45 + random:uniform()/10]).

r_long({_Pid, _DynVar})->
  io_lib:format("~.4f", [13.35 + random:uniform()/10]).
