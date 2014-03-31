package com.gmrmarketing.humana.rockandroll
{
	import flash.net.*;
	import flash.events.*;
	
	public class JSONReader extends EventDispatcher
	{
		public static const DATA_READY:String = "dataReady";
		private var data:Object;
		
		
		public function JSONReader(){}
		
		public function getRunners():void
		{
			var urlRequest:URLRequest  = new URLRequest("http://humanarocknroll.thesocialtab.net/Milestones/GetLatestRunners");

			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);

			try{
				urlLoader.load(urlRequest);
			} catch (e:Error) {
				trace("JSON - Cannot load : " + e.message);
			}
		}

		
		private function completeHandler(e:Event):void 
		{
			var loader:URLLoader = URLLoader(e.target);			
			data = JSON.parse(loader.data);			
			dispatchEvent(new Event(DATA_READY));
		}
		
		
		/**
		 * Returns the parsed JSON object containing the latest runner data
		 * @return
		 */
		public function getData():Object
		{
			return data;
		}
		
	}
	
}