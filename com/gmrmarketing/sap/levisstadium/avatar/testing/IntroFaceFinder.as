/*** NOT USED ***/

package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.geom.*;
	import com.tastenkunst.as3.brf.vars.FaceDetectionVars;
	import com.tastenkunst.as3.brf.BRFUtils;
	import com.tastenkunst.as3.brf.BeyondRealityFaceManager;
	import flash.utils.Timer;
	
	public class IntroFaceFinder extends EventDispatcher
	{
		public static const START_APP:String = "appStart"; //face recognized
		private var _brfManager:BeyondRealityFaceManager;
		private var stageRef:Stage;
		private var camBMP:BitmapData;
		private var _brfReady:Boolean;
		private var cam:Camera;
		private var vid:Video;
		private var faceFoundTimer:Timer;
		
		
		public function IntroFaceFinder($stageRef:Stage)
		{
			stageRef = $stageRef;
			camBMP = new BitmapData(640, 480, false, 0x000000);
			_brfReady = false;
			
			cam = Camera.getCamera();
			cam.setMode(640, 480, 30, false);
			
			vid = new Video(640, 480);
			vid.attachCamera(cam);
			
			faceFoundTimer = new Timer(1000, 1);
			faceFoundTimer.addEventListener(TimerEvent.TIMER, startApp, false, 0, true);
			
			_brfManager = new BeyondRealityFaceManager(stageRef);
			_brfManager.addEventListener(Event.INIT, onInitBRF);
		}
		
		
		private function onInitBRF(e:Event):void
		{
			_brfManager.removeEventListener(Event.INIT, onInitBRF);
			_brfManager.addEventListener(BeyondRealityFaceManager.READY, onReadyBRF);			
			_brfManager.init(camBMP);
		}
		
		
		private function onReadyBRF(e:Event):void
		{
			_brfManager.removeEventListener(BeyondRealityFaceManager.READY, onReadyBRF);
			
			//disables face estimation and pose estimation
			_brfManager.isEstimatingFace = true;
			_brfManager.deleteLastDetectedFace = true;			
			
			_brfManager.vars.faceDetectionVars.baseScale = 2.0;			
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;			
			_brfManager.vars.faceDetectionVars.maxScale = 5.0;
			_brfManager.vars.faceDetectionVars.minRectsToFind = 12;
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;
			
			_brfReady = true;
			stageRef.addEventListener(Event.ENTER_FRAME, onVideoUpdate, false, 0, true);			
		}
		
		
		private function onVideoUpdate(e:Event) : void 
		{			
			if (_brfReady) {
				camBMP.draw(vid);				
				_brfManager.update();
				var rect : Rectangle = _brfManager.lastDetectedFace;
				if (rect != null) {
					faceFoundTimer.start();
				}else {
					faceFoundTimer.reset();
				}
			}
		}
		
		
		/**
		 * Called when a face has been found continuously for 1 sec
		 * @param	e
		 */
		private function startApp(e:TimerEvent):void
		{
			stageRef.removeEventListener(Event.ENTER_FRAME, onVideoUpdate);
			faceFoundTimer.reset();
			_brfManager = null;
			dispatchEvent(new Event(START_APP));
		}
		
	}	
}