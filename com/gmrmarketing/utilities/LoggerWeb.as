/**
 * Server Logger
 * 
 * POSTS log messages to a server side script
 * 
 * Script should accept post to variable: message
 * 
 */

package com.gmrmarketing.utilities
{		
	import com.gmrmarketing.utilities.ILogger;
	import Date;
	import flash.events.*;
	import flash.net.*;	

	public class LoggerWeb implements ILogger
	{
		private const LOG_TYPE:String = "ServerLogger";
		private const DELIM:String = " | ";
		private var loader:URLLoader;
		private var request:URLRequest;
		private var variables:URLVariables;	
		
		/**
		 * CONSTRUCTOR
		 * 
		 * @param	postURL Full URL to the receiving script
		 * Script must accept post to variable: message
		 */
		public function LoggerWeb(postURL:String)
		{		
			loader = new URLLoader(); 
			loader.dataFormat = URLLoaderDataFormat.VARIABLES;
			
			request = new URLRequest(postURL);
			request.method = URLRequestMethod.POST;
            
			variables = new URLVariables();
			
			loader.addEventListener(Event.COMPLETE, handleComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError); 
		}
		
		
		/**
		 * Writes a message into the log
		 * Writes log type, the message, and the date / time the message arrived
		 * 
		 * @param	mess String message to write
		 */
		public function log(mess:String):void
		{			
			variables.message = LOG_TYPE + DELIM + mess + DELIM + new Date() + "\n";;
            request.data = variables;
            loader.load(request);
		}
		
		
		/**
		 * not valid for server logger
		 */
		public function getLog():Array
		{
			return new Array("getLog() not valid in Server Logger");
		}
		
		
		/**
		 * Not valid for server logger
		 */
		public function clearLog():void
		{			
		}
		
		
		/**
		 * Called whenever a message successfully posts to the server-side script
		 * @param	e Event
		 */
		private function handleComplete(e:Event)
		{			
		}
		

		/**
		 * Called when a message post fails
		 * @param	e IOErrorEvent
		 */
		private function onIOError(e:IOErrorEvent)
		{			
		}
	}	
}