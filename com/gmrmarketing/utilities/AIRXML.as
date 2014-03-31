/**
 * AIR class
 * Reads and writes XML
 */

package com.gmrmarketing.utilities
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileStream; 
	import flash.filesystem.FileMode; 
	import flash.events.IOErrorEvent;
	
	
	public class AIRXML extends EventDispatcher
	{
		private var prefsFile:File;
		private var stream:FileStream;
		private var prefsXML:XML;
		
		public static const NOT_FOUND:String = "configFileNotFound";
		public static const SAVED:String = "configFileSaved";
		
	  
		public function AIRXML()
		{
			//prefsFile = File.desktopDirectory.resolvePath("config.xml");
			prefsFile = File.applicationDirectory.resolvePath("config.xml");
		}
		
		
		public function readXML():void
		{
			stream = new FileStream();
			stream.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			stream.addEventListener(Event.COMPLETE, fileOpened, false, 0, true);			
			stream.openAsync(prefsFile, FileMode.READ);	
		}

		
		private function fileOpened(e:Event):void
		{
			prefsXML = XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			dispatchEvent(new Event(Event.COMPLETE));			
		}
		
		
		public function getXML():XML
		{
			return prefsXML;
		}
		
		
		public function writeXML(theXML:XML):void
		{
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			outputString += theXML.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);

			stream = new FileStream();
			stream.open(prefsFile, FileMode.WRITE);

			stream.writeUTFBytes(outputString);

			stream.close();
			dispatchEvent(new Event(SAVED));
		}
		
		
		private function fileNotFound(e:IOErrorEvent):void
		{			
			dispatchEvent(new Event(NOT_FOUND));
			stream.close();
		}
	} 
}
