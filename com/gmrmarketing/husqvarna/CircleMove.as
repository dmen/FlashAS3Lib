package com.gmrmarketing.husqvarna
{
	import com.greensock.TweenLite;	
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.events.*;
	
	public class CircleMove extends EventDispatcher
	{
		private var ob:DisplayObject;
				
		private var xAng:Number;
		private var yAng:Number;
		
		private var initX:int;
		private var initY:int;
		private var twoPI:Number = Math.PI * 2;
		
		public function CircleMove($ob:DisplayObject)
		{
			ob = $ob;
			initX = ob.x;
			initY = ob.y;
			xAng = 0;
			yAng = 0;
			ob.addEventListener(Event.ENTER_FRAME, nextPoint, false, 0, true);			
		}
		
		private function nextPoint(e:Event):void
		{			
			xAng += .03;
			if (xAng > twoPI) {
				xAng = 0;
			}
			ob.x = initX + Math.cos(xAng) * 6;
			ob.y = initY + Math.sin(xAng) * 3;
		}
		
		public function stop():void
		{
			ob.removeEventListener(Event.ENTER_FRAME, nextPoint);		
		}
		
		public function play():void
		{			
			ob.addEventListener(Event.ENTER_FRAME, nextPoint, false, 0, true);
		}
		
	}
	
}