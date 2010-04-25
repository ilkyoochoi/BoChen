ArrayList points;
ArrayList lines;
ArrayList leftPoints;
ArrayList rightPoints;

final int DIAMETER = 8;
final int WINDOW_WIDTH = 400;
final int WINDOW_HEIGHT = 400;
final int BUTTON_WIDTH = 25;
final int BUTTON_HEIGHT = 25;
final int GO_X = WINDOW_WIDTH - BUTTON_WIDTH;
final int GO_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int RESET_X = 0;
final int RESET_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int TEST_X = (WINDOW_WIDTH - BUTTON_WIDTH) / 2;
final int TEST_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int BACKGROUND_COLOR = 255;
final int DRAW_COLOR = 0;
final int REGION_COLOR = color(0, 255, 0);
final float EPSILON = 3;

void setup() {
  size(400, 400); // Export seems to only like magic numbers here.
  stroke(DRAW_COLOR);
  background(BACKGROUND_COLOR);
  makeButtons();
  fill(DRAW_COLOR);
  points = new ArrayList();
  lines = new ArrayList();
  leftPoints = new ArrayList();
  rightPoints = new ArrayList();
}

void reset() {
  stroke(BACKGROUND_COLOR);
  fill(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  stroke(DRAW_COLOR);
  makeButtons();
  fill(DRAW_COLOR);
  points.clear();
  lines.clear();
  leftPoints.clear();
  rightPoints.clear();
}

void makeButtons() {
  rect(RESET_X, RESET_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(GO_X, GO_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(TEST_X, TEST_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
}
		  
void draw() {
}
     
void mousePressed() {
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
  else if (mouseX < RESET_X + BUTTON_WIDTH && mouseY > RESET_Y) {
    reset();
  }
  else if (mouseX > TEST_X && mouseX < TEST_X + BUTTON_WIDTH && mouseY > TEST_Y) {
    Line L = findL();
    line(L.a.x, L.a.y, L.b.x, L.b.y);
    Line hm1 = stretchLine(getHSC(0.25, 0.375));
    line(hm1.a.x, hm1.a.y, hm1.b.x, hm1.b.y);
    Line hm2 = stretchLine(getHSC(0.75, 0.625));
    line(hm2.a.x, hm2.a.y, hm2.b.x, hm2.b.y);
  }
  else {
    Point p = new Point(mouseX, mouseY);
    points.add(p);
    drawPoint(p);
  }
}

void centerpoint() {
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
      float xymax = xymax(a, b);
      float xymin = xymin(a, b);
      
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

float xymin(Point a, Point b) {
  return (-b.y)*(a.x - b.x) / (a.y - b.y) + b.x;
}

float xymax(Point a, Point b) {
  return (WINDOW_HEIGHT - b.y) * (a.x - b.x) / (a.y - b.y) + b.x;
}

float isInRange(Point a, Point b, int x) {
  return (a.y - b.y) * (x - b.x) / (a.x - b.x) + b.y;
}

Line stretchLine(Line shortLine) {
  if (shortLine.a.y == shortLine.b.y) {
    return new Line(new Point(0, shortLine.a.y), new Point(WINDOW_WIDTH, shortLine.a.y));
  }
  
  Line top = new Line(new Point(0, 0), new Point(WINDOW_WIDTH, 0));
  Line bottom = new Line(new Point(0, WINDOW_HEIGHT), new Point(WINDOW_WIDTH, WINDOW_HEIGHT));  
  return new Line(top.getIntersect(shortLine), bottom.getIntersect(shortLine));
}

void drawPoint(Point p) {
  ellipse(p.x, p.y, DIAMETER, DIAMETER);
}

boolean isCCW(Point a, Point b, Point c) {
  return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y) < 0;
}

Line findL() {
  // sorts point array the laziest way possible.
  for (int i = 0; i < points.size(); i++) {
    for (int j = 0; j < points.size() - 1; j++) {
      if (((Point)points.get(j)).x > ((Point)points.get(j + 1)).x) {
        Object temp = points.get(j);
        points.set(j, points.get(j+1));
        points.set(j+1, temp);
      }
    }
  }
  
  int firstRight = ((points.size() + 2) / 3) - 1;
  leftPoints.addAll(points);
  while (leftPoints.size() > firstRight) {
    leftPoints.remove(firstRight);
  }
  rightPoints.addAll(points);
  for (int i = 0; i < firstRight; i++) {
    rightPoints.remove(0);
  }
  float x = firstRight > 0 ? (((Point)points.get(firstRight)).x + ((Point)points.get(firstRight - 1)).x) / 2 : ((Point)points.get(firstRight)).x;
  
  return new Line(new Point(x, 0), new Point(x, WINDOW_HEIGHT));
}

Line getHSC(float leftRatio, float rightRatio) {
  int leftTarget = Math.round(leftRatio * leftPoints.size());
  int rightTarget = Math.round(rightRatio * rightPoints.size());
  for (int i = 0; i < points.size(); i++) {
    for (int j = i + 1; j < points.size(); j++) {
      Point a = (Point)points.get(i);
      Point b = (Point)points.get(j);
      boolean shiftA = false;
      boolean shiftB = false;
      int leftCount = 0;
      for (int k = 0; k < leftPoints.size(); k++) {
        if (isCCW(a, b, (Point)leftPoints.get(k))) {
          leftCount++;
        }
      }
      //println ("Target is " + leftTarget + " and left count is " + leftCount + " a " + leftPoints.contains(a) + " b " + leftPoints.contains(b));
      if (leftCount != leftTarget) {
        if (leftTarget - leftCount == 1 && (leftPoints.contains(a) || leftPoints.contains(b))) {
          if (leftPoints.contains(a)) {
            shiftA = true;
          }
          else {
            shiftB = true;
          }
        }
        else if (leftTarget - leftCount == 2 && leftPoints.contains(a) && leftPoints.contains(b)) {
          shiftA = true;
          shiftB = true;
        }
        else {
          continue;
        }
      }
      int rightCount = 0;
      for (int k = 0; k < rightPoints.size(); k++) {
        if (isCCW(a, b, (Point)rightPoints.get(k))) {
          rightCount++;
        }
      }
      //println ("Target is " + rightTarget + " and right count is " + rightCount + " a " + rightPoints.contains(a) + " b " + rightPoints.contains(b));
      if (rightCount == rightTarget) {
        a = new Point(a.x, shiftA ? a.y + EPSILON : a.y - EPSILON);
        b = new Point(b.x, shiftB ? b.y + EPSILON : b.y - EPSILON);
        return new Line(a, b);
      }
      else if (rightTarget - rightCount == 1 && (rightPoints.contains(a) || rightPoints.contains(b))) {
        a = new Point(a.x, rightPoints.contains(a) || shiftA ? a.y + EPSILON : a.y - EPSILON);
        b = new Point(b.x, rightPoints.contains(b) || shiftB ? b.y + EPSILON : b.y - EPSILON);
        return new Line(a, b);
      }
      else if (rightTarget - rightCount == 2 && rightPoints.contains(a) && rightPoints.contains(b)) {
        a = new Point(a.x, a.y + EPSILON);
        b = new Point(b.x, b.y + EPSILON);
        return new Line(a, b);
      }
    }
  }
  
  println("OH NO THE HAM SANDWICH CUT BROKE!!!");
  return null;
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
  
  Point getIntersect(Line otherLine) {
    return new Point(
      ((a.x*b.y - a.y*b.x)*(otherLine.a.x - otherLine.b.x) - (a.x - b.x)*(otherLine.a.x*otherLine.b.y - otherLine.a.y*otherLine.b.x)) /
      ((a.x - b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x - otherLine.b.x)),
      ((a.x*b.y - a.y*b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x*otherLine.b.y - otherLine.a.y*otherLine.b.x)) /
      ((a.x - b.x)*(otherLine.a.y - otherLine.b.y) - (a.y - b.y)*(otherLine.a.x - otherLine.b.x)));
  }
  
  boolean isParallel(Line otherLine) {
    return (b.y - a.y)*(otherLine.b.x - otherLine.a.x) == (b.x - a.x)*(otherLine.b.y - otherLine.a.y);
  }
}
