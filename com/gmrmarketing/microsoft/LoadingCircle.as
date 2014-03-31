package com.gmrmarketing.microsoft
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;	
	
	public class LoadingCircle
	{
		private var container:DisplayObjectContainer;
		
		
		public function LoadingCircle($container:DisplayObjectContainer)
		{
			container = $container;
		}		
		
		
		public function show(centX:int, centY:int, numCircles:int):void
		{
			var radius:int = 50;
			var circleRadians:Number = Math.PI * 2;
			var sliceAngle:Number = circleRadians / numCircles;
			var xLoc:Number;
			var yLoc:Number;
			
			centX -= radius / 2;
			centY -= radius / 2;
			
			for (var i:Number = 0; i < circleRadians; i += sliceAngle) {
				xLoc = Math.cos(i) * radius;
				yLoc = Math.sin(i) * radius;
				
				var c:MovieClip = new circ(); //lib clip
				container.addChild(c);
				c.x = centX + xLoc;
				c.y = centY + yLoc;
			}
			animate();
		}
		
		public function hide():void
		{
			TweenMax.killAll();
			while (container.numChildren) {
				container.removeChildAt(0);
			}
		}
		
		private function animate():void
		{
			for (var i:int = 0; i < container.numChildren; i++){
				TweenMax.to(container.getChildAt(i), 1, { alpha:0, repeat: -1, delay:i * .25, yoyo:true } );
			}
		}
	}	
}