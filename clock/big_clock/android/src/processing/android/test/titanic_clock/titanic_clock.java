package processing.android.test.titanic_clock;

import processing.core.*; 

import oscP5.*; 
import netP5.*; 

import android.view.MotionEvent; 
import android.view.KeyEvent; 
import android.graphics.Bitmap; 
import java.io.*; 
import java.util.*; 

public class titanic_clock extends PApplet {



OscP5 oscP5;
int mins, secs =0;
PFont font;
char[] characterSet = {'0','1','2','3','4','5','6','7','8','9',':'};

public void setup()
{
  oscP5 = new OscP5(this, 6499);
 
  orientation(LANDSCAPE);
  font=createFont("sans_serif",width/2,true,characterSet);
  textFont(font);
  frameRate(5);
  stroke(255);
  fill(255);
  textAlign(CENTER);
}

public void draw()
{
  background(0);
  text(mins+":"+nf(secs,2,0),width/2,(textAscent()+height)/2);
}

public void oscEvent (OscMessage msg)
{
  if (msg.addrPattern().equals("/clock"))
  {
    mins = msg.get(0).intValue();
    secs = msg.get(1).intValue();
    println(mins+":"+secs);
  }
}


  public int sketchWidth() { return screenWidth; }
  public int sketchHeight() { return screenHeight; }
}
