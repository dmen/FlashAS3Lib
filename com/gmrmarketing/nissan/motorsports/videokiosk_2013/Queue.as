package com.gmrmarketing.nissan.motorsports.videokiosk_2013 
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.filesystem.*;	
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax; //for delayed call	
	
	
	public class Queue extends EventDispatcher  
	{
		public static const DEBUG_MESSAGE:String = "newMessageReady";	
		private const VIDEO_URL:String = "http://nissanmotorsports.thesocialtab.net/video/create";				
		private var videoFolder:File; //local folder where fms videos are stored
		
		private var so:SharedObject;		
		private var debugMessage:String;		
		private var queue:Array;//array of id's
		private var videoLoader:File;
		
		
		public function Queue()
		{			
			videoFolder = new File("c:\\Program Files\\Adobe\\Flash Media Server 4.5\\applications\\nissanCap\\streams\\_definst_");			
			
			so = SharedObject.getLocal("nissanMotorSports", "/");
			queue = so.data.queue;
			if (queue == null) {
				queue = new Array();
				saveQueue();
			}	
			
			debug("Queue loaded - " + queue.length + " videos need uploading");
			
			//start uploading immediately if there are videos waiting
			if (queue.length > 0) {
				uploadNext();
			}
		}
		
		private function saveQueue():void
		{
			so.data.queue = queue;
			so.flush();
		}
		
		
		/**
		 * Adds the id (QR code) to the queue array
		 * called from main
		 * 
		 * @param vidName unique string name of the video - comes from ProcessVideo
		 * contains the userID and a unique number like: 40002_484948449
		 */
		public function addToQueue(vidName:String):void
		{
			queue.push(vidName);
			saveQueue();
			
			//if it were > 1 the queue would already be uploading
			if (queue.length == 1) {
				uploadNext();
			}
		}
			
		
		/**
		 * waits 10 seconds before restarting the queue
		 */
		private function delayedRestart():void
		{
			debug("restarting queue - waiting 10 seconds");
			TweenMax.delayedCall(10, uploadNext);
		}
		
		
		/**
		 * Uploads the next video in the queue
		 */
		private function uploadNext():void
		{
			debug("starting video upload");
			
			videoLoader = videoFolder.resolvePath(queue[0] + ".mp4");
			debug("VIDEO:" + videoLoader.nativePath);
			
			videoLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
			videoLoader.addEventListener(Event.COMPLETE, doneUploading, false, 0, true);
			videoLoader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			videoLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false, 0, true);
			videoLoader.addEventListener(Event.OPEN, openHandler, false, 0, true);
			videoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			
			videoLoader.upload(new URLRequest(VIDEO_URL));			
		}
		
		private function httpStatusHandler(e:HTTPStatusEvent):void {
            debug("video httpStatusHandler: " + e.toString());
        }
		
		
		private function openHandler(e:Event):void {
            debug("video opened: " + e.toString());
        }
		
		
		private function securityErrorHandler(e:SecurityErrorEvent):void {
            debug("video securityErrorHandler: " + e.toString());
			
			if (queue.length > 0) {
				var badVid:String = queue.shift();
				queue.push(badVid); //stick error prone video onto end of queue
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
			
			if (queue.length > 0) {
				var badVid:String = queue.shift();
				queue.push(badVid); //stick error prone video onto end of queue
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
			queue.shift();//remove vid from queue
			saveQueue();
			if (queue.length > 0) {
				delayedRestart();
			}
		}

	}
	
}