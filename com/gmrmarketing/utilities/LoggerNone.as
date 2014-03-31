/**
 * No Logger
 * writes nothing
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;		

	public class LoggerNone implements ILogger
	{				
		public function LoggerNone(){}		
	
		public function log(mess:String):void
		{			
		}		
		
		public function getLog():Array
		{
			return new Array("No Logger");
		}
				
		public function clearLog():void
		{			
		}
	}	
}