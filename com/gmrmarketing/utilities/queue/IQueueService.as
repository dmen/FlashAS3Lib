﻿/**
* Defines the methods required by all QueueService classes
*/

package com.gmrmarketing.utilities.queue
{	
	import flash.events.IEventDispatcher;
	
	public interface IQueueService extends IEventDispatcher
	{		
		function get errorEvent():String;//"Event constants" - these because you can't define string constants here in the interface
		function get completeEvent():String;
		
		function get authData():Object;//for Hubble this returns an object with an AccessToken key - not yet implemented for FormService
		function get busy():Boolean;//returns true if the service is busy
		function get ready():Boolean;//returns true if the service is ready to use - for hubble if the token != ""
		function send(data:Object):void;//sends the data object to the service
		function get data():Object;//returns the data object set in send()
		function get lastError():String;//returns the last error that occured - non-timestamped
	}	
}