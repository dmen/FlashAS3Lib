/**
 * Connection Monitor
 * Pings google.com every five minutes in order to monitor
 * connection status.
 */
package com.gmrmarketing.utilities
{
	import flash.net.*;
	import flash.events.*;
	import flash.utils.Timer;

	public class ConnectionMonitor
	{
		private var request:URLRequest;
		private var loader:URLLoader;
		private var interval:Timer;
		private var isConnected:Boolean;
		
		
		public function ConnectionMonitor()
		{
			request = new URLRequest("http://google.com");
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, pingComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onFail);
			
			interval = new Timer(300000);
			interval.addEventListener(TimerEvent.TIMER, doPing);
			interval.start();
			
			doPing();
		}
		
		
		public function get connected():Boolean
		{
			return isConnected;
		}
		
		
		private function doPing(e:TimerEvent = null):void
		{
			loader.load(request);
		}
		
		
		private function pingComplete(e:Event):void
		{			
			isConnected = true;
		}

		
		private function onFail(e:IOErrorEvent):void
		{			
			isConnected = false;
		}
		
	}
	
}