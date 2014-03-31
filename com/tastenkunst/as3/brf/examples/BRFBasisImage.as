package com.tastenkunst.as3.brf.examples {
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.assets.BRFButtonGo;

	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * This is the basic image example class.
	 * Extends this class to use the functionality you need.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class BRFBasisImage extends BRFBasicView {
			
		public var _image : Bitmap = new Bitmap();
		public var _leftEyeMarker : BRFMarkerEye;
		public var _rightEyeMarker : BRFMarkerEye;
		public var _btGo : BRFButtonGo;
		
		public function BRFBasisImage() {
			super();
		}

		override public function initVideoHandling() : void {
			super.initVideoHandling();
			//We don't want to mirror still images
			_videoManager.mirrored = false;
			//set the image as input for the video manager
			_videoManager.attachInput(null, null, _image.bitmapData);
			//don't set _videoManager.handler = this; - we want to try our own detection, when BRF is ready
			//_videoManager.handler = this;
		}
		/** Initialzes the lib. Must again be waiting for the lib to be ready. */
		override public function onInitBRF(event : Event = null) : void {
			//override the face detection regions of interest, if needed.
			_brfManager.vars.faceDetectionVars.updateFaceDetectionROI(0, 0, 640, 480);
			_brfManager.vars.faceDetectionVars.updateLeftEyeDetectionROI(0, 0, 640, 480);
			_brfManager.vars.faceDetectionVars.updateRightEyeDetectionROI(0, 0, 640, 480);
			
			super.onInitBRF(event);
		}
		/** We render the image once in the video manager and try to find the face automatically. */
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			
			_videoManager.render();
			
			//We try to find the face on our own:
			//step 1 - find the initial face
			_brfManager.isEstimatingFace = false;
			_brfManager.update();
			
			//step2 - if there was face, we calculate the positions of the eyes 
			if(_brfManager.lastDetectedFace != null) {
				BRFUtils.estimateEyes(_brfManager.lastDetectedFace, _leftEyePoint, _rightEyePoint);
				//check, if the eyes where in the regions of interest
				if(BRFUtils.areEyesValid(_leftEyePoint, _rightEyePoint)) {
					_brfManager.isEstimatingFace = true;
					//do 5 iterations (face shape morphes to the end position
					_brfManager.updateByEyes(_leftEyePoint, _rightEyePoint, 5);
					//draw the resulting shape
					showResult();
				}
			} else {
				//oops, automatic face finding failes:
				//use the markers to mark the eyes and press go.			
			}
		}
		/** Add 2 markers and a "go" button to the stage. */
		override public function initGUI() : void {
			super.initGUI();
						
			_leftEyeMarker = new BRFMarkerEye();
			_leftEyeMarker.x = 525;
			_leftEyeMarker.y = 25;
			addChild(_leftEyeMarker);
			
			_rightEyeMarker = new BRFMarkerEye();
			_rightEyeMarker.x = 575;
			_rightEyeMarker.y = 25;
			addChild(_rightEyeMarker);
			
			_btGo = new BRFButtonGo();
			_btGo.x = 525;
			_btGo.y = 400;
			_btGo.addEventListener(MouseEvent.CLICK, onClickGo);
			addChild(_btGo);
		}
		/** Analyse the image based on the set markers */
		public function onClickGo(event : MouseEvent) : void {
			if(_brfReady) {
				_leftEyePoint.x = _leftEyeMarker.x;
				_leftEyePoint.y = _leftEyeMarker.y;
				_rightEyePoint.x = _rightEyeMarker.x;
				_rightEyePoint.y = _rightEyeMarker.y;
				
				_leftEyeMarker.x = 525;
				_leftEyeMarker.y = 25;
				_rightEyeMarker.x = 575;
				_rightEyeMarker.y = 25;
				
				_brfManager.updateByEyes(_leftEyePoint, _rightEyePoint, 5);
				
				showResult();
			}	
		}
	}
}
