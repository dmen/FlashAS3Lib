package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*;
	import com.greensock.TweenMax;
	
	public class TickLine
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private const minX:int = 56;
		private const maxX:int = 1877;
		
		public function TickLine()
		{
			clip = new mcTick();
			clip.blendMode = BlendMode.OVERLAY;
			clip.y = 1051;
			clip.x = Math.round(minX + (Math.random() * (maxX - minX)));
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}		
		}
		
		
		public function analyze():void
		{
			nextPoint();
		}
		
		
		public function stop():void
		{
			TweenMax.killTweensOf(clip);
		}
		
		private function nextPoint():void
		{
			var newX:int = Math.round(minX + (Math.random() * (maxX - minX)));
			var t:Number = .25 + Math.random() * 3;
			TweenMax.to(clip, t, { x:newX, onComplete:nextPoint } );
		}
	}
	
}