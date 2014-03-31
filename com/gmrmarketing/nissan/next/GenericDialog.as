package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	
	public class GenericDialog extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function GenericDialog()
		{
			clip = new genericDialog();
		}
		
		
		public function show($container:DisplayObjectContainer, message:String, delay:int = 2):void
		{
			container = $container;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = message.toUpperCase();
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.to(clip, 1, { alpha:0, delay:delay, onComplete:removeClip } );
		}
		
		
		private function removeClip():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
	}
	
}