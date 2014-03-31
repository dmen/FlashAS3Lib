/**
 * Controls the password entry dialog that appears in the admin
 * kiosk when the upper right button is pressed
 * 
 * allows entry to the select winner screen
 */

package com.gmrmarketing.indian.daytona
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	
	
	public class PasswordDialog extends EventDispatcher	
	{
		public static const ACCEPTED:String = "passwordEntered";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var kbd:KeyBoard;
		private var pwd:String;
		private var thePassword:String;		
		
		
		public function PasswordDialog($thePassword:String)
		{
			thePassword = $thePassword;
			
			kbd = new KeyBoard();
			kbd.loadKeyFile("numpad.xml");
			
			clip = new pwdDialog(); //lib clip
			clip.x = 1502;
			clip.y = 82;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = "";
			pwd = "";
			
			clip.addChild(kbd);
			kbd.x = 59;
			kbd.y = 132;
			kbd.setFocusFields([clip.theText]);
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
						
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeDialog);			
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		/**
		 * Called from Admin.as update() if the timer
		 * runs out and the time to pick text is shown
		 * insures the dialog is over the text
		 */
		public function moveToTop():void
		{
			if(container){
				if (container.contains(clip)) {
					container.setChildIndex(clip, container.numChildren - 1);					
				}
			}
		}
		
		public function hide():void
		{
			closeDialog();
		}
		
		
		private function keyPressed(e:Event):void
		{
			var lastChar:String = kbd.getKey();
			
			if(lastChar != "Enter"){
				pwd += lastChar;
				var l:int = clip.theText.text.length;
				var s:String = "";
				for (var i:int = 0; i < l; i++) {
					s += "*";
				}
				clip.theText.text = s;
			}else {
				if (pwd == thePassword) {
					dispatchEvent(new Event(ACCEPTED));
				}else {
					clip.theText.text = "";
					pwd = "";
				}
			}
		}
		
		
		private function closeDialog(e:MouseEvent = null):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		public function kill():void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
		}
	}
	
}