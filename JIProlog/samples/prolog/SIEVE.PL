/*
   Sieve of Erasthatones - Copyright (c) Brian D Steel - 11 Dec 98 / 10 Feb 99
   ===========================================================================

   In this classic algorithm, a list of prime numbers is generated by sifting
   a list of all integers between 2 and the given limit, and discarding those
   which are directly divisible by a known prime number.

   The initial list of integers is created using a simple recursive program,
   and all entries directly divisible by the first number in the list
   (initially 2) are then removed; the head of the resulting list (2)
   is kept, and the tail (in this case, starting with 3) is processed
   recursively until all numbers have been stripped.

   For example, to generate all prime numbers up to the value 20, type:

   ?- primes(20,P).
   P = [2,3,5,7,11,13,17,19]

   A shorter variant of this algorithm can be found in the file SIEVE2.PL.
*/

% generate a list of integers [2..Limit], and sieve it to extract the primes

primes( Limit, Primes ) :-
   make( 2, Limit, List ),
   sieve( List, Primes ).

% when the limit is reached, return it in the list

make( Limit, Limit, [Limit] ) :-
   !.

% otherwise make a list with this value, and recursively create the tail

make( Head, Limit, [Head|Tail] ) :-
   Next is Head + 1,
   make( Next, Limit, Tail ).

% sieve an empty list to give an empty list

sieve( [], [] ).

% we know the head is prime: use it to sift the tail, and sieve the result

sieve( [Prime|Tail], [Prime|Rest] ) :-
   sift( Prime, Tail, Sift ),
   sieve( Sift, Rest ).

% sift an empty list to give an empty list

sift( Prime, [], [] ) :-
   !.

% discard the head if it is divisible by the prime, and sift the rest

sift( Prime, [Head|Tail], Sift ) :-
   0 is Head mod Prime,
   !,
   sift( Prime, Tail, Sift ).

% otherwise keep the head, and sift the rest

sift( Prime, [Head|Tail], [Head|Sift] ) :-
   sift( Prime, Tail, Sift ).
