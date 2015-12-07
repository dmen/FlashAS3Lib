package com.gmrmarketing.holiday2015
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import flash.filters.DropShadowFilter;	
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Email extends EventDispatcher
	{
		public static const COMPLETE:String = "emailComplete";
		public static const HIDDEN:String = "emailHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		
		private var tim:TimeoutHelper;
		
		
		public function Email()
		{
			kbd = new KeyBoard();
			kbd.filters = [new DropShadowFilter(0, 0, 0, .8, 12, 12, 1, 2)];
			clip = new mcEmail();
			tim = TimeoutHelper.getInstance();
			
			kbd.loadKeyFile("keyboard.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			clip.alpha = 1;
			
			clip.theText.text = "";
			clip.notValid.alpha = 0;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if(!clip.contains(kbd)){
				clip.addChild(kbd);
			}
			kbd.x = 240;
			kbd.y = 650;
			kbd.alpha = 0;
			
			TweenMax.to(kbd, .5, { y:430, alpha:.8, ease:Back.easeOut } );
			
			kbd.setFocusFields([[clip.theText, 40]]);
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			TweenMax.to(clip, .5, { alpha:0, onComplete:hidden } );
		}
		
		
		private function keyPressed(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function hidden():void
		{
			dispatchEvent(new Event(HIDDEN));
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (clip.contains(kbd)) {
				clip.removeChild(kbd);
			}
		}
		
		private function submitPressed(e:Event):void
		{
			checkEmail();
		}
		
		
		public function checkEmail():void
		{
			if (Validator.isValidEmail(clip.theText.text)) {
				dispatchEvent(new Event(COMPLETE));
			}else {
				TweenMax.killTweensOf(clip.notValid);
				TweenMax.to(clip.notValid, .5, { alpha:1 } );
				TweenMax.to(clip.notValid, 1, { alpha:0, delay:1 } );
			}
		}
		
		
		public function get theEmail():String
		{
			return clip.theText.text;
		}
		
	}
	
}