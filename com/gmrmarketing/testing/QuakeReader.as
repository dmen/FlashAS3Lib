package com.gmrmarketing.testing
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	

	public class QuakeReader extends EventDispatcher
	{
		public static const QUAKES_LOADED:String = "quakeListLoaded";
		
		private var csvLoader:URLLoader;
		private var dataSources:Array;
		private var quakeList:Array;
		private var today:Boolean;
		
		public function QuakeReader()
		{
			csvLoader = new URLLoader();
			quakeList = new Array();
			
			dataSources = new Array();
			dataSources.push("http://earthquake.usgs.gov/earthquakes/catalogs/eqs1hour-M0.txt"); //last hour m0+
			dataSources.push("http://earthquake.usgs.gov/earthquakes/catalogs/eqs1day-M0.txt"); //last day m0+
			dataSources.push("http://earthquake.usgs.gov/earthquakes/catalogs/eqs7day-M2.5.txt"); //past 7 days m2.5+			
		}
		
		
		/**
		 * Loads the quake list
		 * @param	source String One of: hour,day,today,week
		 */
		public function load(source:String):void
		{
			csvLoader.addEventListener(Event.COMPLETE, sourceLoaded, false, 0, true);
			var s:String = String(new Date().valueOf());//cache buster
			today = false;
			switch(source) {
				case "hour":
					csvLoader.load(new URLRequest(dataSources[0] + "?r=" + s));
					break;
				case "day":
					csvLoader.load(new URLRequest(dataSources[1] + "?r=" + s));
					break;
				case "today":
					today = true;
					csvLoader.load(new URLRequest(dataSources[1] + "?r=" + s));
					break;
				case "week":
					csvLoader.load(new URLRequest(dataSources[2] + "?r=" + s));
					break;
			}			
			
		}
		
		
		
		/**
		 * Parses the loaded CSV into the quakeList array of quake objects
		 * See traceQuake for the properties of each quake object
		 * 
		 * Dispatches QUAKES_LOADED
		 * 
		 * equator/prime meridian intersection: 729,356
		 * 3.1333333333 pixels per latitude degree
		 * 2.8472222222 pixels per longitude degree
		 * 
		 * @param	e
		 */
		private function sourceLoaded(e:Event):void
		{
			var todaysDate:int = new Date().date;			
			
			quakeList = new Array();
			
			var csv:String = csvLoader.data;
			
			//split the csv list by line breaks
			var csvList:Array = csv.split("\n");
			
			//first line is field list - remove it
			//Src,Eqid,Version,Datetime,Lat,Lon,Magnitude,Depth,NST,Region
			csvList.shift();
			
			for (var i:int = 0; i < csvList.length; i++) {
				var q:String = csvList[i];
				//split the item by "
				var qSplit:Array = q.split("\"");	
				if (qSplit.length > 2) {
					var quake:Object = new Object();
					
					//qSplit array
					//0 is src, eqid, version
					//1 is Datetime
					//2 is lat,lon,magnitude,depth,nst
					//3 is region
					
					//src,eqid,version
					var a:Array = qSplit[0].split(",");
					quake.src = a[0];
					quake.eqid = a[1];
					quake.version = a[2];
					
					//DateTime - like Wednesday, March 22, 2011 22:12:17 UTC
					var t:Array = qSplit[1].split(",");					
					quake.day = t[0]; //day of week in text - like Wednesday
					var m:Array = t[1].split(" ");
					
					//m[0] is the leading space...
					quake.month = m[1]; //like March
					
					//m[2] can be a space... if it's a single digit date 2 versus 22					
					if(m[2] == " " || m[2] == ""){
						quake.date = m[3]; //like 22
					}else {
						quake.date = m[2];
					}
					
					var ti:Array = t[2].split(" ");
					//ti[0] is leading space
					quake.year = ti[1];
					quake.time = ti[2]; //all in UTC no need to keep t[2]
					
					//UTC time format: 15:26:40
					var utcTime:Array = String(ti[2]).split(":");
					var d:Date = new Date();
					d.setUTCHours(utcTime[0], utcTime[1], utcTime[2]);
					quake.localTime = d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
					
					var b:Array = qSplit[2].split(",");					
					quake.latitude = b[1];
					quake.longitude = b[2];
					quake.magnitude = b[3];
					quake.depth = b[4];
					quake.nst = b[5]; //number of stations reporting
					
					quake.location = qSplit[3]; //region like Southern California
					
					if (today) {						
						if (todaysDate == parseInt(quake.date)) {
							quakeList.push(quake);
						}
					}else{
						quakeList.push(quake);
					}
				}				
			}			
			dispatchEvent(new Event(QUAKES_LOADED));
		}
		
		
		
		public function getQuakes():Array
		{
			return quakeList;
		}
		
		
		
		public function traceQuake(num:int):void
		{
			var q:Object = quakeList[num];
			trace("Source Network: ", q.src);
			trace("Eqid:" , q.eqid);
			trace("Version: ", q.version);
			trace("Day of week: ", q.day);
			trace("Month: ", q.month);
			trace("Date: ", q.date);
			trace("Year: ", q.year);
			trace("UTC Time: ", q.time);
			trace("Local Time: ", q.localTime);
			trace("Latitude: ", q.latitude);
			trace("Longitude: ", q.longitude);
			trace("Magnitude: ", q.magnitude);
			trace("Depth: ", q.depth);
			trace("Number of reporting stations: ", q.nst);
			trace("Location: ", q.location);
		}
		
	}
	
}