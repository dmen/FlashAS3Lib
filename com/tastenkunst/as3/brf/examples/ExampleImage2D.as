package com.tastenkunst.as3.brf.examples {
	import com.tastenkunst.as3.brf.container.Images2D;

	import flash.geom.Rectangle;

	/**
	 * Example for a still image and a 2d png image as content overlay.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleImage2D extends BRFBasisImage {
		
		[Embed(source="user_image.png")]
		private var IMAGE : Class;
		
		public function ExampleImage2D() {
			super();
        }
		
		override public function initVideoHandling() : void {
			_image = new IMAGE();
			super.initVideoHandling();
			
			//no 3d? then add the input image to the display list.
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		
		override public function initContentContainer() : void {
			_contentContainer = new Images2D(_containerContent);
			_contentContainer.init(new Rectangle(0, 0, 640, 480));
		}
				
		override public function showResult(showAll : Boolean = false) : void {
			//updating the glasses here. In 3D mode the IBRFContentContainer will be updated
			//by the BRFManager directly.
			_contentContainer.updatePoseByEyes(_brfManager.faceShape.pointLeftEyeCenter, 
				_brfManager.faceShape.pointRightEyeCenter, _brfManager.task, _brfManager.nextTask);
			//super.showResult(); shows the face shape and the face detection areas.
			super.showResult(showAll);
		}
	}
}