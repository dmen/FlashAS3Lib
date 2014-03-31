/**
 * Instantiated by Main
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	
	
	public class Welcome_CANADA extends EventDispatcher
	{
		private var container:DisplayObjectContainer;
		private var clip:MovieClip;
		
		
		public function Welcome_CANADA()
		{			
			clip = new welcomeClip(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			clip.alpha = 1;
			container = $container;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
		}
		
		
		public function hide():void
		{
			if(clip){
				TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
			}
		}
		
		
		private function kill():void
		{
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
		}
		
	}
	
}