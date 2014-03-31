//one single oscillating line in the analyzer bg

package com.gmrmarketing.wrigley.gumergency
{
	import flash.display.*;
	import flash.events.Event;
	import com.greensock.TweenMax;
	
	
	public class VLine
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var angle:Number;
		private const twoPI:Number = 2 * Math.PI;
		private var initY:int;
		
		public function VLine()
		{
			clip = new vline();			
		}
		
		
		public function add($container:DisplayObjectContainer, tx:int, ty:int, initAngle:Number):void
		{
			container = $container;
			container.addChild(clip);
			clip.x = tx;
			clip.y = ty;
			initY = ty;
			angle = initAngle;
			//start();
		}	

		public function start():void
		{
			clip.addEventListener(Event.ENTER_FRAME, update);
		}
		
		public function stop():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void
		{
			var s:Number = Math.sin(angle) * (Math.random() * 30);
			
			angle += .3;
			if (angle >= twoPI) {
				angle = 0;
				clip.y = initY;
			}			
			clip.y += Math.round(s);			
		}
	}
	
}