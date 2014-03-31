/**
 * Image Service
 * 
 * Queues images into the documents folder and sends to a web service
 * 
 * Images are optionally stored in a desktop folder
 * 
 * Usage:
 * 
		import com.gmrmarketing.utilities.ImageService;
		
		var is:ImageService = new ImageService();
		is.setServiceURL("http://myserviceurl");
		
		is.setSaveFolder("desktopFolderName"); //if you want to store all images sent to the service, on the desktop
		
		is.addToQueue(bitmapDataObject, "emailAddress@gmail.com");
 * 
 */

package com.gmrmarketing.utilities
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
	
	
	public class ImageService extends EventDispatcher
	{		
		public static const COMPLETE:String = "saveComplete";//dispatches when file is sent to server and server replies ok
		public static const ADDED:String = "fileAddedToQueue";//dispatches when a new file is added to the queue
		
		private var queue:Array; //current array of file names to be sent to the service
		private var imageString:String;	//base64 string of the current image	
		private var webService:String; //url of the service - set in setServiceURL()
		private var queueWait:Timer; //timer that calls refreshQueue every 30 seconds
		private var saveFolder:String;
		
		
		public function ImageService()
		{
			queue = new Array();
			
			queueWait = new Timer(30000);
			queueWait.addEventListener(TimerEvent.TIMER, refreshQueue, false, 0, true);
			
			URLRequestDefaults.idleTimeout = 300000; //5 min timeout
			
			saveFolder = "";
		}		
		
		
		/**
		 * Sets the service url that image and email data is sent
		 * Service is assumed to take a post request with two variables: base64 and email
		 * 
		 * Calls refreshQueue() to process any older items still remaining in the queue
		 * 
		 * @param	url
		 */
		public function setServiceURL(url:String):void
		{
			webService = url;
			refreshQueue();
		}
		
		
		/**
		 * Sets the desktop folder name that images are saved into
		 * This is a separate folder from the queue storage in the documents folder
		 * used for just saving any and all images for later viewing
		 * @param	f
		 */
		public function setSaveFolder(f:String):void
		{
			saveFolder = f;
		}
		
		
		/**
		 * Adds a new image and email to the queue
		 * 
		 * Image is first stored in the desktop folder before being queued
		 * images are only saved to the desktop if saveFolder has been defined in setSaveFolder()
		 * 
		 * @param	img BitmapData
		 * @param	em String - Email address
		 */
		public function addToQueue(img:BitmapData, em:String):void
		{
			var jpeg:ByteArray = getJpeg(img);
			
			if(saveFolder != ""){
				var a:Date = new Date();
				var fileName:String = "gmr_" + String(a.valueOf()) + ".jpg";
				var fl:File = File.desktopDirectory.resolvePath(saveFolder + fileName);
				var fs:FileStream = new FileStream();
				try{			
					fs.open(fl,FileMode.WRITE);				
					fs.writeBytes(jpeg);				
					fs.close();
				}catch(e:Error){
					trace(e.message);
				}
			}
			
			imageString = getBase64(jpeg);		
			
			writeObject( { image:imageString, email:em } );//write object to documents folder
			queueWait.reset();			
			refreshQueue();	
			dispatchEvent(new Event(ADDED));//added to the queue
		}
		
		
		/**
		 * Sends image to the webserver if there's data in the queue
		 * if the queue is empty the timer is started
		 */
		private function processQueue():void
		{			
			if (queue.length) {
				
				queueWait.reset(); //stop timer while processing
				
				var fName:String = queue[0];
				var file:File = File.documentsDirectory.resolvePath( fName );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				var ob:Object = stream.readObject();
				stream.close();
				file = null;
				stream = null;
					
				var vars:URLVariables = new URLVariables();
				vars.base64 = ob.image;
				vars.email = ob.email;
				
				var request:URLRequest = new URLRequest(webService);
				request.data = vars;
				request.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
				lo.addEventListener(IOErrorEvent.IO_ERROR, saveError, false, 0, true);
				
				try{
					lo.load(request);
				}catch (e:Error) {
					
				}
				
			}else {				
				//queue is empty... refresh it - calls refreshQueue() after 30 sec
				queueWait.reset();
				queueWait.start();
			}
		}		
		
	
		/**
		 * Called by listener when the file transfer is complete
		 * removes the file from the documents folder and then calls
		 * processQueue to start the next transfer
		 * 
		 * @param	e event.COMPLETE
		 */
		private function saveDone(e:Event):void
		{				
			var vars:URLVariables = new URLVariables(e.target.data);			
			var success = vars.ok;			
			if(success != "0"){
				//success!
				killFile(); //remove from documents folder		
				processQueue(); //send next object
			}else {
				//no success				
				processQueue();//just do the next file but don't delete the errored one... try again on next refresh
			}
			
			dispatchEvent(new Event(COMPLETE));
		}		
		
		
		/**
		 * Image saved - remove it from the queue and delete from the documents folder
		 */
		private function killFile():void
		{			
			var processedFile:String = queue.shift();
			var file:File = File.documentsDirectory.resolvePath( processedFile );
			file.deleteFile();
		}
		
		
		/**
		 * Called if an IO error occurs - removes current object from the queue
		 * and continues processing. Once the queue is empty the file will be re-tried
		 * when it's put back in the queue in refreshQueue()
		 * 
		 * @param	e
		 */
		private function saveError(e:IOErrorEvent):void
		{	
			queue.shift();
			processQueue();
		}
		
		
		/**
		 * Returns a JEG image from the incoming bitmapData
		 * @param	bmpd
		 * @param	q
		 * @return
		 */
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		/**
		 * Encodes the JPEG byteArray into a base64 string
		 * @param	ba
		 * @return
		 */
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		
		/**
		 * Writes the object to the documents directory
		 * Called from addToQueue
		 * @param	im - Object containing image and email properties
		 */
		private function writeObject(im:Object):void
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
		
		
		/**
		 * Called every 30 seconds by queueWait timer
		 * Pushes objects in the documents folder onto the queue, once the queue is empty
		 * 
		 * Initially called from setServiceURL() so any old items will be processed before
		 * calling addToQueue()
		 * 
		 * @param	e
		 */
		private function refreshQueue(e:TimerEvent = null):void
		{	
			if (queue.length == 0) {
				
				var file:File = File.documentsDirectory; 
				var allFiles:Array = file.getDirectoryListing();//array of file objects				
				
				for (var i = 0; i < allFiles.length; i++) {				
					if (String(allFiles[i].name).substr(0, 4) == "img_") {
						queue.push(allFiles[i].name);
					}
				}
				
				processQueue();
			}
		}
	}
	
}