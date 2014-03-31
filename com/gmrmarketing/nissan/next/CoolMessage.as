/**
 * One single message being displayed in the screensaver or wouldn't it be cool screen
 * Instantiated by Cool.as 
 */

package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	
	public class CoolMessage extends EventDispatcher
	{
		public static const FINISHED:String = "messageComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var targetString:String;
		
		private var charTimer:Timer;
		private var charIndex:int;
		
		private var theTween:TweenMax;
		private var speed:Number;
		
		private var fadeTimer:Timer;
		
		
		
		public function CoolMessage($container:DisplayObjectContainer, mess:String, name:String, theX:int, theY:int)
		{
			container = $container;
			
			targetString = mess.toUpperCase();						
			targetString = targetString.replace("'", "’"); //All upper and using the curved single quote ’
			
			clip = new coolMessage(); //lib clip			
			
			clip.theText.text = "";
			clip.theText.autoSize = TextFieldAutoSize.LEFT;
			
			clip.theName.text = name.toUpperCase();
			clip.x = theX;
			clip.y = theY;
			clip.alpha = .85;
			clip.scaleX = clip.scaleY = .5 + (Math.random() * .6);
			
			clip.cursor.alpha = .85;
			
			container.addChild(clip);
			
			charIndex = 0;
			
			//determine margin widths
			var deltaLeft:int = clip.x * .5;
			var deltaRight:int = (1366 - (clip.x + clip.theText.textWidth)) * .5;
			
			if (deltaLeft > deltaRight) {
				speed = 0 - (1 + Math.random() * 1.5);
			}else {
				speed = 1 + Math.random() * 1.5;
			}
			
			clip.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			
			//starts fading the message out 7 seconds in
			fadeTimer = new Timer(7000, 1);
			fadeTimer.addEventListener(TimerEvent.TIMER, doFade);
			fadeTimer.start();
			
			charTimer = new Timer(50);
			charTimer.addEventListener(TimerEvent.TIMER, addCharacter);
			charTimer.start();
		}
		
		
		private function doFade(e:TimerEvent):void
		{		
			theTween = TweenMax.to(clip, 3, { alpha:0, onComplete:kill } );
		}
		
		
		private function update(e:Event):void
		{
			clip.x += speed;
		}
		
		
		private function addCharacter(e:TimerEvent):void
		{			
			if (charIndex < targetString.length) {
				var char:String = targetString.substr(charIndex, 1);				
				clip.theText.appendText(char);
				
				var r:Rectangle = TextField(clip.theText).getCharBoundaries(charIndex);
				charIndex++;
				
				clip.cursor.y = r.y + r.height + 12;
				clip.cursor.x = r.x + 12;
				
				clip.theName.y = clip.theText.y + ((clip.theText.numLines * 37) - ((clip.theText.numLines - 1) * 6));
				
			}else {
				charTimer.stop();
				clip.cursor.alpha = 0;
				
			}			
		}
		
		
		public function kill():void
		{
			if(theTween){
				theTween.kill();
			}
			theTween = null;
			
			fadeTimer.reset();
			fadeTimer.removeEventListener(TimerEvent.TIMER, doFade);
			fadeTimer = null;
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			
			clip.removeEventListener(Event.ENTER_FRAME, update);
			charTimer.removeEventListener(TimerEvent.TIMER, addCharacter);
			charTimer = null;
			
			clip = null;			
			dispatchEvent(new Event(FINISHED));
		}
		
		
	}
	
}