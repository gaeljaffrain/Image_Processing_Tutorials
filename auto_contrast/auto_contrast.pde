/* @pjs preload="mont_aiguille_low.jpg"; */ 
/*
    Copyright 2013 Gael Jaffrain

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// ================================================================
// Y'CbCr to RGB in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
// ================================================================

PImage img, img_processed;
HScrollbar hs;
int[][] original_ycbcr, stretched_ycbcr;
int[] original_luma_hist, stretched_luma_hist;
float blkpercent, new_blkpercent;
int[] th;

void setup() {

  // Our picture is 640*428 pix. Scrollbar is 16pix high. 428*2+16=872pix
  size(640,872);
  noStroke();
  
  // Define a new scrollbar
  hs = new HScrollbar(0, height/2, width, 16, 4);

  // Load and display our initial image
  img = loadImage("mont_aiguille_low.jpg");
  image(img, 0, 0, img.width,img.height); // Displays the original image from point (0,0)
  img.loadPixels(); // we load the pixels to be able to work on it

  // Compute Y'CbCr channels from the RGB picture, we do it only once
  original_ycbcr = get_ycbcr(img);
  original_luma_hist = get_hist(original_ycbcr[0]);
  stroke(0);
  draw_hist(original_luma_hist,10,100,100);

  frameRate(30);
}

void draw() {
  // We get new value from slider only if mouse is released
  if (hs.locked == false) {
    // Get new black %, between 0 (=no histogram stretch, and 10 (=4% of black pixels requested in final picture)
    new_blkpercent = 4*(hs.getPos()-1)/(width-2);
  }
  
  // If black % is modified, we need to get new stretch points by histogram analysis
  // Then we need to stretch the luma channel
  // Updated processed picture is finally displayed in the bottom part of the sketch
  if (new_blkpercent != blkpercent) {
    blkpercent = new_blkpercent;
    

    // Get new stretch points
    th = get_threshold_hist(original_luma_hist, blkpercent, 0, img.height*img.width);

    // Stretch Luma
    stretched_ycbcr = get_stretched_luma(original_ycbcr, img.width, img.height, th[0], th[1]);

    
    // Recreate RGB
    img_processed = get_ycbcr_to_rgb(stretched_ycbcr, img.width, img.height, 1);
    image(img_processed,0,img.height+16);
    
    // Draw histogram on new stretched picture
    stretched_luma_hist = get_hist(stretched_ycbcr[0]);
    // Write new %
    String s = "Black pixels : "+ nf((float)stretched_luma_hist[0]*100/(img.width*img.height),1,3)+" %";
    fill(200);
    text(s,10,img.height+16+100+20);
    
    stroke(0);
    draw_hist(stretched_luma_hist,10,100+16+img.height,100);
    
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


