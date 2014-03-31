package com.gmrmarketing.bicycle
{		
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	
	import gs.TweenLite;
	import gs.easing.*
	
	public class Keyboard extends MovieClip
	{		
		public static const INITIALS_ENTERED:String = "initialsEntered";		
		private var cursorCounter:int;		
		
		public function Keyboard()
		{			
		}
		
	
		public function getInitials():String
		{
			return theText.text;
		}			

		
		/**
		 * 	A - Z = 65 - 90
		 *  a - z = 97 - 122
		 */
		public function enable():void
		{		
			theText.text = "";
			
			var i:int;
			for(i = 65; i < 91; i++){
				this["key" + String.fromCharCode(i)].myLetter = String.fromCharCode(i);
				this["key" + String.fromCharCode(i)].addEventListener(MouseEvent.CLICK, enterInit, false, 0, true);				
			}
			
			keyBS.myLetter = "<";
			keyBS.addEventListener(MouseEvent.CLICK, enterInit, false, 0, true);			
			keyOK.addEventListener(MouseEvent.CLICK, submit, false, 0, true);			
			insertion.addEventListener(Event.ENTER_FRAME, flashCursor, false, 0, true);			
			
			cursorCounter = 0;					
		}
		
		
		
		public function disable():void
		{
			var i:int;
			for(i = 65; i < 91; i++){		
				this["key" + String.fromCharCode(i)].removeEventListener(MouseEvent.CLICK, enterInit);				
			}
			
			keyBS.removeEventListener(MouseEvent.CLICK, enterInit);			
			keyOK.removeEventListener(MouseEvent.CLICK, submit);			
			insertion.removeEventListener(Event.ENTER_FRAME, flashCursor);			
		}
		
		
		
		private function flashCursor(e:Event):void
		{
			cursorCounter++;
			if (cursorCounter % 10 == 0) {
				if (insertion.alpha < 1) {
					insertion.alpha = 1;					
				}else {
					insertion.alpha = 0;					
				}
			}
			insertion.x = theText.x + theText.textWidth + 4;
		}
	
		

		private function submit(e:MouseEvent):void
		{					
			dispatchEvent(new Event(INITIALS_ENTERED));			
		}
		
		
		
		/**
		 * Called whenever a 'key' on the keyboard is clicked
		 * 
		 * @param	e CLICK mouse event
		 */
		private function enterInit(e:MouseEvent) {
			//e.currentTarget.key.red.alpha = 1;
			//TweenLite.to(e.currentTarget.key.red, .5, {alpha:0});
			var char = e.currentTarget.myLetter;
		
			if(char == "<"){
				//backspace
				if(theText.text.length > 0){
					theText.text = theText.text.substr(0, theText.text.length - 1);
				}		
			}else {				
				if(theText.text.length < 2){
					theText.appendText(char);
				}
			}			
		}		
	}	
}