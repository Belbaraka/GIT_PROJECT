class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  float constantG=0.21;
  float normalForce = 1;
  float mu = 0.1;
  float frictionMagnitude = normalForce * mu;
  PVector friction;
  float sphereRad = 10;

  Mover() {
    location = new PVector(0, 0, 0);
    velocity = new PVector(0, 0, 0);
    friction = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
  }

  void update(float rX, float rZ) {
    PVector friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    gravityForce.x = sin(rZ) * constantG;
    gravityForce.z = -sin(rX) * constantG;   
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
  }

  void display() {
    fill(26, 175, 87);
    translate(location.x, location.y, location.z);
    sphere(sphereRad);
  }
  void checkEdges() {

    if (location.x > 100) {
      velocity.x = -abs(velocity.x);
      location.x=bWIDTH/2;
    } else if (location.x < -100) {
      velocity.x = abs(velocity.x);
      location.x =-bWIDTH/2;
    }
    if (location.z > 100) {
      velocity.z = -abs(velocity.z);
      location.z= bDEPTH/2;
    } else if (location.z < -100) {
      velocity.z = abs(velocity.z);
      location.z=-bDEPTH/2;
    }
  }

  void checkCylinderCollision(ArrayList<PVector> positions) {
    for (int i=0; i< positions.size (); i++) {
      PVector positionCyl = positions.get(i);
      float distance = sqrt(pow((location.x-positionCyl.x), 2)+pow((location.z-positionCyl.z), 2));
      if (distance <= cylinderBaseSize + sphereRad) {
        PVector norm = PVector.sub(location, positionCyl).normalize();
        float scalar = PVector.dot(velocity, norm)*2;
        PVector vec = PVector.mult(norm, scalar);
        velocity = PVector.sub(velocity, vec);
        PVector nextPos = new PVector(location.x - positionCyl.x, location.y - positionCyl.y, 0).normalize();
        nextPos = PVector.mult(nextPos, 30); 
        location.x = positionCyl.x + nextPos.x;
        location.y = positionCyl.y + nextPos.y;
      }
    }
  }
}