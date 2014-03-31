package com.gmrmarketing.holiday2012
{
	import flash.display.BitmapData;
	import flash.events.*;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPEGEncoder;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.utils.Timer;
	import flash.filesystem.*; //for saving images to the local filesystem
	
	
	public class WebServices extends EventDispatcher
	{		
		public static const COMPLETE:String = "saveComplete";
		public static const ADDED:String = "fileAddedToQueue";
		
		private var queue:Array;
		private var imageString:String;		
		private var webService:String;
		private var queueWait:Timer;
		
		public function WebServices()
		{
			queue = new Array();
			
			queueWait = new Timer(30000);
			queueWait.addEventListener(TimerEvent.TIMER, refreshQueue, false, 0, true);
			
			URLRequestDefaults.idleTimeout = 300000; //5 min timeout
		}		
		
		
		public function setServiceURL(url:String):void
		{
			webService = url;
		}
		
		/**
		 * Called from Main.processImage()
		 * saves a jpeg to the desktop and readies imageString for sending 
		 * to the web service
		 * @param	img
		 */
		public function processImage(img:BitmapData):void
		{
			var jpeg:ByteArray = getJpeg(img);
			
			var a:Date = new Date();
			var fileName:String = "gmr_" + String(a.valueOf()) + ".jpg";
			var fl:File = File.desktopDirectory.resolvePath("gmr_holiday/" + fileName);
			var fs:FileStream = new FileStream();
			try{			
				fs.open(fl,FileMode.WRITE);				
				fs.writeBytes(jpeg);				
				fs.close();
			}catch(e:Error){
				trace(e.message);
			}
			
			imageString = getBase64(jpeg);	
			//queueImage("
		}
		
		
		/**
		 * Called from Main.submitClicked() when the user submits
		 * their email address
		 * @param	em
		 */
		public function queueImage(em:String):void
		{			
			//trace("queueImage() - reset queueWait timer");
			writeImage( { image:imageString, email:em } );
			queueWait.reset();			
			refreshQueue();	
			dispatchEvent(new Event(ADDED));//added to the queue
		}
		
		
		private function processQueue():void
		{
			//trace("processQueue()");
			if (queue.length) {
				//trace("processQueue() - queue.length:", queue.length);
				var fName:String = queue[0];
				var file:File = File.documentsDirectory.resolvePath( fName );
				//trace(file.name);
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				var ob:Object = stream.readObject();
				stream.close();
				file = null;
				stream = null;
					
				var vars:URLVariables = new URLVariables();
				vars.base64 = ob.image;
				vars.email = ob.email;	
				//trace("emailing:",ob.email);
				
				var request:URLRequest = new URLRequest(webService);
				request.data = vars;			
				request.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, saveError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
				lo.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpError, false, 0, true);
				
				try{
					lo.load(request);
				}catch (e:Error) {
					
				}
			}else {
				//trace("processQueue() - length 0 - starting queueWait timer");
				//queue is empty... refresh it - calls refreshQueue after 30 sec				
				queueWait.start();
			}
		}
		
		private function httpError(e:HTTPStatusEvent):void
		{
			//trace("httpError()", e.toString());
		}

		private function saveDone(e:Event):void
		{	
			//trace("saveDone()", e.toString());
			var vars:URLVariables = new URLVariables(e.target.data);			
			var success = vars.ok;			
			if(success != "0"){
				
				killFile();
				//trace("saveDone() - success:",success," deleting", file.name);
				
				//do another
				processQueue();
			}else {
				killFile();
				processQueue();
			}
			dispatchEvent(new Event(COMPLETE));
		}		
		
		private function killFile():void
		{
			//image saved - remove it from the queue and folder
			var processedFile:String = queue.shift();
			var file:File = File.documentsDirectory.resolvePath( processedFile );
			file.deleteFile();
		}
		
		/**
		 * try sending again if a send error occurred
		 * @param	e
		 */
		private function saveError(e:IOErrorEvent):void
		{	
			killFile();
			processQueue();
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		
		
		
		//FILE STUFF
		
		public function writeImage(im:Object):void
		{
			var a:Date = new Date();
			var fileName:String = "img_" + String(a.valueOf()) + ".img";			
			
			try{
				var file:File = File.documentsDirectory.resolvePath( fileName );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeObject( im );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				
			}
		}		
		
		
		
		public function refreshQueue(e:TimerEvent = null):void
		{		
			//trace("refreshQueue()");
			if (queue.length == 0) {
				//trace("refreshQueue() - length: 0");
				var file:File = File.documentsDirectory; 
				var allFiles:Array = file.getDirectoryListing();//array of file objects
				
				//queue = new Array();
				for (var i = 0; i < allFiles.length; i++) {				
					if (String(allFiles[i].name).substr(0, 4) == "img_") {
						queue.push(allFiles[i].name);
					}
				}
				
				//trace("refreshQueue() - length:", queue.length);
				
				processQueue();
			}
		}
	}
	
}