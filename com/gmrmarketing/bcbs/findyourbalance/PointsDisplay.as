package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import flash.text.*;
	
	public class PointsDisplay
	{		
		private var container:DisplayObjectContainer;
		private var format:TextFormat;
		
		
		public function PointsDisplay()
		{
			format = new TextFormat();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(at:Point, mess:String, color:Number = 0x00529B):void
		{
			var clip:MovieClip = new mcPointsDisplay();//lib			
			
			clip.theText.text = mess;
			clip.scaleX = clip.scaleY = 1;
			clip.alpha = 1;
			clip.x = at.x;
			clip.y = at.y - 50;
			container.addChild(clip);
			
			format.color = color;
			clip.theText.setTextFormat(format);
			
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