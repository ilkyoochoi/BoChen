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

final int DIAMETER = 8;
final int WINDOW_WIDTH = 400;
final int WINDOW_HEIGHT = 400;
final int BUTTON_WIDTH = 25;
final int BUTTON_HEIGHT = 25;
final int GO_X = WINDOW_WIDTH - BUTTON_WIDTH;
final int GO_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int RESET_X = 0;
final int RESET_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int BACKGROUND_COLOR = 255;
final int DRAW_COLOR = 0;
final int REGION_COLOR = color(0, 255, 0);

public void setup() {
  size(400, 400); // Export seems to only like magic numbers here.
  stroke(DRAW_COLOR);
  background(BACKGROUND_COLOR);
  makeButtons();
  fill(DRAW_COLOR);
  points = new ArrayList();
  lines = new ArrayList();
}

public void reset() {
  stroke(BACKGROUND_COLOR);
  fill(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  stroke(DRAW_COLOR);
  makeButtons();
  fill(DRAW_COLOR);
  points.clear();
  lines.clear();
}

public void makeButtons() {
  rect(RESET_X, RESET_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(GO_X, GO_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
}
		  
public void draw() {
}
     
public void mousePressed() {
  if (mouseX > GO_X && mouseY > GO_Y) {
    stroke(REGION_COLOR);
    fill(REGION_COLOR);
    rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    stroke(BACKGROUND_COLOR);
    fill(BACKGROUND_COLOR);
    centerpoint();
    stroke(DRAW_COLOR);
    makeButtons();
    fill(DRAW_COLOR);
    for (int i = 0; i < points.size(); i++) {
      drawPoint((Point)points.get(i));
      for (int j = i+1; j < points.size(); j++) {
        line(((Point)points.get(i)).x, ((Point)points.get(i)).y, ((Point)points.get(j)).x, ((Point)points.get(j)).y);
      }
    }
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
        //line(((Point)points.get(i)).x, ((Point)points.get(i)).y, ((Point)points.get(j)).x, ((Point)points.get(j)).y);
      }
      Point a = (Point)points.get(i);
      Point b = (Point)points.get(j);
      boolean flipped = count2 < min == a.x < b.x;      
      float y1 = isInRange(a, b, 0);
      float y2 = isInRange(a, b, WINDOW_WIDTH);
      float xymax = (WINDOW_HEIGHT - b.y) * (a.x - b.x) / (a.y - b.y) + b.x;
      float xymin = (-b.y)*(a.x - b.x) / (a.y - b.y) + b.x;
      
      //println("Point a is " + a.x + ", " + a.y + " and point b is " + b.x + ", " + b.y + " and y1 is " + y1 + " and y2 is " + y2 + " and count1 is " + count1 + " and count2 is " + count2);
      
      // Both half-spaces are acceptable, so continue iterating.
      if (count1 >= min && count2 >= min) {
        continue;
      }
      
      // Both half-spaces need to be removed.
      if (count1 < min && count2 < min) {
        rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        return;
      }
      
      // Dealing with all the cases for shaving off one half-space.
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

public float isInRange(Point a, Point b, int x) {
  return (a.y - b.y) * (x - b.x) / (a.x - b.x) + b.y;
}

public void drawPoint(Point p) {
  ellipse(p.x, p.y, DIAMETER, DIAMETER);
}

public boolean isCCW(Point a, Point b, Point c) {
  return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y) < 0;
}

class Point {
  float x,y;
  
  Point (float x, float y) {
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
