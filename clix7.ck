//-----------------------------------------------------------------------------
// name: clix.ck
// desc: networked typing-based instrument, quantized, multi-channel
//
// author: Ge Wang
//
// to run (in command line chuck):
//
// SINGLE HOST:
//    %> chuck clix7.ck:(ip-addresses, colon-separated)
//

OscSend xmit;
"localhost" => string myhost;
0 => int connected;
spork ~ getServerIP();

// computer keyboard input via terminal
KBHit kb;

// time
92::ms => dur T;

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

int x;
int y;
int clear;

// spork
spork ~ mouse( 0 );

<<< "CLIX: ready to use","" >>>;

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

        // figure out period
        y * 8 + x => int index;
        // generate impulse
        mygains[index] => i.next;
        
        0 => float theFloat;
        if (c!=27) (c $ float) => theFloat;
        
        if (connected)
        {
        	xmit.startMsg( "/ciclop/clix", "f" );
        	theFloat => xmit.addFloat;
        }
        else broadcast (theFloat);
        
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
    	<<< "  buffer cleared!", "" >>>;
    	xmit.startMsg( "/ciclop/clix", "f" );
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

// visualization server
fun void getServerIP()
{
	OscRecv orec;
	6449 => orec.port;
	orec.listen();
	orec.event("/ciclop/clix/sync,iiii") @=> OscEvent sync;
	sync => now;
	while (sync.nextMsg() != 0)
	{
		sync.getInt() => int ip1;
		sync.getInt() => int ip2;
		sync.getInt() => int ip3;
		sync.getInt() => int ip4;
		ip1+"."+ip2+"."+ip3+"."+ip4 => myhost;
	}
	<<< "--- RECEIVED MESSAGE FROM SERVER ---","" >>>;
	<<< "    setting host IP address to",myhost >>>;
	xmit.setHost(myhost,12001);
	1 => connected;
}

fun void broadcast (float f)
{
	for (int i; i<me.args(); i++)
	{
		if (me.arg(i) != "")
		{
			<<< "broadcasting to",me.arg(i) >>>;
			xmit.setHost(me.arg(i),12001);
			xmit.startMsg( "/ciclop/clix", "f" );
       		f => xmit.addFloat;
       	}
  }
}

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
