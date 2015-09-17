/**
 * AIR Logger
 * Writes to a log file on the desktop
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import com.gmrmarketing.utilities.Strings;
	import Date;
	import flash.filesystem.*;

	public class LoggerAIR implements ILogger
	{
		private const LOG_LENGTH:int = 2000; //limit log to 2000 entries
		private var fName:String;
		
		
		public function LoggerAIR($fName:String = "kiosklog.txt")
		{
			fName = $fName;			
		}
		
		
		public function truncate():void
		{
			var entries:Array = getLog();
			
			if (entries.length > LOG_LENGTH) {				
				clearLog();
				//remove oldest entries
				entries.splice(0, entries.length - LOG_LENGTH);
				
				while (entries.length > 0) {
					var a:String = entries.shift();
					if(a.length > 0){
						a = Strings.removeLineBreaks(a);
						log(a);
					}
				}
			}
		}
		
	
		/**
		 * Writes a line into the log
		 * newest entries on the bottom
		 * Log file is located on the desktop
		 * @param message String
		 */
		public function log(message:String):void
		{		
			var targetFile:File = File.desktopDirectory.resolvePath(fName)
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(targetFile, FileMode.APPEND);
				fs.writeMultiByte(message + "\r\n", "utf-8");
				fs.close();
			}catch (e:Error) {}
		}
		
		
		/**
		 * Returns an array of log entries, one line per item
		 * @return Array of Strings
		 */
		public function getLog():Array
		{
			var myArray = new Array();
			var targetFile:File = File.desktopDirectory.resolvePath(fName)
			var fs:FileStream = new FileStream();
			try {
				fs.open(targetFile, FileMode.READ);
				var str:String = fs.readMultiByte(targetFile.size, "utf-8");
				myArray = str.split("\r\n");
				fs.close();
			}catch (e:Error) { }
			
			return myArray;
		}
		
		
		/**
		 * Deletes the log file
		 */
		public function clearLog():void
		{
			var targetFile:File = File.desktopDirectory.resolvePath(fName);
			try{				
				targetFile.deleteFile();
			}catch(e:Error){}
		}		
		
	}
	
}