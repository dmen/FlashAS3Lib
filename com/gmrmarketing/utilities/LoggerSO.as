/**
 * Shared Object Logger
 * writes log messages to a local SO
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import Date;
	import flash.net.SharedObject;
	

	public class LoggerSO implements ILogger
	{
		private var theSO:SharedObject;		
		private var myData:Array;
		
		/**
		 * CONSTRUCTOR
		 * @param	loggerName Name of the local shared object to use for logging
		 */
		public function LoggerSO(loggerName:String)
		{
			theSO = SharedObject.getLocal(loggerName);
			myData = so.data.logData;
			if (myData == null) {
				myData = new Array();
			}
		}
		
		
		/**
		 * Writes a message into the log
		 * Writes message, and the date / time the message arrived
		 * @param	mess String message to write
		 */
		public function log(mess:String):void
		{
			myData.push(mess + " | " + new Date());
			theSO.data.logData = myData;			
			theSO.flush();
		}
		
		
		/**
		 * Returns the current log data
		 * @return myData Array
		 */
		public function getLog():Array
		{
			return myData;
		}
		
		
		/**
		 * Clears the shared object
		 */
		public function clearLog():void
		{
			myData = new Array();
			theSO.data.logData = myData;			
			theSO.flush();
		}
	}	
}