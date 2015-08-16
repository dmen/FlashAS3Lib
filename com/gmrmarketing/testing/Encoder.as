package com.gmrmarketing.testing
{
	import flash.events.*;	
	import flash.utils.Timer;
	import org.bytearray.gif.encoder.GIFEncoder;	
	import com.dynamicflash.util.Base64;

	public class Encoder extends EventDispatcher  
	{
		public static const COMPLETE:String = "gifIsReady";
		private var encoder:GIFEncoder;
		private var frames:Array;
		private var timer:Timer;
		private var gif:String;
		
				
		public function Encoder()
		{
			timer = new Timer(35);
			timer.addEventListener(TimerEvent.TIMER, encFrame);
			
			encoder = new GIFEncoder();
		}
		
		
		public function addFrames(images:Array):void
		{
			frames = images;
			processFrames();
		}
		
		
		public function getGif():String
		{
			return gif;
		}
		
		
		private function processFrames():void
		{
			//var over:BitmapData = new overlay();//lib
			
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(8);//default is 10 - lower = slower/better
			
			encoder.start();//returns a boolean...
			timer.start();
		}
		
		
		private function encFrame(e:TimerEvent):void
		{
			var over:BitmapData = new overlay();//lib
			
			if(frames.length > 0){
				var m:Matrix = new Matrix();
				m.scale(320 / 749, 281 / 657);
				var b:BitmapData = new BitmapData(320, 281);
				b.draw(frames.shift(), m, null, null, null, true);			
				b.copyPixels(over, new Rectangle(0, 0, 320, 281), new Point(0, 0), null, null, true);		
				encoder.addFrame(b);
			}else {
				timer.reset();
				
				encoder.finish();
				
				gif = Base64.encodeByteArray(encoder.stream);
				
				dispatchEvent(new Event(COMPLETE));
			}
		}
	}
	
}