package com.gmrmarketing.nissan.rodale
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	

	public class Bullet
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var minFrame:int;
		private var maxFrame:int;
		private var interval:Timer;
		private var theCar:MovieClip;
		
		public function Bullet($clip:MovieClip, $container:DisplayObjectContainer, fMin:int, fMax:int, $x:int, $y:int, car:MovieClip)
		{
			clip = $clip;
			container = $container;
			
			minFrame = fMin;
			maxFrame = fMax;
			
			clip.x = $x;
			clip.y = $y;
			
			theCar = car;
			
			//interval = new Timer(10);
			//interval.addEventListener(TimerEvent.TIMER, check, false, 0, true);
			//interval.start();
		}
		
		
		public function check(fr:int):void
		{			
			//var c:int = theCar.currentFrame;			
			
			if (fr >= minFrame && fr <= maxFrame) {
				if(!container.contains(clip)){
				clip.alpha = 0;
				container.addChild(clip);
				
				TweenMax.to(clip, .25, { alpha:1 } );
				}
			}else {
				if (container.contains(clip)) {
					TweenMax.to(clip, 1, { alpha:0, onComplete:kill } );
				}
			}
		}
		
		
		private function kill():void
		{			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}