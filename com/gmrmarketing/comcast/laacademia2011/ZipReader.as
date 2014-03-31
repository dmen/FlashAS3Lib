/**
 * Reads the zip code file zips.txt and places each zip into the zips array
 */

package com.gmrmarketing.comcast.laacademia2011
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class ZipReader
	{
		private var loader:URLLoader;
		private var zips:Array;
		
		
		public function ZipReader()
		{
			zips = new Array();
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, zipsLoaded, false, 0, true);
			loader.load(new URLRequest("zips.txt"));
		}
		
		
		private function zipsLoaded(e:Event):void
		{
			zips = e.target.data.split(",");			
		}
		
		
		/**
		 * Returns true if the passed in zip code is in the zips array
		 * @param	zip
		 * @return
		 */
		public function containsZip(zip:String):Boolean
		{		
			return zips.indexOf(zip) == -1 ? false : true;
		}
		
		public function zipLen():int
		{
			return zips.length;
		}
	}
	
}