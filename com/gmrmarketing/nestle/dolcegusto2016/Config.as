package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	
	public class Config extends EventDispatcher
	{
		public static const COMPLETE:String = "configComplete";
		private var loader:URLLoader;
		private var config:Object;
		
		
		public function Config()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("config.json"));
		}
		
		
		private function parseJSON(e:Event):void
		{
			config = JSON.parse(loader.data);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * Returns the port number serproxy is listening on
		 * configured in serproxy.cfg - something like 5331
		 */
		public function get serproxyPort():int
		{
			return config.serproxyPort;
		}
		
		
		/**
		 * ID string from the back of the bridge like 2BBF52
		 */
		public function get bridgeID():String
		{
			return config.bridgeID;
		}
		
		
		/**
		 * Returns the bridge user string - bridge user is needed
		 * in order to make api calls
		 */
		public function get bridgeUser():String
		{
			return config.bridgeUser;
		}
				
		
		/**
		 * Returns an array of x,y color arrays
		 * Array length is the number of lights
		 * @param	mood String - beach,woods,mountains - these match the mood in the result key of the quiz json
		 * @return
		 */
		public function getColor(mood:String):Array
		{
			return config.colors[mood];
		}
		
	}
	
}