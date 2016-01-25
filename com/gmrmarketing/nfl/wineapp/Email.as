package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Email extends EventDispatcher
	{
		public static const COMPLETE:String = "emailComplete";
		public static const HIDDEN:String = "emailHidden";
		public static const CANCEL:String = "emailCanceled";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		private var emailHolder:String;
		
		public function Email()
		{
			clip = new mcEmail();
			kbd = new KeyBoard();
			//kbd.addEventListener(KeyBoard.KEYFILE_LOADED, init, false, 0, true);
			kbd.loadKeyFile("kbd.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * Returns an object with name and email properties
		 */
		public function get data():Object
		{
			return {name:clip.inputs.theName.text, email:clip.inputs.theEmail.text};
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.x = 0;
			clip.title.alpha = 0;
			clip.inputs.alpha = 0;
			clip.textCancel.alpha = 0;
			clip.inputs.theName.text = "";
			clip.inputs.theEmail.text = "";
			
			clip.kbdBack.alpha = 0;
			
			clip.addChild(kbd);
			kbd.scaleX = 1.3;
			kbd.scaleY = 1.5;
			kbd.x = 200; 
			kbd.y = 1824;// 1030;
			kbd.setFocusFields([[clip.inputs.theName, 0], [clip.inputs.theEmail, 0]]);
			
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.inputs, 1, { alpha:1, delay:.5 } );
			
			TweenMax.to(kbd, .5, { y:1030, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.kbdBack, 1, { alpha:1, delay:1.5 } );
			TweenMax.to(clip.textCancel, 1.5, { alpha:.8, delay:1.5 } );
			
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelEmail, false, 0, true);
		}
		
		
		public function hide():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if (clip.contains(kbd)) {
					clip.removeChild(kbd);
				}
			}
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function submitPressed(e:Event):void
		{
			if (Validator.isValidEmail(clip.inputs.theEmail.text)) {
				kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
				dispatchEvent(new Event(COMPLETE));
			}else {
				emailHolder = clip.inputs.theEmail.text;
				clip.inputs.theEmail.text = "Please enter a valid email";
				TweenMax.to(clip.inputs.theEmail, 1, { alpha:0, delay:1, onComplete:replaceEmail } );
			}
		}
		
		
		private function replaceEmail():void
		{
			clip.inputs.theEmail.text = emailHolder;
			clip.inputs.theEmail.alpha = 1;
		}
		
		
		private function cancelEmail(e:MouseEvent):void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			dispatchEvent(new Event(CANCEL));
		}
		
	}
	
}