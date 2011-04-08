import controlP5.*;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myBroadcastLocation;
String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";
int numPlayers = 20;
int mouseDown = 0;
float[] x, y;
int clickStartTime;
ControlP5 controlP5;
public int ip1 = 0;
public int ip2 = 0;
public int ip3 = 0;
public int ip4 = 0;
public int player = 0;
ControlWindow controlWindow;
Controller add1, add2, add3, add4;
boolean showWindow = true;
boolean connected = false;
PFont font;
String serverMessage = "please select your player number";
String connectionMessage;

void setup() {
  size(800,630,P2D);
  frame.setResizable(true);
  smooth();
  cursor(ARROW);
  font = createFont("sanserif",24,true);
  controlP5 = new ControlP5(this);
  controlWindow = controlP5.addControlWindow("controlP5window",100,100,140,420);
  controlWindow.setBackground(color(40));
  Textlabel myTextlabel = controlP5.addTextlabel("label","CHOOSE YOUR PLAYER #",10,10);
  myTextlabel.setWindow(controlWindow);
  Radio r = controlP5.addRadio("radio",60,30);
  r.setWindow(controlWindow);
  r.add("1",1);
  r.add("2",2);
  r.add("3",3);
  r.add("4",4);
  r.add("5",5);
  r.add("6",6);
  r.add("7",7);
  r.add("8",8);
  r.add("9",9);
  r.add("10",10);
  r.add("11",11);
  r.add("12",12);
  r.add("13",13);
  r.add("14",14);
  r.add("15",15);
  r.add("16",16);
  r.add("17",17);
  r.add("18",18);
  r.add("19",19);
  r.add("20",20);
  add1 = controlP5.addNumberbox("ip1",0,20,360,20,14);
  add2 = controlP5.addNumberbox("ip2",0,45,360,20,14);
  add3 = controlP5.addNumberbox("ip3",0,70,360,20,14);
  add4 = controlP5.addNumberbox("ip4",0,95,360,20,14);
  add1.setWindow(controlWindow);
  add2.setWindow(controlWindow);
  add3.setWindow(controlWindow);
  add4.setWindow(controlWindow);
  Controller button = controlP5.addButton("manual connect",0,25,390,85,14);
  button.setWindow(controlWindow);
  button.setId(25);
  Textlabel dashedLine = controlP5.addTextlabel("dashedLine","----------------------",15,315);
  dashedLine.setWindow(controlWindow);
  Textlabel warning1 = controlP5.addTextlabel("label","ADVANCED SETUP",26,340);
  warning1.setWindow(controlWindow);
  oscP5 = new OscP5(this,12000);
  myBroadcastLocation = new NetAddress("0.0.0.0",32000);
  noStroke();
  smooth();
  connectionMessage = "not connected";
  clickStartTime = 0;
  oscP5.plug(this,"hose","hose/");
  oscP5.plug(this,"servMessage","smessage/");
}

void draw() {
  background(0);
  controlP5.draw();
  textFont(font);
  fill(255);
  textSize(18);
  textAlign(CENTER);
  text(serverMessage,width/2,height-9);
  textAlign(LEFT);
  text("player "+player,10,height-9);
  textAlign(RIGHT);
  text(connectionMessage,width-10,height-9);
  if (frameCount==10)
    controlP5.window("controlP5window").show();
  if (mouseDown==1)
    fill(0,255,0);
  else
    fill(255,0,0);
  if (connected&&mouseY<height-30)
    ellipse(mouseX, mouseY, 10,10);
  if (mouseDown==1)
  {
    OscMessage myMessage = new OscMessage("/mouse");
    myMessage.add(player);
    myMessage.add(float(mouseX)/width);
    myMessage.add(float(mouseY)/height);
    oscP5.send(myMessage, myBroadcastLocation);
  }
  stroke(255);
  line(0,height-30,width,height-30);
  noStroke();
}

void controlEvent(ControlEvent theEvent)
{
  if (theEvent.controller().id()==25)
  {
    String s = ip1+"."+ip2+"."+ip3+"."+ip4;
    println("host ip: "+s);
    myBroadcastLocation = new NetAddress(s,32000);
    OscMessage m = new OscMessage("/server/connect",new Object[0]);
    oscP5.flush(m,myBroadcastLocation);
    connected = true;
    connectionMessage = "manual connect...";
    noCursor();
  }
}

void mousePressed()
{
  clickStartTime = millis();
  mouseDown = 1;
  OscMessage myMessage = new OscMessage("/clickDown");
  myMessage.add(player);
  oscP5.send(myMessage, myBroadcastLocation);
}

void mouseReleased()
{
  mouseDown = 0;
  OscMessage myMessage = new OscMessage("/clickUp");
  myMessage.add(player);
  myMessage.add(millis()-clickStartTime);
  oscP5.send(myMessage, myBroadcastLocation);
}

void servMessage(String s)
{
  serverMessage = s;
  connectionMessage = "connected";
  if (s.equals("connecting"))
  {
    serverMessage = "please wait";
    connectionMessage = "connecting";
  }
  if (s.equals("disconnected"))
  {
    serverMessage = "goodbye";
    connectionMessage = "disconnected";
  }
}

void hose(String s)
{
  println("host ip: "+s);
  myBroadcastLocation = new NetAddress(s,32000);
  String[] pieces = split(s,".");
  add1.setValue(int(pieces[0]));
  add2.setValue(int(pieces[1]));
  add3.setValue(int(pieces[2]));
  add4.setValue(int(pieces[3]));
  controlWindow.hide();
  showWindow = false;
  OscMessage m = new OscMessage("/server/connect",new Object[0]);
  oscP5.flush(m,myBroadcastLocation);
  connected = true;
  noCursor();
}

void radio(int theID)
{
  player = theID;
}

void keyPressed() {
  OscMessage m;
  switch(key) {
    case(' '):
    showWindow = !showWindow;
    if (showWindow)
      controlP5.window("controlP5window").show();
    else
      controlP5.window("controlP5window").hide();
    break;
    case('q'):
    stop();
    break;
  }
}

void stop()
{
  OscMessage m = new OscMessage("/server/disconnect",new Object[0]);
  oscP5.flush(m,myBroadcastLocation);
  exit();
}

