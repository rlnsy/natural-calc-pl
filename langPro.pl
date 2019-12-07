% equation("one", 1).
% equation("two", 2).
% equation("three",3).
% equation("four", 4).
% equation("five", 5).
% equation("six", 6).
% equation("seven", 7).
% equation("eight", 8).
% equation("nine", 9).
% equation("ten", 10).
% equation("eleven", 11).
% equation("twelve", 12).
% equation("thirteen", 13).
% equation("fourteen", 14).
% equation("fifteen", 15).
% equation("sixteen", 16).
% equation("seventeen", 17).
% equation("eighteen", 18).
% equation("ninteen",19).
% equation("twenty", 20). 

calculate(X, Y) :- langPro(X, Z), once(calc2(Z, Y)).
langPro(X, Y) :- split_string(X, " ", "", L), once(equation(L, _, Y)).

equation(A, D, Y) :-
    numb(A, B, Av),
    operator(B, C, Ov),
    equation(C, D, Bv),
    append(Av, Ov, Tv),
    append(Tv, Bv, Y).

equation(A, _, V) :- numb(A, [], V).

operator(["plus" | L], L, [+]).
operator(["minus" | L], L, [-]).
operator(["times" | L], L, [*]).
operator(["divided" | ["by" | L]], L, [/]).

numb(["one" | L], L, [1]).
numb(["two" | L], L, [2]).
numb(["three" | L], L, [3]).
numb(["four" | L], L, [4]).
numb(["five" | L], L, [5]).
numb(["six" | L], L, [6]).
numb(["seven" | L], L, [7]).
numb(["eight" | L], L, [8]).
numb(["nine" | L], L, [9]).
numb(["ten" | L], L, [10]).
numb(["twenty" | ["two" | L]], L, [22]).

calc2([H], H) :- number(H).
calc2([_ | [_ | []]], _) :- fail.
calc2([H | [+ | T ]], V) :-
    number(H), 
    calc2(T, VT),
    V is H + VT.
calc2([H | [- | T ]], V) :-
    number(H), 
    calc2(T, VT),
    V is H - VT.
calc2([H | [* | T ]], V) :-
    number(H), 
    calc2(T, VT),
    V is H * VT.
calc2([H | [/ | T ]], V) :-
    number(H), 
    calc2(T, VT),
    V is H / VT.

:- [markov].

% auto-correct version
% C represents the corrected sentence
ccalculate(X, C, Y) :- clangPro(X, C, Z), once(calc2(Z, Y)).
clangPro(X, C, Y) :- 
    split_string(X, " ", "", L),
    correct(L, C),
    once(equation(C, _, Y)).
