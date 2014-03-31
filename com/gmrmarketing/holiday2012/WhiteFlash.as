package com.gmrmarketing.holiday2012
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import com.greensock.TweenMax;
	
	public class WhiteFlash
	{
		private var white:Sprite;
		private var container:DisplayObjectContainer;
		
		public function WhiteFlash()
		{
			white = new Sprite();
			white.graphics.beginFill(0xFFFFFF, 1);
			white.graphics.drawRect(0, 0, 1680, 1050);
			white.graphics.endFill();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function show():void
		{
			if (!container.contains(white)) {
				container.addChild(white);
			}
			white.alpha = 1;
			TweenMax.to(white, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(white)) {
				container.removeChild(white);
			}
		}
	}
	
}