\ Hunt the Wumpus - FORTH 0.10

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
CREATE INITIAL 6 CHARS ALLOT

\ Player states
0 CONSTANT IN-PLAY
1 CONSTANT WON
2 CONSTANT LOST

\ New or same initial state
0 CONSTANT SAME
1 CONSTANT NEW

\ A pointer to a prompt string
CREATE PROMPT-STRING 2 CELLS ALLOT

\ An 8-character buffer for prompt answers
CREATE PROMPT-ANSWER 8 CHARS ALLOT

\ Responses to a yes-no question
CHAR y CONSTANT YES
CHAR n CONSTANT NO

\ Responses to a command prompt
CHAR w CONSTANT ?WHERE
CHAR m CONSTANT MOVE
CHAR s CONSTANT SHOOT

\ Scratch area for generating a random shuffle of the 20 room numbers
CREATE room-numbers COUNT-ROOMS CHARS ALLOT

ALIGN  \ Align to next slot boundary

\
\ Room number shuffling words
\

\ Fill room numbers with the sequence 1..20
: reset-room-numbers ( -- )
    COUNT-ROOMS 0 DO I CHARS room-numbers + I 1+ SWAP C! LOOP
  ;

\ Display the room numbers
: display-room-numbers ( -- )
    COUNT-ROOMS 0 DO I CHARS room-numbers + C@ . LOOP
  ;

\ Swap ith (i in 0..19) room with a room in i+1..20
: swap-random-in-tail ( i -- ) 
    DUP room-numbers + C@ SWAP      ( i -- ni i )
    DUP DUP COUNT-ROOMS 1 - SWAP -  ( ni i i -- ni i i s-1 )
    1+ random                       ( ni i i s-1 -- ni i i t )
    SWAP + TUCK                     ( ni i i t -- ni r i r )
    room-numbers + C@ SWAP          ( ni r i r -- ni r nr i )
    room-numbers + C!               ( ni r nr i -- ni r )
    room-numbers + C!               ( ni r -- )
  ;

\ Select n <= 20 rooms at random
: select-random-rooms ( n -- random-rooms ) 
    DUP COUNT-ROOMS > IF
      CR . ABORT" Can't select more than 20 rooms "
    THEN
      reset-room-numbers
      0 DO
        I swap-random-in-tail
        CR display-room-numbers
      LOOP
  ;

\
\ Cave words
\   room-number in 1..20
\ WARNING: These cave referencing words
\ don't validate room numbers!!!
\

\ Get a pointer to a room
: cave-room-address ( room-number -- room-address)
    1- COUNT-NEIGHBORS * CAVE +
  ;

\ Get a list of a room’s neighbors
: cave-room-neighbors ( room-number -- n_1 n_2 n_3 )
    DUP cave-room-address     C@ SWAP
    DUP cave-room-address 1+  C@ SWAP
        cave-room-address 2 + C@
  ;

\ Determine if a room is a neighbor
: ?cave-room-reachable ( to from -- TRUE|FALSE )
    cave-room-neighbors FALSE
    4 PICK 4 PICK = OR
    4 PICK 3 PICK = OR
    4 PICK 2 PICK = OR
    SWAP DROP SWAP DROP SWAP DROP SWAP DROP
  ;

\
\ Player dialogue words
\

\ Ask a yes-no question, don't accept anything else
: prompt-yes-no ( question -- answer )
    PROMPT-STRING 2!
    BEGIN
      CR PROMPT-STRING 2@ type ." (y|n)? "
      CR ." > "
      PROMPT-ANSWER 1 ACCEPT DROP
      \ ASCII alpha lowercase; others don't care
      PROMPT-ANSWER C@ 32 OR PROMPT-ANSWER !
      PROMPT-ANSWER C@
      DUP YES = OVER NO = OR ( answer -- answer valid )
      DUP INVERT IF
        CR ." Huh? "
        SWAP DROP \ Lose invalid answer
      THEN
    UNTIL \ Exit if valid
  ;

\ Prompt for a command, (w)here am I, (m)ove, or (s)hoot
: prompt-command ( -- W | M | S )
  ;

\ Display congratulations or condolences
: show-result ( WON | LOST -- )
    DUP WON = IF
      CR ." Congratulations! You got the Wumpus! But next time, hee, hee, hee!"
      DROP
    ELSE
      DUP LOST = IF
        CR ." Condolences, the Wumpus got you.  Maybe next time."
        DROP
      ELSE
        CR . s" unknown game result " exception throw
      THEN
    THEN
  ;

\ List the neighboring rooms
: list-neighbors ( room-number -- )
    cave-room-neighbors
    CR . .” , “
    CR . .” , “
    CR . .” .“
  ;

\ List any hazards in a room
: hazards-in-room ( room-number -- )
    DUP WUMPUS C@ = IF
     CR .“ I smell a Wumpus!”
    THEN
    DUP PITS C@ = OVER PITS 1 CHARS + C@ = OR IF
     CR .“ I feel a draft!”
    THEN
    DUP BATS C@ = OVER BATS 1 CHARS + C@ = OR IF
     CR .“ I hear a rustling sound!”
    THEN
  ;

\ Warn of any hazards in the neighboring rooms
: warn-of-hazards ( room-number -- )
    cave-room-neighbors
    hazards-in-room
    hazards-in-room
    hazards-in-room
  ;

\ Describe player’s location
: describe-location ( room-number -- )
    CR .” You are in room “ DUP .
    CR .” Tunnels lead to rooms “ DUP list-neighbors
    warn-of-hazards
  ;

\ Display instructions
: show-instructions ( -- )
    CR ." ---- INSTRUCTIONS ---- " CR
  ;

\ Display a greeting
: show-greeting ( -- )
    CR ."  ----  ----  Hunt the Wumpus  ----  ----  " CR
  ;

\
\ Game play words
\

\ SCAFFOLDING - get random play result
: play-random ( -- WON | IN-PLAY | LOST )
        3 random
        CASE
          0 OF LOST     PLAYER C! ENDOF
          1 OF IN-PLAY  PLAYER C! ENDOF
          2 OF WON      PLAYER C! ENDOF
          DUP CR . s" unexpected random value " exception throw
        ENDCASE
    PLAYER C@
  ;

\ Describe the hunter’s location
: hunter-location ( -- )
    HUNTER C@ describe-location
  ;

\ Move the hunter to a new room
: move-hunter ( -- )
    play-random DROP
  ;

\ Shoot an arrow
: shoot-arrow ( -- )
    play-random DROP
  ;

\ Play the game until won or lost
: play ( -- WON | LOST )
    BEGIN
      PLAYER C@ IN-PLAY = WHILE
        prompt-command
        CASE
          ?WHERE OF hunter-location ENDOF
          MOVE   OF move-hunter     ENDOF
          SHOOT  OF shoot-arrow     ENDOF
          CR . s" unexpected command " exception throw
        ENDCASE
    REPEAT
    PLAYER C@
  ;

\ Create and save a new room configuration
: create-new-room-assignments ( -- )
    6 select-random-rooms
    room-numbers           @ INITIAL           !
    room-numbers 2 CHARS + @ INITIAL 2 CHARS + !
    room-numbers 4 CHARS + @ INITIAL 4 CHARS + !
  ;

\ Set the room configuration to the saved one
: set-rooms-to-initial-assignments ( -- )
    INITIAL           C@ HUNTER C!
    INITIAL 1 CHARS + C@ WUMPUS C!
    INITIAL 2 CHARS + C@ PITS C!
    INITIAL 3 CHARS + C@ PITS 1 CHARS + C!
    INITIAL 4 CHARS + C@ BATS C!
    INITIAL 5 CHARS + C@ BATS 1 CHARS + C!
  ;

\ Reset the state for a new game
: init ( SAME | NEW -- )
    NEW = IF
      create-new-room-assignments
    THEN
    set-rooms-to-initial-assignments
    5 ARROWS C!
    IN-PLAY PLAYER C!
  ;

\ Greet the player, play, then prompt for a new game
: Hunt-the-Wumpus ( -- )
    show-greeting 
    s" Show instructions " prompt-yes-no
    YES = IF
      show-instructions
    THEN
    NEW init
    BEGIN
      play
      show-result
      s" Play again " prompt-yes-no
      YES = IF
        CR ." OK, play again ... "
        s" Same rooms " prompt-yes-no
        YES = IF
          CR ." OK, you, the Wumpus, pits, and bats in the same rooms "
          SAME init
        ELSE
          CR ." OK, you, the Wumpus, pits, and bats in new rooms (probably) "
          NEW init
        THEN
        FALSE
      ELSE
        CR ." Bye "       
        TRUE
      THEN
    UNTIL
  ;

