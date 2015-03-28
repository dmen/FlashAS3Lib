package com.gmrmarketing.humana.rrbighead
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Timer;
	import com.gmrmarketing.nissan.rodale2013.Print;
	//for saving images to the local filesystem
	import flash.utils.ByteArray;
	import flash.filesystem.*; 
	import com.adobe.images.JPEGEncoder;
	
	
	public class ThankYou extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		public static const PRINT_ERROR:String = "printError";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var theTimer:Timer;
		private var print:Print;
		private var im:Bitmap;
		private var oPic:BitmapData;
		private var pCopy:BitmapData;
		
		public function ThankYou()
		{
			clip = new mcThanks();			
			print = new Print();
			theTimer = new Timer(30000, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		public function set printCopy(im:BitmapData):void
		{
			pCopy = im;//lib clip
		}
		
		//pic comes in at 800x800
		public function setPic(pic:BitmapData):void
		{
			oPic = pic;//sent to writeImage() in showing()
			
			var m:Matrix = new Matrix();
			m.scale(.8125, .8125); //to scale 800x800 to 650x650			
			
			//oPic.copyPixels(pCopy, pCopy.rect, new Point(oPic.width - pCopy.width, oPic.height - pCopy.height), null, null, true);
			
			var bmd:BitmapData = new BitmapData(650, 650);
			bmd.draw(pic, m, null, null, null, true);
			im = new Bitmap(bmd);
			im.x = 1188;
			im.y = 311;
			im.alpha = 0;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if (myContainer.contains(im)) {
				myContainer.removeChild(im);
			}			
			myContainer.addChild(im);//image from setPic
			clip.alpha = 0;
			TweenMax.to(im, 1, { alpha:1 } );
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			print.removeEventListener(Print.ADD_ERROR, printError);
			print.removeEventListener(Print.SEND_ERROR, printError);
			
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if(im){
					if(myContainer.contains(im)){
						myContainer.removeChild(im);
					}
				}
			}
		}
		
		
		private function printError(e:Event):void
		{
			dispatchEvent(new Event(PRINT_ERROR));
		}
		
		
		private function showing():void
		{	
			dispatchEvent(new Event(SHOWING));//to hide confirm screen
			
			print.addEventListener(Print.ADD_ERROR, printError, false, 0, true);//removed in resetApp()
			print.addEventListener(Print.SEND_ERROR, printError, false, 0, true);
			print.beginPrint(oPic);//800x800
			
			theTimer.addEventListener(TimerEvent.TIMER, timedOut);
			theTimer.start();
			
			//save full image to local HD
			writeImage(oPic);			
			
			TweenMax.delayedCall(3, enableScreenClick);
		}
		
		private function enableScreenClick():void
		{
			clip.addEventListener(MouseEvent.MOUSE_DOWN, interruptTimer, false, 0, true);
		}
		
		
		private function interruptTimer(e:MouseEvent):void
		{			
			theTimer.reset();
			timedOut();
		}
		
		/**
		 * called after 30 seconds unless user touches screen and calls interruptTimer()
		 * @param	e
		 */
		private function timedOut(e:TimerEvent = null):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, interruptTimer);
			theTimer.removeEventListener(TimerEvent.TIMER, timedOut);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * 
		 * @param	bmpd
		 */
		private function writeImage(bmpd:BitmapData):void
		{
			var encoder:JPEGEncoder = new JPEGEncoder(82);
			var ba:ByteArray = encoder.encode(bmpd);
			
			var a:Date = new Date();
			var fileName:String = "humana_bh_rr_" + String(a.valueOf()) + ".jpg";			
			
			try{
				var file:File = File.documentsDirectory.resolvePath( fileName );
				var stream:FileStream = new FileStream();
				stream.open( file, FileMode.APPEND );
				stream.writeBytes (ba, 0, ba.length );
				stream.close();
				file = null;
				stream = null;
			}catch (e:Error) {
				
			}
		}		
	}
	
}