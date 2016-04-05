Mover mover;
Cylinder cylinder;
void setup() {
  noStroke();
  mover = new Mover();
  cylinder = new Cylinder();
  size(500, 500, P3D);
}

float depth = 500;
float rZ=0, rX=0;
float tmp_rX=0, tmp_rZ=0;
float value=0;
float valueX, valueY;
float speed=100 ;

ArrayList<PVector> positions=new ArrayList<PVector>();

boolean gamePaused=false;
boolean putCylinder=false;
static final int bWIDTH = 200;
static final int bDEPTH = 200;
static final int bHEIGHT = 10;
void draw() {
  camera(width/2, height/2, depth, 250, 250, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, 1, 0);
  ambientLight(102, 102, 102);
  background(255);

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
    shape(cylinder.shapeC);
    popMatrix();
  } 
  pushMatrix();
  //translate the sphere up 
  translate(0, -15, 0);
  if (!gamePaused) {
    mover.update(rX, rZ);
    mover.checkCylinderCollision(positions);
    mover.checkEdges();
  }
  mover.display();
  popMatrix();
  popMatrix();
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
  if (checkBorders(mouseX - 150, mouseY - 150 )) {
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