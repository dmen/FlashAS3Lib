package com.tastenkunst.as3.brf.examples {
	import com.tastenkunst.as3.brf.container.Images2D;

	import flash.events.Event;
	import flash.geom.Rectangle;

	/**
	 * This examples does the whole job. Flare3D and Away3DLite are available at the moment.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcam2D extends BRFBasicWebcam {
		
		public function ExampleWebcam2D() {
			super();
        }
		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void {
			super.initVideoHandling();
			
			//no 3d? then add the input image to the display list.
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		
		override public function initContentContainer() : void {			
			_contentContainer = new Images2D(_containerContent);
			_contentContainer.init(new Rectangle(0, 0, 640, 480));
		}
				
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			_brfManager.isEstimatingPose = false;
		}
		
		override public function showResult(showAll : Boolean = false) : void {
			//updating the glasses here. In 3D mode the IBRFContainer will be updated
			//by the _brfManager directly.
			_contentContainer.updatePoseByEyes(_brfManager.faceShape.pointLeftEyeCenter, 
				_brfManager.faceShape.pointRightEyeCenter, _brfManager.task, _brfManager.nextTask);
			//super.showResult(); shows the face shape and the face detection areas.
			super.showResult(showAll);
		}
	}
}