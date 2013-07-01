/* @pjs preload="Yosemite.jpg"; */ 

// ================================================================
// Y'CbCr to RGB in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
//
// Feel free to use and share if you find it useful or interesting,
//                  a link would be appreciated, thanks ! :)
// ================================================================

PImage img, img_processed;
HScrollbar hs;
int[][] ycbcr;
float sat, new_sat;

void setup() {

  // Our picture is 640 pix wide
  size(320,496);
  noStroke();
  
  // Define a new scrollbar
  hs = new HScrollbar(0, height/2, width, 16, 4);

  // Load and display our initial image
  img = loadImage("Yosemite.jpg");
  image(img, 0, 0, img.width/2, img.height/2); // Displays the original image from point (0,0), we downscale by 50%
  img.loadPixels(); // we load the pixels to be able to work on it

  // Compute Y'CbCr channels from the RGB picture, we do it only once
  ycbcr = get_ycbcr(img);

  frameRate(30);
}

void draw() {
  // We get new value from slider only if mouse is released
  if (hs.locked == false) {
    // Get new sat, between 0 (=0% color saturation, or Black and White), and 2 (=200% color saturation)
    new_sat = 2*hs.getPos()/width;
  }
  
  // If saturation is modified, we need to update the bottom picture
  // Saturation is passed as an argument to the Y'CbCr to RGB color conversion
  // Updated processed picture is then displayed in the bottom part of the sketch
  if (new_sat != sat) {
    sat = new_sat;
    img_processed = get_ycbcr_to_rgb(ycbcr, img.width, img.height, sat);
    image(img_processed, 0,img.height/2+16, img_processed.width/2, img_processed.height/2);
  }
  
  // Update and display slider
  hs.update();
  hs.display();
  stroke(0);
  line(0, height/2, width, height/2);
}


////////////////////////////
// HScrollbar Class, from processing.org
////////////////////////////

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}


