
package com.gmrmarketing.holiday2015
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dynamicflash.util.Base64;
	import flash.utils.*;
	import com.adobe.images.JPEGEncoder;

	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var image:BitmapData;
		private var imString:String;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(bmd:BitmapData):void
		{
			image = bmd;
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.bigThanks.scaleX = clip.bigThanks.scaleY = 0;
			clip.subText.alpha = 0;
			
			TweenMax.to(clip.bigThanks, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.subText, 1, { alpha:1, delay:.5 } );
			
			var a:Timer = new Timer(1500, 1);
			a.addEventListener(TimerEvent.TIMER, encodeImage, false, 0, true);
			a.start();			
		}
		
		
		public function get imageString():String
		{	
			return imString;
		}
		
		
		private function encodeImage(e:TimerEvent):void
		{
			var n:Number = getTimer();
			
			var jpeg:ByteArray = getJpeg(image);
			imString = getBase64(jpeg);			
			
			var a:Timer = new Timer(Math.max(1000, 6000 - (getTimer() - n)), 1);
			a.addEventListener(TimerEvent.TIMER, encodingComplete, false, 0, true);
			a.start();
		}
		
		private function encodingComplete(e:TimerEvent):void
		{			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
	}
	
}