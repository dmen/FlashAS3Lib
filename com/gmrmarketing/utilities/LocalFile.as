/**
 * AIR
 * Used to allow local file saving on the iPad/iPhone
 * 
 * Saves and retrieves an Object
 */

package com.gmrmarketing.utilities
{
	//AIR classes
	import flash.filesystem.*;
	
	
	public class LocalFile
	{
		private static var instance:LocalFile;
		
		public static function getInstance():LocalFile
		{
         if (instance == null) {
            instance = new LocalFile(new SingletonBlocker());
          }
         return instance;
       }

	   
	   
		public function LocalFile(p_key:SingletonBlocker):void {         
         if (p_key == null) {
            throw new Error("Error: Instantiation failed: Use LocalFile.getInstance()");
          }
       }

		
		
		/**
		 * Returns the loaded object
		 * @return
		 */
		public function load():Object 
		{
			var data:Object = new Object();
			
			var fs:FileStream = getFileStream(false);
			if (fs) {
				try {
					data = fs.readObject();
					data.error = "ok";
					fs.close();
				}
				catch (e:Error)
				{
					data.error = e.toString();
				}
			}
			return data;
		}
		
		public function loadAll():Array
		{
			var a:Array = new Array();
			var data:Object = new Object();
			
			var fs:FileStream = getFileStream(false);
			if (fs) {
				while(1){
					data = fs.readObject();				
					a.push(data);
				}
				fs.close();
			}
			return a;
		}
		
		
		
		/**
		 * Get stream and write to it – asynchronously, to avoid hitching.
		 * 
		 * @param	data Object to write
		 */
		public function save(data:Object):void 
		{			
			var fs:FileStream = getFileStream(true, false); 
			fs.writeObject(data); 
			fs.close();			
		}
		
		
		
		private function getFileStream(write:Boolean, sync:Boolean = true):FileStream 
		{ 
			// The data file lives in the app storage directory, per iPhone guidelines. 
			var f:File = File.applicationStorageDirectory.resolvePath("myApp.dat");	
			
			// Try creating and opening the stream. 
			var fs:FileStream = new FileStream(); 
			try {				
				if (write && !sync) {
					// If we are writing asynchronously, openAsync. 
					fs.openAsync(f, FileMode.UPDATE);
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


internal class SingletonBlocker {}