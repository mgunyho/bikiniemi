import kinect4WinSDK.Kinect;

class Skeleton {
  SkeletonData data;

  //public Skeleton(Skeleton s) {
  //  skel = s;
  //}

  public Skeleton(SkeletonData d) {
    data = d;
  }

  // get a body part. if it is not present, return null
  PVector getBodyPartByIndex(int idx) {
    if(this.data.skeletonPositionTrackingState[idx] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED) {
      return this.data.skeletonPositions[idx];
    } else {
      return null;
    }
  }

  public PVector getHead() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_HEAD); }

  public PVector getLeftShoulder() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_SHOULDER_LEFT); }
  public PVector getRightShoulder() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_SHOULDER_RIGHT); }

  public PVector getLeftWrist()  { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_WRIST_LEFT); }
  public PVector getRightWrist() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT); }
  
  public PVector getLeftHip() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_HIP_LEFT); }
  public PVector getRightHip() { return getBodyPartByIndex(Kinect.NUI_SKELETON_POSITION_HIP_RIGHT); }

}
