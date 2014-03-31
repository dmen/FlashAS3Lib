package com.gmrmarketing.husqvarna
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class Mowers
	{
		private var mower:MovieClip;		
		private var mowerX:int;
		private var mowerY:int;
		
		public function Mowers() { }
		
		public function getMower(theView:String):MovieClip
		{			
			switch(theView) {
				case "front":
					mower = new mowerFront();
					mowerX = 446;
					mowerY = 353;
					break;
				case "side":
					mower = new mowerSide();
					mowerX = 170;
					mowerY = 70;
					break;
				case "top":
					mower = new mowerTop();
					mowerX = 170;
					mowerY = 115;
					break;
			}
			return mower;
		}
		
		public function getMowerX():int
		{
			return mowerX;
		}
		
		public function getMowerY():int
		{
			return mowerY;
		}
	}
	
}