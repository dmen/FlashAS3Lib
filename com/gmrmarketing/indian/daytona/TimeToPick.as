/**
 * Controls the flashing 'time to pick' text that will appear if the
 * countdown reaches zero
 */

package com.gmrmarketing.indian.daytona
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;	
	
	public class TimeToPick
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function TimeToPick()
		{
			clip = new timeToPick();
			clip.x = 270;
			clip.y = 352;
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			
			container.addChild(clip);
			clip.theText.alpha = 1;
			
			fadeOut();
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.theText);
			if(container){
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
		}
		
		
		private function fadeOut():void
		{
			TweenMax.to(clip.theText, 1, { alpha:0, onComplete:fadeIn } );
		}
		
		
		private function fadeIn():void
		{
			TweenMax.to(clip.theText, 1, { alpha:1, onComplete:fadeOut } );
		}		
		
	}
	
}