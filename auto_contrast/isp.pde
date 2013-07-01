// ================================================================
// Image Processing Functions Library in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
//
// Feel free to use and share if you find it useful or interesting,
//                  a link would be appreciated, thanks ! :)
// ================================================================

// ================================================================
// get_ycbcr() : return the Y'CbCr channels from a PImage
//
// Notes:
// - Y'CbCr is computed using JFIF spec. 
// - returned Y'CbCr range is 0-255, if input RGB pixel range is 0-255. 
//
// ================================================================
int[][] get_ycbcr(PImage img) {
  
  // Create 3 arrays of the same size as the original image, for the Y'CbCr channels.
  int[][] YCbCr = new int[3][img.width*img.height];
  
  // Loop through every pixel in the image, update Y'CbCr array.
  for (int y = 0; y < img.height; y++) {  //we loop through every line
    for (int x = 0; x < img.width; x++) {  //we loop through every column
      
      int loc = y*img.width + x;  //computing 1D location of current pixel.
      
      // Compute Y'CbCr - output range [0-255] if input range is [0-255]
      // Y' = 0.299 R' + 0.587 G' + 0.114 B'
      // Cb = - 0.1687 R' - 0.3313 G' + 0.5 B' + 128
      // Cr = 0.5 R' - 0.4187 G' - 0.0813 B' + 128
      
      float r = red(img.pixels[loc]);
      float g = green(img.pixels[loc]);
      float b = blue(img.pixels[loc]);
      
      YCbCr[0][loc] = constrain( round(0.299 * r + 0.587 * g + 0.114 * b), 0, 255);
      YCbCr[1][loc] = constrain( round(-0.1687 * r - 0.3313 * g + 0.5 * b + 128), 0, 255);
      YCbCr[2][loc] = constrain( round(0.5 * r - 0.4187 * g - 0.0813 * b + 128), 0, 255);

    }
  }
  return YCbCr;
}

// ================================================================
// get_ycbcr_to_rgb() : return the PImage from Y'CbCr channels
//
// Notes:
// - Y'CbCr=>RGB is computed using JFIF spec. 
// - Expected input range is 0-255. 
//
// ================================================================
PImage get_ycbcr_to_rgb(int[][] YCbCr, int w, int h, float sat) {
  
  // Create RGB Image, of the specified size.
  PImage RGBimage;
  RGBimage = createImage(w, h, RGB);
  RGBimage.loadPixels();
  
  // Loop through every pixel in the image, update RGB array.
  for (int yy = 0; yy < h; yy++) {  //we loop through every line
    for (int xx = 0; xx < w; xx++) {  //we loop through every column
      
      int loc = yy*w + xx;  //computing 1D location of current pixel.
      
      // Compute RGB from Y'CbCr - output range [0-255] if input range is [0-255]
      // Y' = 0.299 R' + 0.587 G' + 0.114 B'
      // Cb = - 0.1687 R' - 0.3313 G' + 0.5 B' + 128
      // Cr = 0.5 R' - 0.4187 G' - 0.0813 B' + 128
      
      // R = Y + 1.402 (Cr-128)
      // G = Y - 0.34414 (Cb-128) - 0.71414 (Cr-128)
      // B = Y + 1.772 (Cb-128)
      
      float y = YCbCr[0][loc];
      float cb = constrain( (sat * (YCbCr[1][loc]-128)+128), 0, 255);
      float cr = constrain( (sat * (YCbCr[2][loc]-128)+128), 0, 255);
      
      float r = constrain( (y + 1.402 * (cr - 128)), 0, 255);
      float g = constrain( (y - 0.34414 * (cb - 128) - 0.71414 * (cr - 128)), 0, 255);
      float b = constrain( (y + 1.772 * (cb - 128)), 0, 255);
      
      RGBimage.pixels[loc] = color(r,g,b);

    }
  }
  RGBimage.updatePixels();
  return RGBimage;
}

// ================================================================
// get_hist() : return an histogram array, from any input array
//
// Notes:
// - Histogram has 256 bins only, so input array data range is expected to be 0-255.
// ================================================================
int[] get_hist(int[] input_array) {
  
  // Create one array to store the histogram
  int[] histogram = new int[256];
  
  // Loop through every entry in the array, update histogram.
  for (int x = 0; x < input_array.length; x++) {    
      histogram[input_array[x]] +=1; //increase the bin count of the selected bin by 1.  
  }
  return histogram;
}

// ================================================================
// draw_hist() : draw an histogram array, at the specified location
//
// Notes:
// - Input histogram is expected to have 256 bins only
// - Draw the histogram, by drawing one line by bin. We have 256 bins to draw
// - max(hist) is giving us the max value in the histogram. 
//   we use it to normalize the other values, and occupy specified height.
// ================================================================
void draw_hist(int[] hist, int start_x, int start_y, int histheight) {
  for (int i = 0; i < 256; i++) {
    int x;
    x = start_x + i;
    line(x,start_y ,x,start_y-(histheight*hist[i]/max(hist)));
  }
}

// ================================================================
// get_threshold_hist() : Compute the luma thresholds for automatic contrast enhancement
//
// Notes:
// - We set the % of pixels we would like to see black and white after stretch:
//    - black_percent : % of pixels we want to be black after contrast enhancement
//    - white_percent : % of pixels we want to be white after contrast enhancement
// - Algorithm needs to find the Y' histogram bins to reach these thresholds
//    - black_Y_bin : Y' bin number, so that the sum of all pixels contained in bin hist(0) to hist(black_bin) is >= (black_percent * nb_pixels)
//    - white_Y_bin : so that sum( hist[n], with n={white_Y_bin to 255} ) >= (white_percent * nb_pixels)
// ================================================================
int[] get_threshold_hist(int[] hist, float black_percent, float white_percent, int nb_pix_total) {

  int nb_pix_target_white = (int)(nb_pix_total*white_percent/100);
  int nb_pix_target_black = (int)(nb_pix_total*black_percent/100);
  
  //Find black_Y_bin
  int black_Y_bin = 0;
  int sum_pix = 0;
  int i = 0;
  while (sum_pix < nb_pix_target_black) {
    sum_pix += hist[i];
    i++;
  }
  black_Y_bin = i;
    
  //Find white_Y_bin
  int white_Y_bin = 255;
  sum_pix = 0;
  i = 255;
  while (sum_pix < nb_pix_target_white) {
    sum_pix += hist[i];
    i--;
  }
  white_Y_bin = i;
  
  int[] th = new int[2];
  th[0] = black_Y_bin;
  th[1] = white_Y_bin;

  return th;
}

// ================================================================
// get_stretched_luma() : stretch luma channel, using a black and white stretch points
//
// Notes:
// - Input is expected to be a Y'CbCr array
// ================================================================
int[][] get_stretched_luma(int[][] ycbcr, int w, int h, int black_stretch_pt, int white_stretch_pt) {
  // Create new array to store the stretched hist
  int[][] new_ycbcr = new int[3][w*h];
  float j;
  
  // Loop through every pixel in the image, update RGB array.
  for (int yy = 0; yy < h; yy++) {  //we loop through every line
    for (int xx = 0; xx < w; xx++) {  //we loop through every column
      
      int loc = yy*w + xx;  //computing 1D location of current pixel.
      
      //Chroma is not changed
      new_ycbcr[1][loc]=ycbcr[1][loc];
      new_ycbcr[2][loc]=ycbcr[2][loc];
      
      //Luma stretch
      if (ycbcr[0][loc] <= black_stretch_pt) {
        new_ycbcr[0][loc] = 0;
      }
      else if (ycbcr[0][loc] >= white_stretch_pt) {
        new_ycbcr[0][loc] = 255;
      }
      else {
        j = (float)(ycbcr[0][loc]-black_stretch_pt) / (float)(white_stretch_pt-black_stretch_pt) * 255;
        new_ycbcr[0][loc]=constrain(round(j),0,255);
      }
    }    
  }
  return new_ycbcr;
}


