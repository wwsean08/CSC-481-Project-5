%Sean Smith

:- consult('quagent.pl').
:- use_module(library(porter_stem)).

targetX:- 0.
targetY:- 0.

%run is where we start running the program
run:- 
	q_connect(Q),
	q_cameraon(Q),
	findTofu(Q, X, Y).
	%gotoTofu(Q, X, Y),
	%gotoTarget(Q, targetX, targetY),
	%q_close(Q).

%Find tofu uses the radius command to locate the tofu within the room.
%Step 1: Find the tofu using the radius command and parsing the event for the x and y values.
%Step 2: Bind the x and y values
findTofu(Q, X, Y) :- 
	q_radius(Q, 1000),
	q_events(Q, RadiusEvents),
	parseRadiusEvent(RadiusEvents).

%traverses the world in order to get to the location of the tofu and pick it up.
%Step 1: Get our location in the world
%Step 2: Determine where we have to go along the X and Y axis to get to the tofu
%Step 3: Pickup Tofu
gotoTofu(Q, X, Y) :- 

	
	q_pickup(Q, 'tofu'). %pickup the tofu and we're done

$traverses the world and goes to the target location to drop the tofu
Step 1: Get our location in the world
Step 2: Determine where we have to go along the x and y axis to get to the target
Step 3: Drop the tofu
gotoTarget(Q, X, Y) :- 
	
	
	q_drop(Q, 'tofu'). %drop the tofu and we are done.

%parse the radius event in order to find the tofu
parseRadiusEvent([]) :- nl.

parseRadiusEvent([H|T]) :-
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
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Testing Rules%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
printEvents([]):- nl.
printEvents([H|T]):- write(H), write(' '), printEvents(T).