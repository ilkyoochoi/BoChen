import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Centerpoint extends PApplet {

public void setup() {
  size(400, 400);
  stroke(0);
  background(255);
}
		  
public void draw() {
}
     
public void mousePressed() {
  ellipse(mouseX, mouseY, 10, 10);
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#ECE9D8", "Centerpoint" });
  }
}
