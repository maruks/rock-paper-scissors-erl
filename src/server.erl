-module(server).

-export([start_game/0,start/0]).

start() ->
    spawn(?MODULE,start_game,[]).

start_game() ->
    register(server, self()),
    reset(),
    play_loop([]).

play_loop(Msgs) ->
    receive
	{play, Address, Player, Vote} ->
            io:format("Recieved Move: ~p ~p ~p~n",[Address, Player, Vote]),
	    play_loop([{Address, Player, Vote} | Msgs]);
	{stop} ->
	    io:format("STOP~n",[]),
	    send_results(Msgs),
	    reset(),
	    play_loop([])
end.

reset() ->
    timer:send_after(10000, self(), {stop}).

score_against(r, p) -> -1;
score_against(p, r) -> 1;
score_against(s, r) -> -1;
score_against(r, s) -> 1;
score_against(p, s) -> -1;
score_against(s, p) -> 1;
score_against(_, _) -> 0.

send_results([]) ->
    ok;
send_results(All) ->
    {Addresses, Names, Moves} = lists:unzip3(All),
    Scores = lists:map(fun (PlayerMove) -> lists:sum(lists:map(fun (OpponentMove) -> score_against(PlayerMove, OpponentMove) end, Moves)) end, Moves),
    Winner = case lists:reverse(lists:sort(lists:zip(Scores, Names))) of
		 [{S1, W1}, {S2, _} | _] when S1 > S2 -> W1;
		 _ -> none
	     end,
    io:format("Winner: ~p~n", [Winner]),
    lists:foreach(fun (Address) -> Address ! {win, Winner} end, Addresses).
