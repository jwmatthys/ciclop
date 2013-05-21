import oscP5.*;
import netP5.*;

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

void setup()
{
  size(400, 200);
  smooth();
  oscClock = new OscP5(this, 26499);
  oscChat = new OscP5(this, "joel-hp-dv6.local", 13032, OscP5.TCP);
  //font = createFont("sans_serif", 60, true);
  noStroke();
  fill(255, 255, 0);
  frameRate(10);
  lines = new String[9];
  for (int i=0; i<lines.length; i++) lines[i]="";
  mins = 0;
  secs = 0;
  section = 0;
}

void draw()
{
  background(0, 0, 64);
  if (nameEntered)
  {
    textAlign(RIGHT);
    textSize(48);
    String time = nf(mins,2,0)+":"+nf(secs,2,0);
    text(time,width-10,50);
    textAlign(LEFT);
    textSize(16);
    stroke(128);
    line(0, height-30, width, height-30);
    noStroke();
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

void keyPressed()
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
  }
  else if (keyCode==BACKSPACE)
  {
    currentMessage = currentMessage.substring(0, (int)max(currentMessage.length()-1, 0));
  }
  else if (keyCode==UP)
  {
    nextMessage = currentMessage;
    currentMessage=lastMessage;
  }
  else if (keyCode==DOWN)
  {
    lastMessage = currentMessage;
    currentMessage = nextMessage;
  }
  else if (keyCode==LEFT && currentMessage.length()>0)
  {
    remainder = currentMessage.substring((int)currentMessage.length()-1) + remainder;
    currentMessage = currentMessage.substring(0, currentMessage.length()-1);
  }
  else if (keyCode==RIGHT && remainder.length()>0)
  {
    currentMessage = currentMessage + remainder.substring(0,1);
    remainder = remainder.substring(1,remainder.length());
  }
  else if (keyCode==DELETE)
  {
    nameEntered=false;
  }
  else if (key==CODED)
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

void oscEvent(OscMessage msg)
{
  if (msg.addrPattern().equals("/ciclop/server"))
  {
    String incoming = msg.get(0).stringValue();
    addToList(incoming);
  }
  else if (msg.addrPattern().equals("/clock"))
  {
    mins = msg.get(0).intValue();
    secs = msg.get(1).intValue();
    section = msg.get(2).intValue();
  }
}

void addToList (String msg)
{
  int i;
  for (i=0; i<lines.length-1; i++)
  {
    lines[i] = lines[i+1];
  }
  lines[i] = msg;
}

