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
// name: clix.ck
// desc: networked typing-based instrument, quantized, multi-channel
//
// author: Ge Wang
//
// to run (in command line chuck):
//
// SINGLE HOST:
//    %> chuck clix3.ck
//
// MULTIPLE HOSTS:
//
// 1. each sound making machine should run:
//    %> chuck clix3.ck:your-player-number:host-ip-address
// ie: chuck clix3.ck:1:127.0.0.1
//    (make sure terminal has focus in order to receive keyboard events)

"10.42.43.10" => string myhost;
int playerNum;
if (me.args()>0)
{
	me.arg(0) => Std.atoi => playerNum;
	<<< "setting player number to",playerNum >>>;
}
if (me.args()>1)
{
	me.arg(1) => myhost;
	<<< "setting host IP address to",myhost >>>;
}

OscSend xmit;
xmit.setHost(myhost,12001);

xmit.startMsg( "/ciclop/clix", "i f" );
0 => xmit.addInt;
0 => xmit.addFloat;

Machine.add("server-local-clix.ck");

// computer keyboard input via terminal
KBHit kb;

// time
4096::samp => dur T;

// patch
Impulse i => BiQuad f => Envelope e => JCRev r;

// set the filter's pole radius
.99 => f.prad;
// set equal gain zeros
1 => f.eqzs;
// envelope rise/fall time
1::ms => e.duration;
// reverb mix
.01 => r.mix;

// strengths
[ 1.0, 0.2, 0.3, 0.2, 0.4, 0.1, 0.2, 0.1,
  0.5, 0.1, 0.3, 0.2, 0.4, 0.1, 0.2, 0.1,
  0.8, 0.1, 0.3, 0.2, 0.5, 0.1, 0.2, 0.1,
  0.4, 0.1, 0.3, 0.2, 0.3, 0.1, 0.2, 0.1 ] @=> float mygains[];

// capacity
mygains.cap() => int N;
// period duration
N * T => dur period;

// last unen
UGen @ last;
// total number of channels
dac.channels() => int C;
// keep track of which
int which;

// event
Event event;
int x;
int y;
int clear;

// spork
spork ~ mouse( 0 );
spork ~ clock();

// time-loop
while( true )
{
    // wait on event
    kb => now;

    // set clear
    0 => clear;

    // loop through 1 or more keys
    while( kb.more() )
    {
        // clear button hit
        if( clear )
        { kb.getchar(); continue; }

        // get key...
        kb.getchar() => int c;

        // synch
        event => now;

        // figure out period
        y * 8 + x => int index;
        // generate impulse
        mygains[index] => i.next;
        
        
        xmit.startMsg( "/ciclop/clix", "i f" );
        if (0)
        {
          0 => xmit.addInt;
          0.0 => xmit.addFloat;
        }
        else
        {
        playerNum => xmit.addInt;
        (c $ float) => xmit.addFloat;
        }
        
        // set filtre freq
        c => Std.mtof => f.pfreq;
        // print int value
        <<< "ascii:", c, "velocity:", mygains[index], "channel:", which >>>;

        // disconnect from previous
        if( last != NULL ) r =< last;
        // the dac channel to connect
        dac.chan(which) @=> last;
        // the next channel
        (which + 1) % C => which;
        // connect revert to dac channel
        r => last;

        // open
        e.keyOn();
        // advance time
        T-2::ms => now;
        // close
        e.keyOff();
    }

    // check clear
    if( clear )
    {
    	<<< "cleared!!!", "" >>>;
    	xmit.startMsg( "/ciclop/clix", "i f" );
        playerNum => xmit.addInt;
        0 => xmit.addFloat;
    	}
}

// mouse
fun void mouse( int device )
{
    // hid objects
    Hid hi;
    HidMsg msg;

    // try
    if( !hi.openMouse( device ) ) me.exit();
    <<< "mouse ready...", "" >>>;

    // go
    while( true )
    {
        // wait on event
        hi => now;

        // get message
        while( hi.recv( msg ) )
        {
            if( msg.is_button_down() )
            { 1 => clear; }
        }
    }
}

// receiver
fun void clock()
{
    // create our OSC receiver
    OscRecv recv;
    // use port 6449
    6449 => recv.port;
    // start listening (launch thread)
    recv.listen();

    // create an address in the receiver, store in new variable
    recv.event( "/ciclop/sync/clock, i i" ) @=> OscEvent oe;

    // count
    0 => int count;

    // infinite event loop
    while ( true )
    {
        // wait for event to arrive
        oe => now;

        // count
        if( count < 5 ) count++;
        if( count < 4 ) <<< ".", "" >>>;
        else if( count == 4 ) <<< "keyboard ready...", "" >>>;

        // grab the next message from the queue. 
        while( oe.nextMsg() != 0 )
        {
            // get x and y
            oe.getInt() => x;
            oe.getInt() => y;

            // broadcast on event
            event.broadcast();
        }
    }
}
