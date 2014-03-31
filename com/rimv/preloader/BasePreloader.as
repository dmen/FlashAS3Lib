package com.rimv.preloader
{
	import flash.display.MovieClip;
	
	/**
	 * 
	 * @author RimV
	 * Base class for preloader
	 */
	
	public class BasePreloader extends MovieClip
	{
		protected var preloaderValue:Number;
		
		// Empty Constructor
		public function BasePreloader()
		{
		}
		
		// Set / Get value
		public function set value(nu:Number):void
		{
			this.preloaderValue = nu;
		}
		
		public function get value():Number
		{
			return preloaderValue;
		}
		
		
		
	}
	
}