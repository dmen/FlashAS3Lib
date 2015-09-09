
package com.gmrmarketing.reeses.gameday
{
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import com.gmrmarketing.reeses.gameday.WebService;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.GUID;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	
	
	public class Queue extends EventDispatcher  
	{
		private const DATA_FILE_NAME:String = "reesesGDQueue.csv";
		private var users:Array;//current queue				
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()	
		
		private var web:WebService;
		private var log:Logger;
		
		public function Queue()
		{
			log = Logger.getInstance();
			log.logger = new LoggerAIR();
			
			web = new WebService();
			web.addEventListener(WebService.DATA_ERROR, formPostError);
			web.addEventListener(WebService.VIDEO_ERROR, videoPostError);
			web.addEventListener(WebService.USER_COMPLETE, uploadComplete);
			
			users = getAllUsers();//populate users array from disk file				
			uploadNext()
		}
		
		
		/**
		 * Called from Main.videoDoneProcessing()
		 * Adds a user data object to the csv file
		 * Called from Main
		 * @param data Object with email,video keys
		 * video is just a string path to the video file
		 * Adds a timestamp key, and guid key
		 */
		public function add(data:Object):void
		{		
			data.timestamp = Utility.hubbleTimeStamp();
			data.videoError = false; //set to true if videoPostError is called
			
			var f:File = new File();
			f.nativePath = data.video;//output.mp4 in applicationStorageDirectory
			
			log.log("queue.add: " + data.video);
			
			var n:String = GUID.create();
			//can't write to applicationDirectory
			var t:File = File.applicationStorageDirectory.resolvePath(n + ".mp4");
			data.video = t.nativePath;//new file path/name with GUID
			data.guid = n;
			log.log("queue.add: " + n + " -- " + data.video);
			try{
				f.moveTo(t);
				log.log("move succeeded");
			}catch (e:Error) {
				log.log(e.message);
			}
			
			users.push(data);//add to queue
			rewriteQueue();
			users = getAllUsers();
			uploadNext();			
		}		
	
		
		/**
		 * uploads the current user form data to the service
		 * removes the curUpload object from users array
		 * Will call uploadComplete() once data is posted
		 */
		private function uploadNext():void
		{
			if (users.length > 0) {		//and uploader not busy...		
				curUpload = users.shift();//object:email,video,timeAdded
				
				//send to server
				web.send(curUpload);
			}
		}
	
		
		/**
		 * Callback for WebService
		 * Called if posting the form data throws an error
		 * 
		 * @param	e WebService.DATA_ERROR
		 */
		private function formPostError(e:Event):void
		{
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			delayNext();
		}
		
		
		/**
		 * Callback for WebService
		 * Called if sending the video throws an error
		 * @param	e
		 */
		private function videoPostError(e:Event):void
		{
			curUpload.videoError = true; //WebService will attemp to only upload the video - not the form data as well
			
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			
			delayNext();
		}
		
		
		/**
		 * Callback for WebService
		 * Called once data has been successfully set to the server
		 * @param	e WebService.USER_COMPLETE event
		 */
		private function uploadComplete(e:Event):void
		{
			rewriteQueue();//writes the users array to disk - with curUpload object now removed
			users = getAllUsers();//repopulate users array from file			
			delayNext();
		}
		
		
		private function delayNext():void
		{
			var a:Timer = new Timer(5000, 1);
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
			var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
			
			try{				
				file.deleteFile();				
			}catch (e:Error) {}
			
			while (users.length) {
				var aUser:Object = users.shift();
				writeUser(aUser);
			}
		}
		
		
		/**
		 * Appends a single user object to the data file
		 * @param	obj
		 */
		private function writeUser(obj:Object):void
		{
			var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
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
		 * Called from constructor and uploadComplete()
		 * returns an array of all user objects in the data file
		 * 
		 * All key types are strings - sharephoto and emailoptin are string booleans "true" or "false"
		 * uploaded is string boolean - special key added by add()
		 * 
		 * @return Array of user objects
		 */
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			var file:File = File.documentsDirectory.resolvePath( DATA_FILE_NAME );
			var stream:FileStream = new FileStream();
				
			try{
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a.email != undefined) {					
					obs.push(a);					
					a = stream.readObject();
				}
				
				stream.close();
				
			}catch (e:Error) {}
			
			file = null;
			stream = null;
			return obs;
		}
		
	}	
}