/**
 * Level intro screen that appears at the start of each level
 * right before the 3-2-1 countdown
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class LevelIntro extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var theLevel:int;
		
		public function LevelIntro()
		{
			clip = new mcLevelIntro();
			clip.addEventListener(Event.ADDED_TO_STAGE, switchFrame);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(level:int):void
		{
			theLevel = level;
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 1;			
		}
		
		private function switchFrame(e:Event):void
		{
			clip.gotoAndStop(theLevel);
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, 1, { alpha:0, onComplete:kill } );			
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
		}
		
	}
	
}