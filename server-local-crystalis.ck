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
// desc: crystalis localhost server
//
// author: Ge Wang
//
// to run (in command line chuck):
//     (see crystalis.ck, under SINGLE HOST)
//-----------------------------------------------------------------------------

// value of 8th
4096::samp => dur T;

// send objects
OscSend xmit[4];
// number of targets
1 => int targets;
// port
6449 => int port;

// aim the transmitter at port
xmit[0].setHost ( "localhost", port );

// dimensions
4 => int height;
8 => int width;

// strengths
[ 1.0, 0.5, 0.8, 0.4, 0.9, 0.6, 0.6, 0.5,
  0.7, 0.4, 0.8, 0.6, 0.9, 0.5, 0.5, 0.9,
  0.9, 0.5, 0.6, 0.5, 0.8, 0.6, 0.8, 0.5,
  0.5, 0.5, 0.8, 0.5, 1.0, 0.8, 0.5, 0.5 ] @=> float mygains[];

int x;
int y;
int z;

// infinite time loop
while( true )
{
    for( 0 => y; y < height; y++ )
        for( 0 => x; x < width; x++ )
        {
            for( 0 => z; z < targets; z++ )
            {
                // start the message...
                xmit[z].startMsg( "/ciclop/sync/crystalis", "f" );

                // a message is kicked as soon as it is complete 
                mygains[y*width+x] => xmit[z].addFloat;
            }

            // advance time
            T => now;
        }
}
