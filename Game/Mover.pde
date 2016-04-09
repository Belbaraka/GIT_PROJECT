class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  float constantG = 0.21;
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
    checkCylinderCollision();
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
    checkEdges();
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

  void checkCylinderCollision() {
    for (PVector Cylinder : positions) {
      float dist = PVector.dist(Cylinder, location);

      //collision
      if (dist < cylinderBaseSize + sphereRad) {
        PVector n = PVector.sub(Cylinder, location);
        n.normalize();
        n.mult(2 * velocity.dot(n));
        velocity = PVector.sub(velocity, n);
        location.add(velocity);
      }
    }
  }
}