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
// name: wind-o-lin.ck
// desc: networked keyboard + trackpad-bowing "wind instrument"
//       (also see crystalis.ck and mapping.pdf)
//
// author: Ge Wang
//
// to run (in command line chuck):
//    %> chuck wind-o-lin.ck
//
// multi-channel (max of 4 in this case):
//    %> chuck -c4 wind-o-lin.ck
//
// MULTIPLE HOSTS:
//
// 1. each sound making machine should run:
//    %> chuck wind-o-lin.ck
//
// 2. (there is no networking involved in wind-o-lin)
//
// to run (in miniAudicle):
//     (similar type of thing)
//-----------------------------------------------------------------------------

// which mouse
0 => int mouse_dev;
// which kb
2 => int kb_dev;
// number of channels
dac.channels() => int channels;
// max is 4 since we have four directions
if( channels > 4 ) 4 => channels;
// base and register
12 => int base;
5 => int register;
// filter pole
.99999 => float filter_pole;
// uniform volume scaling
25 => float volume;
// level control
1 => float level;
// filter resonance
1 => float resonance;

// print
<<< "------------------", "" >>>;
<<< "wind-o-lin - v 1.0", "" >>>;
<<< "------------------", "" >>>;
// print channels
<<< "* channels:", channels >>>;

// hid objects
Hid mouse;
KBHit kb;
HidMsg msg;

// try
if( !mouse.openMouse( mouse_dev ) ) me.exit();
<<< "mouse "+mouse.name()+" ready...", "" >>>;
// open keyboard
//if( !kb.openKeyboard( kb_dev ) ) me.exit();
//<<< "keyboard "+kb.name()+" ready...", "" >>>;

// numbers
0 => int L;
1 => int R;
2 => int U;
3 => int D;

// key map
int key[256];
// key and pitch
0 => key[29];
1 => key[27];
2 => key[6];
3 => key[25];
4 => key[5];
5 => key[4];
6 => key[22];
7 => key[7];
8 => key[9];
9 => key[10];
10 => key[20];
11 => key[26];
12 => key[8];
13 => key[21];
14 => key[23];
// which is current
-1 => int current;

// band map
ADSR @ playing[256];
// dir map
int dir[4];

// find key
fun int findNext( int which )
{
    current++; if( current >= channels ) 0 => current;
    for( current => int i; i < channels; i++ )
        if( dir[i] == 0 )
        {
            which => dir[i];
            return i;
        }

    for( int i; i < current; i++ )
        if( dir[i] == 0 )
        {
            which => dir[i];
            return i;
        }

    return -1;
}

// free key
fun void freeNext( int which )
{
    for( int i; i < 4; i++ )
        if( dir[i] == which )
            0 => dir[i];
        }

// bands
Noise noise[channels];
ADSR adsr[channels];
ResonZ reson[channels];
Gain gain[channels];
OnePole pole[channels];
LPF lpf[channels];
Impulse imp[4];
JCRev reverb[channels];
Gain out[dac.channels() > channels ? dac.channels() : channels];
// Echo echoA[channels];
// Echo echoB[channels];

// normal
if( dac.channels() != 6 )
    for( int i; i < channels; i++ ) out[i] => dac.chan(i);
else // special: plork 6 channel
{
    <<< "* rerouting audio for 6 channel plork...", "" >>>;
    for( int i; i < channels; i++ )
    {
        // two per out
        out[i] => dac.chan(i);
        out[i] => dac.chan((i+3)%6);
    }
}

// connect
for( int i; i < channels; i++ )
{
    // go
    noise[i] => reson[i] => adsr[i] => gain[i] => reverb[i] => out[i];
    imp[i] => lpf[i] => pole[i] => gain[i];
    3 => gain[i].op;
    // preset
    adsr[i].set( 2, 1, .75, 1.5 );
    adsr[i].keyOff();
    reson[i].freq( 220 );
    reson[i].Q( 5 );
    // filters
    filter_pole => pole[i].pole;
    volume => gain[i].gain;
    10 => lpf[i].freq;
    // reverb
    .05 => reverb[i].mix;
}

// set level
fun void setLevel( float val )
{
    // loop
    for( int i; i < channels; i++ )
        val => out[i].gain;
    }

// go
spork ~ do_kb();

// infinite time loop
int i;
while( true )
{
    // wait
    mouse => now;
    // loop over messages
    while( mouse.recv( msg ) )
    {
        if( msg.isMouseMotion() )
        {
            // left
            if( msg.deltaX < 0 )
                -msg.deltaX * 4 => imp[L].next;
            // right
            else if( msg.deltaX > 0 )
                msg.deltaX * 4 => imp[R].next;

            // up
            if( msg.deltaY > 0 )
                msg.deltaY * 4 => imp[U].next;
            // down
            else if( msg.deltaY < 0 )
                -msg.deltaY * 4 => imp[D].next;
        }
    }
}

// keyboard
fun void do_kb()
{
    // go
    int i;
    while( true )
    {
        // wait
        kb => now;
        // inspect
        while( kb.recv( msg ) )
        {
            // which
            if( msg.which > 256 ) continue;
            if( key[msg.which] == 0 && msg.which != 29 )
            {
                // volume
                if( msg.which == 45 && msg.isButtonDown() )
                { .95 *=> level; setLevel( level ); <<< "volume:", level >>>; }
                else if( msg.which == 46 && msg.isButtonDown() )
                { 1.05 *=> level; setLevel( level ); <<< "volume:", level >>>; }
                // register
                else if( msg.which == 54 && msg.isButtonDown() )
                { if( register > 0 ) register--; <<< "register:", register >>>; }
                else if( msg.which == 55 && msg.isButtonDown() )
                { if( register < 10 ) register++; <<< "register:", register >>>; }
                else if( msg.which >= 30 && msg.which <= 39 )
                {
                    // resonance
                    if( msg.isButtonDown() )
                    {
                        Math.pow( 2.0, msg.which - 34 ) => resonance;
                        <<< "resonance:", resonance >>>;
                    }
                }
            }
            // set
            else if ( msg.isButtonDown() )
            {
                // the player
                findNext( msg.which ) => int num;
                // busy
                if( num < 0 ) continue;
                // freq
                base + register * 12 + key[msg.which] => 
                    Std.mtof => reson[num].freq;
                register * resonance => reson[num].Q;
                resonance < 1.0 ? Math.sqrt(resonance) : 
                    Math.pow(resonance, .8) => reson[num].gain;
                // bow
                adsr[num].keyOn();
                // remember
                adsr[num] @=> playing[msg.which];
            }
            else if( msg.isButtonUp() )
            {
                // playing
                if( playing[msg.which] != null )
                {
                    // stop
                    playing[msg.which].keyOff();
                    // clear
                    null @=> playing[msg.which];
                    // free
                    freeNext( msg.which );
                }
            }
        }
    }
}
