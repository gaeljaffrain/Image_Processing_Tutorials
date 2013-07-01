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
// Automatic Contrast Enhancement in Processing.js - Part1
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
// ================================================================

PImage img;

void setup() {

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

  // Compute Y' channel from the RGB picture
  int[] Y = get_luma(img);

  // Get the Y' histogram from to Y' channel
  int[] hist = get_hist(Y);
  
  // Draw the histogram, at the right side of our picture
  draw_hist(hist, img.width, img.height, 50);
  
  // Get Auto Contrast Thresholds, 0.5% black and white requested
  int[] AC_thresholds = get_threshold_hist(hist, 0.5, 0.5, Y.length);
  
  // Stretch Luma histogram
  int[] hist2 = stretch_hist(hist, AC_thresholds[0], AC_thresholds[1]);

  // Draw the stretched histogram
  draw_hist(hist2, img.width, img.height/2, 100);

}

