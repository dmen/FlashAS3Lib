package com.gmrmarketing.miller.gifphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.bytearray.gif.encoder.GIFEncoder;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;		
		private var encoder:GIFEncoder;
		private var frames:Array;
		
		private var queue:Queue;
		private var userData:Object;
		
		
		public function Thanks()
		{
			encoder = new GIFEncoder();
			queue = new Queue();
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		
		/**
		 *
		 * @param	f Array of bitmapData frames 812x610
		 * @param	o Object with email, phone, opt1, opt2, opt3, dob keys
		 */
		public function show(f:Array, o:Object):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			frames = f;
			userData = o;
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:processFrames } );
		}
		
		
		private function processFrames():void
		{
			var over:BitmapData = new overlay();//lib
			
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(8);//default is 10 - lower = slower/better
			encoder.start();
			
			var m:Matrix = new Matrix();
			m.scale(320 / 812, 240 / 610);
			
			for (var i:int = 0; i < frames.length; i++) {
				var b:BitmapData = new BitmapData(320, 240);
				b.draw(frames[i], m, null, null, null, true);			
				b.copyPixels(over, new Rectangle(0, 0, 320, 240), new Point(0, 0), null, null, true);		
				encoder.addFrame(b);
			}
			
			encoder.finish();
			
			userData.gif = encoder.stream;//byteArray
			queue.add(userData);
			
			//saveFile(encoder.stream);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function hide():void
		{
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
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