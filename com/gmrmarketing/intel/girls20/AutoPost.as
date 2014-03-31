package com.gmrmarketing.intel.girls20
{
	import com.adobe.air.logging.FileTarget;	
	import com.gmrmarketing.utilities.AIRFile;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	
	public class AutoPost
	{
		private var airFile:AIRFile;
		private var fileList:Array;
		private var curFile:File;
		
		
		public function AutoPost()
		{
			airFile = new AIRFile();
		}
		
		public function check():void
		{
			fileList = airFile.getFiles("c:/intelgirls20/");			
			
			if (fileList.length > 0) {
				postNext();
			}
		}
		
		
		/**
		 * duplicated from Main.postToService()
		 */
		private function postNext():void
		{
			curFile = fileList.splice(0, 1)[0];
			var curOb:Object = airFile.getFile(curFile);
			
			//id,email,phone,country,optin
			var request:URLRequest = new URLRequest("http://intelgirls20.gmrstage.com/Home/Register");
			var poster:URLLoader = new URLLoader();
			
			//CAVEAT: IOErrorEvent.IO_ERROR will not be thrown when the format is set to URLLoaderDataFormat.VARIABLES
			//this is due to that constant being "variables" and not "VARIABLES" as it should be... bug
			//workaround is to just use the string "VARIABLES"
			poster.dataFormat = "VARIABLES";
			
			var variables:URLVariables = new URLVariables();
			
			variables.id = curOb.id;
			variables.email = curOb.email;
			variables.phone = curOb.phone;
			variables.country = curOb.country;
			variables.optin = curOb.optin;
			
			request.data = variables;
			request.method = URLRequestMethod.GET;
			
			poster.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			poster.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);			
			
			try{
				poster.load(request);
			}catch (e:Error) {
				dataError();
			}
		}
		
		
		private function dataPosted(e:Event = null):void
		{
			try{
				curFile.deleteFile();
			}catch (e:Error) {
				
			}
			
			if (fileList.length > 0) {
				postNext();
			}
		}
		
		
		private function dataError(e:IOErrorEvent = null):void
		{
			//do nothing on error
		}
	}
	
}