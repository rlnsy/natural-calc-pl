calc(N,N) :- number(N).
calc(N,A/B) :-
    calc(NA,A),
    calc(NB,B),
    N is NA/NB.
calc(N,A*B) :-
    calc(NA,A),
    calc(NB,B),
    N is NA*NB.
calc(N,A+B) :-
    calc(NA,A),
    calc(NB,B),
    N is NA+NB.
calc(N,A-B) :-
    calc(NA,A),
    calc(NB,B),
    N is NA-NB.