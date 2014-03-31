/**
 * AIR Logger
 * Uses Adobe AIR to write log data to file kiosklog.txt on the desktop
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import Date;
	import flash.filesystem.*;

	public class LoggerAIR implements ILogger
	{
			
		public function LoggerAIR(){}		
	
		/**
		 * Writes a line into kiosklog.txt
		 * Log file is located on the desktop
		 * @param	newLine
		 */
		public function log(message:String):void
		{			
			var targetFile:File = File.desktopDirectory.resolvePath("kiosklog.txt")
			var fs:FileStream = new FileStream();
			try {
				fs.open(targetFile, FileMode.APPEND);
				fs.writeMultiByte(message + "|" + new Date() + "\r\n", "utf-8");
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
			var targetFile:File = File.desktopDirectory.resolvePath("kiosklog.txt")
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
		 * Erases the log file
		 */
		public function clearLog():void
		{
			var targetFile:File = File.desktopDirectory.resolvePath("kiosklog.txt")
			var fs:FileStream = new FileStream();
			try {
				fs.open(targetFile, FileMode.WRITE);
				fs.writeMultiByte("", "utf-8");
				fs.close();
			}catch (e:Error) {
				trace(e);
			}
		}
	}	
}