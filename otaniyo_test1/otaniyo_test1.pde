import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

Kinect kinect;

void setup() {
  
  size(640, 640);
  kinect = new Kinect(this);
  //kinect.stopVideo();
  kinect.initDepth();
  
}

void draw() {
  //PImage img = kinect.getVideoImage();
  PImage img2 = kinect.getDepthImage().copy();
  int w = img2.width;
  int h = img2.height;
  img2.loadPixels();
  for(int i = 0; i < w*h; i++) {
    //for(int j = 0; j < h; j++) {
      color c = img2.pixels[i];
      float r = red(c);
      float g = green(c);
      float b = blue(c);
      //r *= 10;
      //r %= 10;
//      r = -(floor(10*r)-10*r)*255;
      r *= 10;
      r %= 255;
      //img2.pixels[i] *= 10;
      //img2.pixels[i] %= 10;
      img2.pixels[i] = color(r, g, b);
    //}
  }
  img2.updatePixels();
  //image(img, 0, 0);
  //tint(255, 255, 255, 255 / 2);
  image(img2, 0, 0);
  //filter(POSTERIZE, 5);
  //rect(100, 100, 100, 100);
}
