package com.gmrmarketing.sap.levisstadium.avatar.testing
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;	
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.SerProxy_Connector;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var preview:Webcam3D_1280x960; //web cam preview - with facial recognition
		private var countdown:Countdown; //3-2-1 counter with white flash
		private var review:Review; //screen to review the pic that was taken
		private var reg:Registration; //email,name registration dialogs
		
		private var avatarImage:BitmapData;
		
		private var cq:CornerQuit;
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var tim:TimeoutHelper;
		
		private var rfidTimer:Timer;	
		
		private var ser:SerProxy_Connector;//for talking to Arduino		
		private var servoTimer:Timer;//delays successive servo writes		
		private var currentAngle:int; //current servo angle - starts at 90
		private var angleDelta:int;
		
		private var bgd:BGDisplay; //for displaying background on 2nd monitor
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.align = StageAlign.TOP_LEFT;				
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 36;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			tim.init(120000);//startMonitoring() called in showPreview() / stopped in reset()
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			ser = new SerProxy_Connector();
			ser.connect();
			
			servoTimer = new Timer(100);
			servoTimer.addEventListener(TimerEvent.TIMER, setServoAngle, false, 0, true);
			
			intro = new Intro();			
			intro.setContainer(mainContainer);
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			review = new Review();
			review.setContainer(mainContainer);			
			
			preview = new Webcam3D_1280x960();
			preview.addEventListener(Webcam3D_1280x960.FACE_FOUND, gotRFID, false, 0, true);
			
			reg = new Registration();
			reg.setContainer(mainContainer);
			
			mainContainer.addChild(preview);//inits BRF with added to stage			
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			//bgd = new BGDisplay();
			
			currentAngle = 90;
			setServoAngle();//reset to straight on camera
			
			intro.show();
			intro.addEventListener(Intro.MANUAL_START, gotRFID, false, 0, true);
		}
		
		
		/**
		 * called by listener once visitor.json appears in the c:\fish folder
		 * calls the web service to get the users data from the rfid tag
		 * @param	e
		 */
		private function gotRFID(e:Event):void
		{
			if(preview.isBrfReady()){
				preview.removeEventListener(Webcam3D_1280x960.FACE_FOUND, gotRFID);
				intro.removeEventListener(Intro.MANUAL_START, gotRFID);				
				
				intro.hide();
				showPreview();
			}			
		}
	
		
		/**
		 * Called by listener on the comm object once the tag_id is sent to the server
		 * and the user data is returned and ready
		 * 
		 * UPDATE - also called on User Error if null or empty data is returned
		 * from the webservice... 
		 * @param	e
		 */
		private function showPreview(e:Event = null):void
		{				
			preview.addEventListener(Webcam3D_1280x960.TAKE_PHOTO, startCountdown, false, 0, true);			
			preview.addEventListener(Webcam3D_1280x960.CLOSE_PREVIEW, reset, false, 0, true);
			preview.addEventListener(Webcam3D_1280x960.CAM_UP, moveCamUp, false, 0, true);
			preview.addEventListener(Webcam3D_1280x960.CAM_DOWN, moveCamDown, false, 0, true);
			preview.addEventListener(Webcam3D_1280x960.CAM_STOP, stopCam, false, 0, true);
			preview.addEventListener(Webcam3D_1280x960.BG_CHANGE, bgChange, false, 0, true);
			
			preview.show();
			if(!mainContainer.contains(preview)){
				mainContainer.addChild(preview);
			}
			
			intro.hide();
			tim.startMonitoring();
		}
		
		
		private function bgChange(e:Event):void
		{
			var yr:String = preview.getBackgroundYear();
			//bgd.showImage(new car1920());
			
			switch(yr) {
				case "2014":
					break;
				case "2005":
					break;
				case "1996":
					break;
				case "1994":
					break;
				case "1984":
					break;
				case "1963":
					break;
				case "1959":
					break;
				case "1946":
					break;
			}
		}
		
		
		/**
		 * called when take pic button is pressed in in preview
		 * @param	e
		 */
		private function startCountdown(e:Event):void
		{		
			tim.buttonClicked();
			preview.removeEventListener(Webcam3D_1280x960.TAKE_PHOTO, startCountdown);
			countdown.addEventListener(Countdown.WHITE_FLASH, takePhoto, false, 0, true);
			countdown.show();
		}
		
		
		/**
		 * Called when thecountdown hits 0
		 * Gets the pic and then adds listener to wait for flash to fade 
		 * @param	e
		 */
		private function takePhoto(e:Event):void
		{
			avatarImage = preview.shotReady();
			countdown.removeEventListener(Countdown.WHITE_FLASH, takePhoto);
			countdown.addEventListener(Countdown.FLASH_COMPLETE, showReview, false, 0, true);
			countdown.doFlash();
		}
		
		
		/**
		 * Whiteflash now faded out
		 * Show review screen
		 * @param	e
		 */
		private function showReview(e:Event):void
		{
			countdown.hide();			
			countdown.removeEventListener(Countdown.FLASH_COMPLETE, showReview);	
			preview.pause();
			review.show(avatarImage);
			review.addEventListener(Review.RETAKE, retake, false, 0, true);
			review.addEventListener(Review.SAVE, save, false, 0, true);
			review.addEventListener(Review.RESET, reset, false, 0, true);
		}
		
		
		/**
		 * Called if Retake is pressed within the review screen
		 * @param	e
		 */
		private function retake(e:Event):void
		{
			tim.buttonClicked();			
			review.removeEventListener(Review.RETAKE, retake);
			review.removeEventListener(Review.SAVE, save);
			review.removeEventListener(Review.RESET, reset);
			review.hide();
			
			preview.unPause();
			preview.addEventListener(Webcam3D_1280x960.TAKE_PHOTO, startCountdown, false, 0, true);
			preview.addListeners();
		}
		
		
		/**
		 * Called when the save button is pressed in the review dialog
		 * Shows the thanks dialog and waits for it to show before making the
		 * call to saveImage - this is because the b64 encode blocks processes
		 * @param	e
		 */
		private function save(e:Event):void
		{
			review.removeEventListener(Review.RETAKE, retake);
			review.removeEventListener(Review.SAVE, save);
			
			tim.buttonClicked();//timeout helper
			
			reg.show(review.getCard());//show registration screen - email only to confirm...
			reg.addEventListener(Registration.REG_COMPLETE, saveImage, false, 0, true);
		}		
		
		
		/**
		 * Callback from Registration Complete
		 * @param	e Registration.COMPLETE event
		 */
		private function saveImage(e:Event):void
		{		
			reg.removeEventListener(Registration.REG_COMPLETE, saveImage);			
			reset();
		}
		
		
		/**
		 * Done - write session.json and delete visitor.json
		 * @param	e
		 */
		private function reset(e:Event = null):void
		{	
			preview.removeEventListener(Webcam3D_1280x960.CLOSE_PREVIEW, reset);
			review.removeEventListener(Review.RESET, reset);
			
			tim.stopMonitoring();
			reg.hide();
			preview.hide();
			review.hide();			
			
			intro.show();			
			intro.addEventListener(Intro.MANUAL_START, gotRFID, false, 0, true);
			
			//turn off estimation and re-enable tracking only
			preview.unPause();
			preview.track();
			
			//reset cam to 90
			currentAngle = 90;
			setServoAngle();//reset to straight on camera
			
			var resetTimer:Timer = new Timer(10000, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, enableTracking, false, 0, true);
			resetTimer.start();
		}
		
		//re-enable tracking after 10 sec.
		private function enableTracking(e:TimerEvent):void
		{
			preview.addEventListener(Webcam3D_1280x960.FACE_FOUND, gotRFID, false, 0, true);
		}
		
		
		private function moveCamUp(e:Event):void
		{
			angleDelta = -2;	
			setServoAngle();
			servoTimer.start();
		}
		
		
		private function moveCamDown(e:Event):void
		{
			angleDelta = 2;
			setServoAngle();
			servoTimer.start();
		}
		
		private function stopCam(e:Event):void
		{
			servoTimer.reset();
		}
		
		
		/**
		 * Sets the servo to currentAngle
		 */
		private function setServoAngle(e:TimerEvent = null):void
		{			
			var ba:ByteArray = new ByteArray();
			
			currentAngle += angleDelta;
			
			if (currentAngle > 120) {
				currentAngle = 120;				
			}
			if (currentAngle < 60) {
				currentAngle = 60;				
			}
			ba.writeByte(currentAngle);
			ser.send(ba);
		}
		
		
		/**
		 * called when four-taps upper left is detected by CornerQuit
		 * @param	e
		 */
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}