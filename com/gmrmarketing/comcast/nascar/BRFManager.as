package com.gmrmarketing.comcast.nascar
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.geom.*;
	import com.tastenkunst.as3.brf.vars.FaceDetectionVars;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	
	public class BRFManager extends EventDispatcher
	{
		public static const READY:String = "BRFisReady";
		private var _brfManager:BeyondRealityFaceManager;
		private var stageRef:Stage;
		private var brfBMD:BitmapData;//640x480 bitmapData BRF requires		
		private var mode:String; //track or estimate - default to track
		
		public function BRFManager()
		{
			brfBMD = new BitmapData(640, 480, false, 0x000000);
		}
		
		
		public function init($stageRef:Stage, $bitmapDataRef:BitmapData):void
		{
			stageRef = $stageRef;
			brfBMD = $bitmapDataRef;
			
			_brfManager = new BeyondRealityFaceManager(stageRef);
			_brfManager.addEventListener(Event.INIT, onInitBRF);
		}
		
		
		private function onInitBRF(e:Event):void
		{
			trace("onInitBRF");
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);			
			_brfManager.init(brfBMD);
		}
		
		
		private function onReadyBRF(e:Event):void
		{
			trace("onReadyBRF");
			_brfManager.removeEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			
			_brfManager.isEstimatingFace = false;//default to tracking only
			_brfManager.deleteLastDetectedFace = true;
			
			_brfManager.vars.faceDetectionVars.baseScale = 1.0;			
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;			
			_brfManager.vars.faceDetectionVars.maxScale = 5.0;
			_brfManager.vars.faceDetectionVars.minRectsToFind = 12;
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;
			
			_brfManager.vars.poseEstimationVars.perspectiveCorrection = true;
			
			dispatchEvent(new Event(READY));	
		}
		
		
		public function reset(mode:String = "track"):void
		{
			if(mode == "track"){
				_brfManager.isEstimatingFace = false;
				_brfManager.deleteLastDetectedFace = true;
			}else {
				_brfManager.isEstimatingFace = true;
				_brfManager.deleteLastDetectedFace = false;
			}
			
			_brfManager.reset();
		}
		
		
		/**
		 * Call this whenever data in the passed in bitmapData reference changes
		 * @param	updateImage
		 */
		public function update():void 
		{					
			//brfBMD.draw(updateImage);				
			_brfManager.update();			
		}		
		
	}
	
}