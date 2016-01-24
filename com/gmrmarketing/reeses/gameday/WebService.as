package com.gmrmarketing.reeses.gameday
{
	import com.adobe.air.logging.FileTarget;
	import flash.filesystem.File;
	import flash.events.*;
	import flash.net.*;	
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class WebService extends EventDispatcher
	{
		public static const DATA_ERROR:String = "errorPostingFormData";
		public static const VIDEO_ERROR:String = "errorPostingVideo";
		public static const USER_COMPLETE:String = "uploadComplete";
		
		private const FORM_URL:String = "https://reesesfacebookvideo.thesocialtab.net/service";
		private const VIDEO_URL:String = "https://reesesfacebookvideo.thesocialtab.net/service/video";
	
		private var formLoader:URLLoader;
		private var videoLoader:File;
		private var upload:Object;
		
		private var log:Logger;
		
		private var isBusy:Boolean;		
		
		
		public function WebService()
		{
			isBusy = false;
			
			log = Logger.getInstance();
			
			formLoader = new URLLoader();
		}
		
		
		public function get busy():Boolean
		{
			return isBusy;			
		}
		
		
		public function send(o:Object):void
		{
			isBusy = true;
			
			upload = o;
			
			if (upload.videoError) {
				
				log.log(Utility.timeStamp + " | WebService.send() - upload.videoError = true");
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
		
		
		private function dataError(e:IOErrorEvent):void
		{
			isBusy = false;
			formLoader.removeEventListener(IOErrorEvent.IO_ERROR, dataError);
			formLoader.removeEventListener(Event.COMPLETE, dataPosted);
			dispatchEvent(new Event(DATA_ERROR));
		}
		
		
		/**
		 * 
		 * @param	e Will be null if called from send - user.videoError = true
		 */
		private function dataPosted(e:Event = null):void
		{
			log.log(Utility.timeStamp + " | WebService.dataPosted() " + e.target.data);
			
			if(!e || e.target.data == "Success=true"){
				
				videoLoader = File.applicationStorageDirectory.resolvePath(upload.guid + ".mp4");
				
				videoLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				videoLoader.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, doneUploading, false, 0, true);
				videoLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
				videoLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
				videoLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
				videoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
				
				videoLoader.upload(new URLRequest(VIDEO_URL));
				//}
			}else {
				isBusy = false;
				dispatchEvent(new Event(DATA_ERROR));	
			}
		}
		
		
		private function doneUploading(e:DataEvent):void
		{
			isBusy = false;			
			
			log.log(Utility.timeStamp + " | WebService.doneUploading() " + e.data);
			
			if(e.data == "Success=true"){
				//delete video
				var f:File = File.applicationStorageDirectory.resolvePath(upload.guid + ".mp4");
				try {
					log.log(Utility.timeStamp + " | WebService.doneUploading - delete video");
					f.deleteFile();
				}catch (e:Error) {log.log(Utility.timeStamp + " | WebService.doneUploading - delete video failed" + e.message);}
				
				
				dispatchEvent(new Event(USER_COMPLETE));
				
			}else {
				
				dispatchEvent(new Event(VIDEO_ERROR));
				
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
			log.log(Utility.timeStamp + " | WebService.securityErrorHandler() " + e.toString());
			isBusy = false;
            dispatchEvent(new Event(VIDEO_ERROR));
        }
		
		
		private function onProgress(e:ProgressEvent):void
		{
			var percentLoaded:Number = e.bytesLoaded / e.bytesTotal;			
		}
		
		
		private function ioError(e:IOErrorEvent):void
		{
			log.log(Utility.timeStamp + " | WebService.ioError() " + e.toString());
			isBusy = false;
			dispatchEvent(new Event(VIDEO_ERROR));
		}
		
	}
	
}