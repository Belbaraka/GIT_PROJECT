public static float cylinderBaseSize = 18;
public static float cylinderHeight = 20;
public static int cylinderResolution = 40;

class Cylinder {

  public PShape shapeC= new PShape();
  PShape openCylinder = new PShape();
  PShape topCylinder=new PShape();
  PShape bottomCylinder=new PShape();

  Cylinder() {

    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides

    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);

    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], 0, y[i]);
      openCylinder.vertex(x[i], -cylinderHeight, y[i]);
    }
    openCylinder.endShape();

    topCylinder= createShape();
     topCylinder.beginShape(TRIANGLES);
     for (int i=0; i< x.length-1; i++) {
     topCylinder.vertex(0, -cylinderHeight, 0);
     topCylinder.vertex(x[i], -cylinderHeight, y[i]);
     topCylinder.vertex(x[i+1], -cylinderHeight, y[i+1]);
     }
     topCylinder.endShape();
     
     bottomCylinder= createShape();
     bottomCylinder.beginShape(TRIANGLES);
     for (int i=0; i< x.length-1; i++) {
     bottomCylinder.vertex(0, 0, 0);
     bottomCylinder.vertex(x[i], 0, y[i]);
     bottomCylinder.vertex(x[i+1], 0, y[i+1]);
     }
     bottomCylinder.endShape();
     
     shapeC = createShape(GROUP);
     shapeC.addChild(openCylinder);
     shapeC.addChild(topCylinder);
     shapeC.addChild(bottomCylinder);
  }
}