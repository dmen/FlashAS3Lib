package com.gmrmarketing.miller.sxsw
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import com.sagecollective.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.Validator;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class Share extends EventDispatcher
	{
		public static const SHARE_ADDED:String = "shareAdded";
		public static const SHARE_FACEBOOK:String = "shareOnFacebook";		
		public static const SHARE_FINISHED:String = "shareFinished";
		public static const SHARE_EMAIL_ERROR:String = "invalidEmailAddress";
		public static const SHARE_EMAIL:String = "shareEmail";
		public static const SHOW_KBD:String = "showKeyboard";
		public static const HIDE_KBD:String = "hideKeyboard";
		public static const SHARE_SPIN:String = "shareSpin";
		public static const SHARE_SPIN_ERROR:String = "shareSpinError";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var previewBmp:Bitmap;
		
		private var timeoutHelper:TimeoutHelper;
		
		private var emailBars:int = 8;
		private var curBar:int = 1;
		private var indicatorTimer:Timer;
		
		
		public function Share()
		{
			clip = new share();			
			timeoutHelper = TimeoutHelper.getInstance();
			indicatorTimer = new Timer(100);
			
		}
		
		public function show($container:DisplayObjectContainer, preview:BitmapData):void
		{
			container = $container;
			clip.alpha = 0;
			container.addChild(clip);
			
			previewBmp = new Bitmap(preview, "auto", true);
			previewBmp.x = 67;
			previewBmp.y = 258;
			previewBmp.width = 400;
			previewBmp.height = 518;
			clip.addChild(previewBmp);
			
			clip.btnFB.addEventListener(MouseEvent.MOUSE_DOWN, shareFB, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, showEmail, false, 0, true);
			//clip.btnSpin.addEventListener(MouseEvent.MOUSE_DOWN, showSpin, false, 0, true);
			clip.btnDone.addEventListener(MouseEvent.MOUSE_DOWN, shareFinished, false, 0, true);
			
			//make sure dialogs are hidden
			clip.emailDialog.dialog.y = 208;
			clip.spinDialog.dialog.y = 262;
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );
			
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed, false, 0, true);
		}
		
		public function hide():void
		{
			clip.btnFB.removeEventListener(MouseEvent.MOUSE_DOWN, shareFB);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, showEmail);
			//clip.btnSpin.removeEventListener(MouseEvent.MOUSE_DOWN, showSpin);
			clip.btnDone.removeEventListener(MouseEvent.MOUSE_DOWN, shareFinished);
			
			if (previewBmp) {
				if (clip.contains(previewBmp)) {
					clip.removeChild(previewBmp);
				}
			}
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			}			
		}
		
		private function keyPressed(e:KeyboardEvent):void
		{
			timeoutHelper.buttonClicked();
		}
		
		private function shareFB(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			dispatchEvent(new Event(SHARE_FACEBOOK));//calls Main.facebookLogin()
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(SHARE_ADDED));
		}
		
		
		/**
		 * Called by clicking the big Spin button
		 * @param	e
		 */
		private function showSpin(e:MouseEvent):void
		{
			if(clip.spinDialog.dialog.y != 1){
				timeoutHelper.buttonClicked();
				hideEmail();
				
				clip.spinDialog.dialog.theName.text = "";
				clip.spinDialog.dialog.theEmail.text = "";
				clip.spinDialog.dialog.thePhone.text = "";
				
				container.stage.focus = clip.spinDialog.dialog.theName;
				
				clip.spinDialog.dialog.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, enterSpin, false, 0, true);
				clip.spinDialog.dialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeSpin, false, 0, true);
				
				TweenMax.to(clip.spinDialog.dialog, .5, { y:1, ease:Back.easeOut, onComplete:showKbd } );
			}
		}
		
		/**
		 * Called by pressing the submit button in the spin dialog
		 * @param	e
		 */
		private function enterSpin(e:MouseEvent):void
		{		
			if(Validator.isValidEmail(clip.spinDialog.dialog.theEmail.text) && clip.spinDialog.dialog.theName.text != "" && clip.spinDialog.dialog.thePhone.text != ""){
				dispatchEvent(new Event(SHARE_SPIN));
			}else {
				dispatchEvent(new Event(SHARE_SPIN_ERROR));
			}
		}
		
		public function getSpinData():Object
		{
			var o:Object = new Object();
			o.name = clip.spinDialog.dialog.theName.text;
			o.email = clip.spinDialog.dialog.theEmail.text;
			o.phone = clip.spinDialog.dialog.thePhone.text;
			return o;
		}
		
		
		public function hideSpin():void
		{
			dispatchEvent(new Event(HIDE_KBD));
			clip.spinDialog.dialog.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, enterSpin);
			clip.spinDialog.dialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeSpin);
			TweenMax.to(clip.spinDialog.dialog, .5, { y:262 } );
		}
		
		
		/**
		 * Called by clicking the close button (x)
		 * @param	e
		 */
		private function closeSpin(e:MouseEvent):void
		{
			hideSpin();			
		}
		
	
		
		/**
		 * Called by pressing the big Email share button
		 * @param	e
		 */
		private function showEmail(e:MouseEvent):void
		{
			if(clip.emailDialog.dialog.y != 1){
				timeoutHelper.buttonClicked();			
				hideSpin();				
				
				clip.emailDialog.dialog.fromEmail.text = "";
				clip.emailDialog.dialog.toEmail.text = "";
				
				container.stage.focus = clip.emailDialog.dialog.fromEmail;
				
				clip.emailDialog.dialog.indicator.alpha = 0;
				clip.emailDialog.dialog.indicator.theText.text = "";
				
				clip.emailDialog.dialog.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, sendEmail, false, 0, true);
				clip.emailDialog.dialog.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeEmailDialog, false, 0, true);
				
				TweenMax.to(clip.emailDialog.dialog, .5, { y:1, ease:Back.easeOut, onComplete:showKbd } );
			}
		}
		private function showKbd():void
		{
			dispatchEvent(new Event(SHOW_KBD));
		}
		public function hideEmail():void
		{
			dispatchEvent(new Event(HIDE_KBD));
			clip.emailDialog.dialog.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, sendEmail);
			clip.emailDialog.dialog.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeEmailDialog);
			TweenMax.to(clip.emailDialog.dialog, .5, { y:208 } );
		}
		
		/**
		 * Called by clicking the close button (x)
		 * @param	e
		 */
		private function closeEmailDialog(e:MouseEvent):void
		{
			hideEmail();
		}
		
		
		/**
		 * Called by clicking submit button in the email dialog
		 * @param	e
		 */
		private function sendEmail(e:MouseEvent):void
		{
			if (Validator.isValidEmail(clip.emailDialog.dialog.fromEmail.text) && Validator.isValidEmail(clip.emailDialog.dialog.toEmail.text)) {
				dispatchEvent(new Event(SHARE_EMAIL));
			}else {
				dispatchEvent(new Event(SHARE_EMAIL_ERROR));
			}
		}
		
		public function getEmailData():Object
		{
			var a:Object = new Object();
			a.from = clip.emailDialog.dialog.fromEmail.text;
			a.to = clip.emailDialog.dialog.toEmail.text;
			return a;
		}
		
		
		/**
		 * Called when the done button is pressed
		 * @param	e
		 */
		private function shareFinished(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			dispatchEvent(new Event(SHARE_FINISHED));
		}
		
		
		public function showSaveIndicator():void
		{
			clip.emailDialog.dialog.indicator.alpha = 1;
			clip.emailDialog.dialog.indicator.theText.text = "Saving your poster...";
			curBar = 0;
			indicatorTimer.addEventListener(TimerEvent.TIMER, updateEmailIndicator, false, 0, true);
			indicatorTimer.start();
		}
		
		private function updateEmailIndicator(e:TimerEvent):void
		{
			curBar++;
			if (curBar > emailBars) {
				curBar = 1;
			}
			TweenMax.to(clip.emailDialog.dialog.indicator["b" + curBar], .25, { alpha:0 } );
			TweenMax.to(clip.emailDialog.dialog.indicator["b" + curBar], .25, { alpha:1, delay:.3 } );			
		}
		
		
		public function showEmailIndicator():void
		{
			clip.emailDialog.dialog.indicator.theText.text = "Sending Email...";
		}
		
		public function hideEmailIndicator():void
		{
			indicatorTimer.stop();
			indicatorTimer.removeEventListener(TimerEvent.TIMER, updateEmailIndicator);
			clip.emailDialog.dialog.indicator.alpha = 0;			
		}
		
		public function showSpinIndicator():void
		{
			clip.spinDialog.dialog.indicator.alpha = 1;
			clip.spinDialog.dialog.indicator.theText.text = "Submitting to SPIN...";
			indicatorTimer.addEventListener(TimerEvent.TIMER, updateSpinIndicator, false, 0, true);
			indicatorTimer.start();			
		}
		private function updateSpinIndicator(e:TimerEvent):void
		{
			curBar++;
			if (curBar > emailBars) {
				curBar = 1;
			}
			TweenMax.to(clip.spinDialog.dialog.indicator["b" + curBar], .25, { alpha:0 } );
			TweenMax.to(clip.spinDialog.dialog.indicator["b" + curBar], .25, { alpha:1, delay:.3 } );			
		}
		public function hideSpinIndicator():void
		{
			indicatorTimer.stop();
			indicatorTimer.removeEventListener(TimerEvent.TIMER, updateSpinIndicator);
			clip.spinDialog.dialog.indicator.alpha = 0;	
		}
	}
	
}