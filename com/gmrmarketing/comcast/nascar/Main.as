package com.gmrmarketing.comcast.nascar
{	
	import com.gmrmarketing.utilities.LoggerAIR;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;	
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.AIRXML;
	import com.gmrmarketing.sap.levisstadium.avatar.testing.Avatar_Flare3D_v2_5;
	import com.gmrmarketing.sap.levisstadium.avatar.testing.Webcam3D_1280x960;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var preview:Webcam3D_1280x960; //web cam preview - with facial recognition
		private var countdown:Countdown; //3-2-1 counter with white flash
		private var review:Review; //screen to review the pic that was taken
		private var thanks:Thanks;
		
		private var avatarImage:BitmapData;
		
		private var cq:CornerQuit;
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var tim:TimeoutHelper;
		
		private var queue:Queue;
		
		private var log:Logger;
		private var cancel:MovieClip;//mcCancel in lib
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			stage.align = StageAlign.TOP_LEFT;				
			stage.quality = StageQuality.HIGH;
			stage.frameRate = 36;
			Mouse.hide();
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset);
			tim.init(180000);//startMonitoring() called in showPreview() / stopped in reset()
			
			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			log = Logger.getInstance();
			log.setLogger(new LoggerAIR());
			
			intro = new Intro();			
			intro.setContainer(mainContainer);
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			review = new Review();
			review.setContainer(mainContainer);			
			
			preview = new Webcam3D_1280x960();
			
			thanks = new Thanks();
			thanks.setContainer(mainContainer);
			
			mainContainer.addChild(preview);//inits BRF with added to stage			
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			cancel = new mcCancel();
			
			queue = new Queue();
			
			intro.show();
			intro.addEventListener(Intro.RFID, gotRFID);
		}
		
		
		private function gotRFID(e:Event = null):void
		{
			if(preview.isBrfReady()){
				intro.removeEventListener(Intro.RFID, gotRFID);				
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
			preview.addEventListener(Webcam3D_1280x960.CLOSE_PREVIEW, askReset, false, 0, true);
			
			preview.show();
			if(!mainContainer.contains(preview)){
				mainContainer.addChild(preview);
			}
			
			intro.hide();
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
			preview.pause();
			review.show(avatarImage);
			review.addEventListener(Review.RETAKE, retake, false, 0, true);
			review.addEventListener(Review.SAVE, save, false, 0, true);			
			review.addEventListener(Review.RESET, askReset, false, 0, true);
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
			review.removeEventListener(Review.RESET, askReset);
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
			review.removeEventListener(Review.RESET, reset);
			
			tim.buttonClicked();//timeout helper
			
			thanks.addEventListener(Thanks.SHOWING, thanksShowing, false, 0, true);
			thanks.show();
		}	
		
		
		public function getPhotoString():String
		{	
			//var jpeg:ByteArray = getJpeg(avatarImage);
			var jpeg:ByteArray = getJpeg(review.getCard());
			var imageString:String = getBase64(jpeg);
			return imageString;
		}		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		private function thanksShowing(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, thanksShowing);
			var im:String = getPhotoString();
			queue.add( { rfid:intro.getRFID(), image:im } );
			TweenMax.delayedCall(3, reset);
		}
		
		
		private function askReset(e:Event):void
		{
			if (!mainContainer.contains(cancel)) {
				mainContainer.addChild(cancel);
			}
			cancel.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, yesReset, false, 0, true);
			cancel.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, noReset, false, 0, true);
		}
		private function yesReset(e:MouseEvent):void
		{
			reset();
		}
		private function noReset(e:MouseEvent):void
		{
			if (mainContainer.contains(cancel)) {
				mainContainer.removeChild(cancel);
			}
			cancel.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, yesReset);
			cancel.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, noReset);
		}
		
		/**
		 * Done - write session.json and delete visitor.json
		 * @param	e
		 */
		private function reset(e:Event = null):void
		{	
			if (e != null) {
				//log
			}
			if (mainContainer.contains(cancel)) {
				mainContainer.removeChild(cancel);
			}
			cancel.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, yesReset);
			cancel.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, noReset);
			
			preview.removeEventListener(Webcam3D_1280x960.CLOSE_PREVIEW, askReset);
			review.removeEventListener(Review.RESET, askReset);
			
			tim.stopMonitoring();
			thanks.hide();
			preview.hide();
			review.hide();			
			
			intro.show();			
			intro.addEventListener(Intro.RFID, gotRFID, false, 0, true);
			
			//turn off estimation and re-enable tracking only
			preview.unPause();
			//preview.track();	
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