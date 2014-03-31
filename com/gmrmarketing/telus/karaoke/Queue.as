package com.gmrmarketing.telus.karaoke 
{
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;	
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax; //for delayed call	
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";
	
		private const FORM_URL:String = "http://teluskaraoke.thesocialtab.net/Home/Register?";
		private const VIDEO_URL:String = "http://teluskaraoke.thesocialtab.net/Home/SubmitVideo";
		private const DATA_FILE_NAME:String = "telusData.csv";
		
		private var videoFolder:File;
		private var users:Array;
		private var currentUser:Object; //currently uploading		
		
		private var debugMessage:String;
		
		private var formLoader:URLLoader;
		private var videoLoader:File;
		
		
		public function Queue()
		{	
			formLoader = new URLLoader();
			videoFolder = new File("c:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\teluscap\\streams\\_definst_");
			//videoFolder = new File("c:\\vid"); //FOR DEBUGGING
			users = readObjects();
			TweenMax.delayedCall(1, initialDebug);	
			
			//start uploading immediately if there are records waiting
			if (users.length > 0) {
				uploadNext();
			}
		}
		
		
		private function initialDebug():void
		{
			debug("Queue loaded - " + users.length + " videos need uploading");
		}
		
		
		/**
		 * Data object contains fname,lname,email,song,guid keys		
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
		 * uploads the form data to the service
		 */
		private function uploadNext():void
		{
			debug("uploadNext " + users.length);
			
			var request:URLRequest = new URLRequest(FORM_URL);
			
			currentUser = users[0];
			
			var vars:URLVariables = new URLVariables();
			vars.firstName = currentUser.fname;
			vars.lastName = currentUser.lname;
			vars.email = currentUser.email;
			vars.song = currentUser.song;
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
		
		
		//wait 30 seconds before restarting the queue
		private function delayedRestart():void
		{
			debug("restarting queue - waiting 10 seconds");
			TweenMax.delayedCall(10, uploadNext);
		}
		
		
		//called when the form data has posted
		private function dataPosted(e:Event):void
		{
			if(e.target.data == "success=true"){
			
				debug("form data posted - starting video upload");
				//form posted now send the video
				videoLoader = videoFolder.resolvePath(currentUser.guid + ".flv");
				debug("VIDEO:" + videoLoader.nativePath);
				
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
			debug("video upload i/o error:" + e.toString());
			
			if (users.length > 0) {
				var badUser:Object = users.shift();
				users.push(badUser); //stick error prone video onto end of queue
				delayedRestart();
			}	
		}
		
		
		private function debug(m:String):void
		{
			debugMessage = m;
			dispatchEvent(new Event(DEBUG_MESSAGE));
		}
		
		
		public function getDebugMessage():String
		{
			return debugMessage;
		}
		
		
		//called once video has uploaded
		//form and vid are now complete
		private function doneUploading(e:Event):void
		{
			debug("video upload complete");
			users.shift();//remove user from queue
			rewriteQueue();
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
			deleteDataFile();
			while (users.length) {
				var aUser:Object = users.shift();
				writeObject(aUser);
			}
		}
		
		
		/**
		 * Writes a single object to the data file
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
				
			}			
		}
		
		
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
				
			}	
			
			stream.close();
			file = null;
			stream = null;
			
			//FOR DEBUGGING
			//obs = [ { fname:"Dave", lname:"Mennenoh", email:"dmennenoh@gmrmarketing.com", song:"taco hunter", guid:"abcdefg-jkl" } ];
			
			return obs;
		}
		
		
		private function deleteDataFile():void
		{
			try{
				var file:File = File.applicationStorageDirectory.resolvePath( DATA_FILE_NAME );
				file.deleteFile();
				
			}catch (e:Error) {
				debug("could not delete data file: " + e.message);
			}	
		}
	}
	
}