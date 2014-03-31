package com.gmrmarketing.nissan.rodale.athfleet
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XMLLoader extends EventDispatcher
	{
		public static const XML_LOADED:String = "xmlFilesLoaded";
		
		private var sliderXML:XML;
		private var fleetXML:XML;
		
		
		public function XMLLoader() { }
		
		
		public function getSliderXML():XML
		{
			return sliderXML;
		}
		
		
		public function getFleetXML():XML
		{
			return fleetXML;
		}
		
		
		public function loadXML():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, slidersXMLLoaded, false, 0, true);
			try{
				loader.load(new URLRequest("sliders.xml"));
			}catch (e:Error) {
				
			}	
		}
		
		
		private function slidersXMLLoaded(e:Event):void
		{	
			sliderXML = new XML(e.target.data);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, fleetXMLLoaded, false, 0, true);
			try{
				loader.load(new URLRequest("nissanFleet.xml"));
			}catch (e:Error) {
				
			}
		}
		
		
		private function fleetXMLLoaded(e:Event):void
		{
			fleetXML = new XML(e.target.data);
			dispatchEvent(new Event(XML_LOADED));
		}
		
	}
	
}