% ---------------------------------------------------------
% Markov Language Model and Toolkit for Sentence Correction
% Rowan Lindsay, 2019
% ---------------------------------------------------------


% ----------------------------
% Probabistic Model
% ----------------------------

% Assumed predicates:
%
% seq(W,P) is true if P is the marginal probability P(W)
%
% seq(W0,W1,P) is true if P is the probability P(W1|W0)

% example (for testing)
% sentence = [im,a,tree]

seq(im,1).
seq(a,1).
seq(tree,1).

seq(im,im,0).
seq(im, a, 1).
seq(im, tree, 0).
seq(a,a,0).
seq(a,im,0).
seq(a,tree, 1).
seq(tree,tree,0).
seq(tree, im, 0).
seq(tree, a, 0).

% Order 1
% mseq(WS,P) is true if P is the probability P(WS) = P(WS_1 WS_2 ... WS_n)
% test assertions:
% m1seq([im,a,tree],0.04]).
% m1seq([im],0.5).
% m1seq([im,a], 0.4).

m1seq([W],P) :- seq(W,P).
m1seq(WSR,P) :-
    reverse(WSR, [W1 | [W0| R]]),
    reverse([W0| R], WR),
    m1seq(WR, P0),
    seq(W0,W1,P1),
    P is P0*P1.


% ----------------------------
% Correction Tools
% ----------------------------

% lang(W) is true if W is any recognized word in the language
% example:
lang(W) :- W = im.
lang(W) :- W = a.
lang(W) :- W = tree.
% TODO: change this in order to reflect our actual language

% error token to inject into malformed list
token(error, eRrOr).

% scan(WS,ES) is true if ES is the list WS but with and error
% token replacing any instance of an unrecognized word.
% test assertions:
% scan([im,a,tree],[im,a,tree]).
% token(error, E), scan([im,a,tee],[im,a,E]).

scan([],[]).
scan([W|RW], [W|RE]) :- 
    lang(W),
    scan(RW,RE).
scan([_|RW], [E|RE]) :-
    token(error, E),
    scan(RW,RE).


% replace(WS,WR) is true if sentence WR is a valid replacement
% for sentence WS. i.e. WR is matching except in positions containing
% and error token
% test assertions:
% replace([im,a,tree],[im,a,tree]).
% token(error, E), replace([im,a,E],[im,a,tree]).
% token(error, E), replace([im,a,E],[im,a,im]).

replace([],[]).
replace([E|RW], [_|RR]) :-
    token(error, E),
    replace(RW,RR).
replace([W|RW], [W|RR]) :-
    replace(RW, RR).

% Generation:
% sentences(N, S) is true if S is a list of all the possible sentences
% of length N using words in the language.
% test assertions:
% sentences(0, [[]]).
% sentences(1, [[im],[a],[tree]]).
% sentences(2, [[im,a],[im,tree],[a,im],[a,tree],[tree,im],[tree,a],[im,im],[a,a],[tree,tree]]).

% (helper) sentence(N,S) is true if S is a sentence of length N in the language
sentence(N,[]) :-
    N is 0.
sentence(N,[W|R]) :-
    N > 0,
    lang(W),
    M is N-1,
    sentence(M,R).

sentences(N, S) :-
    findall(AS, sentence(N, AS), S).

% (helper) sentencereplace(RS,N,S) is true if S is a sentence of length N that
% is a valid replacment for error string RS
sentencereplace(RS, N,[]) :-
    N is 0,
    replace(RS,[]).
sentencereplace(RS, N,[W|R]) :-
    N > 0,
    lang(W),
    M is N-1,
    sentence(M,R),
    replace(RS,[W|R]).
sentencesreplace(RS,N,S) :-
    findall(AS, sentencereplace(RS, N, AS), S).

% mpsortss(SS,(MS,MP)) is true if MS is the sentence in the list SS with maximum language
% probability MP
pmaxs([],([],0)).
pmaxs([S|RS],(S,MP)) :-
    pmaxs(RS,(_,RMP)),
    m1seq(S,MP),
    MP > RMP.
pmaxs([S|RS],(RMS,RMP)) :-
    pmaxs(RS,(RMS,RMP)),
    m1seq(S,MP),
    MP =< RMP.


% mpcorrect(S,CS) is true if CS is the maximum probability corrected version of
% sentence S with probability CSP
correct(S,(CS,CSP)) :-
    scan(S,ES),
    length(S,N),
    sentencesreplace(ES,N,SS),
    pmaxs(SS,(CS,CSP)).
