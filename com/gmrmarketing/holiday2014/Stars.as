package com.gmrmarketing.holiday2014
{
	import flash.display.*;
	import flash.geom.Point;
	
	
	public class Stars
	{
		private var stars:Array; //array of star bitmaps
		private var myContainer:DisplayObjectContainer;
		
		
		public function Stars()
		{
			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function build(numStars:int, center:Point, maxRadius:int = 2000):void
		{
			for (var i:int = 0; i < numStars; i++) {
				var s:BitmapData = new BitmapData(2, 2);
			}
		}
	}
	
}