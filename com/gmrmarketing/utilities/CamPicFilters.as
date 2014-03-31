/**
 * Static support class for CamPic.as
 * Contains filters to be used in CamPic.addFilter()
 */
package com.gmrmarketing.utilities
{
	import flash.filters.ColorMatrixFilter;	
	import flash.filters.BlurFilter;
	
	public class CamPicFilters
	{
		public function CamPicFilters() { }
		
		
		/**
		 * Returns a BlurFilter instance
		 * @param	blur Amount of blur in x and y
		 * @param	qual Blout quality - medium (2) is default
		 * @return  BlurFilter
		 */
		public static function blur(blur:int = 3, qual:int = 2):BlurFilter
		{
			return new BlurFilter(blur, blur, qual);
		}
		
		
		/**
		 * Returns a gray scale color matrix filter
		 */
		public static function gray():ColorMatrixFilter
		{
			var rc:Number = 1 / 3;
			var gc:Number = 1 / 2;
			var bc:Number = 1 / 6;
			
			var m:Array = new Array();
			m = m.concat([rc, gc, bc, 0, 0]);	// red
			m = m.concat([rc, gc, bc, 0, 0]);	// green
			m = m.concat([rc, gc, bc, 0, 0]);	// blue
			m = m.concat([0, 0, 0, 1, 0]);		// alpha
			
			return new ColorMatrixFilter(m);
		}
		
		
		/**
		 * sets contrast value available are -100 ~ 100 @default is 0
		 * @param 		value:int	contrast value
		 * @return		ColorMatrixFilter
		 */
		public static function contrast(value:Number):ColorMatrixFilter
		{
			value /= 100;
			var s: Number = value + 1;
    		var o : Number = 128 * (1 - s);

			var m:Array = new Array();
			m = m.concat([s, 0, 0, 0, o]);	// red
			m = m.concat([0, s, 0, 0, o]);	// green
			m = m.concat([0, 0, s, 0, o]);	// blue
			m = m.concat([0, 0, 0, 1, 0]);	// alpha

			return new ColorMatrixFilter(m);
		}

		
		/**
		 * sets saturation value available are -100 ~ 100 @default is 0
		 * @param 		value:int	saturation value
		 * @return		ColorMatrixFilter
		 */
		public static function saturation(value:Number):ColorMatrixFilter
		{
			const lumaR:Number = 0.212671;
    		const lumaG:Number = 0.71516;
    		const lumaB:Number = 0.072169;

			var v:Number = (value / 100) + 1;
			var i:Number = (1 - v);
   		 	var r:Number = (i * lumaR);
    		var g:Number = (i * lumaG);
    		var b:Number = (i * lumaB);

			var m:Array = new Array();
			m = m.concat([(r + v), g, b, 0, 0]);	// red
			m = m.concat([r, (g + v), b, 0, 0]);	// green
			m = m.concat([r, g, (b + v), 0, 0]);	// blue
			m = m.concat([0, 0, 0, 1, 0]);			// alpha

 			return new ColorMatrixFilter(m);
		}
		
		
		/**
		 * sets brightness value available are -100 ~ 100 @default is 0
		 * @param 		value:int	brightness value
		 * @return		ColorMatrixFilter
		 */
		public static function brightness(value:Number):ColorMatrixFilter
		{
			value = value * (255/250);

			var m:Array = new Array();
    		m = m.concat([1, 0, 0, 0, value]);	// red
   		 	m = m.concat([0, 1, 0, 0, value]);	// green
   		 	m = m.concat([0, 0, 1, 0, value]);	// blue
    		m = m.concat([0, 0, 0, 1, 0]);		// alpha

    		return new ColorMatrixFilter(m);
		}
	}
	
}