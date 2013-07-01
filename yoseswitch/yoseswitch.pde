/* @pjs preload="Yosemite.jpg"; */ 
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

// First processing example in Processing.js


float v = 1.0 / 8.0;
float sharp = 2;
float[][] kernel = {{ -sharp*v, -sharp*v, -sharp*v }, 
                    { -sharp*v, +sharp+1, -sharp*v }, 
                    { -sharp*v, -sharp*v, -sharp*v }};

PImage img;

void setup() {
  size(1280,480);
  img = loadImage("Yosemite.jpg");
}

void draw() {
  image(img, 0, 0); // Displays the image from point (0,0) 
  img.loadPixels();

  // Create an opaque image of the same size as the original
  PImage edgeImg = createImage(img.width, img.height, RGB);

  // Loop through every pixel in the image
  for (int y = 1; y < img.height-1; y++) {   // Skip top and bottom edges
    for (int x = 1; x < img.width-1; x++) {  // Skip left and right edges
      float sum = 0; // Kernel sum for this pixel
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          // Calculate the adjacent pixel for this kernel point
          int pos = (y + ky)*img.width + (x + kx);
          // Sharpen only based on green
          float val = green(img.pixels[pos]);
          // Multiply adjacent pixels based on the kernel values
          sum += kernel[ky+1][kx+1] * val;
        }
      }
      // Get Red and Blue from original picture.
      edgeImg.pixels[y*img.width + x] = color(blue(img.pixels[y*img.width+x]), green(img.pixels[y*img.width+x]), red(img.pixels[y*img.width+x]));
    }
  }
  // State that there are changes to edgeImg.pixels[]
  edgeImg.updatePixels();

  image(edgeImg, width/2, 0); // Draw the new image
}
