package com.gmrmarketing.sap.levisstadium.avatar.testing {
	import flash.events.Event;
	import flash.display.*;
	import flash.events.MouseEvent;
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
	public class ExampleWebcamFaceDetection_manualMove extends BRFBasicWebcam 
	{
		private var sp:SerProxy_Connector
		private var ba:ByteArray;			
		
		private var midFaceY:int = 0;
		private var errorWindow:int = 30;
		
		//min max servo angles - 90 is straight up
		private var minAngle:int = 40;
		private var maxAngle:int = 120;
		private var curAngle:int = 90;
		private const INIT_ANGLE:int = 90;
		private var angleStep:int;
		private var servoDelayTimer:Timer;//delays successive servo writes		
		
		private var frame:MovieClip;//mcFrame lib clip
		private var startTimer:Timer; //starts the app if a face is found for more than .5 sec
		
		
		public function ExampleWebcamFaceDetection_manualMove() 
		{
			super();
			
			sp = new SerProxy_Connector();
			sp.connect();
			
			frame = new mcFrame(); 
			
			startTimer = new Timer(500, 1);
			startTimer.addEventListener(TimerEvent.TIMER, startApp, false, 0, true);
			
			servoDelayTimer = new Timer(50);
			servoDelayTimer.addEventListener(TimerEvent.TIMER, servoMove, false, 0, true);
			
			ba = new ByteArray();
			ba.writeByte(INIT_ANGLE);
			sp.send(ba);			
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
			//when isEstimatingFace is false face estimation and pose estimation are disabled
			_brfManager.isEstimatingFace = true;
			//if this is true then _brfManager.lastDetectedFace will be null when no face is detected (it's lost)
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
			_brfManager.vars.faceDetectionVars.scaleIncrement = 0.1;
			//end scale for depth search
			_brfManager.vars.faceDetectionVars.maxScale = 5.0;
			
			//set this to a high number to get more results --defaults to 12
			_brfManager.vars.faceDetectionVars.minRectsToFind = 12;
			
			//add some space between the face rectangles searches. default is 0.02, 
			//which is really few space between the rects
			_brfManager.vars.faceDetectionVars.rectIncrement = 0.05;			
			
			super.onReadyBRF(event);			
		}
		
		
		override public function showResult(showAll : Boolean = false) : void 
		{
			_draw.clear();
			ba = new ByteArray();
			//drawROIs();
			
			var rect : Rectangle = _brfManager.lastDetectedFace;
			if (rect != null) {
				startTimer.start();//calls startApp in .5 sec
				_draw.lineStyle(1, 0xffff00, 1);
				_draw.drawRect(rect.x*2, rect.y*2, rect.width*2, rect.height*2);
				_draw.lineStyle();
			}else {
				trace("rn");
				startTimer.reset();
				//rect is null - face is lost				
				//_brfManager.reset(); //reset to start detecting again			
			}
		}		
		
		
		//just to remove stats
		override public function initGUI() : void
		{	
			_containerVideo = new Sprite();
			_containerDraw = new Sprite();
			_containerContent = new Sprite();
			
			_draw = _containerDraw.graphics;		
			
			addChild(_containerVideo);
			addChild(_containerDraw);
			addChild(_containerContent);
			
			addChild(frame);
			frame.btnUp.addEventListener(MouseEvent.MOUSE_DOWN, servoUp, false, 0, true);			
			frame.btnDown.addEventListener(MouseEvent.MOUSE_DOWN, servoDown, false, 0, true);
			frame.stage.addEventListener(MouseEvent.MOUSE_UP, servoStop, false, 0, true);
		}
		
		
		private function startApp(e:TimerEvent):void
		{
			removeChild(frame);
			
		}
		
		
		private function servoUp(e:MouseEvent):void
		{
			angleStep = -2;
			servoMove();
			servoDelayTimer.start();
		}
		
		
		private function servoDown(e:MouseEvent):void
		{
			angleStep = 2;
			servoMove();
			servoDelayTimer.start();
		}
		
		
		private function servoStop(e:MouseEvent):void
		{
			servoDelayTimer.stop();
		}
		
		
		private function servoMove(e:TimerEvent = null):void
		{			
			curAngle += angleStep;
			if (curAngle < minAngle) {
				curAngle = minAngle;							
			}
			if (curAngle > maxAngle) {
				curAngle = maxAngle;
			}
			ba = new ByteArray();
			ba.writeByte(curAngle);
			sp.send(ba);
		}
		
	}
}
