package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.display.Bitmap;
	
	
	public class Requirements extends MovieClip
	{		
		private var xmlLoader:URLLoader;
		private var imageLoader:Loader;
		private var brand:String;
		
		public function Requirements()
		{			
			xmlLoader = new URLLoader();
			imageLoader = new Loader();			
		}
		
		
		public function init($brand:String, $facilityType:String):void
		{
			brand = $brand;			
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded);
			xmlLoader.load(new URLRequest("requirements.xml"));
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);		
			
			var theXML:XML = new XML(e.target.data);
			var theRequirements:XMLList = theXML.requirement;
			
			imageLoader.load(new URLRequest(theXML.brandImages.image.(@brand == brand)));
			imageLoader.addEventListener(Event.COMPLETE, doSmooth, false, 0, true);
			addChild(imageLoader);
			
			var output:String = "";
			output += "<ul>";
			for each (var req:XML in theRequirements)  {
			 output += "<li>" + req + "</li>";
			}
			output += "</ul>";
			theText.htmlText = output;
		}
		
		private function doSmooth(e:Event):void
		{
			imageLoader.removeEventListener(Event.COMPLETE, doSmooth);
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
		}
		
	}
	
}