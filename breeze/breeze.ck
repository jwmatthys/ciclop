// a breeze brings...
//
// Scott Smallwood, 2006, revised 2008
//
//  to run: %> chuck -cN breeze.ck (where N = # of channels)
//

//controls

1 => int running;
Shred s;
dac.channels() => int channels;

0.0 => float mGain;   // main Gain var
1.0 => float mTempo;  // main tempo adjustment var
0.0 => float mBrite;  // main brightness adjustment var
0.0 => float mDense;  // main density adjustment var

//audio chain
Envelope amp[channels];
JCRev r[channels];

for (0 => int i; i < dac.channels(); i++) {
    amp[i] => r[i] => dac.chan(i);
    mGain => amp[i].target;
    second => amp[i].duration;
    Std.rand2f(.01, .03) => r[i].mix;
}

int inst;
spork ~ readTCL_GUI();

while (running) second => now;

fun void readTCL_GUI()
{
    StringTokenizer perry;      // substring parser
    ConsoleInput skot;      // stdin line grabber
    string out[10];
    int ii;

    while (true)
    {
        skot.prompt ( "" ) => now;
        while ( skot.more() )
        {
            skot.getLine() => perry.set;
            0 => ii;
            while (perry.more())
            {
                perry.next (out[ii++]);
            }
        }
        if (out[0] == "goodbye")
        {
        	for (int i; i < dac.channels(); i++)
        	{
        		0 => amp[i].target;
        		10::second => amp[i].duration;
        	}
        	10::second => now;
		    0 => running;
        }
        if (out[0] == "volume")
        {
	        Std.atof(out[1]) / 255.0 => mGain;
        	for (int i; i < dac.channels(); i++)
        	{
        		mGain => amp[i].target;
        	}
        }
        if (out[0] == "tempo") 1.5 - (Std.atof(out[1]) / 127.0) => mTempo;
        if (out[0] == "brightness") Std.atof(out[1]) / 255.0 => mBrite;
        if (out[0] == "density") Std.atof(out[1]) / 255.0 => mDense;
        if (out[0] == "inst")
        {
            out[1] => Std.atoi => int instNum;
            if (instNum != inst)
            {
            	if (inst>0) Machine.remove(s.id());
            	if (instNum == 1) spork ~ arpPlanes() @=> s;
            	if (instNum == 2) spork ~ melPlanes() @=> s;
            	if (instNum == 3) spork ~ harmPlanes() @=> s;
            	instNum => inst;
            }
        }
    }
}

fun void arpPlanes ()
{
  6 => int voices;

  //oscillators + reverbs
  SinOsc o[voices];
  JCRev rv[voices];

  for (0 => int i; i < voices; i++)
    o[i] => rv[i] => amp[Std.rand2(0, channels - 1)];

  //define just scale
  524.4 / 8 => float c;
  9.0 / 8.0 * c => float d;
  5.0 / 4.0 * c => float e;
  4.0 / 3.0 * c => float f;
  3.0 / 2.0 * c => float g;
  27.0 / 16.0 * c => float a;
  15.0 / 8.0 * c => float b;

  Std.rand2(80,200) => int Q; //tempo

  [(c / 8), (f / 4), (a / 2), c, a, (g * 2)] @=> float notes[];
  float theNote;
  5 => int size;
  0 => int nStart => int nNext;


  0 => int ct;
  1 => int octv;

  while (true)
  {
        //for (0 => int i; i < channels; i++)
        //    mGain => amp[i].target;

        for (0 => int i; i < voices; i++)
        {
            Std.rand2f(.13, .16) + mDense => rv[i].mix;
            Std.rand2f(.13, .16) => rv[i].gain;
            Std.rand2f(.18, .22) => o[i].gain;
        }

        for (3 => int i; i < voices; i++)
        {

            rv[i].gain() + mBrite => rv[i].gain;
            o[i].gain() + mBrite => o[i].gain;
        }

        Std.rand2(0,5) => nStart;
        while (ct < 4)
        {
            notes[nStart] * octv => theNote;
            for (0 => int i; i < voices; i++)
                theNote * Math.pow(2, i) => o[i].freq;

            Std.rand2((nStart + 1), (nStart + 4)) => nNext;
            if (nNext > size)
            {
                1 +=> octv;
                nNext - size => nNext;
            }
            nNext => nStart;
            1 +=> ct;
            Q * mTempo::ms => now;
        }
        0 => ct;
        1 => octv;
  }
}

fun void melPlanes ()
{
  6 => int voices;

  //oscillators + reverbs
  SinOsc o[voices];
  JCRev rv[voices];

  for (0 => int i; i < voices; i++)
    o[i] => rv[i] => amp[Std.rand2(0, channels - 1)];

  //define just scale
  524.4 => float c;
  9.0 / 8.0 * c => float d;
  5.0 / 4.0 * c => float e;
  4.0 / 3.0 * c => float f;
  3.0 / 2.0 * c => float g;
  27.0 / 16.0 * c => float a;
  15.0 / 8.0 * c => float b;

  700 => int Q; // tempo

  // array of note set
  [(c / 4), (f / 16), f, b, a, (b / 2), c, (a / 2), g] @=> float notes[];
  float theNote;

  while (true)
  {

    //for (0 => int i; i < channels; i++)
            //mGain => amp[i].target;

    for (0 => int i; i < voices; i++)
    {
        Std.rand2f(.13, .16) + mDense => rv[i].mix;
        Std.rand2f(.13, .16) => rv[i].gain;
        Std.rand2f(.18, .22) => o[i].gain;
    }

    o[4].gain() + mBrite => o[4].gain;
    o[5].gain() + mBrite => o[5].gain;

   notes[Std.rand2(0,8)] => theNote;

   theNote          => o[0].freq;
   (theNote / 2)    => o[1].freq;
   (theNote / 4)    => o[2].freq;
   (theNote * 2)    => o[3].freq;
   (theNote * 4)    => o[4].freq;
   (theNote * 6)    => o[5].freq;

   Q * mTempo * Std.rand2f(.995,1.005)::ms => now;
  }
}

fun void harmPlanes ()
{
  8 => int voices;

  //oscillators + reverbs
  SinOsc o[voices];
  JCRev rv[voices];

  for (0 => int i; i < voices; i++)
    o[i] => rv[i] => amp[Std.rand2(0, channels - 1)];

  //define just scale
  (524.4 / 2) => float c;
  9.0 / 8.0 * c => float d;
  5.0 / 4.0 * c => float e;
  4.0 / 3.0 * c => float f;
  3.0 / 2.0 * c => float g;
  27.0 / 16.0 * c => float a;
  15.0 / 8.0 * c => float b;

  3000 => int Q;  //tempo

  [(g / 4), c, (d * 2), f, (a / 2), (c / 2), (d / 4)] @=> float notes[];
  float theNote1, theNote2, theNote3;

  while (true)
  {

    //for (0 => int i; i < channels; i++)
            //mGain => amp[i].target;

    for (0 => int i; i < voices; i++)
    {
        Std.rand2f(.13, .16) + mDense => rv[i].mix;
        Std.rand2f(.13, .16) => rv[i].gain;
        Std.rand2f(.18, .22) => o[i].gain;
    }

    o[3].gain() + mBrite => o[3].gain;

    notes[Std.rand2(0,4)] => theNote1;
    notes[Std.rand2(2,6)] => theNote2;
    notes[Std.rand2(1,5)] => theNote3;

    theNote1        => o[0].freq;
    (theNote1 * 2)  => o[1].freq;
    theNote2        => o[2].freq;
    (theNote2 * 7)  => o[3].freq;
    theNote3        => o[4].freq;
    (theNote3 / 2)  => o[5].freq;
    (theNote2 / 4)  => o[6].freq;
    (theNote3 / 4)  => o[7].freq;

    Q * mTempo::ms => now;
  }
}
