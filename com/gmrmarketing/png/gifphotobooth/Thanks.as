package com.gmrmarketing.png.gifphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;	
	import flash.geom.*;
	import org.bytearray.gif.encoder.GIFEncoder;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.TimeoutHelper;	
	import com.dynamicflash.util.Base64;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;		
		private var encoder:GIFEncoder;
		private var frames:Array;
		
		private var queue:Queue;
		private var userData:Object;
		
		//private var overlay:BitmapData;//commented for puffs kiss cry
		
		
		public function Thanks()
		{
			encoder = new GIFEncoder();
			queue = new Queue();
			//overlay = new overlaySmall();//lib//commented for puffs kiss cry
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
		 * Called from Main.showThanks()
		 * @param	f Array of bitmapData frames 749x657
		 * @param	o Object with email, phone, opt[1-5], print keys
		 */
		public function show(f:Array, o:Object):void
		{
			frames = f;
			userData = o;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			TweenMax.delayedCall(.1, processFrames);
		}
		
		
		private function processFrames():void
		{
			//var over:BitmapData = new overlay();//lib
			
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(4);//default is 10 - lower = slower/better
			
			encoder.start();//returns a boolean... 
			myContainer.addEventListener(Event.ENTER_FRAME, encFrame, false, 0, true);
			/*
			var m:Matrix = new Matrix();
			m.scale(320 / 812, 240 / 610);
			
			for (var i:int = 0; i < frames.length; i++) {
				var b:BitmapData = new BitmapData(320, 240);
				b.draw(frames[i], m, null, null, null, true);			
				//b.copyPixels(over, new Rectangle(0, 0, 320, 240), new Point(0, 0), null, null, true);		
				encoder.addFrame(b);
			}
			
			encoder.finish();
			
			var gString:String = Base64.encodeByteArray(encoder.stream);
				
			userData.gif = gString;
			
			queue.add(userData);
			
			dispatchEvent(new Event(COMPLETE));
			*/
		}
		private function encFrame(e:Event):void
		{			
			if(frames.length > 0){
				var m:Matrix = new Matrix();
				m.scale(500 / 749, 439 / 657);
				var b:BitmapData = new BitmapData(500, 439);
				b.draw(frames.shift(), m, null, null, null, true);			
				//b.copyPixels(overlay, new Rectangle(0, 0, 500, 439), new Point(0, 0), null, null, true);		//commented for puffs kiss cry
				encoder.addFrame(b);
			}else {
				myContainer.removeEventListener(Event.ENTER_FRAME, encFrame);
				encoder.finish();
				
				var gString:String = Base64.encodeByteArray(encoder.stream);
				//saveFile(encoder.stream);
				
				userData.gif = gString;//userData object set in show()
				
				queue.add(userData);				
			
				dispatchEvent(new Event(COMPLETE));
			}
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