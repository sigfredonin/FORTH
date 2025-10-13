Hunt the Wumpus - FORTH

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

\ Ask a yes-no question, don’t accept anything else
: prompt-yes-no ( question - answer )
  ;

\ Prompt for a command, (w)here am I, (m)ove, or (s)hoot
: prompt-command ( - W | M | S )
  ;

\ Ask if want to use the same starting configuration?
: prompt-play-same ( - SAME | NEW )
  ;

\ Ask if want to play again?
: prompt-play-again ( - YES | NO )
  ;

\ Display congratulations or condolences
: show-result ( WON | LOST - )
  ;

\ Play the game until won or lost
: play ( - WON | LOST )
  loop
    prompt-command
    execute-command
    in-play if-not break
  end
  ;

\ Initialize game configuration in state
: init ( SAME | NEW - )
  ;

\ Display instructions if wanted
: prompt-show-instructions ( - )
  ;

: show-greeting ( - )
  .”  ----  ----  Hunt the Wumpus  ----  ----  “
  ;

: Hunt-the-Wumpus ( - )
  show-greeting 
  prompt-show-instructions
  NEW init
  loop
   play show-result
   prompt-play-again YES if-not break
   prompt-play-same init
  end
  ;

