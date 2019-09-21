import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

import themidibus.*;

import java.util.Map;


PShader feedbackShader;
PGraphics fbbuf1;
PGraphics fbbuf2;

PShader glitchShader;
PGraphics glitchbuf1;

PImage mask;

PVector headPrevious;

// knobs[0] == feedback freeze threshold
// knobs[1] == feedback hue speed
//TODO: glitch intensity and glitch count knob
float[] knobs = new float[8];


//TODO: glitch normal distribute around body

Kinect kinect;
HashMap <Integer, Skeleton> skeletons;

MidiBus myBus;

void setup()
{
  //size(640, 480, P2D);
  size(960, 540, P2D);
  //fullScreen(P2D, 2);

  background(0);
  kinect = new Kinect(this);
  //smooth();
  skeletons = new HashMap<Integer, Skeleton>();
  
  feedbackShader = loadShader("feedback.glsl");
  feedbackShader.set("feedbackAmount", 0.5);
  feedbackShader.set("feedbackScale", 0.9);
  feedbackShader.set("feedbackCenter", new PVector(0.5, 0.5));
  feedbackShader.set("feedbackHueSpeed", 0.1);

  fbbuf1 = createGraphics(width, height, P2D);
  fbbuf2 = createGraphics(width, height, P2D);

  glitchShader = loadShader("glitch.glsl");

  glitchbuf1 = createGraphics(width, height, P2D);

  //mask = loadImage("mask.png");

  // initialize buffers
  PGraphics[] buffers = { fbbuf1, fbbuf2, glitchbuf1};
  for(int i = 0; i < buffers.length; i++) {
    PGraphics buf = buffers[i];
    buf.beginDraw();
    buf.background(0);
    buf.endDraw();
  }

  headPrevious = new PVector(0.5,0.5,0);

  knobs[0] = 0.5;

  // MIDI

  String midi_name = "MPK mini";
  myBus = new MidiBus(this, midi_name, midi_name);
}

void draw()
{
  //background(255, 0, 0);
  background(0);

  //image(kinect.GetImage(), 320, 0, 320, 240);
  //image(kinect.GetDepth(), 320, 240, 320, 240);
  //image(kinect.GetMask(), 0, 240, 320, 240);

  mask = kinect.GetMask();

  println(knobs);

  if(skeletons.size() > 0) {
    for(Map.Entry<Integer, Skeleton> e: skeletons.entrySet()) {
      Skeleton s = e.getValue();

      PVector head = s.getHead();
      if(head != null) {
        rectMode(RADIUS);
        //rect(map(head.x, 0, 1, 0, width), map(head.y, 0, 1, 0, height), 50, 50);

        float mpl = 0.07;

        float avgX = (mpl*head.x + (1-mpl)*headPrevious.x);
        float avgY = (mpl*head.y + (1-mpl)*headPrevious.y);

        //println(avgX + " " + avgY + " " + head.x + "  " + head.y);

        feedbackShader.set("feedbackCenter", avgX, 1 - avgY);
        headPrevious.x = avgX;
        headPrevious.y = avgY;
      }

      PVector wrist_l = s.getLeftWrist();
      PVector wrist_r = s.getRightWrist();
      if(wrist_l != null && wrist_r != null) {

        wrist_l.z = 0;
        wrist_r.z = 0;

        //TODO: scale delta by shoulder width -- what happens when player is sideways?
        float delta = wrist_l.dist(wrist_r);
        feedbackShader.set("feedbackScale", map(delta, 0, 1, 1.2, 0.8));
        //float a = (PVector.sub(wrist_l, wrist_r).heading() - PI) * 0.05;
        //float a = map((PVector.sub(wrist_l, wrist_r).heading() + TWO_PI) % TWO_PI, -PI, PI, 0.5, -0.5);
        float a = -PVector.sub(wrist_r, wrist_l).heading();
        a = map(a, -PI, PI, -1, 1);
        a = map(pow(a,3), -1, 1, -PI, PI);
        //println(a);
        feedbackShader.set("feedbackAngle", a);

        //TODO: scale glitches based on some velocity?

        //println(wrist_l, wrist_r, delta);

      }

      break;
    }
  } else {
    //feedbackCenter(0.5, 0.5);
    feedbackShader.set("feedbackCenter", 0.5, 0.5);
  }

  feedbackShader.set("feedbackHueSpeed", knobs[1] * 0.1);

  glitchbuf1.beginDraw();
  //println(noise(millis() / 1000.0));
  if(noise(millis() / 1000.0) < knobs[0] * 0.7) {
    glitchbuf1.clear(); // TODO: randomly skip clear?
  }
  glitchbuf1.image(mask, 0, 0, glitchbuf1.width, glitchbuf1.height);
  glitchbuf1.endDraw();

  for(int i = 0; i < 20; i++) {
    glitchbuf1.beginDraw();
    glitchShader.set("rectPosition", random(0, 1), random(0, 1), 0.1 * random(0.5, 2.5), 0.01 * random(0.5, 2.5));
    glitchShader.set("rectOffset", random(-1, 1) * 0.01, 0);
    glitchShader.set("mask", mask);
    glitchbuf1.shader(glitchShader);
    glitchbuf1.image(glitchbuf1, 0, 0);
    glitchbuf1.endDraw();
  }

  fbbuf1.beginDraw();
  fbbuf1.image(fbbuf2, 0, 0); // apply feedback from previous frame
  fbbuf1.image(glitchbuf1, 0, 0);
  fbbuf1.endDraw();


  fbbuf2.beginDraw();
  fbbuf2.shader(feedbackShader);
  fbbuf2.image(fbbuf1, 0, 0);
  fbbuf2.endDraw();

  image(fbbuf1, 0, 0);

}

void mouseClicked() {
  //println("foo");
  mask.save("mask.png");
}

void appearEvent(SkeletonData s) 
{
  println("appear:", s.dwTrackingID);
  if(s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) return;
  synchronized(skeletons) {
    skeletons.put(s.dwTrackingID, new Skeleton(s));
    //println(skeletons.get(skeletons.size() - 1).dwTrackingID);
  }
}
 
void disappearEvent(SkeletonData s) 
{
  println("disappear:", s.dwTrackingID);
  synchronized(skeletons) {
    // iterate backwards because we're removing elements while iterating the list
    //for (int i = skeletons.size() - 1; i >= 0; i--) 
    //{
    //  println(skeletons.get(i).dwTrackingID);
    //  if (s.dwTrackingID == skeletons.get(i).dwTrackingID) 
    //  {
    //    println("removing", i);
    //    skeletons.remove(i);
    //  }
    //}
    skeletons.remove(s.dwTrackingID);
  }
}
 
void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(skeletons) {
    //for (int i=skeletons.size ()-1; i>=0; i--) 
    //{
    //  if (_b.dwTrackingID == skeletons.get(i).dwTrackingID) 
    //  {
    //    skeletons.get(i).copy(_a);
    //    break;
    //  }
    //}
    //if(b.trackingID == )
  return;
  }
}



//////////////////////
/// MIDI CALLBACKS ///
//////////////////////

void controllerChange(int channel, int number, int value) {
  //println("controllerChange:", channel, number, value);
  float normV = map(value, 0, 127, 0.f, 1.f);
  if(1 <= number && number <= 8) {
    knobs[number - 1] =  normV;
  }
}
