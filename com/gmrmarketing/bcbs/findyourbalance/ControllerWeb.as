/**
 * Controller web services
 * Gets the event list from the web server
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.events.*;
	import flash.net.*;
	
	
	public class ControllerWeb extends EventDispatcher 
	{
		public static const CONTROLLER_EVENTS:String = "gotEvents";
		
		private static const EVENT_URL:String = "http://bluecrosshorizon.thesocialtab.net/home/getprograms";
		private var events:Object; //array of objects - objects have pid and descr properties
		private var eventStore:SharedObject;//local cached event list if get from service fails
		private var localEvents:Object;
		
		public function ControllerWeb()
		{
			events = new Object();
			eventStore = SharedObject.getLocal("events");
			localEvents = eventStore.data.events;
		}
		
		
		/**
		 * gets the JSON event list from the web server
		 */
		public function retrieveEvents():void
		{
			var request:URLRequest = new URLRequest(EVENT_URL);			
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			
			request.requestHeaders.push(hdr);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotEvents, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, eventsError, false, 0, true);			
			lo.load(request);
		}
		
		
		private function gotEvents(e:Event):void
		{			
			events = JSON.parse(e.currentTarget.data);
			
			eventStore.data.events = events;
			eventStore.flush();
			
			dispatchEvent(new Event(CONTROLLER_EVENTS));
		}
		
		
		private function eventsError(e:IOErrorEvent):void
		{
			if(eventStore.data.events == null){
				events = new Object();
			}else {
				events = eventStore.data.events;
			}
			dispatchEvent(new Event(CONTROLLER_EVENTS));			
		}		
		
		/**
		 * returns the JSON event list
		 * @return
		 */
		public function getEvents():Object
		{
			return events;
		}
		
	}
	
}