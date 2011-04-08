/*----------------------------------------------------------------------------
    S.M.E.L.T. : Small Musically Expressive Laptop Toolkit

    Copyright (c) 2007 Rebecca Fiebrink and Ge Wang.  All rights reserved.
      http://smelt.cs.princeton.edu/
      http://soundlab.cs.princeton.edu/

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
    U.S.A.
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// name: server-local.ck
// desc: clix localhost server
//
// author: Ge Wang
//
// to run (in command line chuck):
//     (see clix.ck, under SINGLE HOST)
//-----------------------------------------------------------------------------

// value of 8th
4096::samp => dur T;

// send object
OscSend xmit;

// aim the transmitter at our local port 6449
xmit.setHost( "localhost", 6449 );

// dimensions
4 => int height;
8 => int width;

int x;
int y;

// infinite time loop
while( true )
{
    for( 0 => y; y < height; y++ )
        for( 0 => x; x < width; x++ )
        {
            // start the message...
            xmit.startMsg( "/ciclop/sync/clock", "i i" );

            // a message is kicked as soon as it is complete 
            // - type string is satisfied and bundles are closed
            x => xmit.addInt; y => xmit.addInt;
            // <<< "sent (via OSC):", x, y >>>;

            // advance time
            T => now;
        }
}
