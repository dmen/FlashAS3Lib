package com.gmrmarketing.comcast.mlb
{	
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	
	
	public class Meter extends MovieClip
	{
		//arrow rotation for each level - beginning at level 0, starting position
		private var arrowRotations:Array = new Array( -90, -67.5, -22.5, 22.5, 67.5);
		private var ds:DropShadowFilter;
		
		public function Meter()
		{
			x = 735;
			y = 723;
			
			ds = new DropShadowFilter(6, 270, 0x000000, 1, 23, 23, 1, 2);
			filters = [ds];
		}
		
		
		public function setMeterLevel(currentLevel:int):void
		{
			TweenLite.to(arrow, 3, { rotation:arrowRotations[currentLevel], ease:Bounce.easeOut});
		}
	}	
}