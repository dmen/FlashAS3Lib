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
		
		private static const EVENT_URL:String = "http://socialtab/";
		private var events:Array;
		
		
		public function ControllerWeb()
		{
			events = new Array();
		}
		
		
		/**
		 * gets the event list from the web server
		 */
		public function retrieveEvents():void
		{
			var request:URLRequest = new URLRequest(EVENT_URL);			
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, gotEvents, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, eventsError, false, 0, true);			
			lo.load(request);
		}
		
		
		private function gotEvents(e:Event):void
		{			
			var lo:URLLoader = URLLoader(e.target);
			var vars:URLVariables = new URLVariables(lo.data);
			//trace(vars.success);
			events = new Array("error-good");
			dispatchEvent(new Event(CONTROLLER_EVENTS));
		}
		
		
		private function eventsError(e:IOErrorEvent):void
		{
			events = new Array("error-bad");
			dispatchEvent(new Event(CONTROLLER_EVENTS));			
		}
		
		
		private function httpStatus(e:HTTPStatusEvent):void
		{
			
		}
		
		
		public function getEvents():Array
		{
			return events;
		}
		
	}
	
}