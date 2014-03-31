package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	
	
	public class PointsDisplay
	{		
		private var container:DisplayObjectContainer;
		
		
		public function PointsDisplay()
		{			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(at:Point, mess:String):void
		{
			var clip:MovieClip = new mcPointsDisplay();//lib			
			
			clip.theText.text = mess;
			clip.scaleX = clip.scaleY = 1;
			clip.alpha = 1;
			clip.x = at.x;
			clip.y = at.y - 50;
			container.addChild(clip);
			
			TweenMax.to(clip, 1, { alpha:0, scaleX:3, scaleY:3, onComplete:kill, onCompleteParams:[clip]} );
		}
		
		
		private function kill(clip:MovieClip):void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}