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
	
	
	public class Benefits extends MovieClip
	{		
		private var xmlLoader:URLLoader;	
		private var imageLoader:Loader;
		private var brand:String;
		
		public function Benefits()
		{			
			xmlLoader = new URLLoader();		
			imageLoader = new Loader();			
		}
		

		public function init($brand:String, $facilityType:String):void
		{
			brand = $brand;			
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded); 
			xmlLoader.load(new URLRequest("benefits.xml"));
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, xmlLoaded);			
			
			var theXML = new XML(e.target.data);
			var theBenefit:XMLList = theXML.benefit.(@brand == brand);
			
			var theGroups:XMLList = theBenefit.benefitGroup;
			
			imageLoader.load(new URLRequest(theBenefit.image));
			imageLoader.addEventListener(Event.COMPLETE, doSmooth, false, 0, true);
			addChild(imageLoader);
			
			theTitle.htmlText = theBenefit.title;
			
			var output:String = "";
		
			for each (var group:XML in theGroups)  {
				var thisGroup = group.@id;
				output += "<b>" + thisGroup + "</b><br/>";
				var groupBens = group.bene;
				
				output += "<ul>";
				for each (var ben:XML in groupBens)  {
					output += "<li>" + ben + "</li>";	
				}
				output += "</ul><br/>";
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