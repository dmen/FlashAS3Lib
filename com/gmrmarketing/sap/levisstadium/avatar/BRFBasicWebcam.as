package com.gmrmarketing.sap.levisstadium.avatar 
{
	import flash.events.Event;
	
	/**
	 * This is the basic webcam example class.
	 * Extends this class to use the functionality you need.
	 * 
	 * To make it easier for you, we already set up the camera and video drawing
	 * using the CameraManager and the VideoManager. This Class implements
	 * the ICameraHandler and IVideoHandler to get things done.
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class BRFBasicWebcam extends BRFBasicView {
		
		public function BRFBasicWebcam() {
			super();
		}
		
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			//init the webcam
			_cameraManager.initCamera();
			//webcam apps should stabilize slow movements, so the objects don't jitter too much.
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = true;	
		}
	}
}
