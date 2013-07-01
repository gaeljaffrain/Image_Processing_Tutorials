/* @pjs preload="Yosemite.jpg"; */ 

// ================================================================
// Automatic Contrast Enhancement in Processing.js - Part1
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
//
// Feel free to use and share if you find it useful or interesting,
//                  a link would be appreciated, thanks ! :)
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

