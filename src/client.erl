-module(client).

-export([start/0]).

start() ->
    play().

read_input() ->
    {ok, [Input]} = io:fread("Your move: ", "~a"),
    Input.

play() ->
    Input = read_input(),
    {server, 'server@Mariss-MacBook-Pro'} ! {play, self(), node(), Input},
    receive
	{win, P} ->
	    io:format("Winner: ~p~n",[P]),
	    play()
    end.
