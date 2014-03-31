/**
 * Bank of America
 * GMR Marketing
 * 
 * Class for high score dialog keyboard in the library
 * 
 * Managed by HighScoreManager
 */

package com.gmrmarketing.morris
{		
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	
	import gs.TweenLite;
	import gs.easing.*
	
	public class HighScoreDialog extends MovieClip
	{		
		private var cursorCounter:int;
		
		public function HighScoreDialog() {
			errorDialog.mouseEnabled = false;
		}
		
		
		public function show():void
		{
			
			//x = (Engine.GAME_WIDTH / 2) - (width / 2);
			//y = -800;
			//var toY = (Engine.GAME_HEIGHT / 2) - (height / 2);
			//TweenLite.to(this, 2, { y:toY, ease:Elastic.easeOut } );
		}
		
		
		/**
		 * Retrieves the name
		 * 
		 * @return String - three initials
		 */		
		public function getInitials():String
		{
			return initials.text;
		}
		public function getPhone():String
		{
			return phone.text;
		}
		
		
		/**
		 * Adds event listeners to keys
		 */
		public function enableScoreKeyboard():void
		{
			//A - Z = 65 - 90
			//a - z = 97 - 122
			//input dialog keyboard
			var i:int;
			for(i = 97; i < 123; i++){
				this["b" + String.fromCharCode(i)].myLetter = String.fromCharCode(i);
				this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.CLICK, enterInit, false, 0, true);
				//this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OVER, keyOver);
				//this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			}
			//0 - 9 = 48 - 57			
			//input dialog keyboard
			for(i = 48; i < 58; i++){
				this["b" + String.fromCharCode(i)].myLetter = String.fromCharCode(i);
				this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.CLICK, enterPhone, false, 0, true);
				//this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OVER, keyOver);
				//this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			}
			/*
			hyphen.myLetter = "-";
			hyphen.addEventListener(MouseEvent.CLICK, enterPhone);
			hyphen.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			hyphen.addEventListener(MouseEvent.MOUSE_OUT, keyOut);		
			*/
			
			backspace.myLetter = "<";
			backspace.addEventListener(MouseEvent.CLICK, enterInit, false, 0, true);
			//backspace.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//backspace.addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			space.myLetter = " ";
			space.addEventListener(MouseEvent.CLICK, enterInit, false, 0, true);
			//space.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//space.addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			backspace2.myLetter = "<";
			backspace2.addEventListener(MouseEvent.CLICK, enterPhone, false, 0, true);
			//backspace2.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//backspace2.addEventListener(MouseEvent.MOUSE_OUT, keyOut);
						
			//enter.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//enter.addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			enter.addEventListener(MouseEvent.CLICK, scoreSubmit, false, 0, true);
			
			insertion.addEventListener(Event.ENTER_FRAME, flashCursor, false, 0, true);			
			cursorCounter = 0;
			insertion.x = initials.x + initials.textWidth - 2;
			insertion2.x = phone.x + phone.textWidth - 2;
		}

		private function flashCursor(e:Event):void
		{
			cursorCounter++;
			if (cursorCounter % 10 == 0) {
				if (insertion.alpha < 1) {
					insertion.alpha = 1;
					insertion2.alpha = 1;
				}else {
					insertion.alpha = 0;
					insertion2.alpha = 0;
				}
			}
		}
		
		/**
		 * Removes event listeners from keys
		 * 
		 * Called by scoreSubmit()
		 */
		private function disableScoreKeyboard():void
		{
			var i:int;
			for(i = 97; i < 123; i++){		
				this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.CLICK, enterInit);
				//this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
				//this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			}
			for(i = 48; i < 58; i++){		
				this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.CLICK, enterPhone);
				//this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
				//this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			}
			backspace.removeEventListener(MouseEvent.CLICK, enterInit);
			//backspace.removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//backspace.removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			backspace2.removeEventListener(MouseEvent.CLICK, enterPhone);
			//backspace2.removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//backspace2.removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			space.removeEventListener(MouseEvent.CLICK, enterInit);
			//space.removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//space.removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			//submit button
			enter.removeEventListener(MouseEvent.CLICK, scoreSubmit);			
			//enter.removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
			//enter.removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			insertion.removeEventListener(Event.ENTER_FRAME, flashCursor);			
		}
	
		
		
		/**
		 * Callback handler - called when enter button is pressed
		 * 
		 * @param	e CLICK mouse event
		 */
		private function scoreSubmit(e:MouseEvent):void
		{
			//var newScores:Array = new Array();
			var n:String = getInitials();
			if (isValidPhoneNumber(getPhone()) && n != "" && n.indexOf(" ") != -1) {
				//good to go								
				disableScoreKeyboard();		
				dispatchEvent(new Event("highScoreSubmitted"));
			}else {				
				TweenLite.to(errorDialog, .5, { alpha:1 } );
				TweenLite.to(errorDialog, .5, { alpha:0, overwrite:0, delay:3 } );
			}
		}
		
		
		
		/**
		 * Callback handler - called whenever a 'key' on the keyboard is clicked
		 * 
		 * @param	e CLICK mouse event
		 */
		private function enterInit(e:MouseEvent) {
			e.currentTarget.key.red.alpha = 1;
			TweenLite.to(e.currentTarget.key.red, .5, {alpha:0});
			var char = e.currentTarget.myLetter;
		
			if(char == "<"){
				//name backspace
				if(initials.text.length > 0){
					initials.text = initials.text.substr(0, initials.text.length - 1);
				}		
			}else {				
				if(initials.text.length < 20){
					initials.appendText(char);
				}
			}
			insertion.x = initials.x + initials.textWidth - 2;
		}
		
		
		/**
		 * Callback handler - called whenever a 'key' on the keyboard is clicked
		 * 
		 * @param	e CLICK mouse event
		 */
		private function enterPhone(e:MouseEvent)
		{
			e.currentTarget.key.red.alpha = 1;
			TweenLite.to(e.currentTarget.key.red, .5, {alpha:0});
			var char = e.currentTarget.myLetter;
			
			if (char == "<") {
				//phone backspace
				if(phone.text.length > 0){
					phone.text = phone.text.substr(0, phone.text.length - 1);
				}
			}else {				
				if (phone.text.length < 12) {
					if (phone.text.length == 3) {
						phone.appendText("-");
					}
					if (phone.text.length == 7) {
						phone.appendText("-");
					}
					phone.appendText(char);
				}
			}
			insertion2.x = phone.x + phone.textWidth - 2;
		}
		
		//listeners for the keys in the high score dialog
		private function keyOver(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.key.red, .5, {alpha:1});
		}
		
		
		private function keyOut(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.key.red, .5, {alpha:0});
		}
		
		
		private function isValidPhoneNumber( str:String ):Boolean
		{
			var phoneRegExp:RegExp = /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,3})|(\(?\d{2,3}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/i;
			return phoneRegExp.test(str);
		}
	}	
}