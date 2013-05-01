SndBuf s1 => DelayL d => JCRev rc => dac;
d => Gain g => d;

"cracklingloop.aif" => s1.read;

1.0 :: second => d.max;
0.99 :: second => d.delay;
0.4 => g.gain;

0.1 => rc.mix;
1.0 => s1.rate;
3.0 => s1.gain;
1 => s1.loop;

JCRev r => dac;
JCRev rl => dac.left;
JCRev rr => dac.right;

0.03 => float vigor;
0.11 => float tempo;
0.0 => float when;

1.0 => float sparsity;

SndBuf h0 => r;
SndBuf hA => r;
SndBuf hB => rr;
SndBuf hC => rr;
SndBuf hD => rl;
SndBuf hE => rl;
SndBuf hF => r;
SndBuf hG => rr;
SndBuf hH => r;

"HitA.aif" => h0.read;
"HitA.aif" => hA.read;
"HitB.aif" => hB.read;
"HitC.aif" => hC.read;
"HitD.aif" => hD.read;
"HitE.aif" => hE.read;
"HitF.aif" => hF.read;
"HitG.aif" => hG.read;
"HitG.aif" => hH.read;

0.1 => r.mix;
0.05 => h0.rate;
3.0 => h0.gain;
0.0 => hA.gain;
0.0 => hB.gain;
0.0 => hC.gain;
0.0 => hD.gain;
0.0 => hE.gain;
0.0 => hF.gain;
0.0 => hG.gain;
0.0 => hH.gain;

[1.0, 0.3, 0.2, 0.1, 1.0, 0.0, 0.0, 
 0.6, 0.3, 0.1, 1.0, 0.0, 
 0.8, 0.0, 0.3, 0.1, 0.4] @=> float bassp[];
[0.7, 0.4, 1.0, 0.1, 0.8, 0.6, 0.4, 
 0.7, 0.3, 0.6, 0.1, 0.3, 
 0.8, 0.6, 0.7, 0.2, 0.6] @=> float snarep[];
[0.2, 0.0, 0.4, 0.4, 0.5, 0.7, 0.0, 
 0.1, 0.0, 0.0, 0.1, 0.0, 
 0.1, 0.0, 0.0, 0.1, 0.0, 
 0.1, 0.0, 0.0, 0.1, 0.0, 0.5, 0.6, 
 0.8, 0.8, 0.0, 0.1, 0.0, 
 0.1, 0.8, 0.0, 0.1, 0.3] @=> float tomp[];
[0.8, 0.5, 0.7, 0.1, 0.8, 0.3, 0.6, 
 0.5, 0.0, 0.4, 0.1, 0.1, 
 0.6, 0.3, 0.6, 0.1, 0.3, 
 0.8, 0.5, 0.6, 0.1, 0.7, 0.0, 0.0, 
 0.7, 0.0, 0.5, 0.4, 0.3, 
 0.6, 0.0, 0.7, 0.4, 0.4] @=> float bellp[];
 
0 => int i;
0 => int j;
0 => int k;
float temp;
0.0 => float decayenv;

0.1 => r.mix;
0.1 => rl.mix;
0.1 => rr.mix;

StringTokenizer perry;      // substring parser
ConsoleInput skot;      // stdin line grabber

// out is defined here to alleviate broken garbage collector
string out[6];

1 => int running;

spork ~ drum();

int m;
float level,rate;

// infinite event loop
while (running)       {
    skot.prompt( "" ) => now;                   // prompt for line
    while( skot.more() )                        // loop over lines
    {
        skot.getLine() => perry.set;            // set the line
        0 => m;
        while( perry.more() )                   // process line
        {
            perry.next( out[m] );               // get all fields
            m + 1 => m;
        }
    }
    if (out[0]=="ExitProgram") 0 => running;    // check for Exit
    else if (out[0]=="NoteOn")       {
	0 => j;
        0 => k;
    }
    else if (out[0]=="AfterTouch")      {       // crackle volume
        Std.atof(out[3]) / 127.0 => level;
        level => s1.gain;
//        level => rl.gain;
//        level => rr.gain;
    }
    else if (out[0]=="ModWheel")       {
        Std.atof(out[3]) / 128.0 => vigor;
    }
    else if (out[0]=="PitchBend")	{
	Std.atof(out[3]) / 128.0 => rate; 
	0.5 + rate => s1.rate;
    }
}

0.0 => vigor;
3.0 :: second => now;

fun void drum()	{
    while (running)	{
	if (j == 0) {
	    0 => h0.pos;
	    Std.rand2f(1.8,3.0) * vigor * vigor => h0.gain;
	    Std.rand2f(0.04,0.08) => h0.rate;
	}
        if (Std.rand2f(1.0-vigor,1.0) < sparsity * bassp[j]) { 
	    0 => hA.pos;  
	    Std.rand2f(0.4,bassp[j]) * vigor => hA.gain;
	    Std.rand2(0,5) * 0.25 + 0.25 => hA.rate;
	}
        if (Std.rand2f(1.0-vigor,1.0) < sparsity * snarep[j]) { 
	    0 => hB.pos;  
	    Std.rand2f(0.4,snarep[j]) * vigor => hB.gain;
	    Std.rand2(0,5) * 0.25 + 0.25 => hB.rate;
	}
        if (Std.rand2f(1.0-vigor,1.0) < sparsity * snarep[j]) { 
	    if (Std.rand2f(0.0,1.0) < 0.5)	{
		0 => hC.pos;
	        Std.rand2f(0.4,snarep[j]) * vigor => hC.gain;
		Std.rand2(0,5) * 0.25 + 0.25 => hC.rate;
	    }
	    else	{
		0 => hD.pos;  
	        Std.rand2f(0.4,snarep[j]) * vigor => hD.gain;
		Std.rand2(0,5) * 0.25 + 0.25 => hD.rate;
	    }
	}
        if (Std.rand2f(1.0-vigor,1.0) < sparsity * tomp[k]) {
	    Std.rand2f(0.0,1.0) => temp;
	    if (temp < 0.333)	{
		0 => hE.pos;
	        Std.rand2f(0.4,tomp[k]) * vigor => hE.gain;
		Std.rand2(0,5) * 0.25 + 0.25 => hE.rate;
	    }
	    else if (temp < 0.666)	{
		0 => hF.pos;  
	        Std.rand2f(0.4,tomp[k]) * vigor => hF.gain;
		Std.rand2(0,5) * 0.25 + 0.25 => hF.rate;
	    }
	    else	{
		0 => hG.pos;  
	        Std.rand2f(0.4,tomp[k]) * vigor => hG.gain;
		Std.rand2(0,5) * 0.25 + 0.25 => hG.rate;
	    }
	}
        if (Std.rand2f(1.0-vigor,1.0) < sparsity * bellp[k]) { 
	    0 => hH.pos;  
	    Std.rand2f(0.4,bellp[k]) * vigor => hH.gain;
	    0.5 * Math.pow(1.123, (1.0 * Std.rand2(0,5))) => hH.rate;
	}
        1 + j => j;
	if (j == 17) 0 => j;
        1 + k => k;
	if (k == 34) 0 => k;
	while (when < tempo)	{
	    when + 0.005 => when;
            0.005 :: second => now;
	}
//	if (k==0) <<< "bang!!">>>;
	0.0 => when;
    }
}

