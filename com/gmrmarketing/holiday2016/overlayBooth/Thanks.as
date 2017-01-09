package com.gmrmarketing.holiday2016.overlayBooth
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
		public static const HIDDEN:String = "thanksHidden";
		
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
			
			clip.yellowBar.scaleX = 0;
			clip.yellowBarShare.scaleX = 0;
			clip.tex1.scaleX = clip.tex1.scaleY = 0;
			clip.tex2.scaleX = clip.tex2.scaleY = 0;
			
			TweenMax.to(clip.tex1, .5, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.tex2, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.3});
			TweenMax.to(clip.yellowBar, 1, {scaleX:1, ease:Expo.easeOut, delay:.5});
			TweenMax.to(clip.yellowBarShare, 1, {scaleX:1, ease:Expo.easeOut, delay:1});
			
			//wait for screen to build
			var a:Timer = new Timer(2000, 1);
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
			TweenMax.to(clip.yellowBar, .3, {scaleX:0, ease:Expo.easeIn});
			TweenMax.to(clip.yellowBarShare, .3, {scaleX:0, ease:Expo.easeIn});
			TweenMax.to(clip.tex1, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.2});
			TweenMax.to(clip.tex2, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.3, onComplete:hidden});			
		}
		private function hidden():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			dispatchEvent(new Event(HIDDEN));
		}
		
		public function kill():void
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