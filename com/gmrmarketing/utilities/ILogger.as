/**
* Defines the methods required by all Logger classes
*/

package com.gmrmarketing.utilities
{	
	public interface ILogger
	{		
		function log(mess:String):void;//adds an entry to the log
		function getLog():Array;//returns all entries in the log - if possible
		function clearLog():void;//deletes the log file / clears all entries
		function truncate():void;//truncates the log
	}	
}