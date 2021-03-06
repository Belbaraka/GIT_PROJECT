PGraphics backgroundSurface;
PGraphics topViewSurface;
PGraphics scoreSurface;
PGraphics bottomRect;


void drawBackgroundSurface() { 
  backgroundSurface.noStroke();
  backgroundSurface.beginDraw();
  backgroundSurface.background(230, 225, 175);
  backgroundSurface.fill(230, 225, 175);
  backgroundSurface.rect(0, 0, backgroundSurface.width, backgroundSurface.height);
  backgroundSurface.endDraw();
}

void drawTopViewSurface() {
  topViewSurface.noStroke();
  topViewSurface.beginDraw();
  topViewSurface.background(6, 144, 255);
  float zoom = boardSize/topViewSurface.width;
  topViewSurface.fill(255, 0, 0);
  for (int i = 0; i < positions.size (); i ++) {
    float posX =  (boardSize/2 + positions.get(i).x) / zoom;
    float posZ = (boardSize/2 + positions.get(i).z) / zoom;
    topViewSurface.ellipse(posX, posZ, 2*cylinderBaseSize/zoom, 2*cylinderBaseSize/zoom);
  }

  float ballPosX = (mover.location.x + boardSize/2)/zoom; 
  float ballPosZ = (mover.location.z  + boardSize/2)/zoom;
  topViewSurface.fill(255,255, 0);
  topViewSurface.ellipse(ballPosX, ballPosZ,2*ballSize/zoom, 2*ballSize/zoom);
  topViewSurface.endDraw();
}

void drawScoreSurface() {

  scoreSurface.beginDraw();
  scoreSurface.stroke(255);
  scoreSurface.strokeWeight(4);
  scoreSurface.strokeJoin(ROUND);
  scoreSurface.fill(230, 225, 175);
  scoreSurface.rect(0, 0, scoreSurface.width, scoreSurface.height);
  scoreSurface.textSize(16);
  scoreSurface.fill(20, 130, 70);
  scoreSurface.textMode(SHAPE);
  scoreSurface.text("Total Score", 5, 17);
  scoreSurface.text(mover.score, 5, 32);
  scoreSurface.text("Velocity", 5, 62);
  scoreSurface.text(mover.velocity.mag(), 5, 77);
  scoreSurface.text("Last Score", 5, 107);
  scoreSurface.text(mover.lastScore, 5, 122);
  scoreSurface.endDraw();
}

void drawBarChartSurface() {  
  float rectWidth = pow(4.0, hs.getPos() + 0.5);
  float rectHeight = 4.0;

  if (millis() - timeSinceLastEvent >= 400) {
    bottomRect.beginDraw();
    bottomRect.background(255);

    timeSinceLastEvent = millis();
    nbCurrentScore ++;

    for (int i = nbScoreMax - 1; i > 0; i--) {
      scoreTable[i] = scoreTable[i-1];
    }
    scoreTable[0] = mover.score;

    bottomRect.fill(23);
    bottomRect.line(0, bottomRect.height/2, bottomRect.width, bottomRect.height/2);
    
    for (int i = 0; i < nbScoreMax; i++) {
      if (scoreTable[i] > 0) {
        bottomRect.fill(0, 255, 0);
        for (int j = 0; j < scoreTable[i]; j++) {
          bottomRect.rect(i * rectWidth, bottomRect.height - j * rectHeight - bottomRect.height/2 - rectHeight, rectWidth, rectHeight);
        }
      }
      else {
        bottomRect.fill(255, 0, 0);
        for (int j = 0; j > scoreTable[i]; j--) {
          bottomRect.rect(i * rectWidth, bottomRect.height - j * rectHeight - bottomRect.height/2, rectWidth, rectHeight);
        }
      }
    }

    bottomRect.endDraw();
  }
}