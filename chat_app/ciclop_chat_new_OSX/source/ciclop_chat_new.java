import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ciclop_chat_new extends PApplet {




OscP5 oscChat;
OscP5 oscClock;

//PFont font;
String[] lines;
String currentMessage = "";
String lastMessage = "";
String nextMessage = "";
String remainder = "";
String name = "";
boolean nameEntered = false;
int mins, secs, section;
int elapsed = 0;
int[] section_times = { 
  0, 10, 50, 
  69, 126, 169, 277, 358, 508, 526, 
  648, 659, 820, 
  835, 1100, 1220, 
  1384, 1398, 
  1505, 1650, 1901, 1911, 1990, 2006, 2033, 2132, 2200, 2341, 2483, 
  2560, 2577, 2594, 2619, 2686, 
  2696, 2767, 2776, 2894, 3036, 
  3043, 3090, 3296, 
  3313, 3387, 3428, 3463, 3467, 
  3538, 3558, 3596, 3610, 3660
};
String[] description =
{ 
  "Title - silence", 
  "Hypnosis - film audio", 
  "Farm - crystal & perc", 
  "Pastimes - panorama", 
  "Parade", 
  "Riot", 
  "3 Houses - film audio", 
  "Nuke - panorama", 
  "Picnic/car ride", 
  "Train", 
  "Corn - perc", 
  "Gardening - mobile & cello", 
  "Old Neighbors - film audio", 
  "Iron Foundry - granite & breeze", 
  "Factory closing - strings", 
  "Typing - clix & clixy", 
  "Eggs - perc", 
  "Hypnosis - film audio", 
  "Tricycles & rocks - crystal", 
  "Danger Dodgers - film audio", 
  "Fish - perc", 
  "Turtle & teddy - laptops", 
  "Drowning teddy - crystal & laptops", 
  "Stop-motion weapons - perc", 
  "Sad Paul - film audio", 
  "Andrew's turmoil - film audio & str", 
  "Andrew on the run - strings", 
  "Crash test - timber & perc", 
  "Return of rocks - laptops", 
  "Seagulls - perc & laptops", 
  "Hypnosis - film audio", 
  "Gas stations - laptops", 
  "Log cabins - film audio", 
  "Corn - perc", 
  "Long Distance - clixy & str", 
  "Couch - perc", 
  "Time & War - str", 
  "Election day - laptops", 
  "Carrots - perc", 
  "Couple driving - str", 
  "Picnic - str + film audio", 
  "Pyrex - perc", 
  "Shopping by day - perc & str", 
  "Dancing by night - perc & str", 
  "New landscapes", 
  "Dog - perc", 
  "Bus stop stripper", 
  "Sheep - film audio", 
  "Seagulss - crystal & perc", 
  "Convertible - perc", 
  "Hypnosis - film audio", 
  "End credits - silence"
};

public void setup()
{
  size(400, 200);
  smooth();
  oscClock = new OscP5(this, 26499);
  oscChat = new OscP5(this, "joel-hp-dv6.local", 13032, OscP5.TCP);
  noStroke();
  fill(255, 255, 0);
  frameRate(10);
  lines = new String[9];
  for (int i=0; i<lines.length; i++) lines[i]="";
  mins = 0;
  secs = 0;
  section = 0;
  println(section_times.length+", "+description.length);
}

public void draw()
{
  background(0, 0, 64);
  if (nameEntered)
  {
    textAlign(RIGHT);
    textSize(48);
    String time = nf(mins, 2, 0)+":"+nf(secs, 2, 0);
    text(time, width-10, 50);
    textSize(12);
    int ttn = timeToNext(elapsed);
    int si = section_index(elapsed);
    text(description[si], width-10, 70);
    textSize(16);
    text("next: "+nf(ttn/60, 2, 0)+":"+nf(ttn%60, 2, 0), width-10, 92);
    textSize(12);
    text(description[si+1], width-10, 110);
    stroke(128);
    line(0, height-30, width, height-30);
    noStroke();
    textAlign(LEFT);
    textSize(16);
    fill(255, 255, 0);
    text("> "+currentMessage+"|"+remainder, 10, height-10);
    for (int i=0; i<lines.length; i++)
    {
      float redness = map(i, 0, lines.length, 0, 255);
      float y = map(i, 0, lines.length, 15, height-20);
      fill(redness, 255, 0);
      text(lines[i], 5, y);
    }
  }
  else
  {
    stroke(255);
    fill(0);
    rect(width/6, height/3, width*2/3, height/3);
    textAlign(CENTER);
    noStroke();
    textSize(18);
    fill(255, 255, 0);
    text("Enter your name:", width/2, (height/2)-8);
    fill(255);
    text(currentMessage+"|"+remainder, width/2, height/2+15);
  }
}

public void keyPressed()
{
  if (keyCode==ENTER || keyCode==RETURN)
  {
    if (nameEntered)
    {
      OscMessage myMessage = new OscMessage ("/ciclop/client");
      String msg = name+": "+currentMessage+remainder;
      myMessage.add(msg);
      oscChat.send(myMessage);
      lastMessage = currentMessage;
      currentMessage = "";
      remainder = "";
    }
    else
    {
      name = currentMessage;
      currentMessage = "";
      remainder = "";
      nameEntered = true;
    }
  } else if (keyCode==BACKSPACE)
  {
    currentMessage = currentMessage.substring(0, (int)max(currentMessage.length()-1, 0));
  } else if (keyCode==UP)
  {
    nextMessage = currentMessage;
    currentMessage=lastMessage;
  } else if (keyCode==DOWN)
  {
    lastMessage = currentMessage;
    currentMessage = nextMessage;
  } else if (keyCode==LEFT && currentMessage.length()>0)
  {
    remainder = currentMessage.substring((int)currentMessage.length()-1) + remainder;
    currentMessage = currentMessage.substring(0, currentMessage.length()-1);
  } else if (keyCode==RIGHT && remainder.length()>0)
  {
    currentMessage = currentMessage + remainder.substring(0, 1);
    remainder = remainder.substring(1, remainder.length());
  } else if (keyCode==DELETE)
  {
    nameEntered=false;
  } else if (key==CODED)
  {
    // do nothing
  }
  else
  {
    currentMessage+= key;
  }
  if (textWidth(name+": "+currentMessage)>width-15)
  {
    OscMessage myMessage = new OscMessage ("/ciclop/client");
    String msg = name+": "+currentMessage;
    myMessage.add(msg);
    oscChat.send(myMessage);
    lastMessage = currentMessage;
    currentMessage = "";
  }
}

public void oscEvent(OscMessage msg)
{
  if (msg.addrPattern().equals("/ciclop/server"))
  {
    String incoming = msg.get(0).stringValue();
    addToList(incoming);
  } else if (msg.addrPattern().equals("/clock"))
  {
    mins = msg.get(0).intValue();
    secs = msg.get(1).intValue();
    section = msg.get(2).intValue();
    elapsed = secs + 60*mins;
  }
}

public int timeToNext (int el)
{
  for (int i=0; i<section_times.length; i++)
  {
    if (section_times[i]-el > 0) return section_times[i]-el;
  }
  return 0;
}

public int section_index (int el)
{
  for (int i=0; i<section_times.length; i++)
  {
    if (el<section_times[i]) return i-1;
  }
  return 0;
}

public void addToList (String msg)
{
  int i;
  for (i=0; i<lines.length-1; i++)
  {
    lines[i] = lines[i+1];
  }
  lines[i] = msg;
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ciclop_chat_new" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
