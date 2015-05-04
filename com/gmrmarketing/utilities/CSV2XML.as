package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	
	public class CSV2XML extends MovieClip
	{
		private var theData:Array;		
		private var userFile:File;
		
		
		public function CSV2XML()
		{
			btnOpen.addEventListener(MouseEvent.MOUSE_DOWN, open);
		}
		
		
		public function open(e:MouseEvent):void
		{			
			var fileToOpen:File = new File();
			var filter:FileFilter = new FileFilter("CSV", "*.csv");
			try{
				fileToOpen.browseForOpen("Open", [filter]);
				fileToOpen.addEventListener(Event.SELECT, fileSelected, false, 0, true);
			}catch (e:Error){
				trace("error:", e.message);
			}
		}
		
		
		private function fileSelected(e:Event):void 
		{
			userFile = File(e.target);
			var stream:FileStream = new FileStream();
			stream.open(userFile, FileMode.READ);
			
			var dataString:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			
			theData = dataString.split(/\r\n|\n|\r/);//split on line breaks
			theData.pop();//remove last item
			
			for (var i:int = 0; i < theData.length; i++){
				var row:Array = theData[i].split("|");
				theData[i] = {account: row[0], category: row[1], address: row[2], city: row[3], state:row[4], zip:row[5], phone:row[6], region:row[7], tollfree:row[8], website:row[9], latitude:row[10], longitude:row[11], listing:row[12]};
			}			
			
			var xmlStr:String = "<myxml>"
			for (var u:int = 0; u < theData.length; u++){
				xmlStr += "<business>";
				xmlStr += "<name>" + theData[u].account + "</name>";
				xmlStr += "<category>" + theData[u].category + "</category>";
				xmlStr += "<address>" + theData[u].address + "</address>";
				xmlStr += "<city>" + theData[u].city + "</city>";
				xmlStr += "<state>" + theData[u].state + "</state>";
				xmlStr += "<zip>" + theData[u].zip + "</zip>";
				xmlStr += "<phone>" + theData[u].phone + "</phone>";
				xmlStr += "<region>" + theData[u].region + "</region>";
				xmlStr += "<tollfree>" + theData[u].tollfree + "</tollfree>";
				xmlStr += "<website>" + theData[u].website + "</website>";
				xmlStr += "<latitude>" + theData[u].latitude + "</latitude>";
				xmlStr += "<longitude>" + theData[u].longitude + "</longitude>";
				xmlStr += "<listing>" + theData[u].listing + "</listing>";
				xmlStr += "</business>";
			}
			xmlStr += "</myxml>"
			
			var myXml:XML = new XML(xmlStr);
			tr
			trace(myXml);
		}
	}
	
}