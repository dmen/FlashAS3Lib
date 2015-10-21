/**
 * Example of a Web Service used with Queue.as
 * 
 * Modify per project
 * 
 * Sends form data to the FORM_URL and then sends a Video
 * using the File class' upload method to the VIDEO_URL
 */
package com.gmrmarketing.utilities.queue
{
	import com.gmrmarketing.utilities.queue.IQueueService;
	import flash.filesystem.File;
	import flash.events.*;
	import flash.net.*;	
	import com.gmrmarketing.utilities.Utility;
	
	
	public class WebService extends EventDispatcher implements IQueueService 
	{
		private const FORM_URL:String = "https://reesesfacebookvideo.thesocialtab.net/service";
		private const VIDEO_URL:String = "https://reesesfacebookvideo.thesocialtab.net/service/video";
	
		private var formLoader:URLLoader;
		private var videoLoader:File;
		private var upload:Object;
		
		private var isBusy:Boolean;		
		private var error:String;
		
		
		public function WebService()
		{
			error = "Web Service Started";
			isBusy = false;			
			formLoader = new URLLoader();
		}
		
		public function get errorEvent():String
		{
			return "serviceError";
		}
		
		public function get completeEvent():String
		{
			return "serviceComplete";
		}
		
		public function get busy():Boolean
		{
			return isBusy;			
		}
		
		
		public function send(data:Object):void
		{
			isBusy = true;
			
			upload = data;
			
			//videoError is set true in ioError() and securityErrorHandler()
			if (upload.videoError == true) {				
				//data was already posted
				dataPosted();
				
			}else{
			
				var request:URLRequest = new URLRequest(FORM_URL);			
				
				var vars:URLVariables = new URLVariables();		
				vars.email = upload.email;
				vars.guid = upload.guid;
				vars.timestamp = upload.timestamp;
			
				request.data = vars;			
				request.method = URLRequestMethod.POST;
				
				formLoader = new URLLoader();
				formLoader.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
				formLoader.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
				formLoader.load(request);
			}
		}
		
		
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
			error = "IOError posting form data: " + e.toString();
			isBusy = false;
			formLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataError);
			formLoader.removeEventListener(Event.COMPLETE, dataPosted);
			dispatchEvent(new Event(errorEvent));
		}
		
		
		/**
		 * 
		 * @param	e Will be null if called from send - user.videoError = true
		 */
		private function dataPosted(e:Event = null):void
		{
			if(!e || e.target.data == "Success=true"){
				
				videoLoader = File.applicationStorageDirectory.resolvePath(upload.guid + ".mp4");
				
				videoLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				videoLoader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, doneUploading, false, 0, true);
				videoLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				videoLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
				videoLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
				videoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
				
				videoLoader.upload(new URLRequest(VIDEO_URL));
			}else {
				error = "Error in dataPosted - server response: " + e.target.data;
				isBusy = false;
				dispatchEvent(new Event(errorEvent));	
			}
		}
		
		
		private function doneUploading(e:DataEvent):void
		{
			isBusy = false;
			
			if(e.data == "Success=true"){
				//delete video
				var f:File = File.applicationStorageDirectory.resolvePath(upload.guid + ".mp4");
				try {
					f.deleteFile();
				}catch (e:Error) {}
				
				
				dispatchEvent(new Event(completeEvent));
				
			}else {
				error = "Error in doneUploading - server response = " + e.data + " -- " + e.message;
				dispatchEvent(new Event(errorEvent));
				
			}
		}
		
		
		
		private function httpStatusHandler(e:HTTPStatusEvent):void 
		{
            
        }
		
		
		private function openHandler(e:Event):void 
		{
            
        }
		
		
		private function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			error = "SecurityError uploading video";
			isBusy = false;
			upload.videoError = true;
            dispatchEvent(new Event(errorEvent));
        }
		
		
		private function onProgress(e:ProgressEvent):void
		{
			var percentLoaded:Number = e.bytesLoaded / e.bytesTotal;			
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			error = "IOError uploading video";
			isBusy = false;
			upload.videoError = true;
			dispatchEvent(new Event(errorEvent));
		}
		
	}
	
}