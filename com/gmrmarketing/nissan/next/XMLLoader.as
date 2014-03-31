package com.gmrmarketing.nissan.next
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class XMLLoader extends EventDispatcher
	{
		public static const XML_LOADED:String = "xmlLoaded";
		private var fleetXML:XML;
		
		
		public function XMLLoader() { }
		
		
		public function getFleetXML():XML
		{
			return fleetXML;
		}
		
		public function getRFIDServiceURL():String
		{	
			return fleetXML.rfidServiceURL;			
		}
		
		public function getApprovedPostsURL():String
		{
			return fleetXML.approvedPostsURL;
		}
		
		public function getPostMessageURL():String
		{
			return fleetXML.postMessageURL;
		}
		
		
		public function loadXML():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			try{
				loader.load(new URLRequest("nissanFleet.xml"));
			}catch (e:Error) {
				
			}	
		}		
		
		
		private function xmlLoaded(e:Event):void
		{
			fleetXML = new XML(e.target.data);
			dispatchEvent(new Event(XML_LOADED));
		}
		
	}
	
}