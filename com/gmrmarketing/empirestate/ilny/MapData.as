/**
 * Loads the mapdata.json file and parses it into the allData array
 * Dispatches READY once the data has been parsed
 * Used by Map.as
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.net.*;
	import flash.events.*;	

	public class MapData extends EventDispatcher
	{
		public static const READY:String = "JSONLoaded";
		private var allData:Object; //loaded JSON
		
		//coords maps latitude / longitude intersections to screen coords - each row is a latitude
		private var coords:Array;
		
		
		public function MapData()
		{			
			coords = [];
			//45 lat - lon 80 to 72
			coords.push([[0,0], [0,0], [0,0], [0,0], [335, 0], [418, 0], [511, 0], [601, 0], [685,0]]);
			//44 lat - lon 80 to 72
			coords.push([[0,0],[0,0],[0,0],[244, 119], [335, 119], [418, 119], [511, 119], [601, 119], [685,119]]);
			//43 lat - lon 80 to 72
			coords.push([[ -11, 235], [75, 235], [160, 235], [244, 235], [335, 235], [418, 235], [511, 235], [601, 235], [685,235]]);
			//42 lat - lon 80 to 72
			coords.push([[ -11, 352], [75, 352], [160, 352], [244, 352], [335, 352], [418, 352], [511, 352], [601, 352], [685,352]]);
			//41 lat - lon 80 to 72
			coords.push([[0,0],[0,0],[0,0],[0,0],[335, 474], [418, 474], [511, 474], [601, 474], [685,474]]);
			//40 lat - lon 80 to 72
			coords.push([[0,0],[0,0],[0,0],[0,0],[0,0],[418, 595], [511, 595], [601, 595], [685,595]]);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, loaded, false, 0, true);
			lo.load(new URLRequest("mapdata.json"));
		}
		
		
		private function loaded(e:Event):void
		{
			allData = JSON.parse(e.currentTarget.data);			
			for (var i:int = 0; i < allData.length; i++) {
				getClosest(allData[i]);//adds x,y keys to each object bvased on lat/lon				
			}
			dispatchEvent(new Event(READY));
		}
		
		
		/**
		 * @param	categories Array of Strings one of: "Must See", "Historical Sites", "Family Fun", "Wineries", "Breweries", "Art & Culture", "Parks and Beaches"
		 * @return Array of objects
		 */
		public function getInterests(categories:Array):Array
		{
			var ret:Array = [];
			var indexes:Array = [];//used to avoid adding duplicates
			
			for (var j:int = 0; j < categories.length; j++){
				for (var i:int = 0; i < allData.length; i++) {
					if ((allData[i].cat1 == categories[j] || allData[i].cat2 == categories[j] || allData[i].cat3 == categories[j]) && indexes.indexOf(i) == -1) {						
						ret.push(allData[i]);
						indexes.push(i);						
					}
				}
			}
			
			return ret;
		}		
		
		
		
		public function getClosest(o:Object):void
		{
			var latIndex:int = Math.round(45 - o.latitude);//index in coords array
			var latClosest:int = 45 - latIndex;//actual lat of closest intersection
			var latDiff:Number = o.latitude - latClosest;//if negative, actual lat is south of latClosest
			
			var lonIndex:int = Math.round(80 - Math.abs(o.longitude));//index in coords array
			var lonClosest:int = 80 - lonIndex;//actual lon of closest intersection
			var lonDiff:Number = Math.abs(o.longitude) - lonClosest; //if positive, actual is west of lonClosest
			
			var closestScreen:Array;			
			
			try {
				closestScreen = coords[latIndex][lonIndex]; //actual x,y on screen of closest lat/lon intersection
			}catch (e:Error) {
				//
			}			
			
			if(closestScreen){
				//lon is x, lat is y
				var xRatio:Number = 87; //about 87 pixels per 1º of longitude
				var xMod:Number = lonDiff * xRatio;
				
				var yRatio:Number = 117; //about 117 pix per 1º of latitude
				var yMod:Number = latDiff * yRatio;				
				
				o.x = closestScreen[0] - xMod;
				o.y = closestScreen[1] - yMod;
			}else {
				o.x = 0;
				o.y = 0;
			}			
		}
		
	}
	
}