package com.gmrmarketing.empirestate.ilny
{
	import flash.geom.Point;
	import flash.net.*;
	import flash.events.*;
	
	public class Zips
	{
		private var allData:Object; //loaded JSON
		//coords maps latitude / longitude intersections to screen coords - each row is a latitude
		private var coords:Array;
		
		
		public function Zips()
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
			lo.load(new URLRequest("nyzipcodes.json"));
		}
		
		
		private function loaded(e:Event):void
		{
			allData = JSON.parse(e.currentTarget.data);
		}
		
		
		public function getZip(zip:String):Point
		{
			if (allData) {
				for (var i:int = 0; i < allData.length; i++) {
					if (allData[i].zip_code == zip) {
						return getClosest(allData[i]);
					}
				}
				return new Point(0, 0);
			}else {
				return new Point(0, 0);
			}
		}
		
		/**
		 * calculates the x,y position of an interest based on its lat/lon
		 * injects x,y keys and values into the object
		 * @param	o The object - the object is modified in place
		 */
		private function getClosest(o:Object):Point
		{
			var p:Point = new Point();
			
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
				
				p.x = closestScreen[0] - xMod;
				p.y = closestScreen[1] - yMod;
			}else {
				p.x = 0;
				p.y = 0;
			}
			
			return p;
		}
	}
	
}