package com.gmrmarketing.sap.levisstadium.avatar
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
	
	
	public class Main extends MovieClip
	{
		private var rfid:Rfid; //intro screen
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
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			tim.init(120000);//startMonitoring() called in showPreview() / stopped in reset()
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			comm = new Comm();
			
			rfid = new Rfid();			
			rfid.setContainer(mainContainer);
			rfid.addEventListener(Rfid.RFID, gotRFID);
			rfid.addEventListener(Rfid.JSON_ERROR, rfidError);			
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			review = new Review();
			review.setContainer(mainContainer);
			
			modal = new Modal();
			modal.setContainer(mainContainer);
			
			preview = new Webcam3D_1280x960();					
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);			
			
			rfidTimer = new Timer(2000);
			rfidTimer.addEventListener(TimerEvent.TIMER, showRFIDModal);
			rfid.show();
		}		
		
		
		/**
		 * called by listener once visitor.json appears in the c:\fish folder
		 * calls the web service to get the users data from the rfid tag
		 * @param	e
		 */
		private function gotRFID(e:Event):void
		{
			//RASCH MEETING
			rfid.hide();
			showPreview();
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
			preview.setTeam("packers", "Guest");
			//preview.setTeam(comm.getUserData().FavoriteTeam, comm.getUserData().FirstName);
			preview.show();
			if(!mainContainer.contains(preview)){
				mainContainer.addChild(preview);
			}
			modal.kill();
			//OMNICOM
			//rfid.hide();
			tim.startMonitoring();
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
			
			review.show(avatarImage, preview.getTeam(), comm.getUserData());//preview.getAlphaShot());// , 
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
			/*
			//OMNICOM
			//Need to show the email field and keyboard here
			email = new mcEmail();
			email.x = 286; email.y = 500;
			email.theEmail.text = "";
			addChild(email);
			
			kbd.x = 319; kbd.y = 682;
			addChild(kbd);
			email.alpha = 0;
			kbd.alpha = 0;
			TweenMax.to(email, .5, { alpha:.8, y:440 } );
			TweenMax.to(kbd, .5, { alpha:1, y:622 } );
			kbd.setFocusFields([email.theEmail]);
			kbd.addEventListener(KeyBoard.SUBMIT, validateEmail, false, 0, true);
			//OMNICOM
			*/
			//FOR OMNICOM - these moved down to validateEmail()
			modal.addEventListener(Modal.HIDING, reset, false, 0, true);
			modal.show("Thank you for showing your team spirit.\nFeel free to create as many NFL players as you want.\nShare with your friends and compare to see\nwho makes the best NFL player.", "THANK YOU", true, true, 7, true);
			TweenMax.delayedCall(.5, saveImage);			
		}
		
		/*
		private function validateEmail(e:Event):void
		{
			if (Validator.isValidEmail(email.theEmail.text)) {
				TweenMax.to(email, .5, { alpha:0, y:530 } );
				TweenMax.to(kbd, .5, { alpha:0, y:708 } );
				modal.addEventListener(Modal.HIDING, reset, false, 0, true);
				modal.show("Feel free to create as many\nrace avatars as you want.\nShare with your friends and compare\nto see who makes the best racer.", "THANK YOU", true, true, 7, true);
				TweenMax.delayedCall(.5, saveImage);
			}
		}
		*/
		
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
			comm.saveImage(review.getCard(), rfid.getVisitorID());
			
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
			rfid.show();
			rfid.addEventListener(Rfid.SHOWING, killModal, false, 0, true);
		}
		
		
		private function killModal(e:Event):void
		{
			modal.kill();
			////OMNICOM
			rfid.removeEventListener(Rfid.SHOWING, killModal);
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