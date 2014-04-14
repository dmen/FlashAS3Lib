package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class Instructions
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Instructions()
		{
			clip = new mcInstructions();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function show():void
		{
			clip.hands.rotation = 0;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			animRight();
		}
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.hands);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		private function animRight():void
		{
			TweenMax.to(clip.hands, 1, { rotation:10, onComplete:animLeft } );
		}
		
		private function animLeft():void
		{
			TweenMax.to(clip.hands, 1, { rotation:-10, onComplete:animRight } );
		}
	}
	
}