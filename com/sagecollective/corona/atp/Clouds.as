package com.sagecollective.corona.atp
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.*;
	
	public class Clouds
	{
		private const SCREEN_WIDTH:int = 1920;
		
		private var cloudContainer:DisplayObjectContainer;
		
		private var cloud_1:Sprite;
		private var cloud_2:Sprite;
		private var cloud_3:Sprite;
		
		private var speed1:Number;
		private var speed2:Number;
		private var speed3:Number;
		
		
		public function Clouds(container:DisplayObjectContainer)
		{
			cloudContainer = container;
			
			cloud_1 = new Sprite();
			cloud_1.addChild(new Bitmap(new cloud1()));
			cloud_1.y = 255;
			cloud_1.x = Math.round(Math.random() * 1920);
			
			cloud_2 = new Sprite();
			cloud_2.addChild(new Bitmap(new cloud2()));
			cloud_2.y = 255;
			cloud_2.x = Math.round(Math.random() * 1920);
			
			cloud_3 = new Sprite();
			cloud_3.addChild(new Bitmap(new cloud3()));
			cloud_3.y = 255;
			cloud_3.x = Math.round(Math.random() * 1920);
			
			//limit cloud speeds to a max of .6
			speed1 = Math.min(.2 + Math.random(), .6);
			speed2 = Math.min(.2 + Math.random(), .6);
			speed3 = Math.min(.2 + Math.random(), .6);
		}
		
		
		public function start():void
		{
			cloudContainer.addChild(cloud_1);
			cloudContainer.addChild(cloud_2);
			cloudContainer.addChild(cloud_3);
			
			cloudContainer.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		public function stop():void
		{
			cloudContainer.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		
		private function update(e:Event):void
		{
			cloud_1.x += speed1;
			cloud_2.x += speed2;
			cloud_3.x += speed3;
			
			if (cloud_1.x > SCREEN_WIDTH) {
				cloud_1.x = 0 - cloud_1.width;
			}
			
			if (cloud_2.x > SCREEN_WIDTH) {
				cloud_2.x = 0 - cloud_2.width;
			}
			
			if (cloud_3.x > SCREEN_WIDTH) {
				cloud_3.x = 0 - cloud_3.width;
			}
		}
	}
	
}