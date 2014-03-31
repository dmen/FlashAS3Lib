/**
 * Loads the images xml file defined in ConfigData
 * Dispatches IMAGES_LOADED when complete
 * 
 * Maintains a list of 'current' images - that is only new
 * images are added when refresh() is called
 * 
 * call getImages() to retrieve the current images array
 * 
 * Instantiated by Main.as
 */

package com.gmrmarketing.htc.movies
{
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.htc.movies.ConfigData;
	
	
	public class Images extends EventDispatcher 
	{
		public static const IMAGES_LOADED:String = "imagesXMLLoaded";
		
		private var xml:XML;
		private var loader:URLLoader;
		private var images:Array; //all current images
		private var im1:Array;
		private var im2:Array;
		
		
		public function Images()
		{
			images = new Array();			
			loader = new URLLoader();			
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
		}
		
		
		public function refresh():void
		{			
			try{
				loader.load(new URLRequest(ConfigData.IMAGE_PATH + ConfigData.IMAGE_XML));
			}catch (e:Error) {
				
			}
		}
		
		/**
		 * Gets the first half of the randomized images array
		 * @return
		 */
		public function getImages1():Array
		{
			return im1;
		}
		
		
		/**
		 * Gets the second half of the randomized images array
		 * @return
		 */
		public function getImages2():Array
		{
			return im2;
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			xml = new XML(e.target.data);
			var xm:XMLList = xml.images.image;
			
			//push any images not in the list
			for (var i:int = 0; i < xm.length(); i++) {
				var thisIm:String = xm[i];
				if (images.indexOf(thisIm) == -1) {
					images.push(thisIm);
				}
			}
			
			//randomized the array and then split it into two
			images = randomizeArray(images);
			
			im1 = images.splice(0, Math.floor(images.length * .5));
			im2 = images.concat();
			
			dispatchEvent(new Event(IMAGES_LOADED));
		}
		
		
		private function randomizeArray(array:Array):Array
		{
			var newArray:Array = new Array();
			while(array.length > 0){
				newArray.push(array.splice(Math.floor(Math.random() * array.length), 1)[0]);
			}
			return newArray;
		}
	}	
}