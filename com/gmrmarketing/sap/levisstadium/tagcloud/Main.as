package com.gmrmarketing.sap.levisstadium.tagcloud
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import com.gmrmarketing.sap.levisstadium.tagcloud.RectFinder;	
	import flash.events.*;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		
		private var ra:RectFinder;
		private var bmp:Bitmap;
		
		public function Main()
		{
			//sample size, max font size, min font size, font colors
			ra = new RectFinder(5, 120, 6,[0xffffff, 0xd5cda8, 0xd2c598, 0xb81f19, 0xa91511, 0x83161b, 0xc4903c, 0xc26528]);
			ra.addEventListener(RectFinder.DICT_READY, dictLoaded);
		}
		
		
		private function dictLoaded(e:Event):void
		{
			dispatchEvent(new Event(READY));
		}
		
		
		public function setConfig(config:String):void
		{
			
		}
		
		
		public function show():void
		{
			var bmd:BitmapData = new BitmapData(1920,1080,false, 0x222222);
			bmp = new Bitmap(bmd);
			addChild(bmp);	
			ra.create(bmd, new helmet());
		}
		
		
		public function hide():void
		{
			if (contains(bmp)) {
				removeChild(bmp);
			}
		}
		
		
		public function doStop():void
		{
			ra.stop();
		}
	}
	
}