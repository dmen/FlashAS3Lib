package com.gmrmarketing
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class Smoke
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Smoke($clip:MovieClip, $container:DisplayObjectContainer, x:int, y:int):void
		{
			clip = $clip;
			container = $container;
			clip.x = x;
			clip.y = y;
			clip.alpha = Math.random();
			clip.scaleX = clip.scaleY = Math.random();
			container.addChild(clip);
			clip.addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{			
			clip.alpha -= .01;
			clip.scaleX += .01;
			clip.scaleY += .01;
			if (clip.alpha <= 0) {
				container.removeChild(clip);
				clip.removeEventListener(Event.ENTER_FRAME, update);
				delete this;
			}
		}
	}
	
}