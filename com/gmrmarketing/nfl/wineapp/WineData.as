package com.gmrmarketing.nfl.wineapp
{
	
	import flash.net.*;
	import flash.events.*;
	
	
	public class WineData extends EventDispatcher
	{
		public static const READY:String = "JSONparsed";
		private var wineData:Object;//all the wine objects
		private var quesData;
		private var theReds:Array;
		private var theWhites:Array;
		
		
		public function WineData()
		{
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, loaded, false, 0, true);
			lo.load(new URLRequest("nflHouse.json"));
		}
		
		
		private function loaded(e:Event):void
		{
			var json:Object = JSON.parse(e.currentTarget.data);
			quesData = json.questionData;
			wineData = json.wineData;
			
			theReds = [];
			theWhites = [];
			
			for (var i:int = 0; i < wineData.length; i++) {
				var thisWine:Object = wineData[i];
				if (thisWine.category == "White") {
					theWhites.push(thisWine);
				}else {
					theReds.push(thisWine);
				}
			}
			
			dispatchEvent(new Event(READY));
		}
		
		
		public function get whites():Array
		{
			return theWhites;
		}
		
		
		public function get reds():Array
		{
			return theReds;
		}
		
		
		public function get questionData():Object
		{
			return quesData;
		}
		
		/**
		 * Gets full wine data objects from the JSON 
		 * 
		 * @param	selections Array of item objects from ConfigDialog
		 * 			each object has label and data properties - data is wine id
		 * @return  Array of objects - full data for each id passed in
		 */
		public function getWineDataFromSelections(selections:Array):Array
		{
			var wines:Array = [];
			
			for (var i:int = 0; i < selections.length; i++) {
				var wineID:int = selections[i].data;
				
				for (var j:int = 0; j < wineData.length; j++) {
					if (wineID == wineData[j].id) {
						wines.push(wineData[j]);
						break;
					}
				}
			}
			
			return wines;
		}
		
	}
	
}