package com.gmrmarketing.sap.metlife
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.*;
	
	
	public class Flare
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Flare()
		{
			clip = new flare();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(sx:int, sy:int, ex:int, delay:Number):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.x = sx;
			clip.y = sy;
			clip.scaleX = 0;
			clip.alpha = 0;
			
			var delta:Number = (ex - sx) / 90;//bout 124 pixels per second
			
			TweenMax.to(clip, .75, { alpha:1, scaleX:1, delay:delay } );
			TweenMax.to(clip, delta, { x:ex, delay:delay, ease:Linear.easeNone } );
			TweenMax.to(clip, .75, { alpha:0, scaleX:0, delay:delay + (delta - .75), onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			container = null;
			clip = null;
		}
	}
	
}