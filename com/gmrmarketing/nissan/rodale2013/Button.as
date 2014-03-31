package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.media.Sound;
	
	public class Button extends EventDispatcher
	{
		public static const PRESSED:String = "buttonpressed";
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var snd:Sound;
		
		public function Button($container:DisplayObjectContainer, which:String, label:String, xPos:int, yPos:int)
		{
			container = $container;
			snd = new sndButton();
			
			if (which == "white") {
				clip = new btnWhite();
			}else {
				clip = new btnRed();
			}
			
			clip.theText.text = label;			
			
			container.addChild(clip);
			clip.x = xPos;
			clip.y = yPos;
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, pressed, false, 0, true);
		}
		
		
		private function pressed(e:MouseEvent):void
		{
			snd.play();
			clip.highlight.alpha = 1;
			TweenMax.to(clip.highlight, .25, { alpha:0, onComplete:dispatchPress } );			
		}
		
		
		private function dispatchPress():void
		{
			dispatchEvent(new Event(PRESSED));
		}
	}
	
}