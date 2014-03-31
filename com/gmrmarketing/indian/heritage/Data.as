/**
 * Loads the data.xml file and makes a sectionData object available
 */
package com.gmrmarketing.indian.heritage
{	
	import flash.events.EventDispatcher;
	import flash.errors.IOError;
	import flash.events.*;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class Data extends EventDispatcher
	{
		public static const ERROR:String = "Error";
		
		private var loader:URLLoader;
		private var xml:XML;
		private var sectionData:XMLList;
		
		
		public function Data()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, fileLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
		}
		
		public function load():void
		{
			loader.load(new URLRequest("data.xml"));
		}
		
		
		private function fileLoaded(e:Event):void
		{
			xml = new XML(e.target.data);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function fileNotFound(e:IOErrorEvent):void
		{
			dispatchEvent(new Event(ERROR));
		}
		
		
		public function setSection(section:String = "racing"):void
		{			
			sectionData = xml.sections.section.(@id == section);			
		}
		
		
		public function getImageData(image:String):Object
		{
			var d:XMLList = sectionData.data.(@image == image);
			return { year:d.@year, text:d };
		}
		
		
		public function getBigImage(image:String):String
		{
			var d:XMLList = sectionData.data.(@image == image);
			return d.@big;
		}
		
	}
	
}