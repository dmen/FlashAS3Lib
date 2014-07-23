package com.indiemaps.mapping.utils
{
	public class AngleUtils
	{
		public function AngleUtils()
		{
			/*
			just a container for static methods
			*/
		}
		
		public static function deg2rad(deg:Number):Number {
			return deg * (Math.PI / 180);
		}
		
		public static function rad2deg(rad:Number):Number {
			return rad * (180 / Math.PI);
		}
	}
}