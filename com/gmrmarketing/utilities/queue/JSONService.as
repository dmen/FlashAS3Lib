package com.gmrmarketing.utilities.queue
{
	import com.gmrmarketing.utilities.queue.IQueueService;
	import flash.events.*;
	import flash.net.*;	
	
	public class JSONService extends EventDispatcher implements IQueueService
	{
		private var serviceURL:String;
		private var formLoader:URLLoader;
		private var upload:Object;		
		private var isBusy:Boolean;		
		private var serverResponse:Object;//what we're expecting from the server on a successful post
		private var error:String;
		
		private var hdr:URLRequestHeader;//headers for sending and receiving JSON
		private var hdr2:URLRequestHeader;
		
		
		/**
		 * Constructor
		 * @param	url URL of the service - used in send()
		 * @param servResp JSON the server sends back on successful post - used in dataPosted()
		 * if servResp is null then dataPosted() will only check if returnedObject.Success = true
		 */
		public function JSONService(url:String, servResp:Object = null)
		{
			serviceURL = url;
			serverResponse = servResp;
			isBusy = false;
			error = "JSONService Started";
			formLoader = new URLLoader();
			
			hdr = new URLRequestHeader("Content-type", "application/json");
			hdr2 = new URLRequestHeader("Accept", "application/json");
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
		
		
		public function get authData():Object
		{
			return { };
		}
		
		
		/**
		 * Returns true if the service is busy interacting with the server
		 */
		public function get busy():Boolean
		{
			return isBusy;			
		}	
		
		
		public function get ready():Boolean
		{
			return true;
		}
		
	
		/**
		 * Called from Queue
		 * @param	data Object with original and qNumTries properties
		 */
		public function send(data:Object):void
		{
			isBusy = true;
			
			//keep this so Queue can retrieve if an error occurs
			upload = data;
			
			//original property contains the original data passed to the Queue
			var js:String = JSON.stringify(data.original);
			
			var req:URLRequest = new URLRequest(serviceURL);
			req.method = URLRequestMethod.POST;
			req.data = js;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.load(req);
		}
		
		
		/**
		 * Returns the data object
		 * Called by Queue if an error is generated
		 * allows the data to be put back on the queue
		 * contains original and qNumTries properties
		 */
		public function get data():Object
		{
			return upload;
		}
		
		
		public function get lastError():String
		{
			return error;
		}
		
		
		private function dataPosted(e:Event):void
		{
			isBusy = false;
			
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if (serverResponse == null){
				
				if(j.Success){
					error = "JSONService.dataPosted success";
					dispatchEvent(new Event(completeEvent));
				}else{
					error = "Error in JSONService.dataPosted - server response: " + JSON.stringify(j);
					dispatchEvent(new Event(errorEvent));	
				}
			}else if (JSON.stringify(j) == JSON.stringify(serverResponse)) {
				error = "JSONService.dataPosted success";
				dispatchEvent(new Event(completeEvent));				
			}else {				
				error = "Error in JSONService.dataPosted - server response: " + JSON.stringify(j) + " expected serverString: " + JSON.stringify(serverResponse);
				dispatchEvent(new Event(errorEvent));	
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			isBusy = false;		
			
			error = "JSONService.dataError IOError: " + e.toString();				
			dispatchEvent(new Event(errorEvent));
		}
		
	}
	
}