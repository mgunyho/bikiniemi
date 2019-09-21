import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

import java.util.Map;


PShader feedbackShader;
PGraphics buf1;
PGraphics buf2;

PVector headPrevious;

Kinect kinect;
HashMap <Integer, Skeleton> skeletons;

void setup()
{
  size(640, 480, P2D);
  //fullScreen(P2D, 2);
  background(0);
  kinect = new Kinect(this);
  //smooth();
  skeletons = new HashMap<Integer, Skeleton>();
  
  feedbackShader = loadShader("feedback.glsl");
  feedbackShader.set("feedbackAmount", 0.5);
  feedbackShader.set("feedbackScale", 0.9);
  feedbackShader.set("feedbackCenter", new PVector(0.5, 0.5));

  headPrevious = new PVector(0.5,0.5,0);

  buf1 = createGraphics(width, height, P2D);
  buf1.beginDraw();
  buf1.background(0);
  buf1.endDraw();

  buf2 = createGraphics(width, height, P2D);
  buf2.beginDraw();
  buf2.background(0);
  buf2.endDraw();
}

void draw()
{
  //background(255, 0, 0);
  background(0);
  //image(kinect.GetImage(), 320, 0, 320, 240);
  //image(kinect.GetDepth(), 320, 240, 320, 240);
  //image(kinect.GetMask(), 0, 240, 320, 240);

  PImage mask = kinect.GetMask();
  //image(mask, 0, 0, width, height);

  buf1.beginDraw();
  buf1.image(buf2, 0, 0); // apply feedback
  buf1.image(mask, 0, 0, buf1.width, buf1.height);
  buf1.endDraw();


  buf2.beginDraw();
  buf2.shader(feedbackShader);
  buf2.image(buf1, 0, 0);
  buf2.endDraw();

  image(buf1, 0, 0);

  int head_idx = Kinect.NUI_SKELETON_POSITION_HEAD;

  if(skeletons.size() > 0) {
  for(Map.Entry<Integer, Skeleton> e: skeletons.entrySet()) {
    Skeleton s = e.getValue();

    PVector head = s.getHead();
    if(head != null) {
      //TODO: lowpass filter position
      rectMode(RADIUS);
      //rect(map(head.x, 0, 1, 0, width), map(head.y, 0, 1, 0, height), 50, 50);
      
      float mpl = 0.07;
      
      float avgX = (mpl*head.x + (1-mpl)*headPrevious.x);
      float avgY = (mpl*head.y + (1-mpl)*headPrevious.y);
      
      println(avgX + " " + avgY + " " + head.x + "  " + head.y);
      
      feedbackShader.set("feedbackCenter", avgX, 1 - avgY);
      headPrevious.x = avgX;
      headPrevious.y = avgY;
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
       float a = -PVector.sub(wrist_r, wrist_l).heading();
       a = map(a, -PI, PI, -1, 1);
       a = map(pow(a,3), -1, 1, -PI, PI);
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
