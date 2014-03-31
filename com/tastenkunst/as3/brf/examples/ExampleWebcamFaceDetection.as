package com.tastenkunst.as3.brf.examples {
	import flash.events.Event;
	
	/**
	 * This example only does the face detection. No face or pose estimation here.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcamFaceDetection extends BRFBasicWebcam {
		
		public function ExampleWebcamFaceDetection() {
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
		}
	}
}
