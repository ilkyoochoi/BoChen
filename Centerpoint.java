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

ArrayList points;
ArrayList lines;

static final int DIAMETER = 8;
static final int WINDOW_WIDTH = 400;
static final int WINDOW_HEIGHT = 400;
static final int BUTTON_WIDTH = 25;
static final int BUTTON_HEIGHT = 25;
static final int GO_X = 375;
static final int GO_Y = 375;
static final int RESET_X = 0;
static final int RESET_Y = 375;
static final int BACKGROUND_COLOR = 255;
static final int DRAW_COLOR = 0;

public void setup() {
  size(400, 400);
  stroke(DRAW_COLOR);
  background(BACKGROUND_COLOR);
  rect(RESET_X, RESET_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(GO_X, GO_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  fill(DRAW_COLOR);
  points = new ArrayList();
  lines = new ArrayList();
}

public void reset() {
  stroke(BACKGROUND_COLOR);
  fill(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  stroke(DRAW_COLOR);
  rect(RESET_X, RESET_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(GO_X, GO_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  fill(DRAW_COLOR);
  
  points.clear();
  lines.clear();
}
		  
public void draw() {
}
     
public void mousePressed() {
  if (mouseX > GO_X && mouseY > GO_Y) {
    centerpoint();
  }
  else if(mouseX < RESET_X + BUTTON_WIDTH && mouseY > RESET_Y) {
    reset();
  }
  else {
    Point p = new Point(mouseX, mouseY);
    points.add(p);
    drawPoint(p);
  }
}

public void centerpoint() {
  int min = (points.size() + 2) / 3;
  Line top = new Line(new Point(0, 0), new Point(WINDOW_WIDTH, 0));
  Line bottom = new Line(new Point(0, WINDOW_HEIGHT), new Point(WINDOW_WIDTH, WINDOW_HEIGHT));
  Line left = new Line(new Point(0, 0), new Point(0, WINDOW_HEIGHT));
  Line right = new Line(new Point(WINDOW_WIDTH, 0), new Point(WINDOW_WIDTH, WINDOW_HEIGHT));
  for (int i = 0; i < points.size(); i++) {
    for (int j = i+1; j < points.size(); j++) {
      int count1 = 0;
      int count2 = 0;
      for (int k = 0; k < points.size(); k++) {
        if (isCCW((Point)points.get(i), (Point)points.get(j), (Point)points.get(k))) {
          count1++;
        }
        else if (isCCW((Point)points.get(j), (Point)points.get(i), (Point)points.get(k))) {
          count2++;
        }
        //lines.add(new Line((Point)points.get(i), (Point)points.get(j)));
        //line((long)((Point)points.get(i)).x, (long)((Point)points.get(i)).y, (long)((Point)points.get(j)).x, (long)((Point)points.get(j)).y);
      }
      Point a = (Point)points.get(i);
      Point b = (Point)points.get(j);
      boolean flipped = count2 < min;
      boolean inOrder = a.x < b.x;
      flipped = flipped == inOrder;
      
      long y1 = isInRange(a, b, 0);
      long y2 = isInRange(a, b, WINDOW_WIDTH);
      
      println("Point a is " + a.x + ", " + a.y + " and point b is " + b.x + ", " + b.y + " and y1 is " + y1 + " and y2 is " + y2 + " and count1 is " + count1 + " and count2 is " + count2);
      
      if (count1 >= min && count2 >= min) {
        continue;
      }
      
      if (count1 < min && count2 < min) {
        rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        return;
      }
      
      long xymax = (long)((WINDOW_HEIGHT - b.y) * (a.x - b.x) / (a.y - b.y) + b.x);
      long xymin = (long)((-b.y)*(a.x - b.x) / (a.y - b.y) + b.x);
      
      if (y1 >= 0 && y2 >= 0 && y1 <= WINDOW_HEIGHT && y2 <= WINDOW_HEIGHT) {
        if (flipped) {
          quad(0, y1, 0, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, y2);
        }
        else {
          quad(0, y1, 0, 0, WINDOW_WIDTH, 0, WINDOW_WIDTH, y2);
        }
      }
      else if (y1 >= 0 && y1 <= WINDOW_HEIGHT) {
        if (y2 > WINDOW_HEIGHT) {
          if (flipped) {
            triangle(0, y1, 0, WINDOW_HEIGHT, xymax, WINDOW_HEIGHT);
          }
          else {
            quad(0, y1, 0, 0, WINDOW_WIDTH, 0, xymax, WINDOW_HEIGHT);
            triangle(xymax, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, 0);
          }
        }
        else {
          if (flipped) {
            quad(0, y1, 0, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, 0);
            triangle(0, y1, WINDOW_WIDTH, 0, xymin, 0);
          }
          else {
            triangle(0, y1, 0, 0, xymin, 0);
          }
        }
      }
      else if (y1 > WINDOW_HEIGHT){
        if (y2 >= 0 && y2 <= WINDOW_HEIGHT) {
          if (flipped) {
            triangle(xymax, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, y2);
          }
          else {
            quad(0, WINDOW_HEIGHT, 0, 0, WINDOW_WIDTH, 0, xymax, WINDOW_HEIGHT);
            triangle(xymax, WINDOW_HEIGHT, WINDOW_WIDTH, 0, WINDOW_WIDTH, y2);
          }
        }
        else if (y2 < 0) {
          if (flipped) {
            quad(WINDOW_WIDTH, 0, WINDOW_WIDTH, WINDOW_HEIGHT, xymax, WINDOW_HEIGHT, xymin, 0);
          }
          else {
            quad(0, WINDOW_HEIGHT, 0, 0, xymin, 0, xymax, WINDOW_HEIGHT);
          }
        }
        else {
          println("DANGER DANGER!!!1");
        }
      }
      else if (y1 < 0) {
        if (y2 >= 0 && y2 <= WINDOW_HEIGHT) {
          if (flipped) {
            quad(WINDOW_WIDTH, y2, WINDOW_WIDTH, WINDOW_HEIGHT, 0, WINDOW_HEIGHT, 0, 0);
            triangle(0, 0, WINDOW_WIDTH, y2, xymin, 0);
          }
          else {
            triangle(WINDOW_WIDTH, y2, WINDOW_WIDTH, 0, xymin, 0);
          }
        }
        else if (y2 > WINDOW_HEIGHT) {
          if (flipped) {
            quad(0, 0, 0, WINDOW_HEIGHT, xymax, WINDOW_HEIGHT, xymin, 0);
          }
          else {
            quad(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, 0, xymin, 0, xymax, WINDOW_HEIGHT);
          }
        }
        else {
          println("DANGER DANGER!!!2");
        }
      }
      else {
        println("DANGER DANGER!!!3");
      }
    }
  }
}

public long isInRange(Point a, Point b, long x) {
  return (long)((a.y - b.y) * (x - b.x) / (a.x - b.x) + b.y);
}

public void drawPoint(Point p) {
  ellipse((long)p.x, (long)p.y, DIAMETER, DIAMETER);
}

public boolean isCCW(Point a, Point b, Point c) {
  return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y) < 0;
}

class Point {
  double x,y;
  
  Point (double x, double y) {
    this.x = x;
    this.y = y;
  }
}

class Line {
  Point a,b;
  
  Line (Point a, Point b) {
    this.a = a;
    this.b = b;
  }
  
  public Point getIntersect(Line otherLine) {
    return new Point(
    ((a.x*b.y - a.y*b.x)*(otherLine.a.x - otherLine.b.x) - (a.x - b.x)*(otherLine.a.x*otherLine.b.y - otherLine.a.y*otherLine.b.x)) /
    ((a.x - b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x - otherLine.b.x)),
    ((a.x*b.y - a.y*b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x*otherLine.b.y - otherLine.a.y*otherLine.b.x)) /
    ((a.x - b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x - otherLine.b.x)));
  }
  
  public boolean isParallel(Line otherLine) {
    return (b.y - a.y)*(otherLine.b.x - otherLine.a.x) == (b.x - a.x)*(otherLine.b.y - otherLine.a.y);
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#ECE9D8", "Centerpoint" });
  }
}
