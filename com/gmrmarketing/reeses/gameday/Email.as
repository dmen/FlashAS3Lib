package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Email extends EventDispatcher
	{
		public static const BACK:String = "backPressed";
		public static const COMPLETE:String = "emailComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer
		private var kbd:KeyBoard;
		
		
		public function Email()
		{
			clip = new mcEmail();
			kbd = new KeyBoard();
			kbd.loadKeyFile("reeses_kbd.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get email():String
		{
			return clip.email.theText.text;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
				myContainer.addChild(kbd);
			}
			
			clip.title.alpha = 0;
			clip.email.theText.text = "";
			clip.error.theText.text = "";
			clip.error.visible = false;
			clip.email.visible = true;
			clip.reesesRight.gotoAndStop(1);
			
			clip.whiteBox.scaleX = 0;
			clip.check1.scaleX = clip.check1.scaleY = 0;
			clip.check1.gotoAndStop(1);//unchecked
			clip.check2.scaleX = clip.check2.scaleY = 0;
			clip.check2.gotoAndStop(1);//unchecked
			clip.mainText.alpha = 0;
			clip.checkText.alpha = 0;
			
			clip.pubRelease.y = 1080;
			
			TweenMax.to(clip.whiteBox, .5, { scaleX:1, ease:Back.easeOut } );
			TweenMax.to(clip.check1, .5, { scaleX:1, scaleY:1, delay:.2, ease:Back.easeOut } );
			TweenMax.to(clip.check2, .5, { scaleX:1, scaleY:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.mainText, .75, { alpha:1, delay:.5 } );
			TweenMax.to(clip.checkText, .75, { alpha:1, delay:.75 } );			
			TweenMax.to(clip.title, .5, { alpha:1, delay:1 } );
			
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			clip.btnCheck1.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck1, false, 0, true);
			clip.btnCheck2.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck2, false, 0, true);
			clip.btnPublicity.addEventListener(MouseEvent.MOUSE_DOWN, showPublicity, false, 0, true);
			
			kbd.setFocusFields([[clip.email.theText, 40]]);
			kbd.x = 225;
			kbd.y = 1080;
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			TweenMax.to(kbd, .5, { y:558, ease:Back.easeOut, delay:1 } );
		}
		
		
		public function hide():void
		{
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			clip.btnCheck1.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheck1);
			clip.btnCheck2.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheck2);
			clip.btnPublicity.removeEventListener(MouseEvent.MOUSE_DOWN, showPublicity);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
				myContainer.removeChild(kbd);
			}
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
		}
		
		
		private function showPublicity(e:MouseEvent):void
		{
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			kbd.visible = false;
			clip.reesesRight.gotoAndStop(2);//unhighlited arrow
			clip.pubRelease.alpha = 0;
			clip.pubRelease.y = 258;
			clip.pubRelease.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hidePublicity, false, 0, true);
			TweenMax.to(clip.pubRelease, .5, { alpha:1, y:208, ease:Back.easeOut } );
		}
		
		
		private function hidePublicity(e:MouseEvent):void
		{
			clip.pubRelease.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hidePublicity);
			TweenMax.to(clip.pubRelease, .3, { alpha:0, onComplete:killPublicity } );
		}
		
		private function killPublicity():void
		{
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			kbd.visible = true;
			clip.reesesRight.gotoAndStop(1);
			clip.pubRelease.y = 1080;
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			submitPressed();
		}
		
		
		private function backPressed(e:MouseEvent):void
		{			
			dispatchEvent(new Event(BACK));
		}
		
		
		private function toggleCheck1(e:MouseEvent):void
		{
			if (clip.check1.currentFrame == 1) {
				clip.check1.gotoAndStop(2);
			}else {
				clip.check1.gotoAndStop(1);
			}
		}
		
		private function toggleCheck2(e:MouseEvent):void
		{
			if (clip.check2.currentFrame == 1) {
				clip.check2.gotoAndStop(2);
			}else {
				clip.check2.gotoAndStop(1);
			}
		}
		
		
		private function submitPressed(e:Event = null):void
		{
			if (Validator.isValidEmail(clip.email.theText.text)) {				
				if (clip.check1.currentFrame == 1 || clip.check2.currentFrame == 1) {
					doError("You must check both check boxes.");				
				}else{
					dispatchEvent(new Event(COMPLETE));
				}
			}else {
				doError("Please enter a valid email address");
			}
		}
		
		
		private function doError(m:String):void
		{
			clip.email.visible = false;
			clip.error.theText.text = m;
			clip.error.visible = true;
			clip.error.alpha = 1;
			TweenMax.to(clip.error, 1, { alpha:0, delay:2, onComplete:showEmail } );
		}
		
		
		private function showEmail():void
		{
			clip.error.visible = false;
			clip.email.visible = true;
		}
		
	}
	
}