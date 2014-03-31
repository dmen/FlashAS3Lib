package com.gmrmarketing.comcast.laacademia2011
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	
	
	public class ScreenSaver extends EventDispatcher
	{		
		public static const SS_CLOSED:String = "screenSaverClicked";
		
		private var container:DisplayObjectContainer;
		private var ss:MovieClip;
		private var xVel:Number;
		private var yVel:Number;
		private var touchXVel:Number;
		private var touchYVel:Number;
		private var hw:Number;
		private var hh:Number;
		private var touchhw:Number;
		private var touchhh:Number;
		
		public function ScreenSaver($container:DisplayObjectContainer)
		{
			container = $container;			
			ss = new screenSaver(); //lib clip
			hw = ss.logo.width * .5 + 10;
			hh = ss.logo.height * .5 + 10;
			touchhw = ss.touch.width * .5 + 10;
			touchhh = ss.touch.height * .5 + 10;
		}		
		
		
		public function show():void
		{			
			container.addChild(ss);
			container.stage.addEventListener(MouseEvent.CLICK, hide, false, 0, true);
			
			xVel = 2 + Math.random() * 2;
			yVel = 2 + Math.random() * 2;
			
			touchXVel = 2 + Math.random() * 2;
			touchYVel = 2 + Math.random() * 2;
			
			container.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		public function hide(e:MouseEvent):void
		{
			container.stage.removeEventListener(MouseEvent.CLICK, hide);
			container.removeEventListener(Event.ENTER_FRAME, update);
			container.removeChild(ss);
			dispatchEvent(new Event(SS_CLOSED));
		}
		
		
		
		private function update(e:Event):void
		{
			ss.logo.x += xVel;
			ss.logo.y += yVel;
			
			ss.touch.x += touchXVel;
			ss.touch.y += touchYVel;
			
			if (ss.logo.x - hw < 0) {
				xVel *= -1;
				ss.logo.x = hw + 1;
			}
			if (ss.logo.x + hw > 1920) {
				xVel *= -1;
				ss.logo.x = 1920 - hw - 1;
			}
			
			if (ss.logo.y - hh < 0) {
				yVel *= -1;
				ss.logo.y = hh + 1;
			}
			if (ss.logo.y + hh > 1080) {
				yVel *= -1;
				ss.logo.y = 1080 - hh - 1;
			}
			
			
			if (ss.touch.x - touchhw < 0) {
				touchXVel *= -1;
				ss.touch.x = touchhw + 1;
			}
			if (ss.touch.x + touchhw > 1920) {
				touchXVel *= -1;
				ss.touch.x = 1920 - touchhw - 1;
			}
			
			if (ss.touch.y - touchhh < 0) {
				touchYVel *= -1;
				ss.touch.y = touchhh + 1;
			}
			if (ss.touch.y + touchhh > 1080) {
				touchYVel *= -1;
				ss.touch.y = 1080 - touchhh - 1;
			}
		}
	}
	
}