
package com.gmrmarketing.reeses.scratchgame
{
	//AIR classes
	import flash.filesystem.*;	
	import flash.utils.ByteArray;
	
	public class AdminFile
	{	
		private var data:Object;

		
		public function AdminFile():void 
		{
			data = new Object();
			readData();
		}		
		
		
		public function getData():Object
		{			
			readData();
			return data;
		}
		
		
		public function scratchStarted():void
		{
			
			readData();
			data.scratch[0] += 1;
			save();			
		}
		
		
		public function scratchWon():void
		{	
			readData();
			data.scratch[1] += 1;
			save();
		}
		
		
		public function scratchLost():void
		{
			readData();
			data.scratch[2] += 1;
			save();
		}
		
		
		public function addPrize(prize:String):void
		{
			readData();
			if (!data.prizeCounts) {
				data.prizeCounts = new Object();
			}
			if (data.prizeCounts[prize] != undefined) {
				data.prizeCounts[prize] += 1;
			}else {
				data.prizeCounts[prize] = 1;
			}
			save();
		}		
		
		
		public function initData():void
		{			
			data.scratch = new Array(0, 0, 0); //started, won, lost			
			data.prizes = new Array("", "", "");
			data.prizeCounts = new Object();
			data.descriptions = new Array("", "", "");
			data.winPercent = 50;
			save();
		}
		
		
		public function resetScratchData():void
		{
			readData();
			data.scratch = new Array(0, 0, 0); //started, won, lost
			save();
		}
		
		
		public function save(newData:Object = null):void 
		{	
			if (newData != null) {
				data = newData;
			}
			
			var fs:FileStream = getFileStream(true, false);
			fs.writeObject(data);
			fs.close();
		}		
		
		
		private function readData():void
		{
			var fs:FileStream = getFileStream(false); 
			if (fs) {
				try { 					
					data = fs.readObject();					
					fs.close();
				} 
				catch (e:Error)
				{					
					initData();
					data.error = e.toString();
				}
			}else {
				//file did not exist				
				initData();
			}
		}
		
		
		private function getFileStream(write:Boolean, sync:Boolean = true):FileStream 
		{ 
			// The data file lives in the app storage directory, per iPhone guidelines. 
			var f:File = File.applicationStorageDirectory.resolvePath("reesesData.dat");	
			
			f.canonicalize();			
			
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
