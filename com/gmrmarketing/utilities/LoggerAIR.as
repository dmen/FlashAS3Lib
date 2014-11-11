/**
 * AIR Logger
 * Writes to a log file on the desktop
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import Date;
	import flash.filesystem.*;

	public class LoggerAIR implements ILogger
	{
		private var fName:String;
			
		
		public function LoggerAIR($fName:String = "kiosklog.txt")
		{
			fName = $fName;
		}		
	
		/**
		 * Writes a line into the log
		 * Log file is located on the desktop
		 * @param	newLine
		 */
		public function log(message:String):void
		{			
			var targetFile:File = File.desktopDirectory.resolvePath(fName)
			var fs:FileStream = new FileStream();
			try {
				fs.open(targetFile, FileMode.APPEND);
				fs.writeMultiByte(new Date() + " | " + message + "\r\n", "utf-8");
				fs.close();
			}catch (e:Error) {
				trace(e);
			}
		}		
		
		/**
		 * Returns an array of log entries, one line per item
		 * @return
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
			}catch (e:Error) {
				trace(e);
			}
			return myArray;
		}
		
		
		/**
		 * Deletes the log file
		 */
		public function clearLog():void
		{
			var targetFile:File = File.desktopDirectory.resolvePath(fName)
			targetFile.deleteFile();
		}
	}	
}