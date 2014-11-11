/**
 * Main Logger class
 * Singleton
 * Wraps an instance of an ILogger object
 */
package com.gmrmarketing.utilities
{
	
	public class Logger
	{		
		private static var instance:Logger;
		private var myLogger:ILogger; //type ILogger so loggers can be swapped
		private var loggerAvailable:Boolean = false; //true is setLogger has been called
		
		
		public function Logger(p_key:SingletonBlocker)
		{			
		}
		
		
		public static function getInstance():Logger 
		{
			if (instance == null) {
				instance = new Logger(new SingletonBlocker());
			}
			return instance;
		}
		
		
		/**
		 * Sets the logger being used
		 * 
		 * @param	aLogger Instance of an ILogger
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
		public function log(logMessage:String):Boolean
		{
			if(loggerAvailable){
				myLogger.log(logMessage);
				return true;
			}else {
				return false;
			}
		}	
		
		
		/**
		 * Returns the log messages
		 * @return Array
		 */
		public function getLog():Array
		{
			if(loggerAvailable){
				return myLogger.getLog();
			}else {
				return [];				
			}
		}
		
		
		/**
		 * Erases the log
		 */
		public function clearLog():Boolean
		{
			if(loggerAvailable){
				myLogger.clearLog();
				return true;
			}else {
				return false;
			}
		}
		
	}	
}

internal class SingletonBlocker {}
