%Sean Smith

:- consult('quagent.pl').
:- use_module(library(porter_stem)).

targetX:- 0.
targetY:- 0.

%run is where we start running the AI
run:- 
	q_connect(Q),							%connect to the game and spawn a quagent
	q_cameraon(Q),							%turn on the camera so we look thru the quagents eyes
	findTofu(Q, X, Y).						%search for the tofu in the world, more information with the rule
	%gotoLocation(Q, X, Y),					%traverse the map to the tofu location and pick it up, more info with the rule
	q_pickup(Q, 'tofu'), 		%pickup the tofu and we're done
	%gotoLocation(Q, targetX, targetY),		%traverse the map to the target location and drop the tofu, more info with the rule
	q_drop(Q, 'tofu'),
	%q_close(Q).							%close the quagent, if we did all this, we are done and worked successfully

%Find tofu uses the radius command to locate the tofu within the room.
%Step 1: Find the tofu using the radius command and parsing the event for the x and y values.
%Step 2: Bind the x and y values
findTofu(Q, X, Y) :- 
	q_radius(Q, 1000),						%run the radius command to try and find the tofu
	q_events(Q, RadiusEvents),				%grab the event (hopefully)
	parseRadiusEvent(RadiusEvents, X, Y).	%parse the event

%traverses the world in order to get to the location (either the target or the tofu)
%Step 1: Get our location in the world -partially implemented (maybe?)
%Step 2: Determine where we have to go along the X and Y axis to get to the tofu
	%To do this go one axis, turn 90 or -90 and then go the other axis to locate the quagent at the tofu
%Step 3: Pickup Tofu - Done, that was easy
gotoLocation(Q, X, Y) :- 
	q_where(Q),					%execute the where event to find out our location
	q_events(Q,WhereEvent),		%not quite sure if this will work but will try it anyways to get the results of the where
	parseWhereEvent(WhereEvent),%parses the event returned by q_events
	%Determine which way we are looking here that way we know where we need to turn
	DistanceX is abs(X - targetX),	%incase we change the target
	q_turn(Q, Turn),
	q_walk(Q, DistanceX),
	%Determine which way we are looking here that way we know where we need to turn
	DistanceY is abs(Y - targetY),	%incase we change the target
	q_turn(Q, Turn),
	q_walk(Q, DistanceY),

%parse the radius event in order to find the tofu
parseRadiusEvent([], X, Y) :- nl.

parseRadiusEvent([H|T], X, Y) :-
	tokenize_atom(H,TokenList),
	handle_radius_event(TokenList),
	write(H), nl,
	parse_radius_events(T).

%parse the walk event in order to walk to the tofu or target location
parseWalkEvent([]) :- nl.

parseWalkEvent([H|T]) :-
	tokenize_atom(H,TokenList),
	handle_walk_event(TokenList),
	write(H), nl,
	parse_walk_events(T).
	
%parse the where event in order to get the quagents location
parseWhereEvent([], X, Y) :- nl.

parseWhereEvent([H|T], X, Y) :-
	tokenize_atom(H,TokenList),
	handle_walk_event(TokenList),
	write(H), nl,
	parse_walk_events(T).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing Rules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
printEvents([]):- nl.
printEvents([H|T]):- write(H), write(' '), printEvents(T).