\ Hunt the Wumpus - FORTH

include random.fs \ defines random ( n -- 0..n-1 )
UTIME DROP SEED ! \ Initialize random seed to low order word of system epoch time

\
\ The cave: 20 rooms, each connected to 3 others, as a dodecahedron
\
20 CONSTANT COUNT-ROOMS
 3 CONSTANT COUNT-NEIGHBORS
CREATE CAVE 
   5 C,  8 C,  2 C, \ ROOM 1
   1 C, 10 C,  3 C, \ ROOM 2
   2 C, 12 C,  4 C, \ ROOM 3
   3 C, 14 C,  5 C, \ ROOM 4
   4 C,  6 C,  1 C, \ ROOM 5
  15 C,  5 C,  7 C, \ ROOM 6
   6 C, 17 C,  8 C, \ ROOM 7
   7 C,  1 C,  9 C, \ ROOM 8
   8 C, 18 C, 10 C, \ ROOM 9
   9 C,  2 C, 11 C, \ ROOM 10
  10 C, 19 C, 12 C, \ ROOM 11
  11 C,  3 C, 13 C, \ ROOM 12
  12 C, 20 C, 14 C, \ ROOM 13
  13 C,  4 C, 15 C, \ ROOM 14
  14 C, 16 C,  6 C, \ ROOM 15
  20 C, 15 C, 17 C, \ ROOM 16
  16 C,  7 C, 18 C, \ ROOM 17
  17 C,  9 C, 19 C, \ ROOM 18
  18 C, 11 C, 20 C, \ ROOM 19
  19 C, 13 C, 16 C, \ ROOM 20

\ Game state
CREATE HUNTER 1 CHARS ALLOT \ Player location
CREATE WUMPUS 1 CHARS ALLOT \ Wumpus location
CREATE PITS   2 CHARS ALLOT \ Rooms with pits
CREATE BATS   2 CHARS ALLOT \ Rooms with bats

CREATE ARROWS 1 CHARS ALLOT \ Number of arrows left
CREATE PLAYER 1 CHARS ALLOT \ Player's state: IN-PLAY, WON, LOST

\ Initial room assignments in order: hunter, wumpus, pits, bats
CREATE INITIAL 6 CHARS ALLOT \ Initial state assignments

\ Player states
 0 CONSTANT IN-PLAY
 1 CONSTANT WON
-1 CONSTANT LOST

\ New or same initial state
0 CONSTANT SAME
1 CONSTANT NEW

\ An 8-character buffer for prompt answers
CREATE PROMPT-ANSWER 8 CHARS ALLOT
CHAR y CONSTANT YES
CHAR n CONSTANT NO

\ Scratch area for generating a random shuffle of the 20 room numbers
CREATE room-numbers 20 CHARS ALLOT

ALIGN  \ Align to next slot boundary

\ Room number shuffling words

: reset-room-numbers ( -- ) \ fill room numbers with the sequence 1..20
    20 0 DO I CHARS room-numbers + I 1+ SWAP C! LOOP
  ;

: display-room-numbers ( -- ) \ display the room numbers
    20 0 DO I CHARS room-numbers + C@ . LOOP
  ;

: swap-random-in-tail ( i -- ) \ Swap ith (i in 0..19) room with a room in i+1..20
    dup room-numbers + C@ swap  ( i -- ni i )
    dup dup 19 swap -           ( ni i i -- ni i i s-1 )
    1+ random                   ( ni i i s-1 -- ni i i t )
    swap + tuck                 ( in i i t -- in r i r )
    room-numbers + C@ swap      ( in r i r -- in r rn i )
    room-numbers + C!           ( in r rn i -- in r )
    room-numbers + C!           ( in r -- )
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
 
\ WARNING: These cave referencing words don't validate room numbers!!!

: cave-room-address ( room-number - room-address)
    1- COUNT-NEIGHBORS * CAVE +
  ;
: cave-room-neighbors ( room-number - n_1 n_2 n_3 )
    DUP cave-room-address     C@ SWAP
    DUP cave-room-address 1+  C@ SWAP
        cave-room-address 2 + C@
  ;
: ?cave-room-reachable ( to from - TRUE|FALSE )
    cave-room-neighbors FALSE
    4 PICK 4 PICK = OR
    4 PICK 3 PICK = OR
    4 PICK 2 PICK = OR
    SWAP DROP SWAP DROP SWAP DROP SWAP DROP
  ;
  
\ Ask a yes-no question, don't accept anything else
: prompt-yes-no ( question - answer )
  ;

\ Prompt for a command, (w)here am I, (m)ove, or (s)hoot
: prompt-command ( - W | M | S )
  ;

\ Display congratulations or condolences
: show-result ( WON | LOST - )
  ;

\ Play the game until won or lost
: play ( - WON | LOST )
    BEGIN
      prompt-command
      execute-command
    IN-PLAY = NOT UNTIL
  ;

\ Initialize game configuration in state
: create-new-room-assignments ( -- )
    6 select-random-rooms
    room-numbers @ INITIAL !
    room-numbers 2 CHARS + @ INITIAL 2 CHARS + !
    room-numbers 4 CHARS + @ INITIAL 4 CHARS + !
  ;

: set-rooms-to-initial-assignments ( -- )
    INITIAL C@ HUNTER C!
    INITIAL 1 CHARS + C@ WUMPUS C!
    INITIAL 2 CHARS + C@ PITS C!
    INITIAL 3 CHARS + C@ PITS 1 CHARS + C!
    INITIAL 4 CHARS + C@ BATS C!
    INITIAL 5 CHARS + C@ BATS 1 CHARS + C!
  ;

: init ( SAME | NEW - )
    NEW = IF
      create-new-room-assignments
    THEN

    set-rooms-to-initial-assignments
    5 ARROWS C!
    IN-PLAY PLAYER C!
  ;

\ Ask if want to use the same starting configuration?
: prompt-play-same ( - SAME | NEW )
  ;

\ Ask if want to play again?
: prompt-play-again ( - YES | NO )
  ;

\ Display instructions
: show-instructions ( - )
    CR ." ---- INSTRUCTIONS ---- " CR
  ;

\ Display instructions if wanted
: prompt-show-instructions ( - )
    CR ." Show instructions (y|n)? "
    CR ." > "
    PROMPT-ANSWER 1 ACCEPT
    \ ASCII alpha lowercase; others don't care
    PROMPT-ANSWER C@ 32 OR PROMPT-ANSWER !
    PROMPT-ANSWER C@ YES = IF
      show-instructions
    ELSE
      PROMPT-ANSWER C@ NO <> IF
        CR ." Huh? " CR
      THEN
    THEN
  ;

: show-greeting ( - )
    CR ."  ----  ----  Hunt the Wumpus  ----  ----  " CR
  ;

: Hunt-the-Wumpus ( - )
    show-greeting 
    prompt-show-instructions
    NEW init
    BEGIN
      play
      show-result
      prompt-play-again
      YES = IF
        prompt-play-same init
        TRUE
      ELSE
        FALSE
    UNTIL
  ;
