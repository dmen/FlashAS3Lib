package com.gmrmarketing.htc.movies
{
	import com.gmrmarketing.htc.movies.ConfigData;	
	import flash.display.*;
	

	public class Overlay
	{
		private var container:DisplayObjectContainer;
		private var overlay:Bitmap;
		
		public function Overlay()
		{
			if (ConfigData.LANGUAGE == "fr") {
				overlay = new Bitmap(new fr_overlay()); //lib clip				
			}else {
				//overlay = new Bitmap(new BitmapData(1, 1, true, 0x00000000));//nothing
				overlay = new Bitmap(new en_overlay()); //lib clip		
			}
		}
		
		
		public function setContainer($container:DisplayObjectContainer, left:int, bottom:int):void
		{
			container = $container;
			
			container.addChild(overlay);
			overlay.x = left;
			overlay.y = bottom - overlay.height;			
		}
		
	}
		
	
}