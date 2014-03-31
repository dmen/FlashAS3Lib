/**
 * 
 * Folder watcher - watches a folder for a specific file
 * Checks every second - once the file is found a FILE_FOUND
 * event will be dispatched each second until the file is either
 * no longer there, or you call stopWatching()
 * 
 * Basic usage:
	
	var f:FolderWatcher = new FolderWatcher();
	f.addEventListener(FolderWatcher.FILE_FOUND, found, false, 0, true);
	f.setFolder("c:\\someFolder");
	f.setWatchFile("some.xml");
	f.startWatching();
	
 * 
 */

package com.gmrmarketing.utilities
{
	import flash.events.*;
	import flash.net.FileFilter;
	import flash.utils.Timer;
	import flash.filesystem.*; 
	
	
	public class FolderWatcher extends EventDispatcher
	{
		public static const FILE_FOUND:String = "watchFileFound";
		
		private var file:File; //watch folder		
		private var watchTimer:Timer;
		private var watchFor:String; //string of the file name to watch for
		
		
		public function FolderWatcher()
		{
			file = new File();			
			watchTimer = new Timer(1000);
			watchTimer.addEventListener(TimerEvent.TIMER, checkFolder);
		}
		
		
		/**
		 * Sets the folder to be watched
		 * 
		 * @param	f String - folder name like "C:\\AIR Test\";
		 */
		public function setFolder(f:String):void
		{			
			file.nativePath = f;
		}
		
		
		/**
		 * Returns the folder being watched
		 * @return
		 */
		public function getFolder():String
		{
			return file.nativePath;
		}
		
		
		/**
		 * Sets the file name to watch for
		 * @param	f
		 */
		public function setWatchFile(f:String):void
		{
			watchFor = f;
		}
		
		
		/**
		 * Returns the name of the file being watched for
		 * @return
		 */
		public function getWatchFile():String
		{
			return watchFor;
		}
		
		
		/**
		 * Starts watching the folder
		 */
		public function startWatching():void
		{
			watchTimer.start();
		}
		
		
		/**
		 * Stops watching the folder
		 */
		public function stopWatching():void
		{
			watchTimer.reset();
		}
		
		
		/**
		 * Called by timer event
		 * Dispatches a FILE_FOUND if the watch for file was found in the folder
		 * @param	e
		 */
		private function checkFolder(e:TimerEvent):void
		{
			for each (var f:File in file.getDirectoryListing()){			
				if (f.name == watchFor) {					
					dispatchEvent(new Event(FILE_FOUND));
				}
			}
		}
		
	}
	
}