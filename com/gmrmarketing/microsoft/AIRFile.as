package com.gmrmarketing.microsoft
{	
	import com.adobe.air.logging.FileTarget;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	
	public class AIRFile extends EventDispatcher
	{		
		public static const NEW_IMAGE_IN_FOLDER:String = "newImagePlacedInFolder";
		
		private var basePath:String;
		private var camSavePath:String;
		private var monitorTimer:Timer; //for calling checkFolder() at every interval
		private var beenChecked:Boolean; //flag for first time file count check
		private var fileCount:int;
		private var latestFile:String;
		
		
		public function AIRFile() { }
		
		
		/**
		 * Must be called before writeImage or writeCSV
		 * @param	s
		 */
		public function setBasePath(s:String):void
		{
			basePath = s;
		}
		
		
		public function setCameraSavePath(s:String):void
		{
			camSavePath = s;
		}
		
		
		public function startMonitoringCameraFolder():void
		{
			beenChecked = false;
			fileCount = 0;
			
			monitorTimer = new Timer(1000);
			monitorTimer.addEventListener(TimerEvent.TIMER, checkFolder, false, 0, true);
			monitorTimer.start();
		}
		
		
		public function writeImage(folderName:String, fileName:String, ba:ByteArray):void
		{
			var targetDir:File = new File(basePath + folderName);		
			targetDir.createDirectory();		
			
			var targetFile:File = targetDir.resolvePath(fileName);			
			var fs:FileStream = new FileStream();			
			
			try {				
				fs.open(targetFile, FileMode.WRITE);
				fs.writeBytes(ba);
				fs.close();
			}catch (e:Error){				
				trace(e);
			}			
		}
		
		
		
		public function writeCSV(newDataLine:String):void
		{
			var targetDir:File = new File(basePath);		
			targetDir.createDirectory();
			
			newDataLine += File.lineEnding;
			
			var targetFile:File = targetDir.resolvePath("interactions.txt");
			var fs:FileStream = new FileStream();	
			
			try {				
				fs.open(targetFile, FileMode.APPEND);								
				fs.writeMultiByte(newDataLine, "utf-8");
				fs.close();
			}catch (e:Error) {
				trace(e);
			}			
		}
		
		
		
		public function readLines():Array 
		{			
			var lines:Array = new Array();
			
			var targetDir:File = new File(basePath);
			var targetFile:File = targetDir.resolvePath("interactions.txt");
			var fileStream:FileStream = new FileStream();			
			fileStream.open(targetFile, FileMode.READ);						
			
			var str:String = fileStream.readMultiByte(targetFile.size, "utf-8");
			//str = str.replace(/\r\n/g, "=");
			lines = str.split("\r\n");
			
			fileStream.close();			
			return lines;
		}
		
		public function readLog():Array 
		{			
			var lines:Array = new Array();
			
			var targetDir:File = new File(basePath);
			var targetFile:File = targetDir.resolvePath("emaillog.txt");
			var fileStream:FileStream = new FileStream();			
			fileStream.open(targetFile, FileMode.READ);						
			
			var str:String = fileStream.readMultiByte(targetFile.size, "utf-8");
			//str = str.replace(/\r\n/g, "=");
			lines = str.split("\r\n");
			
			fileStream.close();			
			return lines;
		}
		
		
		/**
		 * Deletes all files in the monitored camera save folder
		 */
		public function deleteFiles():void
		{
			var f:File;
			var targetDir:File = new File(camSavePath);
			//array of file objects
			var list:Array = targetDir.getDirectoryListing();
			while (list.length) {				
				f = list.splice(0, 1)[0];
				f.deleteFile();
			}
			fileCount = 0;
		}
		
		
		/**
		 * Returns the URL of the latest image file found in checkFolder()
		 * @return
		 */
		public function getLatestImage():String
		{
			return latestFile;
		}
		
		
		/**
		 * Called by monitorTimer - timer event
		 * @param	e
		 */
		private function checkFolder(e:TimerEvent):void
		{
			var targetDir:File = new File(camSavePath);
			//array of file objects
			var list:Array = targetDir.getDirectoryListing();
			
			var sorted:Array = new Array();
			var inserted:Boolean;
			
			var f:File;
			if (list.length > 0) {
				f = list.splice(0, 1)[0];
				sorted.push(f);
			}			
			
			while (list.length) {
				
				f = list.splice(0, 1)[0];
				inserted = false;
				
				for (var i:int = 0; i < sorted.length; i++) {
					if (f.creationDate < sorted[i].creationDate) {
						sorted.splice(i, 0, f);
						inserted = true;
						break;
					}
				}
				if (!inserted) {
					sorted.push(f);
				}
				
			}
			
			if (!beenChecked) {
				//first time checking store the initial file count
				fileCount = sorted.length;
				beenChecked = true;
			}			
			
			if (sorted.length > fileCount) {				
				fileCount = sorted.length;
				//new file added to the folder
				latestFile = sorted[sorted.length - 1].url;
				var lf:String = latestFile.toLowerCase();
				//make sure it's a jpg image
				if (lf.substr(lf.length - 3) == "jpg"){				
					dispatchEvent(new Event(NEW_IMAGE_IN_FOLDER));
				}
			}			
			
		}
	}
	
}