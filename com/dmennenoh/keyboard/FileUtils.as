/**
 * AIR File utilities to load/save XML
 */
package com.dmennenoh.keyboard
{	
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	
	
	public class FileUtils extends EventDispatcher
	{
		public static const FILE_OPENED:String = "newFileOpened";
		private var theXML:XML;		
		private var userFile:File;
		
		
		public function FileUtils(){}
		
		
		/**
		 * Calls browseForOpen to show a open file dialog
		 * where the use can select a XML file
		 */
		public function open():void
		{			
			var fileToOpen:File = new File();
			var filter:FileFilter = new FileFilter("XML", "*.xml");
			try{
				fileToOpen.browseForOpen("Open", [filter]);
				fileToOpen.addEventListener(Event.SELECT, fileSelected, false, 0, true);
			}catch (e:Error){
				trace("error:", e.message);
			}
		}
		
		
		/**
		 * Calls browseForSave to show a save as dialog
		 * where the user can save the editied XML
		 * @param	file XML to save
		 */
		public function save(file:XML):void
		{
			theXML = file;
			userFile = new File();
			try{
				userFile.browseForSave("Save As");
				userFile.addEventListener(Event.SELECT, doWrite, false, 0, true);
			}catch (e:Error) {
				trace("error:", e.message);
			}
			//doWrite();
		}
		
		
		/**
		 * Returns the XML file
		 * @return
		 */
		public function getFile():XML
		{
			return theXML;
		}
		
		
		/**
		 * Callback from browseForOpen called in open()
		 * Reads the XML into theXML
		 * @param	e Event SELECT
		 */
		private function fileSelected(e:Event):void 
		{
			userFile = File(e.target);
			var stream:FileStream = new FileStream();
			stream.open(userFile, FileMode.READ);
			theXML = new XML(stream.readUTFBytes(stream.bytesAvailable));
			stream.close();
			dispatchEvent(new Event(FILE_OPENED));
		}
		
		
		/**
		 * Callback from browseForSave called in save()
		 * Writes the XML to the user selected File
		 * @param	e Event SELECT
		 */
		private function doWrite(e:Event):void
		{
			var outputString:String = '<?xml version="1.0" encoding="utf-8"?>\n';
			outputString += theXML.toXMLString();
			outputString = outputString.replace(/\n/g, File.lineEnding);

			var stream:FileStream = new FileStream();
			try{
				stream.open(userFile, FileMode.WRITE);				
				stream.writeUTFBytes(outputString);
			}catch (e:Error) {
				trace("error:", e.message);
			}

			stream.close();
		}
		
	}
	
}