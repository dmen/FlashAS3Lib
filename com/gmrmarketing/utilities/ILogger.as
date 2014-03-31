/**
* Defines the methods required by all Logger classes
*/

package com.gmrmarketing.utilities
{	
	public interface ILogger
	{		
		function log(mess:String):void;
		function getLog():Array;
		function clearLog():void;
	}	
}