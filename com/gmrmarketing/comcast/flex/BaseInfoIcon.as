package com.gmrmarketing.comcast.flex
{
	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	

	public class BaseInfoIcon extends MovieClip
	{
		private var shadow:DropShadowFilter;
		private var col:ColorTransform;
		private var col2:ColorTransform;
		private var myIcon:MovieClip;
		
		public function BaseInfoIcon(ic:MovieClip)
		{			
			myIcon = ic;
			shadow = new DropShadowFilter(3, 45, 0x000000, 1, 0, 0, 1, 2, false);
			col = new ColorTransform();
			col2 = new ColorTransform();
		}
		
		
		public function highlight():void
		{
			col.color = 0xFAF49E; //light yellow
			col2.color = 0x000000;
			
			myIcon.theShape.filters = [];
			myIcon.theShape.theShape.transform.colorTransform = col2;
			myIcon.bg.transform.colorTransform = col;			
		}
		
		
		public function normal():void
		{
			col.color = 0x1D3566; //blue
			col2.color = 0xFFFFFF;			
			myIcon.theShape.theShape.transform.colorTransform = col2;
			myIcon.theShape.filters = [shadow];
			myIcon.bg.transform.colorTransform = col;
		}
	}
	
}