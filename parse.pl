%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - Parsing  %
%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%
% Main entry
%%%%%%%%%%%%%%%%%

% parse/1 succeeds if and only if the token list follows the grammar:
%   Lines -> Line ; Lines | Line
%   Line  -> Num , Line | Num
%   Num   -> Digit | Digit Num
%   Digit -> '0' | ... | '9'
parse(Tokens) :-
    lines(Tokens, []).

%%%%%%%%%%%%%%%%%
% Recursive descent parser
%%%%%%%%%%%%%%%%%

% Lines -> Line ; Lines | Line
lines(Tokens, Rest) :-
    line(Tokens, Rest1),
    (
        % Case 1: only a single Line
        Rest1 = [] ->
            Rest = []
    ;
        % Case 2: Line ; Lines
        Rest1 = [';' | MoreTokens],
        lines(MoreTokens, Rest)
    ).

% Line -> Num , Line | Num
line(Tokens, Rest) :-
    num(Tokens, Rest1),
    (
        % Case 1: Num , Line
        Rest1 = [',' | MoreTokens] ->
            line(MoreTokens, Rest)
    ;
        % Case 2: a single Num
        Rest = Rest1
    ).

% Num -> Digit | Digit Num
num([D | Tokens], Rest) :-
    digit(D),
    num_rest(Tokens, Rest).

% Continue consuming digits as long as the next token is a digit
num_rest([D | Tokens], Rest) :-
    digit(D), !,
    num_rest(Tokens, Rest).
num_rest(Rest, Rest).

% Digit -> '0' ... '9'
digit(Token) :-
    member(Token, ['0','1','2','3','4','5','6','7','8','9']).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example:
%
% ?- parse(['3','2',',','0',';','1',',','5','6','7',';','2']).
% true.
%
% ?- parse(['3','2',',','0',';','1',',','5','6','7',';','2',',']).
% false.
%
% ?- parse(['3','2',',',';','0']).
% false.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
