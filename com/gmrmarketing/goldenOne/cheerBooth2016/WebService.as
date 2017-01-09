/**
 * Example of a Web Service used with Queue.as
 * 
 * Modify per project
 * 
 * Sends form data to the FORM_URL and then sends a Video
 * using the File class' upload method to the VIDEO_URL
 */
package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import com.gmrmarketing.utilities.queue.IQueueService;
	import flash.filesystem.File;
	import flash.events.*;
	import flash.net.*;	
	import com.gmrmarketing.utilities.Utility;
	
	
	public class WebService extends EventDispatcher implements IQueueService 
	{
		private const FORM_URL:String = "http://Golden1SacramentoKings.GMRPreProd.com/api/Registrant/Register";
		private const VIDEO_URL:String = "http://Golden1SacramentoKings.GMRPreProd.com/api/Registrant/AddMedia";
	
		private var formLoader:URLLoader;
		private var videoLoader:File;
		private var upload:Object;//original data object set in send()
		
		private var isBusy:Boolean;		
		private var error:String;
		
		
		public function WebService()
		{
			error = "Web Service Started";
			isBusy = false;			
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
		
		
		/**
		 * Called from Queue.uploadNext()
		 * data has original and qNumTries properties
		 * original is an object containing the original data sumbitted to the Queue from the application
		 * 
		 * there will be a videoError property also if there was an error uploading the file
		 * in this case the form upload wll be skipped and just the file will be tried again
		 * 
		 * Here, the data.original object contains these properties
		 * fname,lname,email,member,opt1,file,event
		 * 
		 * @param	data
		 */
		public function send(data:Object):void
		{
			isBusy = true;
			
			upload = data;			
			
			//videoError is set true in ioError() and securityErrorHandler()
			if (upload.videoError == true) {				
				
				//data was already posted - skip and upload file only
				dataPosted();
				
			}else{
			
				var request:URLRequest = new URLRequest(FORM_URL);			
				
				var vars:URLVariables = new URLVariables();		
				vars.fname = upload.original.fname;
				vars.lname = upload.original.lname;
				vars.email = upload.original.email;
				vars.member = upload.original.member;
				vars.opt1 = upload.original.opt1;
				var fn:String = upload.original.file;//this is the full path - extract just the filename from the end
				vars.filename = fn.substring(fn.length - 40);//GUID is 36 chars, plus .mp4 = 40
				vars.event = upload.original.event;//this comes from the config dialog
				
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
		 * @param	e Will be null if called from send() - upload.videoError = true
		 */
		private function dataPosted(e:Event = null):void
		{
			if(!e || e.target.data == "success=true"){
				
				videoLoader = new File(upload.original.file);//mp4 or jpg - full path
				
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
			
			if(e.data == "success=true"){
				//delete video
				var f:File = new File(upload.original.file);
				try {
					f.deleteFile();
				}catch (e:Error) {}
				
				
				dispatchEvent(new Event(completeEvent));
				
			}else {
				error = "Error in doneUploading - server response = " + e.data;
				upload.videoError = true;
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