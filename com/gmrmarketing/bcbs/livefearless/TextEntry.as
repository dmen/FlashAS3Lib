package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.utils.Timer;
	
	public class TextEntry extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const NEXT:String = "nextPressed";
		private const MAX_CHARS:int = 160;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var kbd:KeyBoard;		
		private var charCountTimer:Timer;
		
		
		public function TextEntry()
		{
			clip = new mcTextEntry();
			kbd = new KeyBoard();			 
			//kbd.addEventListener(KeyBoard.KEYFILE_LOADED, init, false, 0, true);
			kbd.loadKeyFile("bcbs_photobooth.xml");
			
			clip.theText.text = "";
			clip.theCount.text = String(MAX_CHARS);
			
			charCountTimer = new Timer(200);
			charCountTimer.addEventListener(TimerEvent.TIMER, updateCharCount, false, 0, true);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(clearText:Boolean = true):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			kbd.x = 485;
			kbd.y = 700;
			if(!clip.contains(kbd)){
				clip.addChild(kbd);
			}
			kbd.setFocusFields([clip.theText]);
			
			if (clearText) {
				clip.theText.text = "";
				clip.theCount.text = String(MAX_CHARS);			
			}
			
			clip.alpha = 0;
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
			
			charCountTimer.start();//call updateCharCount()
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			charCountTimer.stop();
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.removeChild(kbd);
		}
		
		
		public function getMessage():String
		{
			return clip.theText.text;
		}
		
		
		/**
		 * Called when the Next button is pressed
		 * @param	e
		 */
		private function doNext(e:MouseEvent):void
		{
			dispatchEvent(new Event(NEXT));
		}
		
		
		private function updateCharCount(e:TimerEvent):void
		{
			var charsRemaining:int = MAX_CHARS - clip.theText.length;
			if (charsRemaining < 0) {
				charsRemaining = 0;
				clip.theText.text = String(clip.theText.text).substr(0, MAX_CHARS);
			}
			clip.theCount.text = String(charsRemaining);
		}
	}
	
}