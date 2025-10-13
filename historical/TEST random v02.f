\ Test random for use in selecting one of 20 rooms in the Wumpus cave
\ Also need to select 6 rooms from the 20 without repetition.

include random.fs
  utime         \ get system epoch time as unsigned double integer
  drop seed !   \ set random seed to the low order part of the time

create room-counts 20 cells allot

: clear-random-counts ( -- ) \ sets the 20 room counts to zero
    20 0 do 0 i cells room-counts + ! loop
  ;

: display-random-counts ( -- ) \ show the 20 room counts
    20 0 do I cells room-counts + @ . loop
  ;

: inc-room-count ( room-number -- ) \ count for room number incremented by 1
    1- cells room-counts + dup @ 1+ swap !
  ;

: try-random ( count-tries -- ) \ updates counts in room-counts
    0 do 20 random 1+ inc-room-count loop
  ;

: try-seeded-random ( count-tries -- ) \ updates counts in room-counts
    utime         \ get system epoch time as unsigned double integer
    drop seed !   \ set random seed to the low order part of the time
    0 DO
      20 random .
    LOOP
  ;

create room-numbers 20 chars allot

align

: reset-room-numbers ( -- ) \ fill room numbers with the sequence 1..20
    20 0 do I chars room-numbers + I 1+ swap c! loop
  ;

: display-room-numbers ( -- ) \ display the room numbers
    20 0 do I chars room-numbers + C@ . loop
  ;

: swap-random-in-tail ( i -- ) \ Swap ith (i in 0..19) room with a room in i+1..20
    dup room-numbers + C@ swap  ( i -- ni i )           \ get the room number n1 at index i in the room numbers array
    dup dup 19 swap -           ( ni i i -- ni i i s-1 )  \ get the size of the tail minus 1: 19-i
    1+ random                   ( ni i i s-1 -- ni i i t )  \ get random number, t in 0..19-i+1, index of a room number in the tail
    swap + tuck                 ( in i i t -- in r i r )    \ convert the index in the tail to one in the room numbers array  
    room-numbers + C@ swap    ( in r i r -- in r rn i ) \ get the room number from the tail
    room-numbers + C!         ( in r rn i -- in r )     \ save the room number as ith room
    room-numbers + C!         ( in r -- )            \ save room number i+1 at the randomly chosen index
  ;

: select-random-rooms ( n -- random-rooms ) \ select n <= 20 rooms at random
    dup 20 > IF
      CR . ABORT" Can't select more than 20 rooms "
    THEN
      reset-room-numbers
      0 DO
        I swap-random-in-tail
        CR display-room-numbers
      LOOP
  ;
 
: shuffle-room-numbers ( -- ) \ randomly shuffle the room numbers 1..20
    19 select-random-rooms
  ;

: try-shuffle 19 0 do i swap-random-in-tail CR display-room-numbers loop ;  ok
try-shuffle
reset-room-numbers  ok
0 swap-random-in-tail  ok
display-room-numbers 20 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 1  ok
.s <0>  ok
1 swap-random-in-tail  ok
display-room-numbers 20 18 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 2 19 1  ok
.s <0>  ok
2 swap-random-in-tail  ok
display-room-numbers 20 18 16 4 5 6 7 8 9 10 11 12 13 14 15 3 17 2 19 1  ok
.s <0>  ok
3 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 5 6 7 4 9 10 11 12 13 14 15 3 17 2 19 1  ok
.s <0>  ok
4 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 6 7 5 9 10 11 12 13 14 15 3 17 2 19 1  ok
.s <0>  ok
5 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 7 5 9 10 11 12 13 14 15 3 17 2 19 6  ok
.s <0>  ok
6 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 5 9 10 11 12 7 14 15 3 17 2 19 6  ok
.s <0>  ok
7 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 5 10 11 12 7 14 15 3 17 2 19 6  ok
.s <0>  ok
8 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 10 11 12 7 14 15 3 17 2 5 6  ok
.s <0>  ok
9 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 11 12 7 10 15 3 17 2 5 6  ok
.s <0>  ok
10 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 12 7 10 15 3 17 2 11 6  ok
.s <0>  ok
11 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 10 15 3 17 2 11 6  ok
.s <0>  ok
12 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 10 15 3 17 2 11 6  ok
.s <0>  ok
13 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 2 15 3 17 10 11 6  ok
.s <0>  ok
14 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 2 3 15 17 10 11 6  ok
.s <0>  ok
16 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 2 3 15 11 10 17 6  ok
.s <0>  ok
17 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 2 3 15 11 6 17 10  ok
.s <0>  ok
18 swap-random-in-tail  ok
display-room-numbers 20 18 16 8 4 1 13 9 19 14 5 7 12 2 3 15 11 6 17 10  ok
.s <0>  ok
\  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
\  ^                                      ^ 
\ 14  2  3  4  5  6  7  8  9 10 11 12 13  1 15 16 17 18 19 20
\     ^                                ^
\ 14 13  3  4  5  6  7  8  9 10 11 12  2  1 15 16 17 18 19 20
\        ^                                      ^
\ 14 13 16  4  5  6  7  8  9 10 11 12  2  1 15  3 17 18 19 20
\           ^                    ^
\ 14 13 16 11  5  6  7  8  9 10  4 12  2  1 15  3 17 18 19 20
\              ^                                ^
\ 14 13 16 11  3  6  7  8  9 10  4 12  2  1 15  5 17 18 19 20
\                 ^                    ^
\ 14 13 16 11  3  2  7  8  9 10  4 12  6  1 15  5 17 18 19 20
\                    ^                          ^
\ 14 13 16 11  3  2  5  8  9 10  4 12  6  1 15  7 17 18 19 20
\                       ^                                ^
\ 14 13 16 11  3  2  5 19  9 10  4 12  6  1 15  7 17 18  8 20
\                          ^                                ^
\ 14 13 16 11  3  2  5 19 20 10  4 12  6  1 15  7 17 18  8  9
\                             ^              ^
\ 14 13 16 11  3  2  5 19 20 15  4 12  6  1 10  7 17 18  8  9
\                                ^                       ^
\ 14 13 16 11  3  2  5 19 20 15  8 12  6  1 10  7 17 18  4  9
\                                   ^  ^
\ 14 13 16 11  3  2  5 19 20 15  8  6  6  1 10  7 17 18  4  9  <=
\                                   ^  !
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  1 10  7 17  6  4  9  <=
\                                      ^              !
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6 10  7 17  1  4  9  <=
\                                         !           ^
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4  7 17  1 10  9
\                                            ^           ^
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4 12 17  1 10  9  <=
\                                               !
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4 12 10  1 17  9
\                                                  ^     ^
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4 12 10  9 17  1
\                                                     ^     ^                                                      
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4 12 10  9  7  1  <=
\                                                        !
\ 14 13 16 11  3  2  5 19 20 15  8  6 18  6  4 12 10  9  7 17  <=
\                                                           !

: try-calc-t ( i -- ni i t ) dup room-numbers + C@ swap dup 19 swap - ;
: try-all-calc-t ( -- [ ni i t ] ) 19 0 do i try-calc-t CR .s clearstack loop ;

\ try-all-calc-t ( -- ni i t ) for i in 0..19 -- t is the input to random
\ <3> 1 0 19  \ swap 1 with contents of room-numbers[0..19] ... swap with itself allowed!!
\ <3> 2 1 18
\ <3> 3 2 17
\ <3> 4 3 16
\ <3> 5 4 15
\ <3> 6 5 14
\ <3> 7 6 13
\ <3> 8 7 12
\ <3> 9 8 11
\ <3> 10 9 10
\ <3> 11 10 9
\ <3> 12 11 8
\ <3> 13 12 7
\ <3> 14 13 6
\ <3> 15 14 5
\ <3> 16 15 4
\ <3> 17 16 3
\ <3> 18 17 2
\ <3> 19 18 1  \ 
\ <3> 20 19 0  ok
 
: select-random-rooms ( n -- random-rooms ) \ select n <= 20 rooms at random
    dup 20 > IF
      CR . ABORT" Can't select more than 20 rooms "
    THEN
      reset-room-numbers
      1- 0 DO
        I swap-random-in-tail
        CR display-room-numbers
      LOOP
  ;

6 select-random-rooms
13 2 3 4 5 6 7 8 9 10 11 12 1 14 15 16 17 18 19 20
13 3 2 4 5 6 7 8 9 10 11 12 1 14 15 16 17 18 19 20
13 3 8 4 5 6 7 2 9 10 11 12 1 14 15 16 17 18 19 20
13 3 8 5 4 6 7 2 9 10 11 12 1 14 15 16 17 18 19 20
13 3 8 5 12 6 7 2 9 10 11 4 1 14 15 16 17 18 19 20  ok

: select-random-rooms ( n -- random-rooms ) \ select n <= 20 rooms at random
    dup 20 > IF
      CR . ABORT" Can't select more than 20 rooms "
    THEN
      reset-room-numbers
      0 DO
        I swap-random-in-tail
        CR display-room-numbers
      LOOP
  ;
 
6 select-random-rooms
12 2 3 4 5 6 7 8 9 10 11 1 13 14 15 16 17 18 19 20
12 9 3 4 5 6 7 8 2 10 11 1 13 14 15 16 17 18 19 20
12 9 5 4 3 6 7 8 2 10 11 1 13 14 15 16 17 18 19 20
12 9 5 16 3 6 7 8 2 10 11 1 13 14 15 4 17 18 19 20
12 9 5 16 17 6 7 8 2 10 11 1 13 14 15 4 3 18 19 20
12 9 5 16 17 15 7 8 2 10 11 1 13 14 6 4 3 18 19 20  ok
6 select-random-rooms
11 2 3 4 5 6 7 8 9 10 1 12 13 14 15 16 17 18 19 20
11 2 3 4 5 6 7 8 9 10 1 12 13 14 15 16 17 18 19 20
11 2 10 4 5 6 7 8 9 3 1 12 13 14 15 16 17 18 19 20
11 2 10 8 5 6 7 4 9 3 1 12 13 14 15 16 17 18 19 20
11 2 10 8 13 6 7 4 9 3 1 12 5 14 15 16 17 18 19 20
11 2 10 8 13 12 7 4 9 3 1 6 5 14 15 16 17 18 19 20  ok
6 select-random-rooms
4 2 3 1 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
4 16 3 1 5 6 7 8 9 10 11 12 13 14 15 2 17 18 19 20
4 16 6 1 5 3 7 8 9 10 11 12 13 14 15 2 17 18 19 20
4 16 6 2 5 3 7 8 9 10 11 12 13 14 15 1 17 18 19 20
4 16 6 2 15 3 7 8 9 10 11 12 13 14 5 1 17 18 19 20
4 16 6 2 15 19 7 8 9 10 11 12 13 14 5 1 17 18 3 20  ok