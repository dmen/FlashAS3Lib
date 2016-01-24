/**
 * Simple Generic Form Web Service that implements IQueueService
 * so it can be used as a service for Utilities.Queue
 * 
 * Posts Key/Value pairs to a service
 * 
 * usage:
	import com.gmrmarketing.utilities.queue.Queue;
	import com.gmrmarketing.utilities.queue.FormService;

	var q:Queue = new Queue();
	q.fileName = "taco2";
	q.service = new FormService("http://formURL");
	q.send({email:"dmennenoh@gmrmarketing.com", fname:"Dave", lname:"Mennenoh"});
	
	Note the object given to the Queue in Queue.add will be used
	to define the data passed to the service in the Post. The
	objects keys will be the variable names in the URLVariables object
	
	Dispatches completeEvent when dataPosted is called and the return string
	from the server matches serverString "Success=true" by default.
 */
package com.gmrmarketing.utilities.queue
{
	import com.gmrmarketing.utilities.queue.IQueueService;
	import flash.filesystem.File;
	import flash.events.*;
	import flash.net.*;	
	import com.gmrmarketing.utilities.Utility;
	
	
	public class FormService extends EventDispatcher implements IQueueService 
	{
		private var formURL:String;
		private var formLoader:URLLoader;
		private var videoLoader:File;
		private var upload:Object;		
		private var isBusy:Boolean;		
		private var serverString:String;
		private var error:String;
		
		/**
		 * Constructor
		 * @param	url URL of the service - used in send()
		 * @param servrString What the server sends back on successful post - used in dataPosted()
		 */
		public function FormService(url:String, servrString:String = "Success=true")
		{
			formURL = url;
			serverString = servrString;
			isBusy = false;
			error = "FormService Started";
			formLoader = new URLLoader();
		}
		
		public function get authData():Object
		{
			return { };
		}
		
		
		public function get ready():Boolean
		{
			return true;
		}
		
		//These functions exist because you can't define String Constants in the Interface
		public function get errorEvent():String
		{
			return "serviceError";
		}
		
		public function get completeEvent():String
		{
			return "serviceComplete";
		}
		
		
		/**
		 * Returns true if the service is busy interacting with the server
		 */
		public function get busy():Boolean
		{
			return isBusy;			
		}			
		
		
		/**
		 * Sends the data object to the web service
		 * key/value pairs in the object are used for key/values in the URLVariables object that is created
		 * @param	data
		 */
		public function send(data:Object):void
		{
			isBusy = true;
			
			upload = data;
			
			var request:URLRequest = new URLRequest(formURL);			
			var vars:URLVariables = new URLVariables();	
			
			for (var key:String in data) {
				vars[key] = data[key];				
			}
		
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			formLoader = new URLLoader();
			formLoader.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			formLoader.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			formLoader.load(request);
		}
		
		
		/**
		 * Returns the data object
		 * Called by Queue if an error is generated
		 * allows the data to be put back on the queue
		 */
		public function get data():Object
		{
			return upload;
		}
		
		
		public function get lastError():String
		{
			return error;
		}
	
		
		private function dataError(e:IOErrorEvent):void
		{
			error = "FormService.dataError IOError: " + e.toString();
			isBusy = false;
			formLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataError);
			formLoader.removeEventListener(Event.COMPLETE, dataPosted);
			dispatchEvent(new Event(errorEvent));
		}
		
		
		private function dataPosted(e:Event):void
		{
			isBusy = false;
			
			if (e.target.data == serverString) {
				error = "FormService.dataPosted success";
				dispatchEvent(new Event(completeEvent));				
			}else {				
				error = "Error in FormService.dataPosted - server response: " + e.target.data + " expected serverString: " + serverString;
				dispatchEvent(new Event(errorEvent));	
			}
		}
		
	}
	
}