ArrayList points;
ArrayList lines;
ArrayList leftPoints;
ArrayList rightPoints;
ArrayList topPoints;
ArrayList bottomPoints;
ArrayList topLeft;
ArrayList bottomLeft;
ArrayList topRight;
ArrayList bottomRight;

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
final int RED = color(255, 0, 0);
final int BLUE = color(0, 0, 255);
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
  topPoints = new ArrayList();
  bottomPoints = new ArrayList();
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
  topPoints.clear();
  bottomPoints.clear();
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
    //while (points.size() >= 10) {
      Line L = findL();
      line(L.a.x, L.a.y, L.b.x, L.b.y);
      Line hm1 = stretchLine(getHSC(leftPoints, rightPoints, 0.25, 0.375, ((points.size() + 2) / 3) - 1));
      stroke(RED);
      line(hm1.a.x, hm1.a.y, hm1.b.x, hm1.b.y);
      Line hm2 = stretchLine(getHSC(leftPoints, rightPoints, 0.75, 0.625, points.size() - ((points.size() - 1) / 3)));
      stroke(BLUE);
      line(hm2.a.x, hm2.a.y, hm2.b.x, hm2.b.y);
      Line hm3 = stretchLine(getHSC2(topPoints, bottomPoints, (points.size() / 12) - 1 , (points.size() / 12) - 1, ((points.size() + 2) / 3) - 1, hm1, hm2));
      stroke(REGION_COLOR);
      line(hm3.a.x, hm3.a.y, hm3.b.x, hm3.b.y);
    
      println(points.size() + " you happy now?");
      stroke(DRAW_COLOR);
    
      for (int i = 0; i < rightPoints.size(); i++) {
        if (!isCCW(hm3.a, hm3.b, (Point)rightPoints.get(i))) {
          rightPoints.remove(i--);
        }
      }
      
      //delay(3000);
      
      println(leftPoints.size() + " " + rightPoints.size() + " " + topPoints.size() + " " + bottomPoints.size());
      
      topLeft = getIntersection(leftPoints, topPoints);
      topRight = getIntersection(rightPoints, topPoints);
      bottomLeft = getIntersection(leftPoints, bottomPoints);
      bottomRight = getIntersection(rightPoints, bottomPoints);
    
      println(topLeft.size()+" "+topRight.size()+" "+bottomLeft.size()+" "+bottomRight.size());
      
      /*while (!(topLeft.isEmpty() || topRight.isEmpty() || bottomLeft.isEmpty() || bottomRight.isEmpty())) {
        radonKill(topLeft, topRight, bottomLeft, bottomRight);
      }
      leftPoints.clear();
      rightPoints.clear();
      topPoints.clear();
      bottomPoints.clear();
      stroke(BACKGROUND_COLOR);
      fill(BACKGROUND_COLOR);
      rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
      stroke(DRAW_COLOR);
      makeButtons();
      fill(DRAW_COLOR);
    }*/
  }
  else {
    Point p = new Point(mouseX, mouseY);
    points.add(p);
    drawPoint(p);
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

void removeHead(ArrayList a, ArrayList b, ArrayList c, ArrayList d) {
  points.remove(a.get(0));
  a.remove(a.get(0));
  points.remove(b.get(0));
  b.remove(b.get(0));
  points.remove(c.get(0));
  c.remove(c.get(0));
  if (d != null) {
    points.remove(d.get(0));
    d.remove(d.get(0));
  }
}

void radonKill(ArrayList topLeft, ArrayList topRight, ArrayList bottomLeft, ArrayList bottomRight) {
  Point a = (Point)topLeft.get(0);
  Point b = (Point)topRight.get(0);
  Point c = (Point)bottomLeft.get(0);
  Point d = (Point)bottomRight.get(0);
  boolean abc = isCCW(a, b, c);
  boolean abd = isCCW(a, b, d);
  boolean bcd = isCCW(b, c, d);
  boolean cad = isCCW(c, a, d);
  int ccwCount = (abd ? 1 : 0) + (bcd ? 1 : 0) + (cad ? 1 : 0);
  if (abc && ccwCount == 2) {
    if (!abd) {
      points.add(new Line(a, b).getIntersect(new Line(c, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (!bcd) {
      points.add(new Line(c, b).getIntersect(new Line(a, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (!cad) {
      points.add(new Line(a, c).getIntersect(new Line(b, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
  }
  else if (!abc && ccwCount == 1) {
    if (abd) {
      points.add(new Line(a, b).getIntersect(new Line(c, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (bcd) {
      points.add(new Line(c, b).getIntersect(new Line(a, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (cad) {
      points.add(new Line(a, c).getIntersect(new Line(b, d)));
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
  }
  else if ((ccwCount == 3 && abc) || (ccwCount == 0 && !abc)) {
      removeHead(topLeft, topRight, bottomLeft, null);
  }
  else if (abc) {
    if (abd) {
      removeHead(topLeft, topRight, bottomRight, null);
    }
    if (bcd) {
      removeHead(topRight, bottomLeft, bottomRight, null);
    }
    if (cad) {
      removeHead(topLeft, bottomLeft, bottomRight, null);
    }
  }
  else {
    if (!abd) {
      removeHead(topLeft, topRight, bottomRight, null);
    }
    if (!bcd) {
      removeHead(topRight, bottomLeft, bottomRight, null);
    }
    if (!cad) {
      removeHead(topLeft, bottomLeft, bottomRight, null);
    }
  }
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

ArrayList getIntersection(ArrayList list1, ArrayList list2) {
  ArrayList returnList = new ArrayList();
  for (int i = 0; i < list1.size(); i++) {
    if (list2.contains(list1.get(i))) {
      returnList.add(list1.get(i));
    }
  }
  return returnList;
}

void loadTopBottom(Line top, Line bottom) {
  // Why write a comparator when you can implement bubble sort?
  for (int i = 0; i < points.size(); i++) {
    for (int j = 0; j < points.size() - 1; j++) {
      if (((Point)points.get(j)).y > ((Point)points.get(j + 1)).y) {
        Object temp = points.get(j);
        points.set(j, points.get(j+1));
        points.set(j+1, temp);
      }
    }
  }
  
  // TODO: Sort line by coordinate
  for (int i = 0; i < points.size(); i++) {
    if (isCCW(top.a, top.b, (Point)points.get(i))) {
      topPoints.add(points.get(i));
    }
    else if (isCCW(bottom.b, bottom.a, (Point)points.get(i))) {
      bottomPoints.add(points.get(i));
    }
  }
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

Line getHSC(ArrayList leftPoints, ArrayList rightPoints, float leftRatio, float rightRatio, int topTarget) {
  ArrayList candidates = new ArrayList();
  int leftTarget = Math.max(Math.round(leftRatio * leftPoints.size()), 1);
  int rightTarget = Math.max(Math.round(rightRatio * rightPoints.size()), 1);
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
      if (Math.abs(leftCount - leftTarget) > 1) {
        if (leftTarget - leftCount == 2 && (leftPoints.contains(a) || leftPoints.contains(b))) {
          if (leftPoints.contains(a)) {
            shiftA = true;
          }
          else {
            shiftB = true;
          }
          leftCount++;
        }
        else if (leftTarget - leftCount == 3 && leftPoints.contains(a) && leftPoints.contains(b)) {
          shiftA = true;
          shiftB = true;
          leftCount += 2;
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
      if (Math.abs(rightCount - rightTarget) < 2 && topTarget == leftCount + rightCount) {
        a = new Point(a.x, shiftA ? a.y + EPSILON : a.y - EPSILON);
        b = new Point(b.x, shiftB ? b.y + EPSILON : b.y - EPSILON);
        candidates.add(new Line(a, b));
      }
      else if (rightTarget - rightCount == 2 && topTarget == leftCount + rightCount + 1 && (rightPoints.contains(a) || rightPoints.contains(b))) {
        a = new Point(a.x, rightPoints.contains(a) || shiftA ? a.y + EPSILON : a.y - EPSILON);
        b = new Point(b.x, rightPoints.contains(b) || shiftB ? b.y + EPSILON : b.y - EPSILON);
        candidates.add(new Line(a, b));
      }
      else if (rightTarget - rightCount == 3 && topTarget == leftCount + rightCount + 2 && rightPoints.contains(a) && rightPoints.contains(b)) {
        a = new Point(a.x, a.y + EPSILON);
        b = new Point(b.x, b.y + EPSILON);
        candidates.add(new Line(a, b));
      }
    }
  }
  
  if (candidates.isEmpty()) {
    println("OH NO THE HAM SANDWICH CUT BROKE!!!");
    return null;
  }
  
  Line firstLine = (Line)candidates.get(0);
  if (firstLine.b.y == firstLine.a.y) {
    return firstLine;
  }
  Line maxLine = firstLine;
  float maxSlope = Math.abs((firstLine.b.x - firstLine.a.x) / (firstLine.b.y - firstLine.a.y));
  for (int i = 1; i < candidates.size(); i++) {
    Line nextLine = (Line)candidates.get(i);
    if (maxSlope < Math.abs((nextLine.b.x - nextLine.a.x) / (nextLine.b.y - nextLine.a.y))) {
      maxSlope = Math.abs((nextLine.b.x - nextLine.a.x) / (nextLine.b.y - nextLine.a.y));
      maxLine = nextLine;
    }
  }
  return maxLine;
}

Line getHSC2(ArrayList leftPoints, ArrayList rightPoints, int leftTarget, int rightTarget, int topTarget, Line hm1, Line hm2) {
  ArrayList candidates = new ArrayList();
  loadTopBottom(hm1, hm2);
  for (int i = 0; i < points.size(); i++) {
    for (int j = i + 1; j < points.size(); j++) {
      Point a = (Point)points.get(i);
      Point b = (Point)points.get(j);
      Line testLine = new Line(a, b);
      Point x1 = hm1.getIntersect(testLine);
      Point x2 = hm2.getIntersect(testLine);
      if (!(x1.x >= 0 && x1.y >= 0 && x1.x <= WINDOW_WIDTH && x1.y <= WINDOW_HEIGHT && x2.x >= 0 && x2.y >= 0 && x2.x <= WINDOW_WIDTH && x2.y <= WINDOW_HEIGHT)) {
        continue;
      }
      boolean shiftA = false;
      boolean shiftB = false;
      int leftCount = 0;
      for (int k = 0; k < leftPoints.size(); k++) {
        if (isCCW(a, b, (Point)leftPoints.get(k))) {
          leftCount++;
        }
      }
      //println ("Target is " + leftTarget + " and left count is " + leftCount + " a " + leftPoints.contains(a) + " b " + leftPoints.contains(b));
      if (leftCount < leftTarget) {
        if (leftTarget - leftCount == 1 && (leftPoints.contains(a) || leftPoints.contains(b))) {
          if (leftPoints.contains(a)) {
            shiftA = true;
          }
          else {
            shiftB = true;
          }
          leftCount++;
        }
        else if (leftTarget - leftCount == 2 && leftPoints.contains(a) && leftPoints.contains(b)) {
          shiftA = true;
          shiftB = true;
          leftCount += 2;
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
      
      int midCount = 0;
      for (int k = 0; k < points.size(); k++) {
        Point aPoint = (Point)points.get(k);
        if (!leftPoints.contains(aPoint) && !rightPoints.contains(aPoint) && isCCW(a, b, aPoint)) {
          midCount++;
        }
      }
      //println ("Target is " + rightTarget + " and right count is " + rightCount + " a " + rightPoints.contains(a) + " b " + rightPoints.contains(b));
      if (rightCount >= rightTarget && topTarget >= leftCount + rightCount + midCount) {
        a = new Point(shiftA ? a.x - EPSILON : a.x + EPSILON, a.y);
        b = new Point(shiftB ? b.x - EPSILON : b.x + EPSILON, b.y);
        candidates.add(new Line(a, b));
      }
      else if (rightTarget - rightCount == 1 && topTarget >= leftCount + rightCount + midCount + 1 && (rightPoints.contains(a) || rightPoints.contains(b))) {
        a = new Point(rightPoints.contains(a) || shiftA ? a.x - EPSILON : a.x + EPSILON, a.y);
        b = new Point(rightPoints.contains(b) || shiftB ? b.x - EPSILON : b.x + EPSILON, b.y);
        candidates.add(new Line(a, b));
      }
      else if (rightTarget - rightCount == 2 && topTarget >= leftCount + rightCount + midCount + 2 && rightPoints.contains(a) && rightPoints.contains(b)) {
        a = new Point(a.x - EPSILON, a.y);
        b = new Point(b.x - EPSILON, a.y);
        candidates.add(new Line(a, b));
      }
    }
  }
  
  if (candidates.isEmpty()) {
    println("OH NO THE HAM SANDWICH CUT2 BROKE!!!");
    return null;
  }
  
  Line firstLine = (Line)candidates.get(0);
  if (firstLine.b.x == firstLine.a.x) {
    return firstLine;
  }
  Line maxLine = firstLine;
  float maxSlope = Math.abs((firstLine.b.y - firstLine.a.y) / (firstLine.b.x - firstLine.a.x));
  for (int i = 1; i < candidates.size(); i++) {
    Line nextLine = (Line)candidates.get(i);
    if (maxSlope < Math.abs((nextLine.b.y - nextLine.a.y) / (nextLine.b.x - nextLine.a.x))) {
      maxSlope = Math.abs((nextLine.b.y - nextLine.a.y) / (nextLine.b.x - nextLine.a.x));
      maxLine = nextLine;
    }
  }
  return maxLine;
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
