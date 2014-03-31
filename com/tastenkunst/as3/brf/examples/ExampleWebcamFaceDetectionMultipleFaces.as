package com.tastenkunst.as3.brf.examples {
	import flash.events.Event;
	
	/**
	 * This example only does the face detection. No face or pose estimation here.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcamFaceDetectionMultipleFaces extends BRFBasicWebcam {
		
		public function ExampleWebcamFaceDetectionMultipleFaces() {
			super();
		}		
		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		/** When you isable face estimation, the pose estimation is disabled, too.*/
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			//disables face estimation and pose estimation
			_brfManager.isEstimatingFace = false;
			
			_brfManager.vars.faceDetectionVars.updateFaceDetectionROI(0, 0, 640, 480);
			_brfManager.vars.faceDetectionVars.updateLeftEyeDetectionROI(0, 0, 1, 1);
			_brfManager.vars.faceDetectionVars.updateRightEyeDetectionROI(0, 0, 1, 1);
			
			//base scale is the starting depth. Change it to 2 to find small faces in
			//the image (eg. when people are standing far away from the camera)
			//For an installation at the client, the user will stand in front of
			//the screen/camera at a very certain distance, I would suggest to
			//choose one base depth, scaleIncrement 0.1 and only maxScale = baseScale + 1.0
			//This way the user has to stay in the distance from the screen you want him
			//to be.
			_brfManager.vars.faceDetectionVars.baseScale = 4.0;
			//step size of the depth
			//so: starting with 4, 4.5, 5, 5.5, 6.0 face size are searched for
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;
			//end scale for depth search
			_brfManager.vars.faceDetectionVars.maxScale = 6.0;
			
			//set this to a high number to get more results
			_brfManager.vars.faceDetectionVars.minRectsToFind = 200;
			
			//add some space between the face rectangles searches. default is 0.02, 
			//which is really few space between the rects
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;
			
		}
	}
}
