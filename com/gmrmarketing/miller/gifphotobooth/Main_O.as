package com.gmrmarketing.miller.gifphotobooth
{
	import com.gmrmarketing.bcbs.findyourbalance.PointsDisplay;
	import flash.filesystem.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.gmrmarketing.utilities.CamPicFilters;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import org.bytearray.gif.encoder.GIFEncoder;
	
	
	public class Main_O extends MovieClip 
	{
		private const EVERY_NTH:int = 10; //capture every n frames
		private const MAX_FRAMES:int = 15;
		private var camPic:CamPic;
		private var camContainer:Sprite;
		private var bmd:BitmapData;
		private var frames:Array;
		private var encoder:GIFEncoder;
		private var frameCount:int;
		
		public function Main_O()
		{	
			camContainer = new Sprite();
			addChild(camContainer);
			camContainer.x = 100;
			camContainer.y = 100;
			
			encoder = new GIFEncoder();
			
			camPic = new CamPic();
			camPic.init(320, 240, 0, 0, 0, 0, 15); //set camera, capture and display
			camPic.show(camContainer);
			//camPic.addFilter(CamPicFilters.gray());
			
			prog.scaleX = 0;
			
			btn.addEventListener(MouseEvent.MOUSE_DOWN, startRecording);
		}
		
		
		private function startRecording(e:MouseEvent):void
		{
			frames = [];
			frameCount = 0;
			prog.scaleX = 0;
			numPics.text = "0";
			addEventListener(Event.ENTER_FRAME, grabFrame);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopRecording);
		}
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % EVERY_NTH == 0) {
				//crop
				var a:BitmapData = new BitmapData(200, 240);
				a.copyPixels(camPic.getDisplay(), new Rectangle(60, 0, 200, 240), new Point(0, 0));
				frames.push(a);
			}
			if (frames.length >= MAX_FRAMES) {
				stopRecording();
			}
			numPics.text = String(frames.length);
		}
		
		
		private function stopRecording(e:MouseEvent = null):void
		{
			removeEventListener(Event.ENTER_FRAME, grabFrame);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopRecording);
			
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(8);//default is 10
			encoder.start();
			
			frameCount = frames.length;
			addEventListener(Event.ENTER_FRAME, addFrameToEncoder);
			/*
			for (var i:int = 0; i < frames.length; i++) {
				encoder.addFrame(frames[i]);
			}
			encoder.finish();
			
			var imageBytes:ByteArray = encoder.stream;
			saveFile(imageBytes);
			*/			
		}
		
		
		private function addFrameToEncoder(e:Event):void
		{
			if (frames.length) {
				prog.scaleX = 1 - (frames.length / frameCount);
				encoder.addFrame(frames.shift());
			}else {
				prog.scaleX = 0;
				removeEventListener(Event.ENTER_FRAME, addFrameToEncoder);
				encoder.finish();				
				saveFile(encoder.stream);
			}
		}
		
		
		private function saveFile(bytes:ByteArray):void
		{
			var outFile:File = File.desktopDirectory;
			outFile = outFile.resolvePath("anim.gif");
			var outStream:FileStream = new FileStream(); 			
			outStream.open(outFile, FileMode.WRITE); 			
			outStream.writeBytes(bytes, 0, bytes.length); 
			outStream.close(); 
		}
	}
	
}