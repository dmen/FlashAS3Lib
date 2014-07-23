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
			ra = new RectFinder(2, 60, 4,[0xffffff, 0xd5cda8, 0xd2c598, 0xb81f19, 0xa91511, 0x83161b, 0xc4903c, 0xc26528]);
			ra.addEventListener(RectFinder.DICT_READY, dictLoaded);
		}
		
		
		private function dictLoaded(e:Event):void
		{
			show();//TESTING
			dispatchEvent(new Event(READY));
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function setConfig(config:String):void
		{
			
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{
			var bmd:BitmapData = new BitmapData(768, 512, false, 0x000000);
			bmp = new Bitmap(bmd);
			addChild(bmp);	
			ra.create(bmd, new helmet());
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			if (contains(bmp)) {
				removeChild(bmp);
			}
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			ra.stop();
		}
	}
	
}