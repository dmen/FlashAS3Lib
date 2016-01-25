/**
 * Generic Queue Class
 * Version 1 - 09/22/2015
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
	
	
	public class Queue extends EventDispatcher
	{
		public static const LOG_ENTRY:String = "newLogEntryAvailable";
		private var queueFileName:String;
		private var data:Array;//current queue
		private var myService:IQueueService;//web/hubble service		
		
		
		public function Queue()
		{
			data = [];
		}
		
		
		/**
		 * Sets myService to an instance of IQueueService
		 */
		public function set service(s:IQueueService):void
		{
			myService = s;
			myService.addEventListener(myService.errorEvent, serviceError);
			myService.addEventListener(myService.completeEvent, uploadComplete);
			dispatchEvent(new Event(LOG_ENTRY));
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
			data = getAllData();
		}
		
		
		public function get logEntry():String 
		{
			return myService.lastError;
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
			if (myService.ready){
				uploadNext();
			}else {
				var a:Timer = new Timer(2000, 1);
				a.addEventListener(TimerEvent.TIMER, start, false, 0, true);
				a.start();
			}
		}
		
		
		/**
		 * Adds a data item to the queue
		 * @param item Object
		 */
		public function add(item:Object):void
		{
			data.push(item);//add to queue
			rewriteQueue();
			data = getAllData();
			uploadNext();			
		}		
	
		
		/**
		 * Uploads the next data object
		 * Will call uploadComplete() once data is posted
		 */
		private function uploadNext():void
		{
			if (data.length > 0 && myService && !myService.busy) {
				myService.send(data.shift());//removes item from the users array
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
			trace(myService.lastError);
			dispatchEvent(new Event(LOG_ENTRY));
			
			data.push(myService.data);
			rewriteQueue();
			data = getAllData();
			
			delayNext();
		}
		
		
		/**
		 * Callback for IQueueService
		 * Called once data has been successfully sent to the server
		 * @param	e IQueueService.completeEvent
		 */
		private function uploadComplete(e:Event):void
		{		
			dispatchEvent(new Event(LOG_ENTRY));
			
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
		
	}	
}