package com.tastenkunst.as3.brf.examples {
	import com.tastenkunst.as3.brf.container.BRFContainerFP11;
	import com.tastenkunst.as3.brf.container.Flare3D_v2_5;

	import flash.geom.Rectangle;

	/**
	 * Example for a still image and a 3d model.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleImage3D extends BRFBasisImage {

		[Embed(source="user_image.png")]
		public var IMAGE : Class;
		
		public var _container3D : BRFContainerFP11;
		
		public function ExampleImage3D() {
			super();
		}

		override public function initVideoHandling() : void {
			_image = new IMAGE();
			
			super.initVideoHandling();
			
			//using 3d? then do not add the input image to the display list.
			//otherwise Stage3D will be covered by this image.oto
//			_containerVideo.addChild(_videoManager.videoBitmap);
		}
				
		override public function initContentContainer() : void {			
			var model : String;
			//you can use either Flare3D v2.5
			_container3D = new Flare3D_v2_5(_containerContent);
			model = "media/f3d/brf_fp11_glasses_blue.zf3d";
			
			//or Away3D v4.1.4
			//_container3D = new Away3D_v4_1(_containerContent);
			//model = "media/awd/glasses.awd";
			
			_container3D.init(new Rectangle(0, 0, 640, 480));
			_container3D.initVideo(_videoManager.videoData);
			_container3D.model = model;

			_contentContainer = _container3D;
		}
		//update the 3d webcam video plane, when there is a new image from the webcam
		override public function onVideoUpdate() : void {
			super.onVideoUpdate();
			_container3D.updateVideo();
		}
				
		override public function showResult(showAll : Boolean = false) : void {
			//decide whether to draw the face shape or not.
			super.showResult(showAll);
		}
	}
}

