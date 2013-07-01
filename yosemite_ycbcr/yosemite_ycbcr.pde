/* @pjs preload="Yosemite.jpg"; */ 

// ================================================================
// YCbCr conversion in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
//
// Feel free to use and share if you find it useful or interesting,
//                  a link would be appreciated, thanks ! :)
// ================================================================

PImage img;

void setup() {

  // Processing.js does not like variables in size() ...  
  //int h = 640*4/3;
  //size(h,480);
  size(853,480);
  
  img = loadImage("Yosemite.jpg");
}

void draw() {
  image(img, 0, 0); // Displays the original image from point (0,0) 
  img.loadPixels(); // we load the pixels to be able to work on it

  // Create 3 arrays of the same size as the original image, for the Y', Cb and Cr planes
  int[] Y = new int[img.width*img.height];
  int[] Cb = new int[img.width*img.height];
  int[] Cr = new int[img.width*img.height];

  // Loop through every pixel in the image, update Y'CbCr arrays.
  for (int y = 0; y < img.height; y++) {  //we loop through every line
    for (int x = 0; x < img.width; x++) {  //we loop through every column
      
      int loc = y*img.width + x;  //computing 1D location of current pixel.
      
      // Compute Y'CbCr - output range [0-255] if input range is [0-255]
      // Y' = 0.299 R' + 0.587 G' + 0.114 B'
      // Cb = - 0.1687 R' - 0.3313 G' + 0.5 B' + 127.5
      // Cr = 0.5 R' - 0.4187 G' - 0.0813 B' + 127.5
      
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
      
      Y[loc] = round(0.299 * r + 0.587 * g + 0.114 * b);
      Cb[loc] = round(-0.1687 * r - 0.3313 * g + 0.5 * b + 127.5);
      Cr[loc] = round(0.5 * r - 0.4187 * g - 0.0813 * b + 127.5);
    }
  }
  
  
  // Here we should do something meaningful on Y'CbCr colors planes
  // After, we could re-create the RGB components, and display the processed picture.
  
  
  // For this example we will do something different :
  
  
  // Display Y'CbCr arrays as RGB pictures
  // Y' plane displayed as a Grayscale picture, with R=G=B=Y'
  // Cb displayed as Blue
  // Cr displayed as Red
  
  PImage Yimg, Cbimg, Crimg;
  Yimg = createImage(img.width, img.height, RGB);
  Cbimg = createImage(img.width, img.height, RGB);
  Crimg = createImage(img.width, img.height, RGB);

  // We load pixels to work on it
  Yimg.loadPixels();
  Cbimg.loadPixels();
  Crimg.loadPixels();

  // Loop through every pixel in the image, update Y'CbCr arrays.
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int loc = y*img.width + x;  //computing 1D location of current pixel

      Yimg.pixels[loc] = color(Y[loc], Y[loc], Y[loc]);
      Cbimg.pixels[loc] = color(0, 0, Cb[loc]);
      Crimg.pixels[loc] = color(Cr[loc], 0, 0);

    }
  }
  
  // State that there are changes to pixels[]
  Yimg.updatePixels();
  Cbimg.updatePixels();
  Crimg.updatePixels();

  image(Yimg, img.width, 0, img.width/3, img.height/3); // Draw the new image
  image(Cbimg, img.width, img.height/3, img.width/3, img.height/3); // Draw the new image
  image(Crimg, img.width, 2*img.height/3, img.width/3, img.height/3); // Draw the new image

}
