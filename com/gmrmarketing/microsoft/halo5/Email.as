package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.Validator;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	
	
	public class Email extends EventDispatcher
	{
		public static const COMPLETE:String = "emailComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		private var ppDlg:MovieClip;
		
		
		public function Email()
		{
			clip = new mcEmail();
			
			ppDlg = new ppDialog();
			ppDlg.x = 980;
			ppDlg.y = 604;
			
			kbd = new KeyBoard();
			kbd.x = 220;
			kbd.y = 690;
			kbd.alpha = .7;
			kbd.loadKeyFile("png_1920_thin.xml"); 
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}			
			
			clip.addChild(kbd);	//so it's behind the privacy dialog		
			kbd.setFocusFields([[clip.theText, 50]]);
			kbd.addEventListener(KeyBoard.SUBMIT, validate, false, 0, true);
			
			clip.theText.text = "";
			clip.theError.theText.text = "";
			clip.theError.alpha = 0;
			clip.btnCheck.gotoAndStop(1);
			clip.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck, false, 0, true);
			clip.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, validate, false, 0, true);			
			
			clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, showPrivacy, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			if (clip.contains(kbd)) {
				clip.removeChild(kbd);
			}
			
			clip.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheck);
			clip.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, validate);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, showPrivacy);
			ppDlg.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePPDialog);
			
			killPPdlg();
		}
		
		
		/**
		 * Returns an object with email:String and optIn:Boolean properties
		 */
		public function get data():Object
		{
			return { "email":clip.theText.text, "optIn":clip.btnCheck.currentFrame == 2 ? true : false };
		}
		
		
		private function toggleCheck(e:MouseEvent):void
		{
			if (clip.btnCheck.currentFrame == 1) {
				clip.btnCheck.gotoAndStop(2);
			}else {
				clip.btnCheck.gotoAndStop(1);
			}
		}
		
		
		private function validate(e:Event):void
		{
			if (Validator.isValidEmail(clip.theText.text)) {				
				dispatchEvent(new Event(COMPLETE));
			} else {
				showError("The email provided does not appear to be valid");
			}
		}
		
		
		private function showError(m:String):void
		{
			TweenMax.killTweensOf(clip.theError);
			clip.theError.theText.text = m;
			clip.theError.alpha = 1;
			TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
		}
		
		
		private function showPrivacy(e:MouseEvent):void
		{
			if (!myContainer.contains(ppDlg)) {
				myContainer.addChild(ppDlg);
			}
			ppDlg.alpha = 0;
			TweenMax.to(ppDlg, .5, { alpha:1 } );
			ppDlg.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closePPDialog, false, 0, true);
		}
		
		
		private function closePPDialog(e:MouseEvent = null):void
		{
			TweenMax.to(ppDlg, .5, { alpha:0, onComplete:killPPdlg } );
			ppDlg.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePPDialog);
		}
		
		
		private function killPPdlg():void
		{
			if (myContainer.contains(ppDlg)) {
				myContainer.removeChild(ppDlg);
			}
		}
	}
	
}