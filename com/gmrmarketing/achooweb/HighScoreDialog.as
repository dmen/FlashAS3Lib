/**
 * Kleenex Achoo Game
 * GMR Marketing
 * 
 * Class for high score dialog in the library
 * 
 * Managed by HighScoreManager
 */

package com.gmrmarketing.achooweb
{	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*
	
	public class HighScoreDialog extends Sprite
	{
		
		//list of three letter swear words to be excluded from entry
		private var exclude:Array = new Array("god", "ass", "azz", "anl", "aho", "fuk", "fkr", "fuc", "fck", "fux", "vag", "pus", "psy", "cnt", "cun", "pis", "pee", "sht", "poo", "cum", "jiz", "dik", "dic", "dck", "pns", "cok", "coc", "cox", "gay", "yag", "fag", "lez", "tit", "tty", "kkk", "ngr", "nig", "sex", "xes", "suk", "sux", "lix", "pig");			
		
		
		public function HighScoreDialog() { }
		
		
		public function show():void
		{
			enableScoreKeyboard();
			x = (Engine.GAME_WIDTH / 2) - (width / 2);
			y = -800;
			var toY = (Engine.GAME_HEIGHT / 2) - (height / 2);
			TweenLite.to(this, 2, { y:toY, ease:Elastic.easeOut } );
		}
		
		
		/**
		 * Retrieves the intitials as upper case
		 * 
		 * @return String - three initials
		 */
		public function getInitials():String
		{
			return initials.text.toUpperCase();
		}
		
		/**
		 * Adds event listeners to keys
		 */
		private function enableScoreKeyboard():void
		{
			//A - Z = 65 - 90
			//a - z = 97 - 122
			//input dialog keyboard
			for(var i = 97; i < 123; i++){
				this["b" + String.fromCharCode(i)].myLetter = String.fromCharCode(i - 32);//upper case
				this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.CLICK, enterInit);
				this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OVER, keyOver);
				this["b" + String.fromCharCode(i)].addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			}
			backSpace.myLetter = "<";
			backSpace.addEventListener(MouseEvent.CLICK, enterInit);
			backSpace.addEventListener(MouseEvent.MOUSE_OVER, keyOver);
			backSpace.addEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			btnSubmit.addEventListener(MouseEvent.MOUSE_OVER, hiliteBGColor);
			btnSubmit.addEventListener(MouseEvent.MOUSE_OUT, normalBGColor);
			btnSubmit.addEventListener(MouseEvent.CLICK, scoreSubmit);
			btnSubmit.addEventListener(MouseEvent.CLICK, normalBGColor);
		}

		
		
		/**
		 * Removes event listeners from keys
		 * Called by scoreSubmit()
		 */
		private function disableScoreKeyboard():void
		{
			for(var i = 97; i < 123; i++){		
				this["b" + String.fromCharCode(i)].removeEventListener(MouseEvent.CLICK, enterInit);
			}	
			backSpace.removeEventListener(MouseEvent.CLICK, enterInit);
			backSpace.removeEventListener(MouseEvent.MOUSE_OVER, keyOver);
			backSpace.removeEventListener(MouseEvent.MOUSE_OUT, keyOut);
			
			btnSubmit.removeEventListener(MouseEvent.CLICK, scoreSubmit);
			btnSubmit.removeEventListener(MouseEvent.CLICK, normalBGColor);
			btnSubmit.removeEventListener(MouseEvent.MOUSE_OVER, hiliteBGColor);
			btnSubmit.removeEventListener(MouseEvent.MOUSE_OUT, normalBGColor);
		}
	
		
		
		/**
		 * Callback handler - called when submit button is pressed
		 * 
		 * @param	e CLICK mouse event
		 */
		private function scoreSubmit(e:MouseEvent):void
		{
			var newScores:Array = new Array();			
			var inits:String = initials.text.toLowerCase();
			
			if(exclude.indexOf(inits) != -1){
				//entered a banned word
				initials.text = "";
				warning.alpha = 1;
				TweenLite.to(warning, 1, { autoAlpha:0 } );				
			}else if (inits == "") {				
				//blank
				initials.text = "CPU";				
			}else {				
				//good to go								
				disableScoreKeyboard();				
				TweenLite.to(this, 1, {y:-650, onComplete:scoreSubmitted});			
			}
		}
		
		
		/**
		 * Called from tween complete once the user has submitted their initials and the
		 * dialog has been removed - HighScoreManager is the listener
		 * Calls saveScore within the manager
		 */
		private function scoreSubmitted()
		{
			dispatchEvent(new Event("highScoreSubmitted"));
		}
		
		
		/**
		 * Callback handler - called whenever a 'key' on the keyboard is clicked
		 * 
		 * @param	e CLICK mouse event
		 */
		private function enterInit(e:MouseEvent) {			
			var char = e.currentTarget.myLetter;			
			if(char == "<"){
				//backspace
				if(initials.text.length > 0){
					initials.text = initials.text.substr(0, initials.text.length - 1);
				}
			}else {				
				if(initials.text.length < 3){
					initials.appendText(char);
				}
			}
		}
		
		
		//submit button listeners
		private function hiliteBGColor(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.bg, .5, {tint:0xFFFF00});
		}
		
		
		private function normalBGColor(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.bg, .5, {tint:0xCCCC00});
		}
		
		
		//listeners for the keyboard keys in the high score dialog
		private function keyOver(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.bg, .5, {tint:0xff0000});
		}
		
		
		private function keyOut(e:MouseEvent)
		{
			TweenLite.to(e.currentTarget.bg, .5, {removeTint:true});
		}
	}	
}