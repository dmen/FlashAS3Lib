package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.Event;
	
	public class Background
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var velX:Number;
		private var velY:Number;
		private var velX2:Number;
		private var velY2:Number;
		
		public function Background()
		{
			velX = 2 + Math.random() * 2;
			if (Math.random() < .5) {
				velX *= -1;
			}
			velY = 2 + Math.random() * 2;
			if (Math.random() < .5) {
				velY *= -1;
			}
			velX2 = 2 + Math.random() * 2;
			if (Math.random() < .5) {
				velX2 *= -1;
			}
			velY2 = 2 + Math.random() * 2;
			if (Math.random() < .5) {
				velY2 *= -1;
			}
			clip = new mcBG();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			clip.cacheAsBitmap = true;
			clip.light.cacheAsBitmap = true;
			myContainer.addEventListener(Event.ENTER_FRAME, updateLight);
		}
		
		
		public function getBG():Object
		{
			return { left:clip.bgL, right:clip.bgR };
		}
		
		
		private function updateLight(e:Event):void
		{
			clip.light.x += velX;
			clip.light.y += velY;
			
			if (clip.light.x < 0 || clip.light.x > 2160) {
				velX *= -1;
			}
			if (clip.light.y < 0 || clip.light.y > 1440) {
				velY *= -1;
			}
			/*
			clip.light2.x += velX2;
			clip.light2.y += velY2;
			
			if (clip.light2.x < 0 || clip.light2.x > 2160) {
				velX2 *= -1;
			}
			if (clip.light2.y < 0 || clip.light2.y > 1440) {
				velY2 *= -1;
			}*/
		}
	}
	
}