import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

import java.util.Map;


PShader feedbackShader;
PGraphics fbbuf1;
PGraphics fbbuf2;
PImage mask;

Kinect kinect;
HashMap <Integer, Skeleton> skeletons;

void setup()
{
  //size(640, 480, P2D);
  fullScreen(P2D, 2);
  background(0);
  kinect = new Kinect(this);
  //smooth();
  skeletons = new HashMap<Integer, Skeleton>();
  
  feedbackShader = loadShader("feedback.glsl");
  feedbackShader.set("feedbackAmount", 0.5);
  feedbackShader.set("feedbackScale", 0.9);
  feedbackShader.set("feedbackCenter", new PVector(0.5, 0.5));

  mask = loadImage("mask.png");

  fbbuf1 = createGraphics(width, height, P2D);
  fbbuf1.beginDraw();
  fbbuf1.background(0);
  fbbuf1.endDraw();

  fbbuf2 = createGraphics(width, height, P2D);
  fbbuf2.beginDraw();
  fbbuf2.background(0);
  fbbuf2.endDraw();
}

void draw()
{
  //background(255, 0, 0);
  background(0);

  //image(kinect.GetImage(), 320, 0, 320, 240);
  //image(kinect.GetDepth(), 320, 240, 320, 240);
  //image(kinect.GetMask(), 0, 240, 320, 240);

  //mask = kinect.GetMask();

  //image(mask, 0, 0, width, height);

  fbbuf1.beginDraw();
  fbbuf1.image(fbbuf2, 0, 0); // apply feedback
  fbbuf1.image(mask, 0, 0, fbbuf1.width, fbbuf1.height);
  fbbuf1.endDraw();


  fbbuf2.beginDraw();
  fbbuf2.shader(feedbackShader);
  fbbuf2.image(fbbuf1, 0, 0);
  fbbuf2.endDraw();

  image(fbbuf1, 0, 0);

  if(skeletons.size() > 0) {
  for(Map.Entry<Integer, Skeleton> e: skeletons.entrySet()) {
    Skeleton s = e.getValue();

    PVector head = s.getHead();
    if(head != null) {
      //TODO: lowpass filter position
      rectMode(RADIUS);
      //rect(map(head.x, 0, 1, 0, width), map(head.y, 0, 1, 0, height), 50, 50);
      feedbackShader.set("feedbackCenter", head.x, 1 - head.y);
    }

    PVector wrist_l = s.getLeftWrist();
    PVector wrist_r = s.getRightWrist();
    if(wrist_l != null && wrist_r != null) {

       wrist_l.z = 0;
       wrist_r.z = 0;

       //TODO: angle between arms rotate feedback? "inverse" sigmoid function, small effect for almost all values, large effet at bounds. ~x^3? tan?
       //TODO: scale delta by shoulder width -- what happens when turning around?
       float delta = wrist_l.dist(wrist_r);
       feedbackShader.set("feedbackScale", map(delta, 0, 1, 1.2, 0.8));
       //float a = (PVector.sub(wrist_l, wrist_r).heading() - PI) * 0.05;
       //float a = map((PVector.sub(wrist_l, wrist_r).heading() + TWO_PI) % TWO_PI, -PI, PI, 0.5, -0.5);
       float a = -PVector.sub(wrist_r, wrist_l).heading() * 0.05;
       //println(a);
       feedbackShader.set("feedbackAngle", a);

       //TODO: rectangle offset glitches (scale by some velocity?)

       //println(wrist_l, wrist_r, delta);
       
    }

    break;
  }
  } else {
    //feedbackCenter(0.5, 0.5);
    feedbackShader.set("feedbackCenter", 0.5, 0.5);
  }
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
