package com.gmrmarketing.pm.matchgame
{	
	import fl.data.DataProvider;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import flash.filesystem.*; //AIR classes - must publish to AIR for this to compile
	
	
	
	
	public class IPadFile extends EventDispatcher
	{	
		//data contains an array of venue objects
		private var data:Object;
		

		public function IPadFile():void 
		{
			load();
		}		

		private function load():void 
		{ 
			data = new Object();
			
			var fs:FileStream = getFileStream(false); 
			if (fs) {
				try { 
					data = fs.readObject();					
					fs.close();
				} 
				catch (e:Error)
				{
					data.error = e.toString();
				}				
			}else {
				//file did not exist
				reset();
			}			
		}
		
		
		public function getData():Array
		{
			return data.venues;
		}
		
		
		
		public function addGame(venue:String, score:int):void
		{
			var theVenues:Array = getData();
			
			for (var i:int = 0; i < theVenues.length; i++) {
				if (theVenues[i].venue == venue) {					
					data.venues[i].games++;
					data.venues[i].total += score;
					data.venues[i].avg = data.venues[i].total / data.venues[i].games;
					save();
					break;
				}
			}
		}
		
		
		public function addVenue(venue:String):void
		{
			var today:Date = new Date();			
			var theDate:String = (today.month + 1) + "/" + (today.date) + "/" + today.fullYear;
			
			//array of venue objects
			var theVenues:Array = data.venues;
			
			var found:Boolean = false;
			for (var i:int = 0; i < theVenues.length; i++) {
				if (theVenues[i].venue == venue) {
					found = true;
					break;
				}
			}
			
			if (!found) {
				var ven:Object = new Object();
				ven.date = theDate;
				ven.venue = venue;				
				ven.games = 0;
				ven.total = 0;
				ven.avg = 0;
				
				data.venues.push(ven);
				
				save();
				
				dispatchEvent(new Event("venueAdded"));
			}else {
				dispatchEvent(new Event("venueExists"));
			}
			
		}
		
		
		public function reset():void
		{
			data = new Object();
			data.venues = new Array();
			save();
		}
		
		
		/**
		 * Get stream and write to it – asynchronously, to avoid hitching.
		 * 
		 * @param	data Object to write
		 */
		public function save():void 
		{			
			var fs:FileStream = getFileStream(true, false);
			fs.writeObject(data);
			fs.close();
			
			dispatchEvent(new Event("dataSaved"));
		}		
		
		
		private function getFileStream(write:Boolean, sync:Boolean = true):FileStream 
		{ 
			// The data file lives in the app storage directory, per iPhone guidelines. 
			var f:File = File.applicationStorageDirectory.resolvePath("reporting.dat");	
			
			// Try creating and opening the stream.
			var fs:FileStream = new FileStream(); 
			try {
				if (write && !sync) {
					// If we are writing asynchronously, openAsync. 
					fs.openAsync(f, FileMode.WRITE);
				} else {
					// For synchronous write, or all reads, open synchronously. 
					fs.open(f, write ? FileMode.WRITE : FileMode.READ);
				}
			}
			catch (e:Error) 
			{
				// On error, simply return null. 
				return null;
			}
			return fs;
		}
	}
	
}
