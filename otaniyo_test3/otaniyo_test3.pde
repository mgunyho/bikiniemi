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
// knobs[4] == glitch color spread
// knobs[5] == glitch mask enable
// knobs[6] == glitch count
float[] knobs = new float[8];

//PVector[] bodyRectangle = new PVector[4];
//PVector[] bodyBounds = {
//  new PVector(0.5, 0.5), // body x boundary
//  new PVector(0.5, 0.5)  // body y boundary
//};
PVector bodyCenter = new PVector(0.5, 0.5);
PVector bodyDims = new PVector(0.5, 0.5);

Kinect kinect;
HashMap <Integer, Skeleton> skeletons;

MidiBus myBus;

void setup()
{
  //size(640, 480, P2D);
  //size(960, 540, P2D);
  fullScreen(P2D, 2);

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

  //for(int i = 0; i < bodyRectangle.length; i++) {
  //  bodyRectangle[i] = new PVector(0.5, 0.5);
  //}

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

  //println(knobs);

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
      PVector shldr_l = s.getLeftShoulder();
      PVector shldr_r = s.getRightShoulder();

      if(wrist_l != null && wrist_r != null && shldr_l != null && shldr_r != null) {

        wrist_l.z = 0;
        wrist_r.z = 0;

        shldr_l.z = 0;
        shldr_r.z = 0;

        float delta = wrist_l.dist(wrist_r) / (shldr_l.dist(shldr_r) / 0.2f);
        //println(delta, shldr_l.dist(shldr_r));
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
      
      PVector hip_l = s.getLeftHip();
      PVector hip_r = s.getRightHip();
      if(hip_l != null && hip_r != null && shldr_l != null && shldr_r != null) {
        //bodyRectangle[0] = shldr_l;
        //bodyRectangle[1] = shldr_r;
        //bodyRectangle[2] = hip_r;
        //bodyRectangle[3] = hip_l;
        //bodyBounds[0] = new PVector((shldr_l.x + hip_l.x) * 0.5,
        //                            (shldr_r.x + hip_r.x) * 0.5);
        //bodyBounds[1] = new PVector((shldr_l.y + shldr_r.y) * 0.5,
        //                            (hip_l.y + hip_r.y) * 0.5);
        bodyCenter = new PVector(0, 0);
        bodyCenter.add(shldr_l);
        bodyCenter.add(shldr_r);
        bodyCenter.add(hip_l);
        bodyCenter.add(hip_r);
        bodyCenter.mult(0.25);
        bodyDims = new PVector(
          0.5 * abs(shldr_r.x + hip_r.x - shldr_l.x - hip_l.x),
          0.5 * abs(shldr_r.y + shldr_l.y - hip_r.y - hip_l.y)
        );
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
    glitchbuf1.clear();
  }
  if(knobs[5] > 0.5) {
    glitchbuf1.image(mask, 0, 0, glitchbuf1.width, glitchbuf1.height);

  }
  glitchbuf1.endDraw();

  //randomSeed(42);
  float glitchx1 = bodyCenter.x - bodyDims.x * 0.5 * 2;
  float glitchx2 = bodyCenter.x + bodyDims.x * 0.5 * 2;
  float glitchy1 = bodyCenter.y - bodyDims.y * 0.5 * 3 - 0.1;
  float glitchy2 = bodyCenter.y + bodyDims.y * 0.5 * 3;
  float maxGlitches = 30;
  for(int i = 0; i < knobs[6] * maxGlitches; i++) {
    glitchbuf1.beginDraw();
    //glitchShader.set("rectPosition", random(0, 1), random(0, 1), 0.1 * random(0.5, 2.5), 0.01 * random(0.5, 2.5));
    float glitchw = 0.1 * random(0.5, 2.5);
    glitchShader.set("rectPosition", random(glitchx1, glitchx2) - 0.5 * glitchw,
                                     random(1 - glitchy2, 1 - glitchy1) - 0.05,
                                     glitchw,
                                     0.01 * random(0.5, 2.5));
    glitchShader.set("rectOffset", random(-1, 1) * 0.01, 0);
    glitchShader.set("mask", mask);
    glitchShader.set("colorSpreadX", random(-1, 1) * knobs[4] * 0.1);
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


  //PVector bodyRectangleCenter = new PVector(0, 0);
  //PVector bodyRectangleDimensions = new PVector(
  //  abs(bodyRectangle[0].x + bodyRectangle[3].x - (bodyRectangle[1].x + bodyRectangle[2].x)) * 0.5f,
  //  abs(bodyRectangle[0].y + bodyRectangle[1].y - (bodyRectangle[2].y + bodyRectangle[3].y)) * 0.5f
  //);
  //for(int i = 0; i < 4; i++) {
  //  bodyRectangleCenter.add(bodyRectangle[i]);
  //}
  //bodyRectangleCenter.mult(0.25f);

  pushStyle();
  //rectMode(RADIUS);
  //rect(bodyRectangleCenter.x * width, bodyRectangleCenter.y * height,
  //     bodyRectangleDimensions.x * width, bodyRectangleDimensions.y * height);
  //rectMode(CORNERS);
  //rect(bodyBounds[0].x * width, (bodyBounds[1].x + 0.2) * height,
  //     bodyBounds[0].y * width, (bodyBounds[1].y + 0.2) * height);
  //rectMode(CENTER);
  //rect(bodyCenter.x * width, (bodyCenter.y + 0.0) * height,
  //     bodyDims.x * width * 2, bodyDims.y * height * 3);
  //println(bodyCenter, bodyDims);
  popStyle();

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
