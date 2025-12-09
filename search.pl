%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - Search %
%%%%%%%%%%%%%%%%%%%%%%

% A state is represented as state(Room, Keys)
% - Room: the current room ID
% - Keys: list of key colors currently held

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main entry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    % Get initial room
    initial(StartRoom),
    % Acquire keys located in the starting room
    acquire_keys(StartRoom, [], StartKeys),
    % Start BFS with a queue containing one node
    bfs([node(StartRoom, StartKeys, [])], [], RevPath),
    % Reverse the accumulated reversed path
    reverse(RevPath, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If the current node is in a treasure room, return the path
bfs([node(Room, _Keys, Path) | _], _Visited, Path) :-
    treasure(Room), !.

% Skip if this (Room, Keys) state has already been visited
bfs([node(Room, Keys, Path) | RestQueue], Visited, Actions) :-
    member(state(Room, Keys), Visited), !,
    bfs(RestQueue, Visited, Actions).

% Normal BFS expansion
bfs([node(Room, Keys, Path) | RestQueue], Visited, Actions) :-
    \+ member(state(Room, Keys), Visited),
    % Generate all valid successor nodes
    findall(
        node(NextRoom, NextKeys, [move(Room, NextRoom) | Path]),
        move_possible(Room, Keys, NextRoom, NextKeys),
        Children
    ),
    append(RestQueue, Children, NewQueue),
    bfs(NewQueue, [state(Room, Keys) | Visited], Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Valid moves: doors + locked doors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Move through an unlocked (normal) door (undirected)
move_possible(Room, Keys, NextRoom, NextKeys) :-
    ( door(Room, NextRoom)
    ; door(NextRoom, Room)
    ),
    acquire_keys(NextRoom, Keys, NextKeys).

% Move through a locked door (undirected) only if the key is held
move_possible(Room, Keys, NextRoom, NextKeys) :-
    ( locked_door(Room, NextRoom, Color)
    ; locked_door(NextRoom, Room, Color)
    ),
    member(Color, Keys),
    acquire_keys(NextRoom, Keys, NextKeys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Acquire keys located in a room
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% acquire_keys(Room, KeysIn, KeysOut)
% Collect all keys in a given room and add them to the current key set
acquire_keys(Room, KeysIn, KeysOut) :-
    findall(Color, key(Room, Color), ColorsHere),
    add_keys(ColorsHere, KeysIn, KeysTemp),
    sort(KeysTemp, KeysOut).

% Add a list of key colors into the current key set (without duplication)
add_keys([], Keys, Keys).
add_keys([C | Cs], KeysIn, KeysOut) :-
    ( member(C, KeysIn) ->
        KeysMid = KeysIn
    ;   KeysMid = [C | KeysIn]
    ),
    add_keys(Cs, KeysMid, KeysOut).
