1 => int syncing;	//  We do this for now, set to 0 if no conductor
1 => int running;	//  This tells all shreds when to stop
0 => int measure;	//  Keep track of how long we've been running

/**************  DAN'S MULTICAST CODE ************/
//get the name of our machine as it appears on the network
Std.getenv("MYIP") => string newclient;
<<<newclient>>>;
//shread to regularly broadcast our presence and name to all on LAN
spork ~ multicast_me();
//multicasts name of this machine to all on LAN
fun void multicast_me()
{       // send object
        OscSend xmit;
        //multicast IP, port should also be the
        //same as the multicast recv port in the server script
        xmit.setHost( "224.0.0.1", 5501 );
        //send out our presence every second
        while(running) {
        1::second => now;
            xmit.startMsg( "/plork/newclient", "s");
            newclient => xmit.addString;
        }
}
/**********************************************/

OscRecv recvglobal; 6449 => recvglobal.port; recvglobal.listen();
recvglobal.event( "/clockGlobal, f, f, i") @=> OscEvent oeglobal;

JCRev r[6];	HPF h[6]; // Reverbs and High-Pass Filters

Dyno dynL => dac.left;
Dyno dynR => dac.right;
dynL.limit();
dynR.limit();
0.5 => dynL.gain => dynR.gain;

int i;
//  DO THESE LINES FOR STEREO
r[0]=>h[0]=>dynL; r[1]=>h[1]=>dynR;
r[2]=>h[2]=>dynL; r[3]=>h[3]=>dynR;
r[4]=>h[4]=>dynL; r[5]=>h[5]=>dynR;

for (0=>i;i<6;i+1=>i)  {
    //r[i] => h[i] => dac.chan(i);   //  DO THIS LINE FOR 6 CHANNEL
    0.1 => r[i].mix;        // DO THIS FOR EITHER
}

JCRev rl => dynL;  JCRev rr => dynR;
0.1 => rl.mix; 0.1 => rr.mix;

Delay d => r[4] => r[5]; Delay dl => rl; Delay dr => rr;
d => d => dl => dr; dl => dr; dr => dl;
2.2 :: second => d.max; 1.1 :: second => dl.max; 1.1 :: second => dr.max;
2.16 :: second => d.delay; 1.08 :: second => dl.delay; 0.72 :: second => dr.delay;
0.6 => d.gain; 0.6 => dl.gain; 0.6 => dr.gain;

0.00 => float bvigor; 0.00 => float mvigor; 0.00 => float mvigor_target;
0.00 => float bass0vigor;  0.00 => float bass1vigor;
0.00 => float bass2vigor;  0.00 => float bass3vigor;
0.12 => float tempo;

SndBuf h0 => r[0] => r[1];  h0 => d;
SndBuf h1 => rl; h1 => dr; SndBuf h2 => rr; h2 => dl;
"snd/Marimba1.aif" => h0.read;
"snd/Marimba2.aif" => h1.read;
"snd/Marimba2B.aif" => h2.read;
1.0 => float basekey;

SndBuf bass[4]; bass[0] => rl; bass[1] => rr;
bass[0] => r[0]; bass[1] => r[0];
bass[0] => r[1]; bass[1] => r[1];
bass[2] => r[2]; bass[2] => r[3];
bass[3] => Gain g4 => r[4]; bass[3] => Gain g5 => r[5];

0.5969 => float bassbase;
"snd/LowBonk1.wav" => bass[0].read;
bassbase => bass[0].rate; 0.0 => bass[0].gain;
"snd/MidBonk1.wav" => bass[1].read;
bassbase => bass[1].rate;  0.0 => bass[1].gain;
"snd/HiBonk1.wav" => bass[2].read;
bassbase => bass[2].rate; 0.0 => bass[2].gain;
"snd/LowBonk2.wav" => bass[3].read;
bassbase => bass[3].rate; 0.0 => bass[3].gain;

SndBuf hA1 => dynL; SndBuf hA2 => dynR;
SndBuf hB1 => dynL; SndBuf hB2 => dynR;
SndBuf hC1 => dynL; SndBuf hC2 => dynR;
SndBuf hD1 => dynL; SndBuf hD2 => dynR;
SndBuf hE1 => dynL; SndBuf hE2 => dynR;
SndBuf hF1 => dynL; SndBuf hF2 => dynR;
"snd/BlockA1.aif" => hA1.read; "snd/BlockA2.aif" => hA2.read;
"snd/BlockB1.aif" => hB1.read; "snd/BlockB2.aif" => hB2.read;
"snd/BlockC1.aif" => hC1.read; "snd/BlockC2.aif" => hC2.read;
"snd/BlockD1.aif" => hD1.read; "snd/BlockD2.aif" => hD2.read;
"snd/BlockE1.aif" => hE1.read; "snd/BlockE2.aif" => hE2.read;
"snd/BlockF1.aif" => hF1.read; "snd/BlockF2.aif" => hF2.read;

0.0 => h0.gain;  0.0 => h1.gain;  0.0 => h2.gain;
0.0 => hA1.gain; 0.0 => hA2.gain; 0.0 => hB1.gain; 0.0 => hB2.gain;
0.0 => hC1.gain; 0.0 => hC2.gain;
0.0 => hD1.gain; 0.0 => hD2.gain;
0.0 => hE1.gain; 0.0 => hE2.gain; 0.0 => hF1.gain; 0.0 => hF2.gain;

[1.0, 0.2, 0.3, 0.1, 1.0, 0.0, 0.2, 0.1,
 1.0, 0.1, 0.2, 0.0, 0.3, 0.0,  0.1, 0.2, 0.3, 0.4] @=> float marimp[];
[1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
 1.0, 0.0, 0.0, 0.0, 0.0, 0.0,
 1.0, 0.0, 0.0, 0.0, 0.0, 0.0] @=> float bas0p[];
[1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] @=> float bas1p[];
[1.0, 0.0, 0.0, 0.0, 0.9, 0.0, 0.0, 0.0,
 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0] @=> float bas2p[];
[1.0, 0.0, 0.5, 1.0, 1.0, 1.0,
 1.0, 0.0, 0.8, 1.0, 0.5, 0.5,
 1.0, 0.0, 0.7, 0.8, 0.9, 0.7] @=> float bas3p[];
[0.7, 0.0, 0.6, 0.6, 0.8, 0.7, 0.7, 0.7,
 0.9, 0.0, 0.5, 0.5, 0.5, 0.5, 0.6, 0.3, 0.3, 0.1] @=> float blockp[];

0 => int j;
0 => int k;
float temp,bgain1,bgain2;
0 => int happiness;
0.0 => float decayenv;

spork ~ smooth();
spork ~ drum();
spork ~ getsync();

int m;

ConsoleInput skot;      // stdin line grabber
StringTokenizer perry;      // substring parser
// out is defined here to alleviate broken garbage collector
string out[10];

while (running)  {
// infinite Stdin TCL/TK GUI handling loop
    skot.prompt( "" ) => now;                   // prompt for line
    while( skot.more() )       {                // loop over lines
        skot.getLine() => perry.set;            // set the line
        0 => m;
        while( perry.more() )      {            // process line
            perry.next( out[m] );               // get all fields
            m + 1 => m;
        }
    //<<< out[0],Std.atof(out[3]) >>>;  // For debugging
        if (out[0] == "ExitProgram") {
        0 => running;
        }
        else if (out[0] == "DownBeat")	{
            17 => j;
            //<<< "DownBeat"," !!!" >>>;
            1.0 => bass[0].gain;  0 => bass[0].pos;
            1.0 => bass[1].gain;  0 => bass[1].pos;
            1.0 => bass[2].gain;  0 => bass[2].pos;
            1.0 => bass[3].gain;  0 => bass[3].pos;
        }
        else if (out[0] == "KeyChange")	{
        if (Std.atoi(out[3]) == 0)	{
                0.5969 => bassbase;
                1.0 => basekey;
                <<< "normal key","(1)" >>>;
        }
        else if (Std.atoi(out[3]) == 1)	{
                0.666 => bassbase;
                1.333 => basekey;
                <<< "alternate key","(2)" >>>;
        }
        else {
                0.53161 => bassbase;
                0.8906 => basekey;
                <<< "yet another key","(3)" >>>;
        }
    }
    else if (out[0] == "Marimba") Std.atof(out[3]) / 128.0 => mvigor_target;
        else if (out[0] == "WoodBlock") Std.atof(out[3]) / 128.0 => bvigor;
        else if (out[0] == "Sub1") Std.atof(out[3]) / 128.0 => bass0vigor;
        else if (out[0] == "Sub2") Std.atof(out[3]) / 128.0 => bass1vigor;
        else if (out[0] == "Sub3") Std.atof(out[3]) / 128.0 => bass2vigor;
        else if (out[0] == "Sub4") Std.atof(out[3]) / 128.0 => bass3vigor;
    else <<< "HUH????" >>>;
    }
}

// Hang a bit while things die down
<<< "\nLook happy and content.", "\nWait for sound to end." >>>;
2.0 :: second => now;
<<< "Thank", " you">>>;
2.0 :: second => now;
<<< "so", " very">>>;
2.0 :: second => now;
<<< "much", " for" >>>;
2.0 :: second => now;
<<< "your", " excellent">>>;
2.0 :: second => now;
<<< "drumming", "!!" >>>;
2.0 :: second => now;
<<< "Please", " drive", " thru..." >>>;
20.0 :: second => now;

fun void smooth()	{	// get them clicks out!!
    while (running)	{
    (0.99 * mvigor) + (0.01 * mvigor_target) => mvigor;
    0.005 :: second => now;
    }
}

fun void drum()	{
//    while (running)	{
    if (j == 0) {
        0 => h0.pos;
        Math.random2f(0.8,2.0) * mvigor * mvigor => h0.gain;
        (mvigor * marimp[j] * 4) $ int => happiness;
        basekey*(Math.random2(0,happiness)*0.25+0.5) => h0.rate;
    }
    if (Math.random2f(1.0-mvigor,1.0) < mvigor * marimp[j]) {
        0 => h1.pos;
        Math.random2f(0.5,marimp[j]) * mvigor * 2.0 => h1.gain;
        (mvigor * marimp[j] * 10) $ int => happiness;
        basekey*(Math.random2(0,happiness)*0.125+0.125) => h1.rate;
    }
    if (Math.random2f(1.0-mvigor,1.0) < mvigor * marimp[j]) {
        0 => h2.pos;
        Math.random2f(0.5,marimp[j]) * mvigor * 2.0 => h2.gain;
        (mvigor * marimp[j] * 10) $ int => happiness;
        basekey*(Math.random2(0,happiness)*0.125+0.125) => h2.rate;
    }
    if (Math.random2f(1.0-bass0vigor,1.0) < bass0vigor * bas0p[j]) {
        0 => bass[0].pos;
        1.0 * Math.random2f(0.5,bas0p[j]) * bass0vigor => bass[0].gain;
        bassbase => bass[0].rate;
    }
    if (Math.random2f(1.0-bass1vigor,1.0) < bass1vigor * bas1p[j]) {
        0 => bass[1].pos;
        1.0 * Math.random2f(0.4,bas1p[j]) * bass1vigor => bass[1].gain;
        bassbase => bass[1].rate;
    }
    if (Math.random2f(1.0-bass2vigor,1.0) < bass2vigor * bas2p[j]) {
        0 => bass[2].pos;
        3.0 * Math.random2f(0.4,bas2p[j]) * bass2vigor => bass[2].gain;
        bassbase * 0.44584 => bass[2].rate;
    }
    if (Math.random2f(1.0-bass3vigor,1.0) < bass3vigor * bas3p[j]) {
        0 => bass[3].pos;
        1.0 * Math.random2f(0.4,bas3p[j]) * bass3vigor => bass[3].gain;
        Math.random2f(0.0,1.0) => g4.gain;
        1.0 - g4.gain() => g5.gain;
        Math.random2(0,4) * 0.5 * bassbase => bass[3].rate;
        Math.random2(0,4) * bassbase => bass[3].rate;
    }

    if (Math.random2f(0.0,1.0) < bvigor * blockp[j]) {
        (bvigor * 7) $ int => happiness;
        for (0 => k; k < happiness; 1 +=> k)	{
        Math.random2f(0.0,1.0) => temp;
        Math.random2f(0.3,blockp[j]) * bvigor => bgain1;
        Math.random2f(0.3,blockp[j]) * bvigor => bgain2;
        if (temp < 0.166)	{	// Used to be 0.166
            0 => hA1.pos; 0 => hA2.pos;
            bgain1 => hA1.gain; bgain2 => hA2.gain;
        }
        else if (temp < 0.333)	{	// Used to be 0.333
            0 => hB1.pos; 0 => hB2.pos;
            bgain1 => hB1.gain; bgain2 => hB2.gain;
        }
        else if (temp < 0.5)	{	// used to be else if < 0.5
            0 => hC1.pos; 0 => hC2.pos;
            bgain1 => hC1.gain; bgain2 => hC2.gain;
        }
		else if (temp < 0.666) {
            0 => hD1.pos; 0 => hD2.pos;
            bgain1 => hD1.gain; bgain2 => hD2.gain;
        }
        else if (temp < 0.8333)	{
            0 => hE1.pos; 0 => hE2.pos;
            bgain1 => hE1.gain; bgain2 => hE2.gain;
        }
        else {
            0 => hF1.pos; 0 => hF2.pos;
            bgain1 => hF1.gain; bgain2 => hF2.gain;
        }

        }
    }
//    timer(tempo);
    1 + j => j;
    if (j == 18) {
        0 => j;
        1 + measure => measure;
        //<<< "One.....", measure >>>;
    }
//    }
}

0 => int bang;

int hpi,hpDownbeat;
float hpf,hpq;

fun void getsync()   {
    int i;
    while (running)  {
        0.11 :: second => now;
//        oeglobal => now;
        while (oeglobal.nextMsg() != 0) {
            1 => bang;
        oeglobal.getFloat() => hpq;
        oeglobal.getFloat() => hpf;
        for (0=>hpi;hpi<6;1+=>hpi) {
        hpq => h[hpi].Q;
        hpf => h[hpi].freq;
        }
        oeglobal.getInt() => hpDownbeat;
        if (hpDownbeat==1)	{
        17 => j;
                <<< "DownBeat from Above"," !!!" >>>;
        1.0 => bass[0].gain;  0 => bass[0].pos;
        1.0 => bass[1].gain;  0 => bass[1].pos;
        1.0 => bass[2].gain;  0 => bass[2].pos;
        1.0 => bass[3].gain;  0 => bass[3].pos;
            }
    }
    drum();
    }
}

fun void timer(float pauseTime)    {
    float when;
    if (syncing == 1) {
//        0.08 :: second => now;
        while (bang == 0) { 0.005 :: second => now; }
        0 => bang;
//	getGUI();
    }
    else  {
        0.0 => when;
        while (when < pauseTime / 2.0)	{
            when + 0.005 => when;
            0.005 :: second => now;
        }
        while (when < pauseTime)	{
            when + 0.005 => when;
            0.005 :: second => now;
        }
//	getGUI();
    }
}

// Some Unused Sounds:
// Clave1.aif Stick1.aif Clave2.aif Stick2.aif
// Cast1.aif Stick3.aif Cast2.aif Stick4.aif Cast4.aif
// More interesting code
