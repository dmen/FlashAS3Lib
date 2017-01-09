package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;//byteArray
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dynamicflash.util.Base64;	
	import com.adobe.images.JPEGEncoder;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var imString:String;//b64 encoded image
		private var userImage:BitmapData;
		
		public function Thanks()
		{
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(isPhotoBooth:Boolean, photo:BitmapData = null):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			imString = "";
			userImage = photo;
			
			clip.thanksTitle.alpha = 0;
			clip.thanksText.alpha = 0;
			
			if (isPhotoBooth){
				clip.thanksTitle.text = "\nTHANK YOU.";//two lines
				clip.thanksText.text = "We have just sent your ideal coffee moment photo to you via the email you provided. We hope you love it enough to share with your friends.\n\nIf you have not yet visited\nour coffee tasting bar or\nVR experience, please do.";
			}else{
				clip.thanksTitle.text = "\nTHANK YOU!";//one line
				clip.thanksText.text = "";
			}
			
			clip.btnNext.width = clip.btnNext.height = 0;	
			
			TweenMax.to(clip.thanksTitle, .4, {alpha:1, delay:.2});
			TweenMax.to(clip.thanksText, .4, {alpha:1, delay:.3});			
			
			if (isPhotoBooth && photo){
				//if encoding an image to b64 - don't add next button till finished
				TweenMax.delayedCall(1, encode);//let screen build before beginning encode
			}else{
				//add it right away - no photo
				TweenMax.to(clip.btnNext, .4, {width:160, height:160, ease:Back.easeOut, delay:.5});
				clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);			
				TweenMax.delayedCall(10, nextPressed);
			}
			
			animateArrow();
		}
		
		
		public function get imageString():String
		{
			return imString;
		}
		
		
		private function encode():void
		{
			var jpeg:ByteArray = getJpeg(userImage);//gets jpeg encoded byte array from bitmapData
			imString = getBase64(jpeg);
			
			//b64 string finished - add button and start timeout
			TweenMax.to(clip.btnNext, .4, {width:160, height:160, ease:Back.easeOut, delay:.5});
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);			
			TweenMax.delayedCall(10, nextPressed);
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip.thanksTitle, .4, {alpha:0});
			TweenMax.to(clip.btnNext, .4, {width:0, height:0, ease:Back.easeIn});
			TweenMax.to(clip.thanksText, .4, {alpha:0, onComplete:killThanks});
			TweenMax.killDelayedCallsTo(animateArrow);
			TweenMax.killDelayedCallsTo(nextPressed);
		}		
		
		
		private function nextPressed(e:MouseEvent = null):void
		{
			TweenMax.killDelayedCallsTo(nextPressed);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function killThanks():void
		{
			if (myContainer.contains(clip)){
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
		
		
		private function animateArrow():void
		{
			clip.btnNext.arrow.x = -80;
			TweenMax.to(clip.btnNext.arrow, .75, {x:0, ease:Elastic.easeOut});
			TweenMax.delayedCall(2, animateArrow);
		}
		
	}
	
}