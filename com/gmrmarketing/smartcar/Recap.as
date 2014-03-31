package com.gmrmarketing.smartcar
{
	import flash.display.MovieClip;
	import com.gmrmarketing.smartcar.*;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.net.*;
	import flash.filesystem.*;
	import com.gmrmarketing.utilities.AIRFile;
	import com.gmrmarketing.utilities.Utility;
	
	public class Recap extends MovieClip
	{
		private var airFile:AIRFile;
		private var items:Array; //array of file objects from AIRFile
		private var curIndex:int;
		private var userData:Object; //current file object 		
		
		public function Recap()
		{
			airFile = new AIRFile();
			errMessage.text = "";
			
			init();
		}
	
		
		private function init():void
		{			
			items = airFile.getFiles(StaticData.LOCAL_SAVE_PATH);
			
			theText.text = "There are " + items.length + " records that need to be uploaded";
			
			if (items.length > 0) {
				btnUpload.alpha = 1;
				btnUpload.addEventListener(MouseEvent.CLICK, beginUpload, false, 0, true);				
			}else {
				btnUpload.alpha = .3;				
			}
			
			btnCancel.addEventListener(MouseEvent.CLICK, stopProcessing, false, 0, true);
		}
		
		
		private function beginUpload(e:MouseEvent):void
		{			
			btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload); //disable upload button
			btnUpload.alpha = .3;
			
			curIndex = 1;
			processNextFile();			
		}
		
		
		private function processNextFile():void
		{			
			theText.text = "Uploading record: " + String(curIndex);
			curIndex++;
			if (items.length > 0) {
				
				errMessage.text = "uploading image...";
				
				var userFile:File = items.shift(); //one file object
				userData = airFile.getFile(userFile);
				
				//Utility.iterateObject(userData);
				
				var variables:URLVariables = new URLVariables();	
				variables.eventId = userData.eventId;
				variables.imagebuffer = userData.imagebuffer; //base64 encoded image
				variables.tracks = userData.tracks;
				variables.vid = userData.vid;
				variables.license = userData.license;
				
				var request:URLRequest = new URLRequest(StaticData.POST_PHOTO_URL);
				request.data = variables;				
				request.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.dataFormat = URLLoaderDataFormat.VARIABLES;
				lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, saveCarDone, false, 0, true);
				try{
					lo.load(request);
				}catch (e:Error) {
					trace("catch error", e);
				}
				
			}else {
				finishedProcessing();
			}
		}

		
		
		/**
		 * IOError
		 * @param	e
		 */
		private function sendError(e:IOErrorEvent):void
		{	
			errMessage.text = "Error: " + e.text;			
			stopProcessing();
		}
		
		
		/**
		 * Pressed cancel upload 
		 * @param	e
		 */
		private function stopProcessing(e:MouseEvent = null):void
		{
			init();
		}
		
		
		/**
		 * Record car data complete
		 * save form data
		 * @param	e
		 */
		private function saveCarDone(e:Event):void
		{
			var vars:URLVariables = new URLVariables(e.target.data);			
			var postResponse:String = vars.success; //either "false" or the ID of this saved data to pass to the form request registrantID field
			
			if (postResponse != "false") {
				errMessage.text = "image uploaded, posting form data";
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, saveFormDone, false, 0, true);
				
				var request:URLRequest = new URLRequest(StaticData.POST_FORM_URL);
				request.method = URLRequestMethod.POST;
				
				var formArray:Array = new Array();
				if (userData.formData != null) {
					formArray = userData.formData;
				}
				
				formArray[7] = "registrantId: '" + postResponse + "'"
				request.data =  " { " + formArray + " } ";
				
				lo.load(request);
				
			}else {
				stopProcessing();				
			}
		}
		
		
		private function saveFormDone(e:Event):void
		{
			processNextFile();
		}
		
		
		/**
		 * Called when all items have been uploaded
		 */
		private function finishedProcessing():void
		{
			userData = null;			
			errMessage.text = "Uploading Complete";
			airFile.deleteFiles(StaticData.LOCAL_SAVE_PATH);
			init();
		}
	}
	
}