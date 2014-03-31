
package com.gmrmarketing.comcast.scratchnew
{
	//AIR classes
	import flash.filesystem.*;
	
	
	public class Reporting
	{	
		private var data:Object;

		public function Reporting():void 
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
		
		public function getData():Object
		{
			return data;
		}
		
		public function scratchStarted():void
		{			
			data.scratch[0] += 1;
			save();			
		}
		
		public function scratchWon():void
		{
			data.scratch[1] += 1;
			save();
		}
		
		public function scratchLost():void
		{
			data.scratch[2] += 1;
			save();
		}
		
		public function addPrize(prize:String):void
		{
			if (data.prizes[prize] != undefined) {
				data.prizes[prize] += 1;
			}else {
				data.prizes[prize] = 1;
			}
			save();
		}		
		
		public function reset():void
		{
			data.scratch = new Array(0, 0, 0); //started, won, lost			
			data.prizes = new Object();			
			save();
		}		
		
		/**
		 * Get stream and write to it – asynchronously, to avoid hitching.		 
		 */
		public function save():void 
		{			
			var fs:FileStream = getFileStream(true, false);
			fs.writeObject(data);
			fs.close();
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
