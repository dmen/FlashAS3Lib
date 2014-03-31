package com.gmrmarketing.indian.daytona
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class Dialog extends EventDispatcher
	{
		public static const REMOVED:String = "dialogRemoved";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Dialog()
		{
			clip = new dialog();
			clip.x = 614;
			clip.y = 316;
		}
		
		
		public function show(message:String, $container:DisplayObjectContainer):void
		{
			container = $container;
			
			clip.theText.text = message;
			clip.theText.y = (clip.height - clip.theText.textHeight) * .5;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			TweenMax.killTweensOf(clip);
			TweenMax.to(clip, .5, { alpha:1, onComplete:remove } );
		}		
		
		
		private function remove():void
		{
			TweenMax.to(clip, .5, { alpha:0, delay:3, onComplete:kill } );
		}
		
		
		
		private function kill():void
		{
			if(container.contains(clip)){
				container.removeChild(clip);
			}
			dispatchEvent(new Event(REMOVED));
		}
		
	}
	
}