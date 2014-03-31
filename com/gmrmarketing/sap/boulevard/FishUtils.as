/**
 * 
 * SAP superbowl boulevard
 * FISH utils
 * 
 * Watches a folder for visitor.json
 * Allows writing session.json to the watch folder
 * 
 */

package com.gmrmarketing.sap.boulevard
{
	import com.gmrmarketing.utilities.FolderWatcher;
	import flash.events.*;
	import flash.filesystem.*; 	
	
	
	public class FishUtils extends EventDispatcher
	{
		public static const NEW_VISITOR:String = "visitorJsonFound";
		//{"tag_id":"A PROBLEM OCCURED WHILE COMMUNICATING WITH THE READER: RFIDME"}
		public static const VISITOR_ERROR:String = "errorInTheJSON";
		private var watcher:FolderWatcher;
		private var theJSON:Object;
		private var stream:FileStream;
		
		
		public function FishUtils()
		{
			watcher = new FolderWatcher();			
		}
		
		
		public function init():void
		{
			watcher.addEventListener(FolderWatcher.FILE_FOUND, found, false, 0, true);
			watcher.setFolder("c:\\Fish");
			watcher.setWatchFile("visitor.json");
			watcher.startWatching();
			
			//Fish wants epoch time in seconds - not ms
			var epochSeconds:int = Math.floor(new Date().valueOf() / 60);
			
			//write initial session.json at app start to start Fish software
			writeSession( {"timestamp":epochSeconds, "session_id":"avatar"} ); //write initial session.json
		}
		
		
		
		/**
		 * Called when visitor.json is found in the watch folder
		 * Opens and reads the file
		 * @param	e
		 */
		private function found(e:Event):void
		{			
			var file:File = new File();
			file.nativePath = watcher.getFolder();
			file = file.resolvePath(watcher.getWatchFile());
			
			stream = new FileStream();			
			stream.addEventListener(Event.COMPLETE, fileOpened, false, 0, true);			
			stream.openAsync(file, FileMode.READ);	
		}
		
		
		/**
		 * Called when visitor.json is opened and ready for reading
		 * Reads the file
		 * dispatches a NEW_VISITOR event
		 * call getVisitor() to retrieve the json
		 * @param	e
		 */
		private function fileOpened(e:Event):void
		{
			theJSON = JSON.parse(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			if (String(theJSON.tag_id).substr(0, 9) == "A PROBLEM") {
				watcher.stopWatching();
				dispatchEvent(new Event(VISITOR_ERROR));
			}else {
				watcher.stopWatching();
				dispatchEvent(new Event(NEW_VISITOR));
			}			
		}
		
		/**
		 * Deletes visitor.json from the watch folder
		 * if it exists
		 */
		/*
		public function deleteVisitor():void
		{
			var file:File = new File();
			file.nativePath = watcher.getFolder();
			file = file.resolvePath(watcher.getWatchFile());
			if(file.exists){
				file.deleteFile();
			}
		}
		*/
		/**
		 * Call this to return the read JSON
		 * Call after getting the NEW_VISITOR event
		 * keys contained in the json: tag_id
		 * @return RFID tag id
		 */
		public function getVisitorID():String
		{
			return theJSON.tag_id;
		}
		
		public function startWatching():void
		{
			watcher.startWatching();
		}
		
		/**
		 * Writes session.json to the watch folder
		 * Deletes visitor.json
		 * @param	sessionData standard object with key/value pairs
		 */
		public function writeSession(sessionData:Object, deleteVisitor:Boolean = true):void
		{		
			var output:String = JSON.stringify(sessionData);

			stream = new FileStream();
			
			var file:File = new File();
			file.nativePath = watcher.getFolder();
			file = file.resolvePath("session.json");
			
			stream.open(file, FileMode.WRITE);

			stream.writeUTFBytes(output);

			stream.close();
			
			if(deleteVisitor){
				//delete visitor.json
				file = new File();
				file.nativePath = watcher.getFolder();
				file = file.resolvePath(watcher.getWatchFile());
				if(file.exists){
					file.deleteFile();
				}
			}
			
			watcher.startWatching();
		}		
		
	}
	
}