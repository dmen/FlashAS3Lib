package com.gmrmarketing.sap.levisstadium.avatar.testing {
	import flash.events.Event;
	import flash.display.*;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
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
		private var sp:SerProxy_Connector;
		private var ba:ByteArray;			
		
		private var midFaceY:int = 0;
		private var errorWindow:int = 30;
		private var midScreenY:int = 480;
		
		//min max servo angles - 90 is straight up
		private var minAngle:int = 50;
		private var maxAngle:int = 110;
		private var curAngle:int = 90;
		private const INIT_ANGLE:int = 90;
		private var angleStep:int = 2;
		private var servoFinishedMoving:Boolean;
		private var servoDelayTimer:Timer;//delays successive servo writes
		
		private var resetTimer:Timer; //started if the face is lost - resets cam if lost for too long
		private const SERVO_ENABLED:Boolean = true;
		private var faceLostTimer:Timer;		
		
		
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
			
			faceLostTimer = new Timer(4000, 1);
			faceLostTimer.addEventListener(TimerEvent.TIMER, faceLost, false, 0, true);
			
			setServoAngle(60);			
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
		override public function onReadyBRF(event : Event = null) : void 
		{			
			//disables face estimation and pose estimation
			_brfManager.isEstimatingFace = false;
			_brfManager.deleteLastDetectedFace = true;
			
			//base scale is the starting depth. Change it to 2 to find small faces in
			//the image (eg. when people are standing far away from the camera)
			//For an installation at the client, the user will stand in front of
			//the screen/camera at a very certain distance, I would suggest to
			//choose one base scale, scaleIncrement 0.1 and only maxScale = baseScale + 1.0
			//This way the user has to stay in the distance from the screen you want him
			//to be.
			_brfManager.vars.faceDetectionVars.baseScale = 2.0;
			//step size of the depth
			//so: starting with 4, 4.5, 5, 5.5, 6.0 face size are searched for
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.5;
			//end scale for depth search
			_brfManager.vars.faceDetectionVars.maxScale = 5.0;
			
			//set this to a high number to get more results --defaults to 12
			_brfManager.vars.faceDetectionVars.minRectsToFind = 12;
			
			//add some space between the face rectangles searches. default is 0.02, 
			//which is really few space between the rects
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;			
			
			super.onReadyBRF(event);
			
		}
		
		
		override public function showResult(showAll : Boolean = false) : void {
			_draw.clear();
			ba = new ByteArray();
			//drawROIs();
			
			var rect : Rectangle = _brfManager.lastDetectedFace;
			if (rect != null) {
				faceLostTimer.reset();
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
				faceLostTimer.start();
				_brfManager.reset(); //reset to start detecting again				
				resetTimer.start();//calls resetCam() if it times out				
			}
		}			
		
		private function faceLost(e:TimerEvent):void
		{
			setServoAngle(INIT_ANGLE);		
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
