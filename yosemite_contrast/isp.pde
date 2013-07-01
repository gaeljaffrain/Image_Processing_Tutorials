// ================================================================
// Image Processing Library in Processing.js
//                  by Gael Jaffrain - 2013 - gaeljaffrain.com
//
// Feel free to use and share if you find it useful or interesting,
//                  a link would be appreciated, thanks ! :)
// ================================================================

// ================================================================
// get_luma() : return the Y' channel from a PImage
//
// Notes:
// - Y' is computed using JFIF spec. 
// - returned Y' range is 0-255, if input pixel range is 0-255. 
//
// ================================================================
int[] get_luma(PImage img) {
  
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
  return Y;
}

// ================================================================
// get_hist() : return an histogram array, from any input array
//
// Notes:
// - Histogram has 256 bins only, so input array data range is expected to be à-255.
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
//   we use it to normalize the other values, and occupy then all the pic height.
// ================================================================
void draw_hist(int[] hist, int start_x, int start_y, int height_percent) {
  for (int i = 0; i < 256; i++) {
    int x;
    x = start_x + i;
    line(x,start_y ,x,start_y-(hist[i]*start_y/(100*max(hist)/height_percent)));
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
// stretch_hist() : stretch an histogram array, using a black and white stretch points
//
// Notes:
// - Input histogram is expected to have 256 bins only
// ================================================================
int[] stretch_hist(int[] hist, int black_stretch_pt, int white_stretch_pt) {
  // Create new array to store the stretched hist
  int[] new_hist = new int[256];
  float j;
  
  for (int i = 0; i < 256; i++) {  
    if (i <= black_stretch_pt) {
      new_hist[0] += hist[i];
    }
    else if (i >= white_stretch_pt) {
      new_hist[255] += hist[i];
    }
    else {
      j = (float)(i-black_stretch_pt) / (float)(white_stretch_pt-black_stretch_pt) * 255;
      new_hist[round(j)]+=hist[i];
    }    
  }
  return new_hist;
}

