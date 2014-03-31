package com.gmrmarketing.bicycle
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	
	
	public class SWFKitFiles
	{
		public function SWFKitFiles() { }
		
		
		/**
		 * Returns a list of files in the images folder
		 * @return Array of files
		 */
		public function getFiles():Array
		{
			return ExternalInterface.call("getFilesInFolder");
		}
		
		
		/**
		 * Saves theFile into the images folder
		 * @param	theFile Base64 encoded ByteArray
		 * @param   theName
		 */
		public function saveFile(theFile:String, theName:String):void
		{			
			ExternalInterface.call("saveFile", theFile, theName);
		}
		
		
		/**
		 * Returns a base64 encoded string
		 * @param	theName - full file name with extension
		 */
		public function readFile(theName:String):String
		{			
			return ExternalInterface.call("getFile", theName);
		}
		
		
		public function removeFile(theName:String):Boolean
		{
			return ExternalInterface.call("removeFile", theName);
		}
		
		
		public function saveFormData(theFile:String, theData:Array):void
		{			
			ExternalInterface.call("saveFormData", theFile, theData);			
		}
	
		
	}
	
}