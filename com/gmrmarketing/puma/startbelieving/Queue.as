package com.gmrmarketing.puma.startbelieving
{
	import flash.display.MovieClip;	
	import flash.filesystem.*;	
	import flash.net.*;
	import flash.events.*;	
	import flash.utils.Timer;
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";
	
		private const FORM_URL:String = "https://pumaworldcupvideo.thesocialtab.net/Home/Register?";
		private const VIDEO_URL:String = "https://pumaworldcupvideo.thesocialtab.net/Home/SubmitVideo";
		private const DATA_FILE_NAME:String = "pumaData.csv";
		
		private var videoFolder:File;
		private var users:Array;
		private var currentUser:Object; //currently uploading - set in uploadNext()	
		
		private var debugMessage:String;
		
		private var formLoader:URLLoader;
		private var videoLoader:File;
		
		
		public function Queue()
		{	
			formLoader = new URLLoader();
			videoFolder = new File("c:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\puma\\streams\\_definst_");
			
			users = readObjects();			
			
			//start uploading immediately if there are records waiting
			if (users.length > 0) {
				uploadNext();
			}
		}
		
		
		/**
		 * called from Main.videoDone()
		 * Data object contains fname,lname,email,optin,guid keys	
		 */
		public function addToQueue(data:Object):void
		{
			users.push(data);
			writeObject(data);
			
			//if it were > 1 the queue would already be uploading
			if (users.length == 1) {
				uploadNext();
			}
		}
		
		/**
		 * uploads the current user form data to the service
		 */
		private function uploadNext(e:TimerEvent = null):void
		{
			debug("uploadNext() " + users.length + " videos in the queue");
			
			var request:URLRequest = new URLRequest(FORM_URL);
			
			currentUser = users[0];
			
			var vars:URLVariables = new URLVariables();
			vars.firstName = currentUser.fname;
			vars.lastName = currentUser.lname;
			vars.email = currentUser.email;
			vars.optin = currentUser.optin;
			vars.id = currentUser.guid;
					
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			formLoader = new URLLoader();
			formLoader.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			formLoader.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			formLoader.load(request);
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			debug("data error from form post");
			
			if (users.length > 0) {
				delayedRestart();
			}			
		}
		
		
		/**
		 * Delayed queue restart
		 * Calls uploadNext() after 20 seconds
		 */
		private function delayedRestart():void
		{
			debug("restarting queue - waiting 20 seconds");
			
			var dc:Timer = new Timer(20000, 1);
			dc.addEventListener(TimerEvent.TIMER, uploadNext, false, 0, true);
			dc.start();
		}
		
		
		/**
		 * Called when the form data for currentUser has posted
		 * uploads the video
		 * @param	e Event.COMPLETE
		 */
		private function dataPosted(e:Event):void
		{
			debug("dataPosted() e.target.data: " + e.target.data);
			
			if(e.target.data == "success=true"){
				
				videoLoader = videoFolder.resolvePath(currentUser.guid + ".flv");
				debug("Uploading video: " + videoLoader.nativePath);
				
				videoLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				videoLoader.addEventListener(Event.COMPLETE, doneUploading, false, 0, true);
				videoLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				videoLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
				videoLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
				videoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
				
				videoLoader.upload(new URLRequest(VIDEO_URL));
				
			}else {
				debug("form data error - success!=true");
				delayedRestart();
			}
		}
		
		
		private function httpStatusHandler(e:HTTPStatusEvent):void {
            debug("video httpStatusHandler: " + e.toString());
        }
		
		
		private function openHandler(e:Event):void {
            debug("video opened: " + e.toString());
        }
		
		
		private function securityErrorHandler(e:SecurityErrorEvent):void {
            debug("video securityErrorHandler: " + e.toString());
			
			if (users.length > 0) {
				var badUser:Object = users.shift();
				users.push(badUser); //stick error prone video onto end of queue
				delayedRestart();
			}	
        }
		
		
		private function onProgress(e:ProgressEvent):void
		{
			var percentLoaded:Number = e.bytesLoaded / e.bytesTotal;
			debug("progress_" + percentLoaded);
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			debug("video upload i/o error: " + e.toString());
			
			if (users.length > 0) {
				var badUser:Object = users.shift();
				users.push(badUser); //stick error prone video onto end of queue
				delayedRestart();
			}	
		}
		
		
		private function debug(m:String):void
		{
			debugMessage = m;
			//trace(m);
			dispatchEvent(new Event(DEBUG_MESSAGE));
		}
		
		
		public function getDebugMessage():String
		{
			return debugMessage;
		}
		
		
		/**
		 * Called once video is done uploading
		 * @param	e Event.COMPLETE
		 */
		private function doneUploading(e:Event):void
		{
			debug("video upload complete");
			users.shift();//remove user from queue
			debug("removing user from queue - new length: " + users.length);
			
			rewriteQueue();//empties the users array
			users = readObjects();//repopulate array
			
			if (users.length > 0) {
				delayedRestart();
			}
		}
		
		
		/**
		 * Deletes the user data file, then writes the current
		 * array of user objects to the file
		 */
		private function rewriteQueue():void
		{
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				file.deleteFile();
				
			}catch (e:Error) {
				debug("could not delete data file: " + e.message);
			}	
			
			while (users.length) {
				var aUser:Object = users.shift();
				writeObject(aUser);
			}
		}
		
		
		/**
		 * Appends a single user object to the data file
		 * @param	obj
		 */
		private function writeObject(obj:Object):void
		{			
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject(obj );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				debug("writeObject() catch error: " + e.message);
			}			
		}
		
		
		/**
		 * called from constructor
		 * returns an array of user objects 
		 * @return
		 */
		private function readObjects():Array
		{
			var obs:Array = new Array();
			var a:Object = { };
		
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				
				a = stream.readObject();
				while (a.fname != undefined) {
					obs.push(a);
					a = stream.readObject();
				}				
			}catch (e:Error) {
				debug("readObjects() catch error: " + e.message);
			}	
			
			stream.close();
			file = null;
			stream = null;
			
			//FOR DEBUGGING
			//obs = [ { fname:"Dave", lname:"Mennenoh", email:"dmennenoh@gmrmarketing.com", optin:"true", guid:"abcdefg-jkl" } ];
			
			return obs;
		}
		
	}
	
}