package com.tastenkunst.as3.brf.simpleapps {
	import com.adobe.images.PNGEncoder;
	import com.tastenkunst.as3.brf.container.*;
	import com.tastenkunst.as3.brf.examples.BRFBasicWebcam;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.utils.ByteArray;

	/**
	 * This is a simple example of what you 
	 * can do with Flare3D v2.0 (Flash Player 11/Stage3D).
	 * You can find the layout elements in the FLA file (fla/BRFLayoutAssets.fla)
	 * 
	 * @author Marcel Klammer, 2012
	 */
	public class SimpleAppWebcam extends BRFBasicWebcam {
		
		public var _layout : BRFLayoutFP11;
		public var _container3D : BRFContainerFP11;
		
		protected var _modelBlue : String = "media/f3d/brf_fp11_glasses_blue.zf3d";
		protected var _modelRed : String = "media/f3d/brf_fp11_glasses_rudy_project_red.zf3d";
		protected var _modelOcclusion : String = "media/f3d/brf_fp11_occlusion_head.zf3d";
		
		public function SimpleAppWebcam() {
			super();
		}
		//add some buttons to the stage
		override public function initGUI() : void {
			super.initGUI();
			
			_layout = new BRFLayoutFP11();			
			_layout._btDownload.addEventListener(MouseEvent.CLICK, onClickedDownload);
			_layout._btWebcam.addEventListener(MouseEvent.CLICK, onClickedWebcam);
			_layout._btCam.addEventListener(MouseEvent.CLICK, onClickedSnapshot);
			_layout._bt0.addEventListener(MouseEvent.CLICK, onClickedLoadModel);
			_layout._bt1.addEventListener(MouseEvent.CLICK, onClickedLoadModel);
			
			addChild(_layout);
		}
		//change default behaviour
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			
			_brfManager.vars.faceEstimationVars.isStabilizingSlowMovements = true;
		}
		//change the 3d model
		private function onClickedLoadModel(event : MouseEvent) : void {
			switch(event.currentTarget){
				case _layout._bt0: _container3D.model = _modelBlue; break;
				case _layout._bt1: _container3D.model = _modelRed; break;
			}
		}
		//pause the whole tracking
		private function onClickedSnapshot(event : MouseEvent) : void {
			_videoManager.stop();
			
			_layout._btCam.visible = false;
			_layout._btWebcam.visible = true;
			_layout._btDownload.visible = true;
		}
		//restart the tracking
		private function onClickedWebcam(event : MouseEvent) : void {
			_brfManager.reset();
			_videoManager.start();
				
			_layout._btCam.visible = true;
			_layout._btWebcam.visible = false;
			_layout._btDownload.visible = false;
		}
		//Let's make a nice little screenshot and save it!
		private function onClickedDownload(event : MouseEvent) : void {
			var bmd : BitmapData = _container3D.getScreenshot();
			var image : ByteArray = PNGEncoder.encode(bmd);
			var fr : FileReference = new FileReference();
			fr.save(image, "brf_snapshot.png");
		}
		//init the Flare3D v2.0 container, init the 3d webcam video plane and set the first model
		override public function initContentContainer() : void {
			//you can use either Flare3D v2.5
			_container3D = new Flare3D_v2_5(_containerContent);
			_modelBlue = "media/f3d/brf_fp11_glasses_blue.zf3d";
			_modelRed = "media/f3d/brf_fp11_glasses_rudy_project_red.zf3d";
			_modelOcclusion = "media/f3d/brf_fp11_occlusion_head.zf3d";
			
			//or Away3D v4.1.4
//			_container3D = new Away3D_v4_1(_containerContent);
//			_modelBlue = "media/awd/glasses.awd";
//			_modelRed = "media/awd/glasses_red.awd";
//			_modelOcclusion = "media/awd/occlusion.awd";
			
			_container3D.init(new Rectangle(0, 0, 640, 480));
			_container3D.initVideo(_videoManager.videoData);
			_container3D.initOcclusion(_modelOcclusion);
			_container3D.model = _modelBlue;

			_contentContainer = _container3D;
		}
		//update the 3d webcam video plane, when there is a new image from the webcam
		override public function onVideoUpdate() : void {
			super.onVideoUpdate();
			_container3D.updateVideo();
		}
		//We don't want to see the green shape, so don't call super.showResult();
		override public function showResult(showAll : Boolean = false) : void {
//			super.showResult();
		}
	}
}