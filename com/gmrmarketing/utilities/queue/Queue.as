/**
 * Generic Queue Class
 * 
 * Stores data objects in a specified local file
 * File is located in the users Documents folder - extension is .que auto appended
 * 
 * Set the service in order to send queue objects to a web service
 * 
 * To see logging results listen for the LOG_ENTRY event on the queue class
 * Anytime it is received call Queue.logEntry to see the result
 * 
 * Currently can use these services:
	 WebService - Example sends data and video to service
	 HubbleService/HubbleServiceExtender - generic - sends form/image to Hubble
	 FormService - generic - posts simple form data
 * 
 * usage:
	import com.gmrmarketing.utilities.queue.Queue;
	import com.gmrmarketing.utilities.queue.FormService;

	var q:Queue = new Queue();
	q.fileName = "ilnySaved";
	q.service = new FormService("https://reesesfacebookvideo.thesocialtab.net/service");
	//or
	q.service = new HubbleServiceExtender();
	q.start();
	
	q.add(dataObject);
 */
package com.gmrmarketing.utilities.queue
{
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;	
	import com.gmrmarketing.utilities.ConnectionMonitor;
	
	
	public class Queue extends EventDispatcher
	{
		public static const LOG_ENTRY:String = "newServiceLogEntryAvailable";//listen for this then call logEntry to get the string
		private const MAX_TRIES:int = 50;//maximum number of upload attempts
		private var queueFileName:String;
		private var errorFileName:String;
		private var data:Array;//current queue
		private var myService:IQueueService;//web/hubble service		
		private var lastError:String = "";
		
		private var connectionMonitor:ConnectionMonitor;
		
		
		public function Queue()
		{
			data = [];
			connectionMonitor = new ConnectionMonitor();			
		}
		
		
		/**
		 * Sets myService to an instance of IQueueService
		 */
		public function set service(s:IQueueService):void
		{
			myService = s;
			myService.addEventListener(myService.errorEvent, serviceError);
			myService.addEventListener(myService.completeEvent, uploadComplete);			
		}
		
		
		/**
		 * Sets the file name for the queue 
		 * The .que extension is added automatically
		 * Queue files are kept in the users Documents folder
		 * 
		 * Populates the data array from the file
		 */
		public function set fileName(fn:String):void
		{
			queueFileName = fn + ".que";
			errorFileName = fn + "_error.que";//used if max_tries is reached for an upload item
			data = getAllData();
		}
		
		
		public function get logEntry():String 
		{
			return myService.lastError;
		}
		
		
		public function get qLogEntry():String 
		{
			return lastError;
		}
		
		
		/**
		 * For Hubble Service this returns an object with a AccessToken key
		 */
		public function get serviceAuthData():Object
		{
			return myService.authData;
		}
		
		
		/**
		 * Starts the queue sending data to the service
		 * This can be used at application start to begin sending any old queue entries
		 */
		public function start(e:TimerEvent = null):void
		{
			//need to wait until the service is ready...
			if (myService && myService.ready){
				uploadNext();
			}else {
				var a:Timer = new Timer(10000, 1);
				a.addEventListener(TimerEvent.TIMER, start, false, 0, true);
				a.start();
			}
		}
		
		
		/**
		 * Adds a data object to the queue
		 * original incoming object is stored in the 'original' property of the new object
		 * adds a qNumTries property to track the number of upload attempts
		 * @param item Object
		 */
		public function add(item:Object):void
		{
			var o:Object = new Object();
			o.original = item;//data portion used by the service - original data sent to queue
			o.qNumTries = 0; //add new queue property for keeping track of upload attempts
			
			data.push(o);//add item to queue
			rewriteQueue();
			data = getAllData();
			uploadNext();//send to service	
		}		
	
		
		/**
		 * Uploads the next data object
		 * Will call uploadComplete() once data is posted
		 * Will only try to upload the item if connection status is true
		 */
		private function uploadNext():void
		{
			if(connectionMonitor.connected){
				if (data.length > 0 && myService && !myService.busy) {
					myService.send(data.shift());//remove object from queue... get it back from service later if an error occurs
				}
			}else {
				delayNext();//call uploadNext() again in 30 seconds
			}
		}
	
		
		/**
		 * Callback for IQueueService
		 * Called if posting the data object generated an error
		 * Places the data object back onto the queue
		 * @param	e IQueueService.errorEvent
		 */
		private function serviceError(e:Event):void
		{
			var o:Object = myService.data;//get full object back from the service
			
			dispatchEvent(new Event(LOG_ENTRY));
			
			o.qNumTries = o.qNumTries + 1;
			if (o.qNumTries >= MAX_TRIES) {
				
				writeErrorData(o);//place in separate error file
				
				rewriteQueue();
				data = getAllData();
				
			}else {
				
				data.push(o);
				rewriteQueue();
				data = getAllData();
			}
			
			delayNext();
		}
		
		
		/**
		 * Callback for IQueueService
		 * Called once data has been successfully sent to the server
		 * @param	e IQueueService.completeEvent
		 */
		private function uploadComplete(e:Event):void
		{
			rewriteQueue();
			data = getAllData();
			delayNext();
		}
		
		
		/**
		 * calls uploadNext in 30 seconds
		 */
		private function delayNext():void
		{
			var a:Timer = new Timer(30000, 1);
			a.addEventListener(TimerEvent.TIMER, callUploadNext, false, 0, true);
			a.start();
		}		
		
		private function callUploadNext(e:TimerEvent):void
		{
			uploadNext();
		}
		
		
		
		//FILE METHODS BELOW
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the current users data file
		 * users array is emptied - call getAllUsers() to repopulate users
		 */
		private function rewriteQueue():void
		{			
			var file:File = File.documentsDirectory.resolvePath( queueFileName );
			
			try{				
				file.deleteFile();				
			}catch (e:Error) {}
			
			while (data.length) {
				var item:Object = data.shift();
				writeData(item);
			}
		}
		
		
		/**
		 * Appends a single data item to the queue file
		 * @param	obj
		 */
		private function writeData(obj:Object):void
		{
			var file:File = File.documentsDirectory.resolvePath( queueFileName );
			var stream:FileStream = new FileStream();
			
			try{				
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);				
				stream.close();				
			}catch (e:Error) {}
			
			file = null;
			stream = null;
		}		
		
		
		/**		
		 * Returns an array of all data objects in the queue file		 * 
		 * @return Array of data objects
		 */
		public function getAllData():Array
		{	
			var obs:Array = new Array();
			var a:Object = { };
		
			var file:File = File.documentsDirectory.resolvePath( queueFileName );
			var stream:FileStream = new FileStream();
			
			var isOK:Boolean = true;
			
			try{
				stream.open( file, FileMode.READ );
			}catch (e:Error) { isOK = false; }
				
			try{
				a = stream.readObject();
			}catch (e:Error) { isOK = false;}			
			
			if (isOK) {
				
				while (a) {
				
					obs.push(a);					
					
					try{
						a = stream.readObject();
					}catch (e:Error) {
						break;
					}
				}
			}
				
			try{
				stream.close();
			}catch(e:Error){}			
			
			file = null;
			stream = null;
			
			return obs;
		}
		
		
		/**
		 * Appends a single error data item to the error queue file
		 * @param	obj
		 */
		private function writeErrorData(obj:Object):void
		{
			var file:File = File.documentsDirectory.resolvePath( errorFileName );
			var stream:FileStream = new FileStream();
			
			try{				
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj);
				stream.close();				
			}catch (e:Error) {}
			
			file = null;
			stream = null;
		}		
	}	
}