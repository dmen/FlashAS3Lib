package com.rimv.aMediaGallery 
{
	
	// full image / item preloader for aMediaGallery
	import flash.display.MovieClip;
	import com.rimv.preloader.*;
	
	public class imgPreloader extends preloader1
	{
		public function imgPreloader() 
		{
		}
		
		override public function set value(value:Number):void
	    {
		   var target:Number = Math.round(value / 100 * 360);
		   for (var i:Number = max; i < target; i++) parts[i].visible = true;
		   max = target;
		}
		
	}
	
}