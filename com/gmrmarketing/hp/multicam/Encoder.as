package com.gmrmarketing.hp.multicam
{
	import flash.display.*;
	import flash.events.*;	
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.geom.*;
	import org.bytearray.gif.encoder.GIFEncoder;	
	import com.dynamicflash.util.Base64;
	import flash.filesystem.*;
	import com.gmrmarketing.utilities.GUID;
	
	
	public class Encoder extends EventDispatcher  
	{
		public static const UPDATE:String = "frameProcessed";
		public static const COMPLETE:String = "gifIsReady";
		private var encoder:GIFEncoder;
		private var frames:Array;
		private var timer:Timer;
		private var gif:String;
		private var saveToFile:Boolean;
		private var email:String;
		private var folder:String;
		private var numFrames:int;
		private var myW:int;
		private var myH:int;
		private var origW:int;
		private var origH:int;
		private var myOverlay:BitmapData;
		
		
		public function Encoder()
		{
			timer = new Timer(35);
			timer.addEventListener(TimerEvent.TIMER, encFrame);
		}
		
		
		public function set overlay(o:BitmapData):void
		{
			myOverlay = o;
		}
		
		
		public function set width(w:int):void
		{
			myW = w;
		}
		
		
		public function set height(h:int):void
		{			
			myH = h;
		}
		
		
		public function addFrames(images:Array, save:Boolean = false, $email:String = "", $folder:String = ""):void
		{
			frames = images.concat();
			numFrames = frames.length;			
			saveToFile = save;
			email = $email;
			folder = $folder;
			origW = BitmapData(images[0]).width;
			origH = BitmapData(images[0]).height;
			
			encoder = new GIFEncoder();
			
			processFrames();
		}
		
		
		public function get GIF():String
		{
			return gif;
		}
		
		
		public function get progress():Number 
		{
			return 1 - (frames.length / numFrames);
		}
		
		
		private function processFrames():void
		{			
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(4);//default is 10 - lower = slower/better
			
			encoder.start();//returns a boolean...
			timer.start();
		}
		
		
		private function encFrame(e:TimerEvent):void
		{
			if (frames.length > 0) {
		
				var m:Matrix = new Matrix();
				m.scale(myW / origW, myH / origH);
				var b:BitmapData = new BitmapData(myW, myH);
				b.draw(frames.shift(), m, null, null, null, true);
				if(myOverlay){
					b.copyPixels(myOverlay, new Rectangle(0, 0, myOverlay.width, myOverlay.height), new Point(0,0), null, null, true);
				}
				encoder.addFrame(b);
				
				dispatchEvent(new Event(UPDATE));
			}else {
				timer.reset();
				
				encoder.finish();
				
				if(saveToFile){
					saveFile(encoder.stream);
				}
				
				gif = Base64.encodeByteArray(encoder.stream);
				
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		
		private function saveFile(bytes:ByteArray):void
		{
			var outFile:File = File.desktopDirectory.resolvePath(folder);
			outFile = outFile.resolvePath(email + GUID.create() + ".gif");
			var outStream:FileStream = new FileStream(); 			
			outStream.open(outFile, FileMode.WRITE); 			
			outStream.writeBytes(bytes, 0, bytes.length); 
			outStream.close(); 
		}
	}
	
}