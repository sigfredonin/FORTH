## Hunt the Wumpus - FORTH

This is a Forth implementation of the game published in the article
"Hunt the Wumpus" by Gregory Yob, in --

*Creative Computing*, Vol. 1, No. 5, September/October 1975, pages 51-54,

and reprinted in --

*The Best of Creative Computing*, Volume 1 (1976), pages 247-250.

The original game was written in BASIC, and the source code was published in the article,
together with a description, a sample session, and some background on how it came to be.
Scans of the article pages are online at

https://archive.org/details/CreativeComputingv01n05SeptemberOctober1975

and

http://www.atariarchives.org/bcc1/showpage.php?page=247

Implementations of the game in various programming languages have been published
on Rosseta Code's "Hunt the Wumpus" page --

https://rosettacode.org/wiki/Hunt_the_Wumpus

The discussion page, https://rosettacode.org/wiki/Talk:Hunt_the_Wumpus,
has a list of game behaviors extracted from the original BASIC.

Hunt the Wumpus was described in the November 1973 issue of the
People's Computer Company's newsletter, page 23.
It was offered for sale to subscribers on tape
(presumably an audio cassette) for $4.
Subscribers could get a free printout of the source code,
if they sent in a request with a stamped self-addressed envelope.
The programs were said to run on any system with Dartmouth BASIC,
using HP strings.
I think that meant string variables
had a dollar sign in front, as in 

$A="This is a string."

Scans of this issue are online at

https://dn790009.ca.archive.org/0/items/1973-11-peoples-computer-company/1973-11%20Peoples%20Computer%20Company.pdf

### The Game

Hunt the Wumpus is one of the text adventure games from the beginning of the
personal computer era, written in the ubiquitous BASIC language with all its limitations.
When you play the game, you are a hunter out to bag a Wumpus, a creature that inhabits
a cave with 20 rooms, each connected by tunnels to exactly three others.
The rooms and the connecting tunnels form the vertices and edges of a dodecahedron,
a deliberate departure, Yob says, from a prevalence of games on rectangular grids.

In the cave, you face several hazards: the Wumpus is asleep in one room;
two others contain bottomless pits; and two more contain super bats.
You starts the game in a room that does not have any of these hazards.
As you move through the cave, you can sense nearby dangers:

* You can smell the Wumpus, if it is in an adjacent room.
* You hear a rustling, if there are bats nearby.
* You feel a breeze, if an adjacent room has a pit.

You are furnished with 5 crooked arrow.
You can shoot an arrow through up to 5 rooms.
An arrow can only fly into an adjacent room,
and is not so crooked that it can go out the way it came in, unless…
If there is no tunnel to the next room on its list,
it bounces around and enters one of the three rooms it can reach,
possibly the one it just left, possibly the one you are in.
After that, it tries to go to the next room on its list.
It flies until it hits something or has tried to visit all of the rooms on its list.

Each turn, you can move to an adjacent room, or shoot an arrow.

* If you shoot and hit the Wumpus, you win.
* If you shoot and hit yourself, you lose.
* If you run out of arrows, you lose.
* If you enter a room with a pit, you fall in and lose
* If go into a room with bats, a bat snatches you and takes you to another room,
  which may have a pit, bats, or the Wumpus.
* If you enter the room with the Wumpus, you wake it.
* If you shoot and don’t hit anything, you wake the Wumpus.
* If you wake the Wumpus, it may move to an adjacent room, or stay where it is.
  After that, if it is in the same room with you, it eats you and you lose.

When the game has ended, with a win or a loss, the player has the option to
play again, with the same arrangement of starting room and hazards,
or a new arrangement in which everything is probably in different rooms.

## The FORTH Code

This implementation is written in fairly elementary Forth.
It does not, for example, make explicit use of the return stack,
and it does not use any of the advanced facilities of the later versions
of the language, such as local variables or object oriented features.
It conforms to the ANSI X3.215-1994 Forth standard, except that it uses
a Forth word to access a system millisecond or microsecond clock,
as a means of seeding the pseudorandom number generator.

The Forth code departs from the original implementation in that the player
is not allowed to make the second room in a crooked arrow's path be the room
that the hunter is in.
That would require the arrow to exit the first room in its path the way it came in, 
assuming the first room can be reached from the hunter's room.
That would exceed its crookedness capabilities.
The original code did not check for this possibility.

The Forth code also departs from the original in the wording of
messages to the player, the wording of the game instructions,
and the manner in which it treats invalid player inputs.

The code has been tested on Gforth (version 0.7.0, November 2, 2008), and
SwiftForth (i386-Win32 3.12.0 21-Sep-2023), on Windows 11 (October 2025).

## License (MIT License)

Copyright © 2025 Sigfredo Ismael Nin Colón (signin@email.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Country of Origin: USA
