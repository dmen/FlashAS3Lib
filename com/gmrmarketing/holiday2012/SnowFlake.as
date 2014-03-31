package com.gmrmarketing.holiday2012
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
		
	public class SnowFlake extends Sprite
	{
		private var clip:MovieClip;
		private var speed:Number;				
		private var angle:int;
		
		public function SnowFlake()
		{
			var b:Bitmap;			
			
			var a:Number = Math.random();
			if (a < .3) {
				b = new Bitmap(new flake1());
			}else if (a < .6) {
				b = new Bitmap(new flake2());
			}else {
				b = new Bitmap(new flake3());
			}
			
			b.alpha = Math.min(1, .1 + Math.random());
			b.scaleX = b.scaleY = Math.min(1, .2 + Math.random());			
			
			addChild(b);
			
			speed = 2 + Math.random() * 5;
			angle = Math.random() * 6.28;
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		public function kill():void
		{
			removeChildAt(0); //removes bitmap from this sprite
			if(parent.contains(this)){
				parent.removeChild(this);
			}
			removeEventListener(Event.ENTER_FRAME, update);		
		}
		
		private function update(e:Event):void
		{
			y += speed;
			
			angle += .1;
			if (angle > 6.28) {
				angle = 0;
			}
			
			x += Math.cos(angle) * .5;
			
			if (y > 1080) {
				kill();		
			}
		}
	}
	
}