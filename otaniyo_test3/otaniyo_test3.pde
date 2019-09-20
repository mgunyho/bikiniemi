import kinect4WinSDK.Kinect;
import kinect4WinSDK.SkeletonData;

import java.util.Map;


PShader feedbackShader;
PGraphics buf1;
PGraphics buf2;

Kinect kinect;
HashMap <Integer, SkeletonData> skeletons;
 
void setup()
{
  //size(640, 480, P2D);
  fullScreen(P2D, 2);
  background(0);
  kinect = new Kinect(this);
  //smooth();
  skeletons = new HashMap<Integer, SkeletonData>();
  
  feedbackShader = loadShader("feedback.glsl");
  feedbackShader.set("feedbackAmount", 0.5);
  feedbackShader.set("feedbackScale", 0.9);
  feedbackShader.set("feedbackCenter", new PVector(0.5, 0.5));

  buf1 = createGraphics(width, height, P2D);
  buf1.beginDraw();
  buf1.background(0);
  buf1.endDraw();

  buf2 = createGraphics(width, height, P2D);
  buf2.beginDraw();
  buf2.background(0);
  buf2.endDraw();
}

Boolean isTracking(SkeletonData s, int pos_idx) {
  return s.skeletonPositionTrackingState[pos_idx] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED;
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
  buf1.image(buf2, 0, 0);
  buf1.image(mask, 0, 0, buf1.width, buf1.height);
  buf1.endDraw();

  buf2.beginDraw();
  buf2.shader(feedbackShader);
  buf2.image(buf1, 0, 0);
  buf2.endDraw();

  image(buf1, 0, 0);

  int head_idx = Kinect.NUI_SKELETON_POSITION_HEAD;
  //if(skeletons.size() > 0) {
  //  SkeletonData s = skeletons.get(0);
  //  if(s.skeletonPositionTrackingState[head_idx] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED)  {
  //    PVector pos = s.skeletonPositions[head_idx];
  //    rectMode(RADIUS);
  //    rect(map(pos.x, 0, 1, 0, width), map(pos.y, 0, 1, 0, height), 50, 50);
  //  }

  //}

  if(skeletons.size() > 0) {
  for(Map.Entry<Integer, SkeletonData> e: skeletons.entrySet()) {
    SkeletonData s = e.getValue();
    if(isTracking(s, head_idx))  {
      PVector pos = s.skeletonPositions[head_idx];
      rectMode(RADIUS);
      //rect(map(pos.x, 0, 1, 0, width), map(pos.y, 0, 1, 0, height), 50, 50);
      feedbackShader.set("feedbackCenter", pos.x, 1 - pos.y);
    }
    if(isTracking(s, Kinect.NUI_SKELETON_POSITION_WRIST_LEFT) &&
       isTracking(s, Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT)) {
       PVector pos_l = s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_WRIST_LEFT];
       PVector pos_r = s.skeletonPositions[Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT];

       pos_l.z = 0;
       pos_r.z = 0;

       float delta = pos_l.dist(pos_r);
       feedbackShader.set("feedbackScale", map(delta, 0, 1, 1.2, 0.8));
       println(pos_l, pos_r, delta);
       
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
    skeletons.put(s.dwTrackingID, s);
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
