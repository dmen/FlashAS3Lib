package com.gmrmarketing.humana.rockandroll
{
	import flash.net.*;
	import flash.events.*;
	
	public class JSONReader extends EventDispatcher
	{
		public static const DATA_READY:String = "dataReady";
		private var data:Object;
		
		private const DEBUG:Boolean = false;
		
		
		public function JSONReader(){}
		
		//called from Main.getRunners()
		public function getRunners():void
		{
			if(!DEBUG){
				var urlRequest:URLRequest  = new URLRequest("http://humanarocknroll.thesocialtab.net/Milestones/GetLatestRunners");

				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);

				try{
					urlLoader.load(urlRequest);
				} catch (e:Error) {
					trace("JSON - Cannot load : " + e.message);
				}
			}else {
				//DEBUG
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(Event.COMPLETE, completeHandler, false, 0, true);
				lo.load(new URLRequest("raceData.json"));
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