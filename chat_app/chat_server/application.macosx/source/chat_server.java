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

public class chat_server extends PApplet {

/**
 * oscP5tcp by andreas schlegel
 * example shows how to use the TCP protocol with oscP5.
 * what is TCP? http://en.wikipedia.org/wiki/Transmission_Control_Protocol
 * in this example both, a server and a client are used. typically 
 * this doesnt make sense as you usually wouldnt communicate with yourself
 * over a network. therefore this example is only to make it easier to 
 * explain the concept of using tcp with oscP5.
 * oscP5 website at http://www.sojamo.de/oscP5
 */





OscP5 oscP5tcpServer;
NetAddressList clients;

public void setup()
{
  /* create  an oscP5 instance using TCP listening @ port 11000 */
  oscP5tcpServer = new OscP5(this, 13032, OscP5.TCP);
  clients = new NetAddressList();
}


public void draw()
{
}

public void oscEvent(OscMessage theMessage)
{
  /* check how many clients are connected to the server. */
  println(oscP5tcpServer.tcpServer().getClients().length);
  System.out.println("### got a message " + theMessage);
  if (theMessage.checkAddrPattern("/ciclop/client")) {
    /* message was send from the tcp client */
    OscMessage m = new OscMessage("/ciclop/server");
    m.add(theMessage.get(0).stringValue());
    /* server responds to the client's message */
    int clients = oscP5tcpServer.tcpServer().getClients().length;
    for (int i=0; i<clients; i++)
    {
      oscP5tcpServer.send(m, oscP5tcpServer.tcpServer().getClients()[i]);
    }
  }
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "chat_server" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
