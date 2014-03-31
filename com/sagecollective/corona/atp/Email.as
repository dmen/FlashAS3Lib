package com.sagecollective.corona.atp
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.filters.DropShadowFilter;
	import com.sagecollective.utilities.Validator;
	import com.sagecollective.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPGEncoder;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.geom.Matrix;
	
	
	public class Email extends EventDispatcher
	{
		public static const EMAIL_CANCELED:String = "emailCancel";		
		public static const EMAIL_SENT:String = "emailWasSent";
		public static const ALL_EMAIL_SENT:String = "allEmailSent";
		public static const SLOW_HIDE_FINISHED:String = "slowHideFinished";
		
		
		private var container:DisplayObjectContainer;
		private var dialog:MovieClip;		
		private var preview:Bitmap;
		private var FBImage:BitmapData;
		private var previewShadow:DropShadowFilter;
		
		private var startY:int = 3;//same as curY - but used in removeEmail for resetting the positions
		private var curY:int = 3;//starting y inside emailItemContainer
		private var increment:int = 43;//height of each item + 1		
		
		private var emailItemContainer:Sprite;
		private var imageString:String;		
		private var stringTimer:Timer;
		
		private var venue:String;
		private var timeoutHelper:TimeoutHelper;
		private var dob:String;
		
		public function Email($container:DisplayObjectContainer)
		{
			previewShadow = new DropShadowFilter(0, 0, 0x000000, .8, 5, 5, 1, 2, false, false, false);
			container = $container;
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			stringTimer = new Timer(200, 1);
			stringTimer.addEventListener(TimerEvent.TIMER, stringImage, false, 0, true);
			
			emailItemContainer = new Sprite();
			emailItemContainer.x = 493;
			emailItemContainer.y = 562;
		}
		
		
		public function init($preview:Bitmap, $venue:String, $dob:String ):void
		{
			venue = $venue;
			dob = $dob;
			
			curY = startY;//reset list position			
			
			dialog = new dialogEmail(); //lib clip			
			
			if (!dialog.contains(emailItemContainer)) {
				dialog.addChild(emailItemContainer);
			}
			
			dialog.alpha = 1;
			dialog.btnAdd.addEventListener(MouseEvent.MOUSE_DOWN, addEmail, false, 0, true);
			dialog.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelEmail, false, 0, true);
			dialog.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, sendEmailPressed, false, 0, true);
			
			dialog.topText.rotator.alpha = 0;
			dialog.topText.rotator.removeEventListener(Event.ENTER_FRAME, spinRotator);
			
			//dialog.topText.gotoAndStop(1);//show instructions on top
			//trace(dialog.topText.currentFrame);
			
			if(preview){
				if (dialog.contains(preview)) {
					dialog.removeChild(preview);
				}
			}
						
			preview = $preview;
			scaleImage(preview);
			
			dialog.addChild(preview);
			preview.width = 394;
			preview.height = 224;
			preview.x = 62;
			preview.y = 562;
			preview.filters = [previewShadow];			
			
			dialog.theEmail.text = "";
			dialog.alert.alpha = 0;
			
			container.addChild(dialog);
			dialog.x = 506;
			dialog.y = -90;		
			
			dialog.stage.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			dialog.addEventListener(Event.ENTER_FRAME, setFocus, false, 0, true);
		}
		
		private function setFocus(e:Event):void
		{
			dialog.stage.focus = dialog.theEmail;
		}
		
		
		private function scaleImage(im:Bitmap):void
		{
			FBImage = new BitmapData(810, 540);
			var m:Matrix = new Matrix();
			m.scale(FBImage.width / im.width, FBImage.height / im.height);
			FBImage.draw(im, m, null, null, null, true);
		}
		
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			 if (e.keyCode == Keyboard.ENTER) {
				 timeoutHelper.buttonClicked();
				 addEmail();
			 }
		}
		
		
		public function hide():void
		{
			if(dialog){
				if (container.contains(dialog)) {
					container.removeChild(dialog);
				}
				dialog.removeEventListener(Event.ENTER_FRAME, setFocus);
			}
			
		}
		
		
		public function hideSlow():void
		{
			if (dialog) {
				if (container.contains(dialog)) {
					TweenMax.to(dialog, 2, { alpha:0, onComplete:dispatchSlow } );
				}
			}
		}
		
		
		private function dispatchSlow():void
		{
			dispatchEvent(new Event(SLOW_HIDE_FINISHED));
		}
		
		
		/**
		 * Called by clicking the 'add to list' button in the dialog
		 * @param	e
		 */
		private function addEmail(e:MouseEvent = null):void
		{
			if (dialog.theEmail.text.length > 0) {
				if (Validator.isValidEmail(dialog.theEmail.text)) {
					if (emailItemContainer.numChildren < 5) {
						if(!duplicateEmail(dialog.theEmail.text)){
							var a:MovieClip = new emailListItem();						
							a.y = curY;
							curY += increment;
							
							a.theText.text = dialog.theEmail.text;
							a.btnDelete.index = emailItemContainer.numChildren;
							a.btnDelete.addEventListener(MouseEvent.MOUSE_DOWN, removeEmail, false, 0, true);
							
							emailItemContainer.addChild(a);
							
							dialog.theEmail.text = ""; //clear field after add to list
						}else {
							//duplicate
							showAlert("Duplicate email address");
						}
					}else {
						//max of 5
						showAlert("Five email limit reached");
					}
				}else {
					//not a valid email
					showAlert("Not a valid email address");
				}
			}else {
				//length not > 0
				showAlert("Nothing to add");
			}			
		}
		
		
		//returns true if theEmail is already in the list
		private function duplicateEmail(theEmail:String):Boolean
		{
			for (var i:int = 0; i < emailItemContainer.numChildren; i++) {
				if (MovieClip(emailItemContainer.getChildAt(i)).theText.text == theEmail) {
					return true;
				}
			}
			return false;
		}
		
		
		private function showAlert(message:String):void
		{
			dialog.alert.theText.text = message;
			TweenMax.to(dialog.alert, 1, { alpha:1 } );
			TweenMax.to(dialog.alert, 2, { alpha:0, delay:2 } );
		}
		
		
		/**
		 * Called by pressing one of the email delete buttons
		 * @param	e
		 */
		private function removeEmail(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			emailItemContainer.removeChildAt(e.currentTarget.index);
			moveEmailItems();
		}
		
		
		private function moveEmailItems():void
		{
			curY = startY;
			var clip:MovieClip;
			for (var i:int = 0; i < emailItemContainer.numChildren; i++) {
				TweenMax.to(emailItemContainer.getChildAt(i), .5, { y:curY } );
				MovieClip(emailItemContainer.getChildAt(i)).btnDelete.index  = i;
				curY += increment;
			}
		}
		
		
		private function removeListeners():void
		{
			dialog.btnAdd.removeEventListener(MouseEvent.MOUSE_DOWN, addEmail);
			dialog.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			dialog.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, sendEmailPressed);
			dialog.stage.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		
		
		/**
		 * Called by clicking the cancel button
		 * @param	e
		 */
		private function cancelEmail(e:MouseEvent):void
		{
			removeListeners();
			timeoutHelper.buttonClicked();
			
			//clear email list
			while (emailItemContainer.numChildren) {
				emailItemContainer.removeChildAt(0);
			}
			
			dispatchEvent(new Event(EMAIL_CANCELED));
		}
		
		
		/**
		 * Called by pressing the send button
		 * @param	e
		 */
		private function sendEmailPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			if (emailItemContainer.numChildren > 0) {
				dialog.topText.gotoAndStop(2);//shows 'Your email is sending' on top
				removeListeners();
				stringTimer.start();//calls string image after 200ms				
			}else {
				//see if there's just one email in the field
				if (dialog.theEmail.text.length > 0) {
					if (Validator.isValidEmail(dialog.theEmail.text)) {
						addEmail();
						dialog.topText.gotoAndStop(2);//shows 'Your email is sending' on top
						
						removeListeners();
						stringTimer.start();//calls string image after 200ms	
					}
				}else{
					showAlert("No emails to send");
				}
			}
		}
		
		private function spinRotator(e:Event):void
		{
			dialog.topText.rotator.rotation += 2;
		}
		
		/**
		 * Called from sendEmailPressed after 100ms to give time for alert to appear
		 * @param	e
		 */
		private function stringImage(e:TimerEvent):void
		{
			var jpeg:ByteArray = getJpeg(FBImage);			
			imageString = getBase64(jpeg);
			dialog.topText.rotator.alpha = 1;
			dialog.topText.rotator.addEventListener(Event.ENTER_FRAME, spinRotator, false, 0, true);
			sendEmail();
		}
		
		
		private function sendEmail():void
		{
			timeoutHelper.buttonClicked();
			
			var clip:MovieClip = MovieClip(emailItemContainer.getChildAt(0));
			clip.marker.alpha = .67; //hilite marker behind clip so they know it's sending
			
			var request:URLRequest = new URLRequest("https://coronaatp.thesocialtab.net/Home/SubmitPhoto");
				
			var vars:URLVariables = new URLVariables();
			vars.imageBuffer = imageString;
			vars.name = "";
			vars.email = clip.theText.text;
			vars.message = "Corona ATP";
			vars.venue = venue;
			vars.dob = dob;
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, sendDone, false, 0, true);
			lo.load(request);
		}
		
		
		private function sendError(e:IOErrorEvent):void
		{			
			if (emailItemContainer.numChildren) {
				sendEmail();
			}else {
				
			}
		}
		
		/**
		 * Called when one email is done sending
		 */
		private function sendDone(e:Event):void
		{
			dispatchEvent(new Event(EMAIL_SENT));//for stats
			
			emailItemContainer.removeChildAt(0);//remove the email item that was just sent
			moveEmailItems();
			
			if (emailItemContainer.numChildren) {
				sendEmail();
			}else {				
				dialog.topText.gotoAndStop(3);//show 'emails have been sent'
				dialog.topText.rotator.alpha = 0;
				dialog.topText.rotator.removeEventListener(Event.ENTER_FRAME, spinRotator);
				dispatchEvent(new Event(ALL_EMAIL_SENT));
			}
		}
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
	}
	
}