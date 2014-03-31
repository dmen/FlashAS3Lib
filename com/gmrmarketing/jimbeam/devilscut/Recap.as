package com.gmrmarketing.jimbeam.devilscut
{	
	import com.gmrmarketing.utilities.SharedObjectWrapper;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.utils.getTimer;
	
	
	
	public class Recap
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var so:SharedObjectWrapper;
		private var items:Array;
		private var curIndex:int;
		private var userData:Object;
		
		
		public function Recap()
		{
			clip = new recap(); //library clip
			
			so = new SharedObjectWrapper();
			clip.errMessage.text = "";			
		}
		
		
		public function show($container:DisplayObjectContainer = null):void
		{
			if($container != null){
				container = $container;
				if(!container.contains(clip)){
					container.addChild(clip);
				}
			}
			
			curIndex = -1;
			items = so.getData(); //array of objects			
			clip.theText.text = "There are " + items.length + " records that need to be uploaded";
			
			if (items.length > 0) {
				clip.btnUpload.alpha = 1;
				clip.btnUpload.addEventListener(MouseEvent.CLICK, beginUpload, false, 0, true);				
			}else {
				clip.btnUpload.alpha = .3;				
			}
			
			clip.btnCancel.addEventListener(MouseEvent.CLICK, cancelPressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload);
			clip.btnCancel.removeEventListener(MouseEvent.CLICK, stopProcessing);
		}		
		
		
		private function beginUpload(e:MouseEvent):void
		{			
			clip.btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload); //disable upload button
			clip.btnUpload.alpha = .3;
			
			curIndex = -1;
			processNextFile();			
		}
		
		
		private function processNextFile():void
		{
			curIndex++;
			clip.theText.text = "Uploading record: " + String(curIndex + 1);
			if(items.length > 0) {
				
				userData = items.shift();
				
				var request:URLRequest = new URLRequest("http://dservices.mangoapi.com/devilscut/capture.php?r=" + String(getTimer()) );
				
				var vars:URLVariables = new URLVariables();
				vars.thename = userData.name;
				vars.theemail = userData.email;
				vars.birthdate = userData.birthDate;
				vars.mobile = userData.mobile;
				vars.insweeps = userData.inSweeps == true ? "true" : "false";
				vars.optin = userData.optin;	
				vars.s1 = userData.s1;
				vars.s2 = userData.s2;
				vars.s3 = userData.s3;
				request.data = vars;
				request.method = URLRequestMethod.POST;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
				lo.load(request);
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
			if (String(e.text).indexOf("2032")) {
				clip.errMessage.text = "Error: Check Internet Connection";
			}else{
				clip.errMessage.text = "Error: " + e.text;
			}
			stopProcessing();
		}
		
		
		private function cancelPressed(e:MouseEvent):void
		{
			if(userData != null){
				items.push(userData);
				so.setData(items);
			}
			hide();
		}
		
		
		/**
		 * Pressed cancel upload 
		 * @param	e
		 */
		private function stopProcessing(e:MouseEvent = null):void
		{	
			if(userData != null){
				items.push(userData);
				so.setData(items);
			}
			show();
		}
		
		
		/**
		 * Record upload complete
		 * @param	e
		 */
		private function saveDone(e:Event):void
		{
			if (e.target.data == false) {
				clip.errMessage.text = "An error occured";
				stopProcessing();
			}else{
				processNextFile();
			}
		}
		
		
		/**
		 * Called when all items have been uploaded
		 */
		private function finishedProcessing():void
		{
			userData = null;
			clip.errMessage.text = "Uploading Complete";			
			show();
		}
	}
	
}