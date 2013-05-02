import oscP5.*;
import netP5.*;
OscP5 oscP5;
int mins, secs, section =0;
PFont font;
char[] characterSet = {
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':'
};
int startTime = 0;
boolean running = false;
boolean flash = false;
boolean listening = true;
boolean rcvdNetworkData = false;
float h;

void setup()
{
  oscP5 = new OscP5(this, 26499);
  size(400, 300);
  if (frame != null) {
    frame.setResizable(true);
  }
  font=createFont("sans_serif", width/4, true, characterSet);
  textFont(font);
  stroke(255);
  fill(255);
  textAlign(CENTER);
  frameRate(4);
}

void draw()
{
  h = textAscent();
  if (flash)
  {
    background(255);
    flash = false;
    fill(0);
  }
  else
  {
    background(0);
    fill(255);
  }
  if (running)
  {
    int currentTime = (millis()-startTime)/1000;
    mins = currentTime/60;
    secs = currentTime%60;
  }
  textAlign(CENTER);
  textSize(width/3);
  fill(0, 255, 255);
  //text(section,width*0.1,h*1.1);
  text(mins+":"+nf(secs, 2, 0), width/2, height*2/3);
  fill(200);
  fill(170);
  textSize(width/16);
  text("total elapsed", width/2, height/6);
  textAlign(CENTER);
  text("section "+nf(section, 2, 0), width/2, height*4/5);
  textSize(width/8);
}

void oscEvent (OscMessage msg)
{
  rcvdNetworkData = true;
  if (listening && msg.addrPattern().equals("/clock"))
  {
    mins = msg.get(0).intValue();
    secs = msg.get(1).intValue();
    section = msg.get(2).intValue();

    if (running)
    {
      running=false;
      flash=true;
    }
  }
}

void keyPressed()
{
  if (key==' ')
  {
    listening=true;
  }
  if (key=='p')
  {
    flash=true;
    running = !running;
    if (running)
    {
      startTime = millis();
    }
    if (rcvdNetworkData) listening=false;
  }
}

