
package com.gmrmarketing.reeses.gameday
{
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.events.*;	
	import flash.utils.Timer;
	import com.gmrmarketing.reeses.gameday.WebService;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Queue extends EventDispatcher  
	{		
		private var DATA_FILE_NAME:String
		private var users:Array;//current queue				
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()	
		
		private var web:WebService;
		private var log:Logger;
		
		
		public function Queue()
		{
			CONFIG::COLLEGE {
				DATA_FILE_NAME = "reesesGDQueue.csv";
			}
			CONFIG::SENIOR {
				//change queue file name if it's for senior bowl
				DATA_FILE_NAME = "reesesGDQueue_SB.csv";
			}
			
			log = Logger.getInstance();
			
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
		 * @param data Object with email, followUp, video, guid, timestamp keys
		 * video is just a string path to the video file
		 * guid is the file name - minus the .mp4 extension
		 */
		public function add(data:Object):void
		{
			log.log(Utility.timeStamp + " | queue.add: " + data.email + " / " + data.video);			
			
			data.videoError = false; //set to true if videoPostError is called
			//used by WebService - if this is true then the form data won't post again - just the video
			
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
			if (users.length > 0 && !web.busy) {
				curUpload = users.shift();//object:email,video,timeAdded
				log.log(Utility.timeStamp + " | Queue.uploadNext() " + curUpload.email);
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
			log.log(Utility.timeStamp + " | Queue.formPostError() " + curUpload.email);
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
			log.log(Utility.timeStamp + " | Queue.videoPostError() " + curUpload.email);
			
			curUpload.videoError = true; //WebService will attempt to only upload the video - not the form data as well
			
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
			log.log(Utility.timeStamp + " | Queue.uploadComplete() " + curUpload.email);

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
			
			var isOK:Boolean = true;
			
			try{
				stream.open( file, FileMode.READ );
			}catch (e:Error) { isOK = false; }
				
			try{
				a = stream.readObject();
			}catch (e:Error) { isOK = false;}
			
			if(isOK){
				while (a.email != undefined) {					
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