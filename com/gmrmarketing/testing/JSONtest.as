package com.gmrmarketing.testing
{
	import flash.net.*;
	import flash.events.*;
	
	public class JSONtest
	{
		
		public function JSONtest()
		{
			
		}
		
		public function getRunners():void
		{
			var urlRequest:URLRequest  = new URLRequest("http://humanarocknroll.thesocialtab.net/Milestones/GetLatestRunners");

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, completeHandler);

			try{
				urlLoader.load(urlRequest);
			} catch (error:Error) {
				trace("Cannot load : " + error.message);
			}
		}

		private function completeHandler(e:Event):void 
		{
			var loader:URLLoader = URLLoader(e.target);
			
			var data:Object = JSON.parse(loader.data);
			trace(data.length);
			trace(data[0].FirstName);
			//All fields from JSON are accessible by theit property names here/
		}
		
	}
	
}