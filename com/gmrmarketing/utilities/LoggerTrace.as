/**
 * Trace Logger
 * writes log messages to the Flash console
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import Date;	

	public class LoggerTrace implements ILogger
	{
			
		public function LoggerTrace(){}		
	
		public function log(mess:String):void
		{
			trace("Trace Logger:", mess + "|" + new Date());
		}		
		
		public function getLog():Array
		{
			return new Array("Trace Logger");
		}
				
		public function clearLog():void
		{			
		}
	}	
}