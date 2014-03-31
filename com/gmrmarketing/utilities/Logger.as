package com.gmrmarketing.utilities
{
	
	public class Logger
	{		
		private var myLogger:ILogger; //type ILogger interface, so loggers can be swapped
		private var loggerAvailable:Boolean = false;
		
		
		public function Logger(){}
		
		
		/**
		 * Sets the logger being used
		 * 
		 * @param	aLogger Instance of ILogger
		 */
		public function setLogger(aLogger:ILogger):void
		{
			myLogger = aLogger;
			loggerAvailable = true;
		}
		
		
		/**
		 * Calls log within the set logger
		 * @param	logMessage String message to log
		 */
		public function log(logMessage:String):void
		{
			if(loggerAvailable){
				myLogger.log(logMessage);
			}
		}	
		
		
		/**
		 * Returns the log messages
		 * @return Array
		 */
		public function getLog():Array
		{
			return myLogger.getLog();
		}
		
		
		/**
		 * Erases the log
		 */
		public function clearLog():void
		{
			myLogger.clearLog();
		}
		
	}	
}
