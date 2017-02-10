package com.gmrmarketing.stryker.mako2016
{
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	
	public class ScreenText 
	{
		private var loader:URLLoader;
		private var theJSON:Object;
		
		
		public function ScreenText()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("screenText.json"));
		}
		
		
		private function parseJSON(e:Event):void
		{
			theJSON = JSON.parse(loader.data);			
		}
		
		
		/**
		 * returns an object with profile,greeting and message properties
		 */
		public function getWelcome(profile:int):Object
		{
			return theJSON.welcome[profile - 1];
		}
	}
	
}