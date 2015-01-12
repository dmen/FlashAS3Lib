package com.gmrmarketing.sap
{	
	import flash.filesystem.*;
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.GUID;
	
	
	public class Queue extends EventDispatcher
	{
		private const QUEUE_FILE:String = "c:\\sap_video_queue\\queueData.dat";
		private const SAVED_FILE:String = "c:\\sap_video_queue\\savedData.dat";
		
		private var users:Array;//current queue of user obects pending upload to the server
		private var curUpload:Object; //currently uploading user object - users[0] - set in uploadNext()
		private var isUploading:Boolean;
		private var logger:Logger;
		
		
		public function Queue()
		{
			logger = Logger.getInstance();
			isUploading = false;
			users = getAllUsers();//populate users array from the QUEUE_FILE
			uploadNext();
		}
		
		
		public function get length():int
		{
			return users.length;
		}
		
		
		/**
		 * Adds a record to the queue. Stores file name, qr code, and fantasy player id
		 * in the queueData.dat file and then moves the file to the queued folder
		 * 
		 * @param	f File object reference to the video
		 * @param	qr QR Code 
		 * @param	pID Fantasy player ID
		 */
		public function add(f:File, qr:String, pID:int):void
		{
			if (f.exists) {
				
				var newFileName:String = GUID.create() + ".mp4";
				
				users.push( { file:newFileName, qr:qr, playerID:pID  } );
				rewriteQueue();
				
				users = getAllUsers();//populate users array from the QUEUE_FILE
				
				var newLoc:File = new File("c:\\sap_video_queue\\" + newFileName);
				f.copyTo(newLoc, true);//can't use moveTo here because the recording software has the file locked
				
				uploadNext();
			}
		}
		
		
		/**
		 * uploads the current user form data to the service
		 * removes the curUpload object from users array
		 * Will call complete() once video is posted
		 */
		private function uploadNext(e:Event = null):void
		{	
			if (users.length > 0 && !isUploading) {	
				isUploading = true;
				curUpload = users.shift();
				postVideo(curUpload);
			}
		}
		
		
		/**
		 * This needs a crossdomain.xml file on the root of the server
		 * uses File.upload 
		 * Posts a user record and associated video to the server
		 * 
		 * @param obj User object containing file, qr and playerID properties
		 */
		public function postVideo(obj:Object):void
		{			
			var request = new URLRequest("https://sapsuperbowl49service.thesocialtab.net/api/video/?authorization=89075BDA-5741-42D6-B89F-8B628B776D49");
			
			var vars:URLVariables = new URLVariables();
			vars.qr1 = obj.qr;			
			vars.fantasyPlayerId = obj.playerID;
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var theFile:File = new File("c:\\sap_video_queue\\" + obj.file);
			theFile.addEventListener(IOErrorEvent.IO_ERROR, ioerror, false, 0, true);		
			theFile.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
			theFile.addEventListener(Event.COMPLETE, uploadComplete, false, 0, true);
			theFile.upload(request);			
		}
		
		
		/**
		 * if an ioError occurs push the curUpload object back onto the users array
		 * rewrites the queue and resumes uploading
		 * @param	e
		 */
		private function ioerror(e:IOErrorEvent):void
		{
			logger.log("IOError uploading video: " + e.toString());
			isUploading = false;
			users.push(curUpload);
			rewriteQueue();
			users = getAllUsers();
			uploadNext();
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			//trace(e.toString());
		}		
		
		
		private function uploadComplete(e:Event):void
		{
			logger.log("UPLOAD:" + curUpload.file + " " + curUpload.qr + " " + curUpload.playerID + " :: " + e.toString());
			
			isUploading = false;
			
			writeSavedUser(curUpload); //keep saved users in sep file
			
			rewriteQueue();//writes the users array to disk - with curUpload object now removed
			users = getAllUsers();//repopulate users array from file
			
			uploadNext();
		}
		
		
		/**
		 * Writes a user object to QUEUE_FILE
		 * file in the object is the file name
		 * @param	obj Record object in the file contains file, qr and playerID properties
		 */
		private function writeUser(obj:Object):void
		{
			var stream:FileStream = new FileStream();
			var qFile:File = new File(QUEUE_FILE);
			
			try {
				stream.open( qFile, FileMode.APPEND );
				stream.writeObject(obj);				
			}catch (e:Error) {
				logger.log("Error in writeUser(): " + e.message);
			}
			
			stream.close();
			qFile = null;
			stream = null;
		}
		
		
		/**
		 * Appends a single user object to the saved data file
		 * Saved Data File contains all users that have been sent to the server
		 * called from uploadComplete()
		 * @param	obj
		 */
		private function writeSavedUser(obj:Object):void
		{	
			var stream:FileStream = new FileStream();
			var qFile:File = new File(SAVED_FILE);
				
			try {				
				stream.open( qFile, FileMode.APPEND );
				stream.writeObject(obj);				
			}catch (e:Error) {
				logger.log("Error in writeSavedUser(): " + e.message);
			}	
			
			stream.close();
			qFile = null;
			stream = null;
		}
		
		
		/**
		 * Called from constructor and uploadComplete()
		 * returns an array of all user objects in the data file
		 * 
		 * User object contain: file, qr and pID properties
		 * 
		 * @return Array of user objects
		 */
		private function getAllUsers():Array
		{			
			var obs:Array = new Array();
			var a:Object = { };
		
			var stream:FileStream = new FileStream();
			var qFile:File = new File(QUEUE_FILE);
				
			try {				
				stream.open( qFile, FileMode.READ );
				
				a = stream.readObject();
				while (a.file != undefined) {					
					obs.push(a);					
					a = stream.readObject();
				}				
			}catch (e:Error) {
				//Commented this because the while loop above will generate an EOF error every time it runs
				//logger.log("Error in getAllUsers() " + e);
			}
			
			stream.close();
			
			logger.log("getAllUsers() - number of records in queue: " + obs.length);
			
			qFile = null;
			stream = null;
			
			return obs;
		}
		
		
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the current users data file
		 * users array is emptied - call getAllUsers() to repopulate users
		 */
		private function rewriteQueue():void
		{
			var qFile:File = new File(QUEUE_FILE);
			
			try{				
				qFile.deleteFile();				
			}catch (e:Error) {
				logger.log("Error in rewriteQueue(): " + e.message);
			}
			
			while (users.length) {
				var aUser:Object = users.shift();
				writeUser(aUser);
			}
		}
	}	
}