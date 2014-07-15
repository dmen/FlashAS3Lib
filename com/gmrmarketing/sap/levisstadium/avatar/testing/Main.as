package com.gmrmarketing.sap.levisstadium.avatar.testing
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;	
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import com.dynamicflash.util.Base64;//nascar
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import com.gmrmarketing.utilities.SerProxy_Connector;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var preview:Webcam3D_1280x960; //web cam preview - with facial recognition
		private var countdown:Countdown; //3-2-1 counter with white flash
		private var review:Review; //screen to review the pic that was taken
		private var modal:Modal;//dialog
		private var comm:Comm; //server communication
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
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			tim.init(120000);//startMonitoring() called in showPreview() / stopped in reset()
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			ser = new SerProxy_Connector();
			ser.connect();
			
			servoTimer = new Timer(200);
			servoTimer.addEventListener(TimerEvent.TIMER, setServoAngle, false, 0, true);
			
			comm = new Comm();
			
			intro = new Intro();			
			intro.setContainer(mainContainer);
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			review = new Review();
			review.setContainer(mainContainer);
			
			modal = new Modal();
			modal.setContainer(mainContainer);
			
			preview = new Webcam3D_1280x960();
			preview.addEventListener(Webcam3D_1280x960.FACE_FOUND, gotRFID, false, 0, true);
			
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
				
				//RASCH MEETING
				intro.hide();
				showPreview();
			}
			/*
			//timer calls showRFIDModal() after 2 seconds - so unless the web
			//service is slow, it doesn't show...
			rfidTimer.start();
			
			comm.addEventListener(Comm.GOT_USER_DATA, showPreview, false, 0, true);
			//comm.addEventListener(Comm.USER_ERROR, userError, false, 0, true);
			comm.addEventListener(Comm.USER_ERROR, showPreview, false, 0, true);
			comm.addEventListener(Comm.TIMEOUT, commTimeout, false, 0, true);
			//get user data from the web service
			comm.userData(rfid.getVisitorID());
			*/
		}
		
		private function showRFIDModal(e:TimerEvent):void
		{
			//COMMENTED FOR OMNICOM MEETING
			//rfidTimer.reset();
			
			//set autoHide to false - so modal stays until kill() is called in showPreview()
			modal.show("please wait a moment while your data is retrieved...", "CARD DETECTED", false, false);			
		}
		
		
		/**
		 * Called by listener on the rfid object if the visitor.json file contains an 
		 * error string for the tag_id - ie if tag_id's value starts with 'A PROBLEM'
		 * visitor.json file deleted by rfid object when error is dispatched
		 * @param	e
		 */
		private function rfidError(e:Event):void
		{
			//COMMENTED FOR OMNICOM MEETING
			//rfidTimer.reset();
			
			modal.show("please see an SAP representative.", "RFID ERROR", false, true);	
			modal.addEventListener(Modal.HIDING, resetVisitor, false, 0, true);
		}
		
		
		private function resetVisitor(e:Event):void
		{
			modal.removeEventListener(Modal.HIDING, resetVisitor);
			//delete visitor.json and restart folder watching
			
			//OMNICOM
			//rfid.resetVisitor();
		}
		
		
		/**
		 * Called by listener on comm object if the tag_id passed to the web
		 * service returns null data - ie the user didn't go through reg
		 * @param	e
		 */
		private function userError(e:Event):void
		{		
			//OMNICOM
			//rfidTimer.reset();
			modal.show("please try again or see an SAP representative.", "INVALID CARD", true, false);
			//delete visitor.json and restart folder watching
			//OMNICOM
			//rfid.resetVisitor();
		}
		
		
		/**
		 * Called by listener on comm object if the call to userData takes longer than 45 seconds
		 * @param	e
		 */
		private function commTimeout(e:Event):void
		{
			modal.show("the call to retrieve user data from the card scan timed out, please try again or see an SAP representative.", "NETWORK TIMEOUT", false, true);
			modal.removeEventListener(Modal.HIDING, resetVisitor);
			modal.addEventListener(Modal.HIDING, timeoutReset, false, 0, true);
			
		}
		
		
		private function timeoutReset(e:Event):void
		{
			modal.removeEventListener(Modal.HIDING, timeoutReset);
			//delete visitor.json and restart folder watching
			//OMNICOM
			//rfid.resetVisitor();
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
			////OMNICOM
			//rfid2.removeEventListener(Rfid_touch.CLICKED, showPreview);
			//rfid2.hide();
			
			//rfidTimer.reset();			
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
			modal.kill();
			//OMNICOM
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
			//mainContainer.addChild(new Bitmap(avatarImage));
			review.show(avatarImage, comm.getUserData());//preview.getAlphaShot());// , 
			review.addEventListener(Review.RETAKE, retake, false, 0, true);
			review.addEventListener(Review.SAVE, save, false, 0, true);
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
			review.hide();
			
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
			tim.buttonClicked();//timeout helper
			
			modal.addEventListener(Modal.HIDING, reset, false, 0, true);
			modal.show("Thank you for showing your team spirit.\nFeel free to create as many players as you want.\nShare with your friends and compare to see\nwho makes the best 49ers player.", "THANK YOU", true, true, 7, false);
			TweenMax.delayedCall(.5, saveImage);			
		}		
		
		
		/**
		 * called after the thanks dialog is showing
		 * calls hide and then makes the call to saveImage 
		 * since saveImage blocks it will finish before the
		 * dialog hides...
		 * @param	e
		 */
		private function saveImage():void
		{			
			//ORIGINAL
			comm.saveImage(review.getCard(), "8675309");
			
			//OMNICOM - added saveImage2() method which takes email isntead of rfid
			//comm.saveImage(review.getCard(), "8675309");//RASCH MEETING
			//removeChild(email);
			//removeChild(kbd);
			
			//comm.saveImage2(review.getCard(), email.theEmail.text);
			//var im:String = getJpegString(review.getCard());
			//queue.add( { email:email.theEmail.text, image:im } );//nowpik
		}
		
		
		private function getJpegString(bmpd:BitmapData, q:int = 80):String
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return Base64.encodeByteArray(ba);
		}
		
		
		/**
		 * Done - write session.json and delete visitor.json
		 * @param	e
		 */
		private function reset(e:Event):void
		{	
			modal.removeEventListener(Modal.HIDING, reset);
			preview.removeEventListener(Webcam3D_1280x960.CLOSE_PREVIEW, reset);
		
			//Fish wants epoch time in seconds - not ms
			var epochSeconds:int = Math.floor(new Date().valueOf() / 60);
			//RASCH MEETING
			//rfid.writeSession( { "timestamp":epochSeconds, "session_id":"avatar", "tag_id":rfid.getVisitorID() } );
			
			tim.stopMonitoring();
			preview.hide();
			review.hide();
			
			//OMNICOM
			//rfid2.addEventListener(Rfid_touch.CLICKED, showPreview, false, 0, true);
			//rfid2.show();
			
			//OMNICOM
			intro.show();
			intro.addEventListener(Intro.SHOWING, killModal, false, 0, true);
			intro.addEventListener(Intro.MANUAL_START, gotRFID, false, 0, true);
			
			//turn off estimation and re-enable tracking only
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
		
		
		private function killModal(e:Event):void
		{
			modal.kill();
			////OMNICOM
			intro.removeEventListener(Intro.SHOWING, killModal);
		}
		
		
		private function moveCamUp(e:Event):void
		{
			angleDelta = -3;			
			servoTimer.start();
		}
		
		
		private function moveCamDown(e:Event):void
		{
			angleDelta = 3;			
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