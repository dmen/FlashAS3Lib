package com.gmrmarketing.sap.levisstadium.avatar.testing
{	
	import com.gmrmarketing.utilities.LoggerAIR;
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.ui.*;	
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.SerProxy_Connector;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.AIRXML;
	
	
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
		
		private var resetTimer:Timer;	
		
		private var ser:SerProxy_Connector;//for talking to Arduino		
		private var servoTimer:Timer;//delays successive servo writes		
		private var currentAngle:Number; //current servo angle - starts at 90
		private var angleDelta:Number;
		private var photoAngle:Number; //currentAngle when a photo is taken - only used for stats - saved in log in saveImage
		
		private var bgd:BGDisplay; //for displaying background on 2nd monitor
		private var bgLoader:Loader; //for loading the bg images
		
		private var log:Logger;
		private var config:AIRXML;
		
		private var angleDefault:int = 90;
		private var angleMin:int = 60;
		private var angleMax:int = 120;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.align = StageAlign.TOP_LEFT;				
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 36;
			//Mouse.hide();
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset);
			tim.init(60000);//startMonitoring() called in showPreview() / stopped in reset()
			
			resetTimer = new Timer(10000, 1);
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			log = new Logger();
			log.setLogger(new LoggerAIR());
			log.log("Application Start");
			
			ser = new SerProxy_Connector();
			ser.addEventListener(SerProxy_Connector.SER_LOG, logSerProxy);
			ser.connect();
			
			servoTimer = new Timer(50);
			servoTimer.addEventListener(TimerEvent.TIMER, setServoAngle);
			
			intro = new Intro();			
			intro.setContainer(mainContainer);
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			review = new Review();
			review.setContainer(mainContainer);			
			
			preview = new Webcam3D_1280x960();
			preview.addEventListener(Webcam3D_1280x960.FACE_FOUND, autoStart);
			
			reg = new Registration();			
			reg.setContainer(mainContainer);
			
			mainContainer.addChild(preview);//inits BRF with added to stage			
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			bgd = new BGDisplay();
			bgLoader = new Loader();
			
			config = new AIRXML(); //reads config.xml in the apps folder
			config.addEventListener(Event.COMPLETE, configReady);
			config.readXML();
			
			intro.show();
			intro.addEventListener(Intro.MANUAL_START, gotRFID);
			bgChange(); //show default 2014 bg
		}
		
		
		private function configReady(e:Event):void
		{	
			var xm:XML = AIRXML(e.currentTarget).getXML();
			angleDefault = parseInt(xm.defaultAngle);
			angleMin = parseInt(xm.minAngle);
			angleMax = parseInt(xm.maxAngle);
			
			currentAngle = angleDefault;
			angleDelta = 0;
			setServoAngle();//reset to straight on camera	
		}
		
		
		private function logSerProxy(e:Event):void
		{
			log.log(ser.getLogMessage());
		}		
		
		
		private function autoStart(e:Event):void
		{
			log.log("Face Detected - starting interaction");
			gotRFID();
		}
		
		
		private function gotRFID(e:Event = null):void
		{
			if(e != null){
				log.log("Face Not Detected - manual start of interaction");
			}
			if(preview.isBrfReady()){
				preview.removeEventListener(Webcam3D_1280x960.FACE_FOUND, autoStart);
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
			resetTimer.reset();
			
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
			
			bgChange(); //show default 2014 bg
		}
		
		
		private function bgChange(e:Event = null):void
		{
			var yr:String = preview.getBackgroundYear();

			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaded, false, 0, true);
			
			switch(yr) {
				case "0":					
					bgd.showSlideshow();
					break;
				case "2014":					
					bgLoader.load(new URLRequest("backgrounds/bg2014.png"));
					break;
				case "2005":
					bgLoader.load(new URLRequest("backgrounds/bg2005.png"));
					break;
				case "1996":
					bgLoader.load(new URLRequest("backgrounds/bg1996.png"));
					break;
				case "1994":
					bgLoader.load(new URLRequest("backgrounds/bg1994.png"));
					break;
				case "1984":
					bgLoader.load(new URLRequest("backgrounds/bg1984.png"));
					break;
				case "1963":
					bgLoader.load(new URLRequest("backgrounds/bg1963.png"));
					break;
				case "1952":
					bgLoader.load(new URLRequest("backgrounds/bg1952.png"));
					break;
				case "1946":
					bgLoader.load(new URLRequest("backgrounds/bg1946.png"));
					break;
			}
		}
		
		
		private function bgLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;			
			bgd.showImage(b);
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
			log.log("Photo Taken - showing review");
			photoAngle = currentAngle;
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
			log.log("Retake Photo");
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
			log.log("Beginning Registration");
			review.removeEventListener(Review.RETAKE, retake);
			review.removeEventListener(Review.SAVE, save);
			
			tim.buttonClicked();//timeout helper
			
			reg.show(review.getCard());//show registration screen - email only to confirm... card maged used on end screen in reg
			reg.addEventListener(Registration.REG_COMPLETE, saveImage, false, 0, true);
			reg.addEventListener(Registration.RESET, regReset, false, 0, true);
			reg.addEventListener(Registration.REG_LOG, logRegistration, false, 0, true);
		}		
		
		
		/**
		 * Callback from Registration Complete
		 * @param	e Registration.COMPLETE event
		 */
		private function saveImage(e:Event):void
		{		
			log.log("Registration Complete - photo has been saved - photo angle: " + photoAngle);
			reg.removeEventListener(Registration.REG_COMPLETE, saveImage);			
			reg.removeEventListener(Registration.RESET, regReset);	
			reg.removeEventListener(Registration.REG_LOG, logRegistration);
			reset();
		}
		
		
		private function regReset(e:Event):void
		{
			reg.removeEventListener(Registration.REG_COMPLETE, saveImage);	
			reg.removeEventListener(Registration.RESET, regReset);	
			reg.removeEventListener(Registration.REG_LOG, logRegistration);
			log.log("Registration Reset - user pressed close button");
			reset();
		}
		
		private function logRegistration(e:Event):void
		{
			log.log(reg.getLogMessage());
		}
		
		/**
		 * Done - write session.json and delete visitor.json
		 * @param	e
		 */
		private function reset(e:Event = null):void
		{	
			if (e != null) {
				log.log("Application timed out - resetting");
			}
			
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
			
			//reset cam to default
			currentAngle = angleDefault;
			setServoAngle();//reset to straight on camera		
			
			bgChange(); //show default bg
			
			resetTimer.addEventListener(TimerEvent.TIMER, enableTracking, false, 0, true);
			resetTimer.start();
		}
		
		//re-enable tracking after 10 sec.
		private function enableTracking(e:TimerEvent):void
		{
			preview.addEventListener(Webcam3D_1280x960.FACE_FOUND, autoStart);
		}
		
		
		private function moveCamUp(e:Event):void
		{
			angleDelta = -1;	
			setServoAngle();
			
			servoTimer.start();//calls setServoAngle every 50ms until stopCam is called
		}
		
		
		private function moveCamDown(e:Event):void
		{
			angleDelta = 1;
			setServoAngle();
			
			servoTimer.start();//calls setServoAngle every 50ms until stopCam is called
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
			currentAngle += angleDelta;
			
			if (currentAngle > angleMax) {
				currentAngle = angleMax;				
			}
			if (currentAngle < angleMin) {
				currentAngle = angleMin;				
			}
			
			var ba:ByteArray = new ByteArray();
			ba.writeByte(currentAngle);
			ser.send(ba);
			//log.log("Main.setServoAngle: " + currentAngle);
		}
		
		
		/**
		 * called when four-taps upper left is detected by CornerQuit
		 * @param	e
		 */
		private function quitApp(e:Event):void
		{
			log.log("Application Exiting from four taps");
			NativeApplication.nativeApplication.exit();
		}
	}
	
}