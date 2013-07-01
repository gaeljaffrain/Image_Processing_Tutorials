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

// ================================================================
// Luma histogram in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
// ================================================================

PImage img;

void setup() {

  // Processing.js does not like variables in size() ...
  // Our picture is 640 pix wide
  // Histogram will have 256 bins, so we will draw it on 256 pix wide
  // Total width = 640 + 256 = 896 pix
  size(896,480);
  
  img = loadImage("Yosemite.jpg");
  noLoop(); // Run draw() only once !
}

void draw() {
  image(img, 0, 0); // Displays the original image from point (0,0) 
  img.loadPixels(); // we load the pixels to be able to work on it

  // Create one array of the same size as the original image, for the Y' channel.
  int[] Y = new int[img.width*img.height];

  // Loop through every pixel in the image, update Y' array.
  for (int y = 0; y < img.height; y++) {  //we loop through every line
    for (int x = 0; x < img.width; x++) {  //we loop through every column
      
      int loc = y*img.width + x;  //computing 1D location of current pixel.
      
      // Compute Y' - output range [0-255] if input range is [0-255]
      // Y' = 0.299 R' + 0.587 G' + 0.114 B'
      
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
      
      Y[loc] = round(0.299 * r + 0.587 * g + 0.114 * b);
    }
  }
  
  int[] hist = new int[256];
  
  // Loop through every pixel in the image, update histogram.
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int loc = y*img.width + x;  //computing 1D location of current pixel
      
      hist[Y[loc]] +=1; //increase the bin count of the selected bin by 1.  
    }
  }
  
  // Draw the histogram, by drawing one line by bin. We have 256 bins to draw
  // max(hist) is giving us the max value in the histogram. 
  // We use it to normalize the other values, and occupy then all the pic height.
  for (int i = 0; i < 256; i++) {
    int x,y;
    x = img.width + i;
    y = img.height;
    line(x,y,x,y-(hist[i]*y/max(hist)));
  } 
}

