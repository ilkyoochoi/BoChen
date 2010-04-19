ArrayList points;
ArrayList lines;

static final int DIAMETER = 8;
static final int WINDOW_WIDTH = 400;
static final int WINDOW_HEIGHT = 400;
static final int BACKGROUND_COLOR = 255;
static final int DRAW_COLOR = 0;

void setup() {
  size(400, 400);
  stroke(DRAW_COLOR);
  background(BACKGROUND_COLOR);
  rect(0, 375, 25, 25);
  rect(375, 375, 25, 25);
  fill(DRAW_COLOR);
  points = new ArrayList();
  lines = new ArrayList();
}

void reset() {
  stroke(BACKGROUND_COLOR);
  fill(BACKGROUND_COLOR);
  rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
  stroke(DRAW_COLOR);
  rect(0, 375, 25, 25);
  rect(375, 375, 25, 25);
  fill(DRAW_COLOR);
  
  points.clear();
  lines.clear();
}
		  
void draw() {
}
     
void mousePressed() {
  if (mouseX > 375 && mouseY > 375) {
    centerpoint();
  }
  else if(mouseX < 25 && mouseY > 375) {
    reset();
  }
  else {
    points.add(new Point(mouseX, mouseY));
    ellipse(mouseX, mouseY, DIAMETER, DIAMETER);
  }
}

void centerpoint() {
  for (int i = 0; i < points.size(); i++) {
    for (int j = i+1; j < points.size(); j++) {
      lines.add(new Line((Point)points.get(i), (Point)points.get(j)));
      line((long)((Point)points.get(i)).x, (long)((Point)points.get(i)).y, (long)((Point)points.get(j)).x, (long)((Point)points.get(j)).y);
    }
  }
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
