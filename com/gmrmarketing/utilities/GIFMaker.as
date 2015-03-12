package com.gmrmarketing.utilities
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import org.bytearray.gif.encoder.GIFEncoder;
	import flash.filesystem.*;
	
	public class GIFMaker extends EventDispatcher
	{
		private var frameObject:DisplayObjectContainer;
		private var frame:BitmapData;
		private var frames:Vector.<BitmapData>;
		private var encoder:GIFEncoder;
		private var frameIndex:int;
		
		public function GIFMaker(w:int, h:int)
		{	
			encoder = new GIFEncoder();
		}	
		
			
		public function start(listenTo:DisplayObjectContainer):void
		{
			frames = new Vector.<BitmapData>();
			frameIndex = 0;
			frameObject = listenTo;
			frameObject.addEventListener(Event.ENTER_FRAME, addFrame);
		}
		
		
		public function addFrame(e:Event):void
		{
			frameIndex++;
			if(frameIndex % 5 == 0){
				frame = new BitmapData(300,250);
				frame.draw(frameObject);
				frames.push(frame);
			}
		}
		
		
		public function finish():void
		{
			frameObject.removeEventListener(Event.ENTER_FRAME, addFrame);
			trace("frames captured:", frames.length);
			gifBegin();
		}
		
		
		private function gifBegin():void
		{
			encoder.setRepeat(0);
			encoder.setDelay(33);
			encoder.setQuality(24);
			encoder.setFrameRate(12);
			encoder.start();
			addAFrame();
		}
		
		
		private function addAFrame():void
		{
			while (frames.length > 0) {
				trace("remaining:", frames.length);
				encoder.addFrame(frames.shift());
			}
			
			encoder.finish();
			var gif:ByteArray = encoder.stream;
			
			var file:File = File.documentsDirectory;
			file = file.resolvePath("test.gif");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(gif);
			fileStream.close();
			
			trace("complete");			
		}		
		
	}	
	
}