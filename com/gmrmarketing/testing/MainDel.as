package com.gmrmarketing.testing
{
	import flash.display.*;
	import com.gmrmarketing.utilities.FolderWatcher;
	import flash.events.*;
	import flash.filesystem.*; 	
	
	public class MainDel extends MovieClip
	{
		private var fw:FolderWatcher;
		private var theJSON:Object;
		private var stream:FileStream;
		
		
		public function MainDel()
		{
			fw = new FolderWatcher();
			fw.addEventListener(FolderWatcher.FILE_FOUND, found, false, 0, true);
			fw.setFolder("c:\\test");
			fw.setWatchFile("visitor.json");
			fw.startWatching();
		}
		
		private function found(e:Event):void
		{			
			var file:File = new File();
			file.nativePath = fw.getFolder();
			file = file.resolvePath(fw.getWatchFile());
			
			stream = new FileStream();
			//stream.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			stream.addEventListener(Event.COMPLETE, fileOpened, false, 0, true);			
			stream.openAsync(file, FileMode.READ);	
		}
		
		
		private function fileOpened(e:Event):void
		{
			theJSON = JSON.parse(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			
			//delete
			var file:File = new File();
			file.nativePath = fw.getFolder();
			file = file.resolvePath(fw.getWatchFile());
			file.deleteFile();			
			
			writeSession( { session_id:46, timestamp:484849494 } );
		}
		
		
		public function writeSession(sessionData:Object):void
		{			
			var output:String = JSON.stringify(sessionData);

			stream = new FileStream();
			var file:File = new File();
			file.nativePath = fw.getFolder();
			file = file.resolvePath("session.json");
			
			stream.open(file, FileMode.WRITE);

			stream.writeUTFBytes(output);

			stream.close();			
		}
	}
	
}