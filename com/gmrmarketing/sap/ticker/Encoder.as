package com.gmrmarketing.sap.ticker
{
	import flash.display.*;
	import flash.events.*;
	import leelib.util.flvEncoder.*;
	import flash.filesystem.*;
	
	
	public class Encoder extends EventDispatcher
	{
		private var myFile:File;
		private var fsFlvEncoder:FileStreamFlvEncoder;
		private var width:int;
		private var height:int;
		
		public function Encoder(w:int, h:int )
		{
			width = w; height = h;
		}		
		
		/**
		 * Starts recording to the flv in fileName
		 * @param	fileName
		 */
		public function record(fileName:String = "video.flv"):void
		{
			myFile = File.documentsDirectory.resolvePath(fileName);
			fsFlvEncoder = new FileStreamFlvEncoder(myFile, 30); //30 is framerate
			fsFlvEncoder.fileStream.openAsync(myFile, FileMode.UPDATE);
			fsFlvEncoder.setVideoProperties(height, width);//final flv resolution
			//fsFlvEncoder.setAudioProperties(BaseFlvEncoder.SAMPLERATE_44KHZ, true, false, true);
			fsFlvEncoder.start();
		}		
		
		public function addFrame(bmd:BitmapData):void
		{
			fsFlvEncoder.addFrame(bmd, null);
			//fsFlvEncoder.addFrame(myBitmapData, myAudioByteArray); // etc.
			
		}
		
		public function stop():void
		{
			fsFlvEncoder.updateDurationMetadata();
			fsFlvEncoder.fileStream.close();
			fsFlvEncoder.kill();
		}		
	}	
}