import processing.core.PGraphics;
import processing.core.PImage;
import processing.video.Capture;
import java.util.Collections;
import java.util.Random;

PImage img, resImg, currentImg;
boolean use = true;
int maxLines = 4;
Capture cam;
int min, max;
QuadGraph quad1=new QuadGraph();

public void setup() {
  size(2200, 600);
  if (use) {
    currentImg = loadImage("board1.jpg");
  } else {
    setupCamera();
  }
}

public void setupCamera() {
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}

public PImage getImage() {
  if (use) {
    return currentImg;
  }
  else if (cam.available() == true) {
    println("camera available");
    cam.read();
    return cam.get();
  } else {
    println("camera not available");
    exit();
    return null;
  }
}

public void draw() {
  ArrayList<PVector> lines = new ArrayList<PVector>();
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  img = getImage();
  if (img == null) {
    exit();
  }
  background(color(0, 0, 0));

  resImg = hueThreshold(img, 80, 140);
  resImg = brightnessThreshold(resImg, 40);
  resImg = saturationThreshold(resImg, 100);
  resImg = blurring(resImg);
  resImg = intensityThreshold(resImg, 170);
  resImg = sobel(resImg);

  image(img, 0, 0);
  
  PImage houghImg = hough(resImg, lines);
  image(houghImg, 800, 0);
  intersections = getIntersections(lines);
  
  ArrayList<PVector[]> quads = computeQuads(lines);
  
  for (PVector[] quad : quads) {
    Random random = new Random();
    fill(color(min(255, random.nextInt(300)),
               min(255, random.nextInt(300)),
               min(255, random.nextInt(300)), 50));
               
    quad(quad[0].x,quad[0].y,quad[1].x,quad[1].y,quad[2].x,quad[2].y,quad[3].x,quad[3].y);
  }
  
  if (quads.size() > 0) {
    PVector[] quad = quads.get(0);
    for (PVector intersection : quad) {
      fill(255, 128, 0);
      ellipse(intersection.x, intersection.y, 10, 10);  
    }
  } else {
    for (PVector intersection : getIntersections(lines)) {
      fill(255, 128, 0);
      ellipse(intersection.x, intersection.y, 10, 10);  
    }
  }
  
  
  image(resImg, 800 + 600, 0);
  
  if (use) {
     noLoop(); 
  }
}

public ArrayList<PVector[]> computeQuads(ArrayList<PVector> lines) {
  QuadGraph graph = new QuadGraph();
  graph.build(lines, 800, 600);
  
  ArrayList<int[]> quads = (ArrayList<int[]>)graph.findCycles();
  ArrayList<PVector[]> resQuads = new ArrayList<PVector[]>();
  
  for (int[] quad : quads) {
    PVector l1 = lines.get(quad[0]);
    PVector l2 = lines.get(quad[1]);
    PVector l3 = lines.get(quad[2]);
    PVector l4 = lines.get(quad[3]);
    
    PVector c12 = intersection(l1, l2);
    PVector c23 = intersection(l2, l3);
    PVector c34 = intersection(l3, l4);
    PVector c41 = intersection(l4, l1);
    
    if (quad1.isConvex(c12, c23, c34, c41) &&
       quad1.validArea(c12, c23, c34, c41, 1000000, 50000) &&
        quad1.nonFlatQuad(c12, c23, c34, c41)) {
          PVector[] validQuad = {c12, c23, c34, c41};
            resQuads.add(validQuad);
    }
  } 
  
  return resQuads;
}

public PImage hueThreshold(PImage img, int hueMin, int hueMax) {
  PImage resImg = createImage(img.width, img.height, RGB); 
  for (int i = 0; i < img.width * img.height; i++) {
    if (hue(img.pixels[i])>hueMin && hue(img.pixels[i])<hueMax) {
      resImg.pixels[i]= img.pixels[i];
    } else {
      resImg.pixels[i]=0;
    }
  } 
  return resImg;
}

public PImage brightnessThreshold(PImage img, int brightness) {
  PImage resImg = createImage(img.width, img.height, RGB); 
  for (int i = 0; i < img.width * img.height; i++) {
    if (brightness(img.pixels[i])>brightness) {
      resImg.pixels[i]= img.pixels[i];
    } else {
      resImg.pixels[i]=0;
    }
  } 
  return resImg;
}

public PImage saturationThreshold(PImage img, int saturation) {
  PImage resImg = createImage(img.width, img.height, RGB);
  for (int i = 0; i < img.width * img.height; i++) {
    if (saturation(img.pixels[i])>saturation) {
      resImg.pixels[i]= color(255, 255, 255);
    } else {
      resImg.pixels[i]=0;
    }
  } 
  return resImg;
}

public PImage intensityThreshold(PImage img, float minIntensity) {
   PImage resImg = createImage(img.width, img.height, ALPHA);
   for (int i = 0; i < img.width * img.height; i++) {
    float intensity = 0.2989*red(img.pixels[i]) + 0.5870*green(img.pixels[i]) + 0.1140*blue(img.pixels[i]);
    if (intensity>minIntensity) {
      resImg.pixels[i]= color(255, 255, 255); 
    } else {
      resImg.pixels[i]= 0;
    }
  } 
  return resImg;
}

public PImage blurring(PImage target) {
  float[][] kernel = { 
    {  9, 12,  9 }, 
    { 12, 15, 12 }, 
    {  9, 12,  9 }
  };
  
  return applyKernel(target, kernel);
}

public PImage applyKernel(PImage target, float[][] kernel) {
   PImage resImg = createImage(target.width, target.height, ALPHA);
  int n = kernel.length / 2;
  for (int i=n; i< target.height-n; i++) {
    for (int j = n; j< target.width-n; j++) {
      float sumR = 0;
      float sumG = 0;
      float sumB = 0;
      float weight = 0.0f;
      for (int k=-n; k <= n; k++) {
        for (int l=-n; l <= n; l++) {
          sumR += (red(  target.get(j+k, i+l)) * kernel[k+n][l+n]);
          sumG += (green(target.get(j+k, i+l)) * kernel[k+n][l+n]);
          sumB += (blue( target.get(j+k, i+l)) * kernel[k+n][l+n]);
          weight += kernel[k+n][l+n];
        }
      }
      sumR = sumR / weight;
      sumG = sumG / weight;
      sumB = sumB / weight;

      resImg.pixels[i*resImg.width + j]= color(sumR, sumG, sumB);
    }
  }
  return resImg;
}

public PImage sobel(PImage img) {
  float[][] hKernel = { 
    { 
      0, 1, 0
    }
    , 
    { 
      0, 0, 0
    }
    , 
    { 
      0, -1, 0
    }
  };
  float[][] vKernel = { 
    { 
      0, 0, 0
    }
    , 
    { 
      1, 0, -1
    }
    , 
    { 
      0, 0, 0
    }
  };

  PImage resImg = createImage(img.width, img.height, ALPHA);
  for (int i = 0; i < img.width * img.height; i++) {
    resImg.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];

  for (int y = 2; y < img.height - 2; y++) { 
    for (int x = 2; x < img.width - 2; x++) { 
      float sum_h, sum_v;
      sum_h =0;
      sum_v =0;
      int sum=0;
      for (int k=- 1; k< 2; k++) {
        for (int l=- 1; l<2; l++) {
          sum_h+=(img.get(x+l, y+k)*hKernel[k+1][l+1]);
          sum_v+=(img.get(x+l, y+k)*vKernel[k+1][l+1]);
        }
      }
      sum = (int)sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      if (sum>max) {
        max=sum;
      }
      buffer[y*img.width+x] =sum;
    }
  }

  for (int y = 2; y < img.height - 2; y++) { 
    for (int x = 2; x < img.width - 2; x++) { 
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { 
        resImg.pixels[y * img.width + x] = color(255);
      } else {
        resImg.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return resImg;
}

public PImage hough(PImage edgeImg, ArrayList<PVector> lines) {
  float discretizationStepsPhi = 0.04f;
  float discretizationStepsR = 2.5f;

  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }

  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {

      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        float phi =0;
        for (int i =0; i<phiDim; i++) {
          int phiIndex= Math.round(phi/discretizationStepsPhi);
          double r = x*tabCos[phiIndex]+y*tabSin[phiIndex];
          int rIndex = Math.round((float)(r)+(rDim-1)/2);


          accumulator[(phiIndex+1)*(rDim+2)+rIndex+1] +=1;
          phi+= discretizationStepsPhi;
        }
      }
    }
  }

  int neighbourhood = 10;
  int minVotes = 200;
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if (accumulator[idx] < accumulator[neighbourIdx]) {
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          bestCandidates.add(idx);
        }
      }
    }
  }


  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  bestCandidates = new ArrayList<Integer>(bestCandidates.subList(0, Math.min(bestCandidates.size(), maxLines)));


  for (int idx = 0; idx < accumulator.length; idx++) {
    if (bestCandidates.contains(idx)) {

      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;

      lines.add(new PVector(r, phi));
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }


  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
   for (int i = 0; i < accumulator.length; i++) {
     houghImg.pixels[i] = color(min(255, accumulator[i]));
   }
   houghImg.updatePixels();
   houghImg.resize(600, 600);

  return houghImg;
}



public ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  for (int i = 0; i < lines.size () - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size (); j++) {
      PVector line2 = lines.get(j);
      intersections.add(intersection(line1, line2));
    }
  }
  return intersections;
}

public PVector intersection(PVector line1, PVector line2) {
  double d = Math.cos(line2.y)*Math.sin(line1.y) -Math.cos(line1.y)*Math.sin(line2.y);
  double x = (line2.x*Math.sin(line1.y)-line1.x*Math.sin(line2.y))/d;
  double y = (-line2.x*Math.cos(line1.y)+line1.x*Math.cos(line2.y))/d;
  
  return new PVector((float)x, (float)y);
}