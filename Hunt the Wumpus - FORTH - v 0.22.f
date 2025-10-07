\ Hunt the Wumpus - FORTH - v 0.22

include random.fs \ defines random ( n -- 0..n-1 )
UTIME DROP SEED ! \ Initialize random seed to low order word of system epoch time

\
\ The cave: 20 rooms, each connected to 3 others, as a dodecahedron
\
20 CONSTANT COUNT-ROOMS
 3 CONSTANT COUNT-NEIGHBORS
CREATE CAVE \ adjacency list
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

CREATE BATS-MOVED-HUNTER 1 CELLS ALLOT \ TRUE if bats moved player

\ Arrow path
CREATE ARROW-PATH-LENGTH 1 CHARS ALLOT
CREATE ARROW-PATH-ROOMS  5 CHARS ALLOT

\ Initial room assignments in order: hunter, wumpus, pits, bats
CREATE INITIAL-ROOMS 6 CHARS ALLOT

\ Scratch area for generating a random shuffle of the 20 room numbers
CREATE room-numbers COUNT-ROOMS CHARS ALLOT

\ Player states
0 CONSTANT IN-PLAY
1 CONSTANT WON
2 CONSTANT LOST

\ Quit, or play again with new or same initial state
0 CONSTANT QUIT-GAME
1 CONSTANT SAME-ROOMS
2 CONSTANT NEW-ROOMS

\ A pointer to a prompt string
CREATE PROMPT-STRING 2 CELLS ALLOT

\ An 8-character buffer for prompt answers
CREATE PROMPT-ANSWER 8 CHARS ALLOT

\ Responses to a yes-no question
CHAR y CONSTANT YES
CHAR n CONSTANT NO

\ Responses to a command prompt
CHAR w CONSTANT ?WHERE
CHAR m CONSTANT MOVE-ME
CHAR s CONSTANT SHOOT

ALIGN  \ Align to next slot boundary

\
\ The Cave
\   room-number in 1..20
\ WARNING: These cave referencing words
\ don't validate room numbers!!!
\

\ Determine if a room number is in the cave
: ?cave-room-number-valid ( room-number -- TRUE | FALSE )
    DUP 0 < SWAP COUNT-ROOMS > OR INVERT
  ;

\ Get a pointer to a room
: cave-room-address ( room-number -- room-address )
    1- COUNT-NEIGHBORS * CAVE +
  ;

\ Get the room number of a neighbor
: cave-room-neighbor ( index room-number -- room-number )
    cave-room-address SWAP CHARS + C@
  ;

\ Get a list of a room's neighbors
: cave-room-neighbors ( room-number -- n_1 n_2 n_3 )
    DUP cave-room-address           C@ SWAP
    DUP cave-room-address 1 CHARS + C@ SWAP
        cave-room-address 2 CHARS + C@
  ;

\ Determine if a room is a neighbor
: ?cave-room-reachable ( to from -- TRUE | FALSE )
    cave-room-neighbors FALSE
    4 PICK 4 PICK = OR
    4 PICK 3 PICK = OR
    4 PICK 2 PICK = OR
    SWAP DROP SWAP DROP SWAP DROP SWAP DROP
  ;

\ Determine if a room is a neighbor
: ?cave-room-reachable? ( to from -- TRUE | FALSE )
    cave-room-address              \ to f@
    FALSE                          \ to f@ flag
    OVER           C@ 3 PICK = OR  \ to f@ flag
    OVER   CHAR+   C@ 3 PICK = OR  \ to f@ flag
    OVER 2 CHARS + C@ 3 PICK = OR  \ to f@ flag
    SWAP DROP \ Lose from-room cave entry address
    SWAP DROP \ Lose to-room number
 ;

\
\ Room number selection - for initial room assignments
\ This is a variant of the
\ Fisher-Yates shuffle (a.k.a. the Knuth shuffle),
\ starting from the beginning of the rooms list,
\ and selecting only as many rooms as needed.
\

\ Fill room numbers with the sequence 1..20
: reset-room-numbers ( -- )
    COUNT-ROOMS 0 DO I CHARS room-numbers + I 1+ SWAP C! LOOP
  ;

\ Display the room numbers
: show-room-numbers ( -- )
    COUNT-ROOMS 0 DO I CHARS room-numbers + C@ . LOOP
  ;

\ Choose a room in i..19 (yes, it could be i)
: choose-room-in-tail ( i -- r )
    DUP COUNT-ROOMS 1- SWAP -  \ max-index-within-tail
    1+ random +                \ r
  ;

\ Swap ith (i in 0..19) room with a room in i..19
: swap-random-in-tail ( i -- ) 
    DUP room-numbers + C@ SWAP   \ Ni i
    DUP choose-room-in-tail TUCK \ Ni r i r
    room-numbers CHARS + C@ SWAP \ Ni r Nr i
    room-numbers CHARS + C!      \ Ni r
    room-numbers CHARS + C!
  ;

\ Select n <= 20 rooms at random
: select-random-rooms ( n -- random-rooms ) 
    DUP COUNT-ROOMS > IF
      CR . ABORT" Can't select more than 20 rooms "
    THEN
      reset-room-numbers
      0 DO
        I swap-random-in-tail
        \ CR I . ." : " show-room-numbers
      LOOP
  ;

\ Create and save a new room configuration
: create-new-room-assignments ( -- )
    6 select-random-rooms
    room-numbers           @ INITIAL-ROOMS           !
    room-numbers 2 CHARS + @ INITIAL-ROOMS 2 CHARS + !
    room-numbers 4 CHARS + @ INITIAL-ROOMS 4 CHARS + !
  ;

\
\ Player dialogue
\

\ Accept a one-character answer from the player
: input-ascii-lowercase ( -- answer )
    CR ." > "
    PROMPT-ANSWER 1 ACCEPT DROP \ Lose count
    \ ASCII alpha to lowercase; others don't care
    PROMPT-ANSWER C@ 32 OR PROMPT-ANSWER !
    PROMPT-ANSWER C@
  ;

\ Accept an unsigned number answer from the player
: input-unsigned-number ( -- uNumber TRUE | FALSE )
    BEGIN
      CR ." > "
      PROMPT-ANSWER DUP 8 ACCEPT \ -- answer-address length
      \ try to convert the answer into a number
      S>UNUMBER? SWAP DROP \ Lose high-order part
      DUP INVERT IF
        CR ." That is not a number. "
        SWAP DROP \ Lose non-numeric answer
      THEN
    UNTIL
  ;

\ Ask a yes-no question, don't accept anything else
: prompt-yes-no ( question -- YES | NO )
    PROMPT-STRING 2!
    BEGIN
      CR PROMPT-STRING 2@ type ." (y|n)? "
      input-ascii-lowercase
      DUP YES = OVER NO = OR
      DUP INVERT IF
        CR ." Huh? "
        SWAP DROP \ Lose invalid answer
      THEN
    UNTIL \ Exit if valid
  ;

\ Show the stored arrow path
: show-arrow-path 
    CR ." ARROW PATH - "
    ARROW-PATH-LENGTH C@ DUP . ." : "
    0 DO
      ARROW-PATH-ROOMS I CHARS + C@ .
    LOOP
  ;

\ Prompt for path length when shooting a crooked arrow
: prompt-arrow-path-length ( -- 1..5 )
    BEGIN
      CR ." How many rooms should the arrow traverse (1..5)? "
      input-unsigned-number
      DUP 1 < OVER 5 > OR
      DUP IF
        CR ." Huh? "
        SWAP DROP \ Lose invalid answer
      THEN
      INVERT \ Try again if invalid
    UNTIL
  ;

\ Prompt for the arrow's path when shooting a crooked arrow
: prompt-arrow-path ( -- )
    prompt-arrow-path-length
    DUP ARROW-PATH-LENGTH C!
    0 DO
      CR ." Enter room " I 1+ .
      input-unsigned-number
      ARROW-PATH-ROOMS I CHARS + C!
    LOOP
  ;

\ Prompt for a command
: prompt-command ( -- MOVE-ME | SHOOT | ?WHERE )
    BEGIN
      CR ." What do you want to do "
         ." (m=move, s=shoot, w=where am I?)? "
      input-ascii-lowercase
      DUP MOVE-ME = OVER SHOOT = OR OVER ?WHERE = OR
      DUP INVERT IF
        CR ." Huh? "
        SWAP DROP \ Lose invalid answer
      THEN
    UNTIL \ Exit if valid
  ;

\ Prompt to play again, with same or new room assignments
: prompt-play-again ( -- QUIT-GAME | SAME-ROOMS | NEW-ROOMS )
    s" Play again " prompt-yes-no
    YES = IF
      CR ." OK, play again ... "
      s" Same rooms " prompt-yes-no
      YES = IF
        CR ." OK, you, the Wumpus, pits, and bats in the same rooms. "
        SAME-ROOMS
      ELSE
        CR ." OK, you, the Wumpus, pits, and bats in new rooms (probably). "
        NEW-ROOMS
      THEN
    ELSE
      CR ." Bye "       
      QUIT-GAME
    THEN
  ;

\ Display congratulations or condolences
: show-result ( WON | LOST -- )
    DUP WON = IF
      CR ." Congratulations! You got the Wumpus! But next time, hee, hee, hee!"
      DROP
    ELSE
      DUP LOST = IF
        CR ." Condolences, maybe better luck next time."
        DROP
      ELSE
        CR . s" unknown game result " exception throw
      THEN
    THEN
  ;

\ List the neighboring rooms
: list-neighbors ( room-number -- )
    cave-room-neighbors
    . . .
  ;

\ List any hazards in a room
: hazards-in-room ( room-number -- )
    DUP WUMPUS C@ = IF
     CR ." I smell a Wumpus!"
    THEN
    DUP PITS C@ = OVER PITS 1 CHARS + C@ = OR IF
     CR ." I feel a draft!"
    THEN
    DUP BATS C@ = OVER BATS 1 CHARS + C@ = OR IF
     CR ." I hear a rustling sound!"
    THEN
    DROP \ Lose room number
  ;

\ Warn of any hazards in the neighboring rooms
: warn-of-hazards ( room-number -- )
    cave-room-neighbors
    hazards-in-room
    hazards-in-room
    hazards-in-room
  ;

\ Describe player's location
: describe-location ( room-number -- )
    CR ." You are in room " DUP .
    CR ." Tunnels lead to rooms " DUP list-neighbors
    warn-of-hazards
  ;

\ Get a new room for the player
: prompt-new-hunter-room ( -- room )
    BEGIN
      CR ." Where do you want to go? "
      input-unsigned-number
      DUP HUNTER C@ = IF
        CR ." You are already in room " . ." ... "
        DROP  \ Lose room hunter already in
        FALSE \ answer not valid, try again
      ELSE
        DUP HUNTER C@ ?cave-room-reachable
        DUP INVERT IF
          CR ." Can't get there from here. "
          SWAP DROP  \ Lose unreachable room
        THEN
      THEN
    UNTIL
  ;

\ Display instructions
: show-instructions ( -- )
    CR ." ---- INSTRUCTIONS ---- " CR
  ;

\ Display instructions if wanted
: show-instructions-if-wanted ( -- )
    s" Show instructions " prompt-yes-no
    YES = IF
      show-instructions
    THEN
  ;

\ Display a greeting
: show-greeting ( -- )
    CR ."  ----  ----  Hunt the Wumpus  ----  ----  "
    CR ."  - (C) 2025 Sigfredo Ismael Nin Colon  -  "
    CR ."  ----  ----  ---------------  ----  ----  "
  ;

\
\ Game play
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

\ Describe the hunter's location
: describe-hunter-location ( -- )
    HUNTER C@ describe-location
  ;

\ Move the Wumpus - did it get the hunter?
: move-wumpus ( -- )
    CR ." Uh oh! You disturbed the Wumpus! "
    4 random DUP 3 < IF
      WUMPUS C@ cave-room-neighbor WUMPUS C!
    ELSE
      DROP \ Lose index indicating Wumpus didn't move
    THEN
    \ The Wumpus eats the hunter if in the same room
    HUNTER C@ WUMPUS C@ = IF
      CR ." Aaaaggghhh! The Wumpus got you! You lose! "
      LOST PLAYER C!
    ELSE
      CR ." Phew! The Wumpus didn't get you. "
    THEN
  ;

\ Hunter went into a room with bats?
: entered-room-with-bats? ( -- flag )
    HUNTER C@ DUP BATS C@ = OVER BATS 1 CHARS + C@ = OR DUP IF
      CR ." Oh oh oh! A bat's got you! Oh ohhh ... "
      COUNT-ROOMS random 1+ DUP HUNTER C!
      CR ." You are now in room " .
    THEN
    \ Return TRUE if a bat moved the Hunter
  ; 

\ Hunter went into a room with a pit?
: entered-room-with-pit? ( -- )
    HUNTER C@ DUP PITS C@ = OVER PITS 1 CHARS + C@ = OR IF
      CR ." Aaaaggghhh! You fell in a pit! You lose! "
      LOST PLAYER C!
    THEN
  ;

\ Hunter went into a room with the Wumpus?
: entered-room-with-wumpus? ( -- )
    HUNTER C@ WUMPUS C@ = IF
      move-wumpus \ may set player state to LOST
    THEN
  ;

\ Shoot an arrow
: shoot-arrow ( -- )
    prompt-arrow-path
    show-arrow-path
    HUNTER C@ \ arrow starts where player is
    DUP CR .
    ARROW-PATH-LENGTH C@
    0 DO
      ." --> "
      ARROW-PATH-ROOMS I CHARS + C@ 2DUP SWAP \ Rf -- Rf Rt Rt Rf
      ?cave-room-reachable IF
        SWAP DROP \ Rf Rt -- Rt ; Arrow now in next room in path
      ELSE
        DROP \ Rf Rt -- Rf ; Lose the unreachable room
        CR ." Uh oh! You hit the cave wall, arrow gone astray! "
        \ Arrow enters one of the adjoining rooms
        cave-room-address 3 random CHARS + C@ \ Rf -- Rt
      THEN
      DUP .
      \ OK, what happens when the arrow reaches this room ...
      DUP HUNTER C@ = IF
        CR ." Ouch! Arrow got you! "
        LOST PLAYER C!
        LEAVE \ That's the end of the arrow's flight
      THEN
      DUP WUMPUS C@ = IF
        CR ." Aha! You got the Wumpus! "
        WON PLAYER C!
        LEAVE \ That's the end of the arrow's flight
      THEN
    LOOP
    DROP \ Forget the last room the arrow went into
    PLAYER C@ IN-PLAY = IF
      \ The arrow didn't hit anything
      CR ." You missed! "
      \ Shooting an arrow always disturbs the Wumpus
      move-wumpus \ may set player state to LOST
      ARROWS C@ 1- DUP ARROWS C! 0 = IF
        CR ." You're out of arrows, you lose! "
        LOST PLAYER C!
      THEN
    THEN
  ;

\ Move the hunter to a new room
: move-hunter ( -- )
    prompt-new-hunter-room HUNTER C!
    BEGIN
      FALSE BATS-MOVED-HUNTER !
      entered-room-with-wumpus? \ may set player state to LOST
      PLAYER C@ IN-PLAY = IF
        entered-room-with-pit?  \ may set player state to LOST
        PLAYER C@ IN-PLAY = IF
          entered-room-with-bats? BATS-MOVED-HUNTER !
        THEN
      THEN
      BATS-MOVED-HUNTER @ INVERT
    UNTIL \ repeat if the bats moved the hunter
    PLAYER C@ IN-PLAY = IF
      \ Nothing too bad happened, let's take a moment
      \ to take in our new surroundings
      describe-hunter-location
    THEN
  ;

\ Play the game until won or lost
: play ( -- WON | LOST )
    BEGIN
      PLAYER C@ IN-PLAY = WHILE
        prompt-command  \ -- MOVE-ME | SHOOT | ?WHERE
        CASE
          MOVE-ME   OF move-hunter              ENDOF
          SHOOT     OF shoot-arrow              ENDOF
          ?WHERE    OF describe-hunter-location ENDOF
          CR . s" unexpected command " exception throw
        ENDCASE
    REPEAT
    PLAYER C@
  ;

\ Set the room configuration to the saved one
: set-rooms-to-initial-assignments ( -- )
    INITIAL-ROOMS           C@ HUNTER C!
    INITIAL-ROOMS 1 CHARS + C@ WUMPUS C!
    INITIAL-ROOMS 2 CHARS + C@ PITS C!
    INITIAL-ROOMS 3 CHARS + C@ PITS 1 CHARS + C!
    INITIAL-ROOMS 4 CHARS + C@ BATS C!
    INITIAL-ROOMS 5 CHARS + C@ BATS 1 CHARS + C!
  ;

\ Reset the state for a new game
: init ( SAME-ROOMS | NEW-ROOMS -- )
    NEW-ROOMS = IF
      create-new-room-assignments
    THEN
    set-rooms-to-initial-assignments
    5 ARROWS C!
    IN-PLAY PLAYER C!
  ;

\ Greet the player, play, then prompt for a new game
: Hunt-the-Wumpus ( -- )
    show-greeting
    show-instructions-if-wanted
    NEW-ROOMS
    BEGIN
      init                      \ SAME-ROOMS | NEW-ROOMS --
      describe-hunter-location  \ --
      play                      \ -- WON | LOST
      show-result               \ WON | LOST --
      prompt-play-again         \ -- QUIT-GAME | SAME-ROOMS | NEW-ROOMS
      DUP QUIT-GAME =
    UNTIL
    DROP \ Lose the QUIT-GAME indicator
  ;

