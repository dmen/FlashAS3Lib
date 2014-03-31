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
	
	
	public class Overview extends MovieClip
	{		
		private var xmlLoader:URLLoader;
		private var brand:String;
		private var imageLoader:Loader;
		private var facilityType:String;
		
		public function Overview()
		{			
			xmlLoader = new URLLoader();
			imageLoader = new Loader();
			
			//testing only
			//init("Marlboro","aof");
		}	

		
		public function init($brand:String, $facilityType:String):void
		{
			brand = $brand;
			facilityType = $facilityType;
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded); 
			xmlLoader.load(new URLRequest("overview.xml"));
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			
			var theXML = new XML(e.target.data);
			var theOverview:XMLList = theXML.overview.(@brand == brand);
		
			imageLoader.load(new URLRequest(theOverview.image));
			imageLoader.addEventListener(Event.COMPLETE, doSmooth, false, 0, true);
			addChild(imageLoader);
			
			theTitle.htmlText = theOverview.title;
			
			var overGroup:XMLList;	//all the overview groups for the selected brand
			if (facilityType == "aof") {
				overGroup = theOverview.overviewGroup;					
			}else {
				overGroup = theOverview.overviewGroup.(@type == "paof" || @type == "both")
			}	
			
			var output:String = "";
			for each (var og:XML in overGroup)  {
				
				output += "<font size='14'>" + og.@title + "</font>";
				
				var bulls:XMLList = og.bullet;
				
				if(bulls.length()){
					output += "<ul>";
					for each (var bull:XML in bulls)  {
						output += "<li>" + bull + "</li>";
					}
					output += "</ul>";
				}
				if(bulls.length() == 0){
					output += "<br/><br/>";
				}else {
					output += "<br/>";
				}
			}
			
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