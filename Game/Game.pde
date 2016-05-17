import java.util.Comparator;
import java.util.Collections;
import java.util.Random;
Mover mover;
Cylinder cylinder;

float depth = 100;
float rZ=0, rX=0;
float tmp_rX=0, tmp_rZ=0;
float value=0;
float valueX, valueY;
float speed=100 ;
float boardSize = 200;
float ballSize = 10;
int timeSinceLastEvent = 0;
HScrollbar hs;
int nbCurrentScore = 0;
ArrayList<PVector> positions=new ArrayList<PVector>();

boolean gamePaused=false;
boolean putCylinder=false;
static final int bWIDTH = 200;
static final int bDEPTH = 200;
static final int bHEIGHT = 10;
int nbScoreMax=0;
float[] scoreTable;
PImage img;
PImage sob;
PImage back;

ArrayList<int[]> cycles = new ArrayList<int[]>();
int[][] graph;

void setup() {
  size(1000, 700, P3D);
  noStroke();
  mover = new Mover();
  cylinder = new Cylinder();
  backgroundSurface = createGraphics(width, 150, P2D);
  topViewSurface = createGraphics(backgroundSurface.height - 10, backgroundSurface.height - 10, P2D);
  scoreSurface = createGraphics(120, backgroundSurface.height - 10, P2D);
  bottomRect = createGraphics(backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, backgroundSurface.height - 40, P2D);
  nbScoreMax = (int)(bottomRect.width/2);
  scoreTable = new float[nbScoreMax];
  hs = new HScrollbar(topViewSurface.width + scoreSurface.width +50, height - 40, backgroundSurface.width - topViewSurface.width - scoreSurface.width - 70, 20);
 
}

void draw() {
  
  pushMatrix();
  
  background(255);
  camera(width/2, height/2 - 20, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  translate(width/2, height/2, 0);
  
  popMatrix();

  pushMatrix();
  translate(width/2, height/2, 0); 
  rotateX(rX);
  rotateZ(rZ);
  rotateY(value);
  fill(234, 38, 50);
  box(bWIDTH, bHEIGHT, bDEPTH);

  for (int i = 0; i < positions.size (); i++) {
    PVector vector = positions.get(i);
    pushMatrix();
    //translate the cylinder up 
    translate(vector.x, -5, vector.z);
    cylinder.display();
    popMatrix();
  } 
  pushMatrix();
  //Translate the sphere up in the main board
  translate(0, -15, 0);
  if (!gamePaused) {
    mover.update(rX, rZ);
  }
  mover.display();
  popMatrix();
  popMatrix();
  
  drawBackgroundSurface();
  drawScoreSurface();
  drawBarChartSurface();
  drawTopViewSurface();
  image(backgroundSurface, 0, height - backgroundSurface.height);
  image(topViewSurface, 5, height-backgroundSurface.height+5);
  image(scoreSurface, topViewSurface.width + 20, height - scoreSurface.height - 5);
  image(bottomRect, topViewSurface.width + scoreSurface.width +50, height - scoreSurface.height - 5);
  
   hs.update();
   hs.display();
}


void mouseDragged() 
{
  if (!gamePaused) {
    float succ_rX = rX+ (valueY - mouseY)/speed;
    if (succ_rX>-PI/3 && succ_rX <PI/3) {
      rX =succ_rX;
    }
    float succ_rZ = rZ+ (mouseX - valueX)/speed;
    if (succ_rZ> -PI/3 && succ_rZ< PI/3) {
      rZ = succ_rZ;
    }

    valueX=mouseX;
    valueY=mouseY;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode==SHIFT) {
      gamePaused=true;
      putCylinder=true;
      tmp_rX=rX;
      tmp_rZ=rZ;
      rX=-PI/2;
      rZ=0;
    }
  }
}

void keyReleased() {
  if (gamePaused) {
    putCylinder=false;
    gamePaused=false;
    rX=tmp_rX;
    rZ=tmp_rZ;
  }
}
void putCylinder() {
  if (checkBorders(mouseX - 400, mouseY - 250)) {
    positions.add(new PVector((mouseX-width/2), 0, (mouseY-height/2)));
  }
}

boolean checkBorders(float x, float y) {
  if ((x > (bWIDTH-cylinderBaseSize/2)) || x < cylinderBaseSize/2) {
    return false;
  } else {
    return (y <= (bDEPTH-cylinderBaseSize/2)) && (y >= cylinderBaseSize/2);
  }
}


void mouseWheel(MouseEvent event) {
  if (event.getCount()>0 && speed<1000) {
    speed = speed*1.1;
  } else if (event.getCount()<0 && speed>10) {
    speed = speed*0.9;
  }
}

void mousePressed() {
  if (putCylinder) {
    putCylinder();
  } else {
    valueX = mouseX;
    valueY = mouseY;
  }
}