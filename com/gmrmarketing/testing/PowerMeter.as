package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	import com.greensock.TweenLite;
	
	
	public class PowerMeter extends MovieClip
	{
		private var mousePoint:Point;
		private var curRotationInRadians:Number;
		
		
		public function PowerMeter(){}
		
		
		
		/**
		 * Called from engine - BCHockey.as
		 * called whenever the power meter is added to the display list
		 * ie from BCHockey.addPowerMeter()
		 */
		public function init():void
		{			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, changeArrowAngle, false, 0, true);
			arrow.rotation = 0;
			bar.scaleY = 1;
			curRotationInRadians = 0;
			mousePoint = new Point(0,0);			
			barDown();
		}
		
		
		public function stopMeter():void
		{
			stopTweens();
		}
		
		
		private function barDown():void
		{
			TweenLite.to(bar, 1, { scaleY:0, onComplete:barUp});
		}
		
		
		private function barUp():void
		{
			TweenLite.to(bar, 1, { scaleY:1, onComplete:barDown});
		}
		
		
		private function stopTweens():void
		{
			TweenLite.killTweensOf(bar);
		}
		
		
		public function getMeterData():Object
		{
			var o:Object = new Object();
			o.angle = arrow.rotation;
			
			var powerRadius:int = Math.max(2, bar.scaleY * 45);
			var powX:Number = Math.cos(curRotationInRadians - Math.PI / 2) * powerRadius;
			var powY:Number = Math.sin(curRotationInRadians - Math.PI / 2) * powerRadius;
			
			o.vx = powX;
			o.vy = powY;			
			
			return o;
		}
		
		
		private function changeArrowAngle(e:MouseEvent):void
		{
			var ang:Number = Math.atan2(mouseY - mousePoint.y, mouseX - mousePoint.x);
			curRotationInRadians = ang;
			arrow.rotation = ang * (180 / Math.PI);
		}
	}
	
}