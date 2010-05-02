/**
 *  Centerpoint
 *  
 *  This program demonstrates the linear-time algorithm for finding a centerpoint region.
 *
 *  4/30/2010
 *
 *  @author Bo Chen
 *  @author Ilkyoo Choi
 */


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
ArrayList oldPoints;

boolean runAlgo = false;
boolean findRadon = false;
boolean showRadon = false;
boolean addPoints = true;

String radonText = "Algo";
Line L;
Line hm1;
Line hm2;
Line hm3;

final int DIAMETER = 8;
final int WINDOW_WIDTH = 600;
final int WINDOW_HEIGHT = 600;
final int TEXT_HEIGHT = 12;
final int BUTTON_WIDTH = 36;
final int BUTTON_HEIGHT = 30;
final int RADON_X = WINDOW_WIDTH - BUTTON_WIDTH;
final int RADON_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int RESET_X = 0;
final int RESET_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int LINE_X = (WINDOW_WIDTH - 3 * BUTTON_WIDTH) / 2;
final int LINE_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int NOLINE_X = (WINDOW_WIDTH - BUTTON_WIDTH) / 2;
final int NOLINE_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int OLD_X = (WINDOW_WIDTH + BUTTON_WIDTH) / 2;
final int OLD_Y = WINDOW_HEIGHT - BUTTON_HEIGHT;
final int MIN_POINTS = 12;
final int BACKGROUND_COLOR = 255;
final int POINT_COLOR = 0;
final int LINE_COLOR = 150;
final int REGION_COLOR = color(0, 255, 0);
final int PURPLE = color(150, 0, 150);
final int RED = color(255, 0, 0);
final int BLUE = color(0, 0, 255);
final int TEAL = color(0, 150, 150);
final float EPSILON = 3;
final int MAX_INTEGER_YOU_CAN_PASS_TO_QUAD = 2147483583;

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

void setup() {
  points = new ArrayList();
  lines = new ArrayList();
  leftPoints = new ArrayList();
  rightPoints = new ArrayList();
  topPoints = new ArrayList();
  bottomPoints = new ArrayList();
  topLeft = new ArrayList();
  topRight = new ArrayList();
  bottomLeft = new ArrayList();
  bottomRight = new ArrayList();
  oldPoints = new ArrayList();
  
  size(600, 600); // Export seems to only like magic numbers here.
  smooth();
  stroke(POINT_COLOR);
  background(BACKGROUND_COLOR);
  makeButtons();
}

void reset() {
  points.clear();
  lines.clear();
  leftPoints.clear();
  rightPoints.clear();
  topPoints.clear();
  bottomPoints.clear();
  topLeft.clear();
  topRight.clear();
  bottomLeft.clear();
  bottomRight.clear();
  oldPoints.clear();
  radonText = "Algo";
  addPoints = true;
  
  fill(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  stroke(POINT_COLOR);
  makeButtons();
}

void makeButtons() {
  fill(BACKGROUND_COLOR);
  rect(0, WINDOW_HEIGHT - BUTTON_HEIGHT, WINDOW_WIDTH, BUTTON_HEIGHT);
  rect(RESET_X, RESET_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(RADON_X, RADON_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(LINE_X, LINE_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(NOLINE_X, NOLINE_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  rect(OLD_X, OLD_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
  
  fill(POINT_COLOR);
  text("Clear", RESET_X + 3, RESET_Y + (3 * BUTTON_HEIGHT / 4));
  text(radonText, RADON_X + 5, RADON_Y + (3 * BUTTON_HEIGHT / 4));
  text("Lines", LINE_X + 3, LINE_Y + (3 * BUTTON_HEIGHT / 4));
  text("None", NOLINE_X + 4, NOLINE_Y + (3 * BUTTON_HEIGHT / 4));
  text("Full", OLD_X + 8, OLD_Y + (3 * BUTTON_HEIGHT / 4));
}

void draw() {
  display("Welcome to centerpoints! v1.0", "Points: " + points.size() + ", Top-Left Points: " + topLeft.size() + ", Top-Right Points: "
    + topRight.size() + ", Bottom-Left Points: " + bottomLeft.size() + ", Bottom-Right Points: " + bottomRight.size());
  
  if (points.size() < MIN_POINTS) {
    runAlgo = false;
  }
  
  if (runAlgo) {
    stroke(BACKGROUND_COLOR);
    fill(BACKGROUND_COLOR);
    rect(0, 3 * TEXT_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT);
    stroke(POINT_COLOR);
    fill(POINT_COLOR);
    for (int i = 0; i < points.size(); i++) {
      drawPoint((Point)points.get(i));
    }
    
    delay(1000);
    
    if (radonText.equals("Done")) {
      runAlgo = false;
      drawCuts();
      makeButtons();
      return;
    }
    if (showRadon) {
      showRadon = false;
      drawCuts();
      makeButtons();
      return;
    }
    
    if (findRadon) {
      if (!(topLeft.isEmpty() || topRight.isEmpty() || bottomLeft.isEmpty() || bottomRight.isEmpty())) {
        stroke(LINE_COLOR);
        if (drawRadon(topLeft, topRight, bottomLeft, bottomRight)) {
          radonKill(topLeft, topRight, bottomLeft, bottomRight);
          showRadon = true;
        }
        stroke(POINT_COLOR);
      }
      else {
        findRadon = false;
        leftPoints.clear();
        rightPoints.clear();
        topPoints.clear();
        bottomPoints.clear();
      }
      drawCuts();
      makeButtons();
      return;
    }
    
    L = findL();
    hm1 = stretchLine(getHSC(leftPoints, rightPoints, 0.25, 0.375, ((points.size() + 2) / 3) - 1));
    hm2 = stretchLine(getHSC(leftPoints, rightPoints, 0.75, 0.625, points.size() - ((points.size() - 1) / 3)));
    hm3 = stretchLine(getHSC2(topPoints, bottomPoints, (points.size() / 12) - 1 , (points.size() / 12) - 1, ((points.size() + 2) / 3) - 1, hm1, hm2));
    drawCuts();
    makeButtons();
    
    Point hm3A = hm3.a;
    Point hm3B = hm3.b;
    if (hm3.a.y > hm3.b.y) {
      hm3A = hm3.b;
      hm3B = hm3.a;
    }
    for (int i = 0; i < rightPoints.size(); i++) {
      if (!isCCW(hm3A, hm3B, (Point)rightPoints.get(i))) {
        rightPoints.remove(i--);
      }
    }
    
    topLeft = getIntersection(leftPoints, topPoints);
    topRight = getIntersection(rightPoints, topPoints);
    bottomLeft = getIntersection(leftPoints, bottomPoints);
    bottomRight = getIntersection(rightPoints, bottomPoints);
    
    if (topLeft.isEmpty() || topRight.isEmpty() || bottomLeft.isEmpty() || bottomRight.isEmpty()) {
      radonText = "Done";
    }
    else {
      findRadon = true;
    }
  }
}
     
void mousePressed() {  
  if (mouseY < 3 * TEXT_HEIGHT) {
    return;
  }
  
  if (runAlgo) {
    return;
  }
  
  if (mouseX > LINE_X && mouseX < LINE_X + BUTTON_WIDTH && mouseY > LINE_Y && mouseY < LINE_Y + BUTTON_HEIGHT) {
    stroke(REGION_COLOR);
    fill(REGION_COLOR);
    rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    stroke(BACKGROUND_COLOR);
    fill(BACKGROUND_COLOR);
    centerpoint(points);
    
    stroke(POINT_COLOR);
    makeButtons();
    fill(POINT_COLOR);
    
    for (int i = 0; i < points.size(); i++) {
      drawPoint((Point)points.get(i));
        for (int j = i+1; j < points.size(); j++) {
          stroke(LINE_COLOR);
          drawLine(new Line((Point)points.get(i), (Point)points.get(j)));
          stroke(POINT_COLOR);
      }
    }
  }
  else if (mouseX > NOLINE_X && mouseX < NOLINE_X + BUTTON_WIDTH && mouseY > NOLINE_Y && mouseY < NOLINE_Y + BUTTON_HEIGHT) {
    stroke(REGION_COLOR);
    fill(REGION_COLOR);
    rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    stroke(BACKGROUND_COLOR);
    fill(BACKGROUND_COLOR);
    centerpoint(points);
    
    stroke(POINT_COLOR);
    makeButtons();
    fill(POINT_COLOR);
    
    for (int i = 0; i < points.size(); i++) {
      drawPoint((Point)points.get(i));
    }
  }
  else if (mouseX > OLD_X && mouseX < OLD_X + BUTTON_WIDTH && mouseY > OLD_Y && mouseY < OLD_Y + BUTTON_HEIGHT) {
    ArrayList oldList = oldPoints.isEmpty() ? points : oldPoints;
    
    stroke(RED);
    fill(RED);
    rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    stroke(BACKGROUND_COLOR);
    fill(BACKGROUND_COLOR);
    centerpoint(oldList);
    
    stroke(POINT_COLOR);
    makeButtons();
    fill(POINT_COLOR);
    
    for (int i = 0; i < points.size(); i++) {
      drawPoint((Point)points.get(i));
    }
  }
  else if (mouseX > RESET_X && mouseX < RESET_X + BUTTON_WIDTH && mouseY > RESET_Y && mouseY < RESET_Y + BUTTON_HEIGHT) {
    reset();
  }
  else if (mouseX > RADON_X && mouseX < RADON_X + BUTTON_WIDTH && mouseY > RADON_Y && mouseY < RADON_Y + BUTTON_HEIGHT) {
    if (points.size() >= MIN_POINTS) {
      runAlgo = true;
      addPoints = false;
      oldPoints.addAll(points);
    }
  }
  else if (mouseY < WINDOW_HEIGHT - BUTTON_HEIGHT) {
    if (addPoints) {
      Point p = new Point(mouseX, mouseY);
      points.add(p);
      drawPoint(p);
    }
  }
}

void drawCuts() {
  stroke(BLUE);
  drawLine(L);
  stroke(PURPLE);
  drawLine(hm1);
  stroke(RED);
  drawLine(hm2);
  stroke(TEAL);
  drawLine(hm3);
  stroke(POINT_COLOR);
}

boolean drawRadon(ArrayList a, ArrayList b, ArrayList c, ArrayList d) {
  Point p1 = (Point)a.get(0);
  Point p2 = (Point)b.get(0);
  Point p3 = (Point)c.get(0);
  Point p4 = (Point)d.get(0);
  
  if (p1.equals(p2)) {
    if (a.size() > b.size()) {
      a.remove(p1);
    }
    else {
      b.remove(p1);
    }
    return false;
  }
  else if (p1.equals(p3)) {
    if (a.size() > c.size()) {
      a.remove(p1);
    }
    else {
      c.remove(p1);
    }
    return false;
  }
  else if (p1.equals(p4)) {
    if (a.size() > d.size()) {
      a.remove(p1);
    }
    else {
      d.remove(p1);
    }
    return false;
  }
  else if (p2.equals(p3)) {
    if (b.size() > c.size()) {
      b.remove(p2);
    }
    else {
      c.remove(p2);
    }
    return false;
  }
  else if (p2.equals(p4)) {
    if (b.size() > d.size()) {
      b.remove(p2);
    }
    else {
      d.remove(p2);
    }
    return false;
  }
  else if (p3.equals(p4)) {
    if (c.size() > d.size()) {
      c.remove(p3);
    }
    else {
      d.remove(p3);
    }
    return false;
  }
  
  drawLine(new Line(p1, p2));
  drawLine(new Line(p1, p3));
  drawLine(new Line(p1, p4));
  drawLine(new Line(p2, p3));
  drawLine(new Line(p2, p4));
  drawLine(new Line(p3, p4));
  
  return true;
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
      Point newPoint = new Line(a, b).getIntersect(new Line(c, d));
      points.add(newPoint);
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (!bcd) {
      Point newPoint = new Line(c, b).getIntersect(new Line(a, d));
      points.add(newPoint);
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (!cad) {
      Point newPoint = new Line(a, c).getIntersect(new Line(b, d));
      points.add(newPoint);
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
  }
  else if (!abc && ccwCount == 1) {
    if (abd) {
      Point newPoint = new Line(a, b).getIntersect(new Line(c, d));
      points.add(newPoint);
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (bcd) {
      Point newPoint = new Line(c, b).getIntersect(new Line(a, d));
      points.add(newPoint);
      removeHead(topLeft, topRight, bottomLeft, bottomRight);
    }
    if (cad) {
      Point newPoint = new Line(a, c).getIntersect(new Line(b, d));
      points.add(newPoint);
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

void display(String line1, String line2) {
  fill(BACKGROUND_COLOR);
  stroke(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, 3 * TEXT_HEIGHT);
  stroke(POINT_COLOR);
  fill(POINT_COLOR);
  text(line1, 0, TEXT_HEIGHT);
  text(line2, 0, 2 * TEXT_HEIGHT);
}

void drawPoint(Point p) {
  ellipse(p.x, p.y, DIAMETER, DIAMETER);
}

void drawLine(Line l) {
  line(l.a.x, l.a.y, l.b.x, l.b.y);
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
  topPoints.clear();
  bottomPoints.clear();
  
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
  
  Point topA = top.a;
  Point topB = top.b;
  if (top.a.x > top.b.x) {
    topA = top.b;
    topB = top.a;
  }
  Point bottomA = bottom.a;
  Point bottomB = bottom.b;
  if (bottom.a.x > bottom.b.x) {
    bottomA = bottom.b;
    bottomB = bottom.a;
  }
  for (int i = 0; i < points.size(); i++) {
    if (isCCW(topA, topB, (Point)points.get(i))) {
      topPoints.add(points.get(i));
    }
    else if (isCCW(bottomB, bottomA, (Point)points.get(i))) {
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
  int leftTarget = round(leftRatio * leftPoints.size());
  int rightTarget = round(rightRatio * rightPoints.size());
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
      if (abs(leftCount - leftTarget) > 1) {
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
      if (abs(rightCount - rightTarget) < 2 && topTarget == leftCount + rightCount) {
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
    return null;
  }
  
  Line firstLine = (Line)candidates.get(0);
  if (firstLine.b.y == firstLine.a.y) {
    return firstLine;
  }
  Line maxLine = firstLine;
  float maxSlope = abs((firstLine.b.x - firstLine.a.x) / (firstLine.b.y - firstLine.a.y));
  for (int i = 1; i < candidates.size(); i++) {
    Line nextLine = (Line)candidates.get(i);
    if (maxSlope < abs((nextLine.b.x - nextLine.a.x) / (nextLine.b.y - nextLine.a.y))) {
      maxSlope = abs((nextLine.b.x - nextLine.a.x) / (nextLine.b.y - nextLine.a.y));
      maxLine = nextLine;
    }
  }
  return maxLine;
}

Line getHSC2(ArrayList topPoints, ArrayList bottomPoints, int topTarget, int bottomTarget, int rightTarget, Line hm1, Line hm2) {
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
      int topCount = 0;
      for (int k = 0; k < topPoints.size(); k++) {
        if (isCCW(a, b, (Point)topPoints.get(k))) {
          topCount++;
        }
      }
      if (topCount < topTarget) {
        if (topTarget - topCount == 1 && (topPoints.contains(a) || topPoints.contains(b))) {
          if (topPoints.contains(a)) {
            shiftA = true;
          }
          else {
            shiftB = true;
          }
          topCount++;
        }
        else if (topTarget - topCount == 2 && topPoints.contains(a) && topPoints.contains(b)) {
          shiftA = true;
          shiftB = true;
          topCount += 2;
        }
        else {
          continue;
        }
      }
      int bottomCount = 0;
      for (int k = 0; k < bottomPoints.size(); k++) {
        if (isCCW(a, b, (Point)bottomPoints.get(k))) {
          bottomCount++;
        }
      }
      
      int midCount = 0;
      for (int k = 0; k < points.size(); k++) {
        Point aPoint = (Point)points.get(k);
        if (!topPoints.contains(aPoint) && !bottomPoints.contains(aPoint) && isCCW(a, b, aPoint)) {
          midCount++;
        }
      }
      if (bottomCount >= bottomTarget && rightTarget >= topCount + bottomCount + midCount) {
        a = new Point(shiftA ? a.x - EPSILON : a.x + EPSILON, a.y);
        b = new Point(shiftB ? b.x - EPSILON : b.x + EPSILON, b.y);
        candidates.add(new Line(a, b));
      }
      else if (bottomTarget - bottomCount == 1 && rightTarget >= topCount + bottomCount + midCount + 1 && (bottomPoints.contains(a) || bottomPoints.contains(b))) {
        a = new Point(bottomPoints.contains(a) || shiftA ? a.x - EPSILON : a.x + EPSILON, a.y);
        b = new Point(bottomPoints.contains(b) || shiftB ? b.x - EPSILON : b.x + EPSILON, b.y);
        candidates.add(new Line(a, b));
      }
      else if (bottomTarget - bottomCount == 2 && rightTarget >= topCount + bottomCount + midCount + 2 && bottomPoints.contains(a) && bottomPoints.contains(b)) {
        a = new Point(a.x - EPSILON, a.y);
        b = new Point(b.x - EPSILON, a.y);
        candidates.add(new Line(a, b));
      }
    }
  }
  
  if (candidates.isEmpty()) {
    return null;
  }
  
  Line firstLine = (Line)candidates.get(0);
  if (firstLine.b.x == firstLine.a.x) {
    return firstLine;
  }
  Line maxLine = firstLine;
  float maxSlope = abs((firstLine.b.y - firstLine.a.y) / (firstLine.b.x - firstLine.a.x));
  for (int i = 1; i < candidates.size(); i++) {
    Line nextLine = (Line)candidates.get(i);
    if (maxSlope < abs((nextLine.b.y - nextLine.a.y) / (nextLine.b.x - nextLine.a.x))) {
      maxSlope = abs((nextLine.b.y - nextLine.a.y) / (nextLine.b.x - nextLine.a.x));
      maxLine = nextLine;
    }
  }
  return maxLine;
}

void centerpoint(ArrayList points) {
  int min = (points.size() + 2) / 3;
  for (int i = 0; i < points.size(); i++) {
    for (int j = i+1; j < points.size(); j++) {
      int count1 = 0;
      int count2 = 0;
      Point a = (Point)points.get(i);
      Point b = (Point)points.get(j);
      if (a.y < b.y || (a.y == b.y && a.x > b.x)) {
        Point temp = a;
        a = b;
        b = temp;
      }
      for (int k = 0; k < points.size(); k++) {
        if (isCCW(a, b, (Point)points.get(k))) {
          count1++;
        }
        else if (isCCW(b, a, (Point)points.get(k))) {
          count2++;
        }
      }
      
      Line halfSpaceLine = stretchLine(new Line(a, b));
      a = halfSpaceLine.a;
      b = halfSpaceLine.b;
      if (a.y < b.y || (a.y == b.y && a.x > b.x)) {
        b = a;
        a = halfSpaceLine.b;
      }
      
      // Both half-spaces are acceptable, so continue iterating.
      if (count1 >= min && count2 >= min) {
        continue;
      }
      
      // Both half-spaces need to be removed.
      if (count1 < min && count2 < min) {
        rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
        return;
      }
      
      boolean flipped = count2 < min;
      
      if (a.y == b.y) {
        if (flipped) {
         rect(0, a.y, WINDOW_WIDTH, WINDOW_HEIGHT);
        }
        else {
          rect(0, 0, WINDOW_WIDTH, a.y);
        }
      }
      else if (!flipped) {
        quad(Float.MIN_VALUE, 0, Float.MIN_VALUE, WINDOW_HEIGHT, a.x, a.y, b.x, b.y);
      }
      else {
        quad(MAX_INTEGER_YOU_CAN_PASS_TO_QUAD, 0, MAX_INTEGER_YOU_CAN_PASS_TO_QUAD, WINDOW_HEIGHT, a.x, a.y, b.x, b.y);
      }
    }
  }
}
