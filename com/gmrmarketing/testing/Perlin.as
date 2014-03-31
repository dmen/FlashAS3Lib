package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.display.BlendMode;
	
	
	public class Perlin extends MovieClip
	{
		private var pMapData:BitmapData;
		private var pMap:Bitmap;
		private var seed:Number;
		private var oPoint:Point;
		private var o2Point:Point;
		private var channels:uint;
		private var disp:DisplacementMapFilter;
		
		private var fireData:BitmapData;
		private var fire:Bitmap;
		private var fire2:Bitmap;
		private var fireData2:BitmapData;
		
		
		public function Perlin()
		{
			pMapData = new BitmapData(550, 400, false, 0x995500);
			//pMap = new Bitmap(pMapData);
			
			seed = Math.floor(Math.random() * 10);
			channels = BitmapDataChannel.RED | BitmapDataChannel.BLUE;
			oPoint = new Point(0, 0);
			o2Point = new Point(0, 0);
			
			fireData = new fired(); //lib clip;
			fireData2 = new fired(); //lib clip;
			fire = new Bitmap(fireData);
			fire2 = new Bitmap(fireData2);
			
			disp = new DisplacementMapFilter();
			disp.mapBitmap = pMapData;
			disp.mapPoint = new Point(0, 0);
			disp.componentY = BitmapDataChannel.RED;
			disp.scaleY = 150;
			disp.mode = DisplacementMapFilterMode.CLAMP;
			
			addChild(fire2);
			addChild(fire);
			fire.y = 60;
			fire2.y = 60;
			fire.blendMode = BlendMode.ADD;
			
			addEventListener(Event.ENTER_FRAME, updatePerlin);
		}
		
		
		private function updatePerlin(e:Event):void
		{
			oPoint.y += 5;
			o2Point.x += 5;
			pMapData.perlinNoise(150, 150, 2, seed, true, false, channels, false, [oPoint, o2Point]);
			fire.filters = [disp];
			fire2.filters = [disp];
		}
	}
	
}