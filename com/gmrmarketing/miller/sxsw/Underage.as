package com.gmrmarketing.miller.sxsw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	
	public class Underage extends EventDispatcher
	{		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Underage()
		{			
		}
		
		public function show($container:DisplayObjectContainer):void
		{
			clip = new underage();
			container = $container;
			clip.alpha = 0;
			container.addChild(clip);			
			TweenMax.to(clip, 2, { alpha:1 } );
			TweenMax.to(clip, 1, { alpha:0, delay:5, onComplete:kill } );
		}
		
		private function kill():void
		{
			container.removeChild(clip);				
			clip = null;
		}
	}
	
}