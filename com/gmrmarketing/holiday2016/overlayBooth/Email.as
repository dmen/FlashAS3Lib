package com.gmrmarketing.holiday2016.overlayBooth
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
		public static const CANCELED:String = "emailCanceled";
		public static const COMPLETE:String = "emailComplete";
		public static const HIDDEN:String = "emailHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		
		private var tmh:TimeoutHelper;
		
		
		public function Email()
		{
			kbd = new KeyBoard();
			kbd.filters = [new DropShadowFilter(0, 0, 0, .8, 12, 12, 1, 2)];
			clip = new mcEmail();
			tmh = TimeoutHelper.getInstance();
			
			kbd.loadKeyFile("keyboard.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			clip.alpha = 1;
			
			clip.theText1.text = "";
			clip.theText2.text = "";
			clip.theText3.text = "";
			clip.theText4.text = "";
			
			clip.notValid1.alpha = 0;
			clip.notValid2.alpha = 0;
			clip.notValid3.alpha = 0;
			clip.notValid4.alpha = 0;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if(!clip.contains(kbd)){
				clip.addChild(kbd);
			}
			kbd.x = 220;
			kbd.y = 700;
			kbd.alpha = 0;
			
			TweenMax.to(kbd, .5, { y:550, alpha:.8, ease:Back.easeOut } );
			
			kbd.setFocusFields([[clip.theText1, 40],[clip.theText2, 40],[clip.theText3, 40],[clip.theText4, 40]]);
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			
			clip.btnCancel.alpha = 0;
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, canceled, false, 0, true);
			TweenMax.to(clip.btnCancel, .5, {alpha:1, delay:.5});
			
			clip.fernSide.alpha = 0;
			clip.fern.gotoAndStop(1);
			clip.fern.scaleY = 0;
			TweenMax.to(clip.fernSide, 2, {alpha:1});
			TweenMax.delayedCall(1.5, showFern);
		}
		
		
		private function canceled(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, canceled);
			dispatchEvent(new Event(CANCELED));
		}
		
		
		private function showFern():void
		{
			clip.fern.gotoAndPlay(2);
			TweenMax.to(clip.fern, 1.5, {scaleY:1, ease:Back.easeOut});
		}
		
		public function hide():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, canceled);
			TweenMax.to(clip, .5, { alpha:0, onComplete:hidden } );
		}
		
		public function kill():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, canceled);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (clip.contains(kbd)) {
				clip.removeChild(kbd);
			}
		}
		
		
		private function keyPressed(e:Event):void
		{
			tmh.buttonClicked();
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
			var isValid1:Boolean = true;
			var isValid2:Boolean = true;
			var isValid3:Boolean = true;
			var isValid4:Boolean = true;
			
			if (clip.theText1.text != ""){
				if (!Validator.isValidEmail(clip.theText1.text)) {
					isValid1 = false;
					TweenMax.killTweensOf(clip.notValid1);
					TweenMax.to(clip.notValid1, .5, { alpha:1 } );
					TweenMax.to(clip.notValid1, 1, { alpha:0, delay:1 } );
				}
			}else{
				//blank
				isValid1 = false;
			}
			if (clip.theText2.text != ""){
				if (!Validator.isValidEmail(clip.theText2.text)) {
					isValid2 = false;
					TweenMax.killTweensOf(clip.notValid2);
					TweenMax.to(clip.notValid2, .5, { alpha:1 } );
					TweenMax.to(clip.notValid2, 1, { alpha:0, delay:1 } );
				}
			}else{
				isValid2 = false;
			}
			if (clip.theText3.text != ""){
				if (!Validator.isValidEmail(clip.theText3.text)) {
					isValid3 = false;
					TweenMax.killTweensOf(clip.notValid3);
					TweenMax.to(clip.notValid3, .5, { alpha:1 } );
					TweenMax.to(clip.notValid3, 1, { alpha:0, delay:1 } );
				}
			}else{
				isValid3 = false;
			}
			if (clip.theText4.text != ""){
				if (!Validator.isValidEmail(clip.theText4.text)) {
					isValid4 = false;
					TweenMax.killTweensOf(clip.notValid4);
					TweenMax.to(clip.notValid4, .5, { alpha:1 } );
					TweenMax.to(clip.notValid4, 1, { alpha:0, delay:1 } );
				}			
			}else{
				isValid4 = false;
			}
			
			if (isValid1 || isValid2 || isValid3 || isValid4){
				dispatchEvent(new Event(COMPLETE));
			}
			
		}
		
		
		public function get theEmail():String
		{
			var s:String = "";
			if (clip.theText1.text != ""){
				s += clip.theText1.text;
			}
			if (clip.theText2.text != ""){
				s += "," + clip.theText2.text;
			}
			if (clip.theText3.text != ""){
				s += "," + clip.theText3.text;
			}
			if (clip.theText4.text != ""){
				s += "," + clip.theText4.text;
			}
			return s
		}
		
	}
	
}