%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% quagent.pro - A simple interface library to the quagent QII mod.
% Version 3.0
% written by Lutz Hamel, 2006.
%
% NOTE: this library has only been tested under SWI-Prolog 5.6.2
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 1, or (at your option) any
% later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
%
% In other words, you are welcome to use, share and improve this program.
% You are forbidden to forbid anyone else to use, share and improve
% what you give them.   Help stamp out software-hoarding!  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(socket)).

%%%%%
% High level quagent interface
%
% Action:
%   q_walk(+Quagent,+Distance)
%   q_turn(+Quagent,+Angle)
%   q_pickup(+Quagent,+Item)
%   q_drop(+Quagent,+Item)
%
% Perception:
%   q_radius(+Quagent,+Radius)
%   q_rays(+Quagent,+No_of_Rays)
%   q_cameraon(+Quagent)
%   q_cameraoff(+Quagent)
%
% Proprioception:
%   q_where(+Quagent)
%   q_inventory(+Quagent)
%   q_wellbeing(+Quagent)
%
% Events:
%   q_events(+Quagent,-[Events])
%
% NOTE: the q_events predicate throws the 'q_died' exception when the
%	bot dies of old age or low energy.

%%%%
% action

q_walk(Quagent,Distance) :- 
	string_to_atom(Dist_str,Distance),
	string_concat('do walkby ',Dist_str,Walk_cmd),
	q_write(Quagent,Walk_cmd).

q_turn(Quagent,Angle) :-
	string_to_atom(Angle_str,Angle),
	string_concat('do turnby ',Angle_str,Turn_cmd),
	q_write(Quagent,Turn_cmd).

q_pickup(Quagent,Item) :-
	string_to_atom(Item_str,Item),
	string_concat('do pickup ',Item_str,Item_cmd),
	q_write(Quagent,Item_cmd).

q_drop(Quagent,Item) :-
	string_to_atom(Item_str,Item),
	string_concat('do drop ',Item_str,Item_cmd),
	q_write(Quagent,Item_cmd).

%%%%
% perception

q_radius(Quagent,Radius) :-
	string_to_atom(Radius_str,Radius),
	string_concat('ask radius ',Radius_str,Radius_cmd),
	q_write(Quagent,Radius_cmd).

q_rays(Quagent,No_of_Rays) :-
	string_to_atom(Rays_str,No_of_Rays),
	string_concat('ask rays ',Rays_str,Rays_cmd),
	q_write(Quagent,Rays_cmd).

q_cameraon(Quagent) :-
	q_write(Quagent,'do cameraon').

q_cameraoff(Quagent) :-
	q_write(Quagent,'do cameraoff').

%%%%
% propioception

q_where(Quagent) :-
	q_write(Quagent,'do getwhere').

q_inventory(Quagent) :-
	q_write(Quagent,'do getinventory').

q_wellbeing(Quagent) :-
	q_write(Quagent,'do getwellbeing').

%%%%
% events

q_events(Quagent,Events) :-
	q_read(Quagent,Events).

%%%%%
% Low level quagent interface
%   q_connect(+Host,-QuagentDesc)
%   q_connect(-QuagentDesc)  - connect to localhost
%   q_close(+QuagentDesc)
%   q_write(+QuagentDesc,+String)
%   q_read(+QuagentDesc,-[Events])
%   q_read_raw(+QuagentDesc,-[Events])  % does not test for dying bot

q_connect(Host,QuagentDesc) :-
	tcp_socket(Socket),
	tcp_connect(Socket, Host:33333),
	tcp_open_socket(Socket, ReadFd, WriteFd),
	set_stream(ReadFd, timeout(1)),
	QuagentDesc = [ReadFd,WriteFd].

q_connect(QuagentDesc) :-
	tcp_socket(Socket),
	tcp_connect(Socket, 'localhost':33333),
	tcp_open_socket(Socket, ReadFd, WriteFd),
	set_stream(ReadFd, timeout(1)),
	QuagentDesc = [ReadFd,WriteFd].

q_close(QuagentDesc) :-
	QuagentDesc = [ReadFd,WriteFd],
	close(ReadFd),
	close(WriteFd).

q_write(QuagentDesc,String) :-
	QuagentDesc = [_,WriteFd],
	write(WriteFd,String),
	nl(WriteFd),
%	put_code(WriteFd,13),
%	put_code(WriteFd,10),
	flush_output(WriteFd).

q_read(QuagentDesc,Events) :-
	q_read_lines(QuagentDesc,[],Events),
	q_parse_events(Events).

q_read_raw(QuagentDesc,Events) :-
	q_read_lines(QuagentDesc,[],Events).

% helper function for q_read and q_read_raw
q_read_lines(S,LinesIn,LinesOut) :- 
	S = [In,_],
	catch(at_end_of_stream(In),_,LinesIn=LinesOut),
	!.

q_read_lines(S,LinesIn,LinesOut) :-
	S = [In,_],
	read_line_to_codes(In, Codes),
	string_to_list(Line, Codes),
%	writeln(Line),
	append(LinesIn,[Line],Temp),
	q_read_lines(S,Temp,LinesOut).

% parse the individual event statements and throw an
% an exception if our bot is dying.
% NOTE: the exception we throw is 'q_died'

:- use_module(library(porter_stem)). % need this for 'tokenize_atom'

q_handle_dying_event(['TELL'|['DYING'|_]]) :- throw(q_died).
q_handle_dying_event(_).

q_parse_events([]).
q_parse_events([H|T]) :- 
	tokenize_atom(H,TokenList), 
	q_handle_dying_event(TokenList),
	q_parse_events(T).






