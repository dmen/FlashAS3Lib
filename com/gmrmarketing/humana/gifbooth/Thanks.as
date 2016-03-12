package com.gmrmarketing.humana.gifbooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;	
	import flash.geom.*;
	import flash.utils.Timer;
	import org.bytearray.gif.encoder.GIFEncoder;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.TimeoutHelper;	
	import com.dynamicflash.util.Base64;
	import com.gmrmarketing.utilities.queue.Queue;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;		
		private var encoder:GIFEncoder;
		private var frames:Array;
		
		private var queue:Queue;
		private var userData:Object;
		
		private var overlay:BitmapData;
		private var waitTimer:Timer;
		
		public function Thanks()
		{
			encoder = new GIFEncoder();
			
			queue = new Queue();
			queue.fileName = "humanaGif216";
			queue.service = new HubbleServiceExtender();
			queue.start();
			
			overlay = new overlaySmall();//500x439
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
		 * @param	o Object with email, phone, opt[1-5], print keys - email is "printOnly" if the user only printed
		 */
		public function show(f:Array, o:Object):void
		{
			frames = f;
			userData = o;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.arrow.alpha = 0;
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			if(userData.email != "printOnly"){
				TweenMax.delayedCall(.1, processFrames);
			}else {
				showButton();
			}
		}
		
		
		private function showButton():void
		{
			waitTimer = new Timer(10000, 1);
			waitTimer.addEventListener(TimerEvent.TIMER, finishedByTimer, false, 0, true);
			waitTimer.start();
			
			clip.btnOK.addEventListener(MouseEvent.MOUSE_DOWN, finished, false, 0, true);
			TweenMax.to(clip.arrow, .5, { alpha:1 } );
		}
		
		
		private function finished(e:MouseEvent = null):void
		{
			waitTimer.removeEventListener(TimerEvent.TIMER, finishedByTimer);
			waitTimer.reset();
			clip.btnOK.removeEventListener(MouseEvent.MOUSE_DOWN, finished);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function finishedByTimer(e:TimerEvent):void
		{
			finished();
		}
		
		
		private function processFrames():void
		{
			encoder.setRepeat(0);
			encoder.setDelay(150);
			encoder.setQuality(4);//default is 10 - lower = slower/better
			
			encoder.start();//returns a boolean... 
			myContainer.addEventListener(Event.ENTER_FRAME, encFrame, false, 0, true);			
		}
		
		
		private function encFrame(e:Event):void
		{			
			if(frames.length > 0){
				var m:Matrix = new Matrix();
				m.scale(500 / 749, 439 / 657);
				var b:BitmapData = new BitmapData(500, 439);
				b.draw(frames.shift(), m, null, null, null, true);			
				b.copyPixels(overlay, new Rectangle(0, 0, 500, 439), new Point(0, 0), null, null, true);
				encoder.addFrame(b);
			}else {
				myContainer.removeEventListener(Event.ENTER_FRAME, encFrame);
				encoder.finish();
				
				var gString:String = Base64.encodeByteArray(encoder.stream);
				//saveFile(encoder.stream);
				
				userData.image = gString;//userData object set in show()
				
				queue.add(userData);				
			
				showButton();
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