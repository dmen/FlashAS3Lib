package com.tastenkunst.as3.brf.examples {
	import flash.events.Event;
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import com.tastenkunst.as3.brf.BRFStatus;
	import com.tastenkunst.as3.brf.BRFUtils;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import com.gmrmarketing.utilities.SerProxy_Connector;


	/**
	 * This example only does the face detection. No face or pose estimation here.
	 * 
	 * @author Marcel Klammer, 2011
	 */
	public class ExampleWebcamFaceDetection extends BRFBasicWebcam 
	{
		private var sp:SerProxy_Connector
		private var ba:ByteArray;
			
		
		private var midFaceY:int = 0;
		private var errorWindow:int = 30;
		private var midScreenY:int = 480;
		
		//min max servo angles - 90 is straight up
		private var minAngle:int = 60;
		private var maxAngle:int = 120;
		private var curAngle:int = 90;
		private const INIT_ANGLE:int = 90;
		private var angleStep:int = 3;
		private var servoFinishedMoving:Boolean;
		private var servoDelayTimer:Timer;//delays successive servo writes
		
		private var resetTimer:Timer; //started if the face is lost - resets cam if lost for too long
		private const SERVO_ENABLED:Boolean = true;
		
		
		public function ExampleWebcamFaceDetection() 
		{
			super();
			
			if(SERVO_ENABLED){
				sp = new SerProxy_Connector();
				sp.connect();
			}
			
			servoDelayTimer = new Timer(200, 1);
			servoDelayTimer.addEventListener(TimerEvent.TIMER, servoComplete, false, 0, true);
			
			resetTimer = new Timer(6000, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, resetCam, false, 0, true);			
			
			setServoAngle(INIT_ANGLE);			
		}	
		
		
		/** 
		 * If you don't use Stage3D (there you have to draw the videoData on a 3D plane), you
		 * have to add the videoBitmap into _containerVideo.
		 */
		override public function initVideoHandling() : void {
			super.initVideoHandling();
			_containerVideo.addChild(_videoManager.videoBitmap);
		}
		
		
		/** When you disable face estimation, the pose estimation is disabled, too.*/
		override public function onReadyBRF(event : Event = null) : void {
			super.onReadyBRF(event);
			
			//disables face estimation and pose estimation
			_brfManager.isEstimatingFace = false;
		}
		
		
		override public function showResult(showAll : Boolean = false) : void {
			_draw.clear();
			ba = new ByteArray();
			//drawROIs();
			
			var rect : Rectangle = _brfManager.lastDetectedFace;
			if (rect != null) {
				
				resetTimer.reset();
				
				_draw.lineStyle(1, 0xffff00, 1);
				_draw.drawRect(rect.x*2, rect.y*2, rect.width*2, rect.height*2);
				_draw.lineStyle();
				
				midFaceY = rect.y*2 + ((rect.height*2) * .5);
				
				if(servoFinishedMoving){
					if (midFaceY < (midScreenY - errorWindow)) {
						curAngle -= angleStep;
						if (curAngle < minAngle) {
							curAngle = minAngle;							
						}
						setServoAngle(curAngle);
						
					}else if (midFaceY > (midScreenY + errorWindow)) {
						curAngle += angleStep;
						if (curAngle > maxAngle) {
							curAngle = maxAngle;							
						}
						setServoAngle(curAngle);
					}
				}
			}else {
				//rect is null - face is lost
				_brfManager.reset(); //reset to start detecting again				
				resetTimer.start();//calls resetCam() if it times out				
			}
		}			
			
		
		//just to remove stats
		override public function initGUI() : void {			
			
			_containerVideo = new Sprite();
			_containerDraw = new Sprite();
			_containerContent = new Sprite();
			//_stats = new Stats();
			
			_draw = _containerDraw.graphics;
			//_stats.x = 640 - 70;
			//_stats.y = 380;
						
			addChild(_containerVideo);
			addChild(_containerDraw);
			addChild(_containerContent);
			//addChild(_stats);
		}
		
		
		private function setServoAngle(ang:int):void
		{			
			if(SERVO_ENABLED){
				ba = new ByteArray();
				ba.writeByte(ang);
				sp.send(ba);
				
				servoFinishedMoving = false;
				servoDelayTimer.start();
			}
		}
		
		
		private function servoComplete(e:TimerEvent):void
		{
			servoFinishedMoving = true;
		}
		
		
		private function resetCam(e:TimerEvent):void
		{
			setServoAngle(INIT_ANGLE);//reset to straight on
		}
		
	}
}
