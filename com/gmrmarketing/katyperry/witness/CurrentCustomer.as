package com.gmrmarketing.katyperry.witness
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	
	
	public class CurrentCustomer extends EventDispatcher
	{
		public static const COMPLETE:String = "currentComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var selection:Boolean;
		private var perlin:PerlinNoise;//for animating the bg
		private var circleTimer:Timer;
		
		
		public function CurrentCustomer()
		{
			clip = new currentCust();
			perlin = new PerlinNoise();
			circleTimer = new Timer(1200);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			perlin.show(clip.bg);
			
			clip.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, selectedYes, false, 0, true);
			clip.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, selectedNo, false, 0, true);
			
			addCircle();
			circleTimer.addEventListener(TimerEvent.TIMER, addCircle, false, 0, true);
			circleTimer.start();
		}
		
		
		private function addCircle(e:TimerEvent = null):void
		{			
			var c:AnimatedCircle = new AnimatedCircle(false);//no mask
			c.x = 232;
			c.y = 412;
			clip.addChild(c);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			perlin.hide();
			circleTimer.removeEventListener(TimerEvent.TIMER, addCircle);
			circleTimer.reset();
		}
		
		
		public function get customer():Boolean
		{
			return selection;
		}
		
		
		private function selectedYes(e:MouseEvent):void
		{
			selection = true;
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function selectedNo(e:MouseEvent):void
		{
			selection = false;
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}