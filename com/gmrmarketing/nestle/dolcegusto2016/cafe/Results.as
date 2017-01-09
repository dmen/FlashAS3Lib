/**
 * Results screen only shown in cafe mode after quiz
 * in photobooth - results changes the mood
 */
package com.gmrmarketing.nestle.dolcegusto2016.cafe
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Results extends EventDispatcher 
	{
		public static const COMPLETE:String = "resultsComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var bigCounter:int;
		private var mugBitmap:Bitmap;
		private var coffeeBitmap:Bitmap;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Results()
		{
			clip = new mcResults();
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	result Key object with value,title,exp,image,coffee properties
		 * from the Key section of the JSON
		 */
		public function show(key:Object):void
		{
			timeoutHelper.buttonClicked();
			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.resultImage.alpha = 0;
			clip.resultTitle.alpha = 0;
			clip.resultExp.alpha = 0;
			clip.weRecommend.alpha = 0;
			clip.recommend.alpha = 0;
			clip.recommend.text = key.coffeeName;
			
			clip.resultTitle.autoSize = TextFieldAutoSize.LEFT;
			clip.resultTitle.text = key.title;
			clip.resultExp.autoSize = TextFieldAutoSize.LEFT;
			clip.resultExp.text = key.exp;			
			/*
			var tHeight:int = clip.resultTitle.textHeight + 15 + clip.resultExp.textHeight;
			//box height is 730
			var startY:int = Math.floor(((730 - tHeight) * .5) * .8);
			clip.resultTitle.y = 550 + startY;*/
			clip.resultExp.y = clip.resultTitle.y + clip.resultTitle.textHeight + 15;
			
			clip.btnNext.alpha = 0;			
			
			TweenMax.to(clip.resultTitle, .5, {alpha:1, delay:.5});
			TweenMax.to(clip.resultExp, .75, {alpha:1, delay:1});
			TweenMax.to(clip.weRecommend, .5, {alpha:1, delay:1.5});
			TweenMax.to(clip.recommend, .5, {alpha:1, delay:2});
			
			TweenMax.to(clip.btnNext, 1, {alpha:1, delay:1});
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextPressed, false, 0, true);
			
			//load coffee cup image			
			var im:String = "assets/" + key.image;				
			var l:Loader = new Loader();
			l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
			l.load(new URLRequest(im));	
			
			//load recommended coffee image		
			var im2:String = "assets/" + key.coffee;				
			var l2:Loader = new Loader();
			l2.contentLoaderInfo.addEventListener(Event.COMPLETE, image2Loaded, false, 0, true);
			l2.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, image2Error, false, 0, true);
			l2.load(new URLRequest(im2));		
		}
		
		
		private function animateArrow():void
		{
			clip.btnNext.arrow.x = -80;
			TweenMax.to(clip.btnNext.arrow, .75, {x:0, ease:Elastic.easeOut, onComplete:arrowWait});
		}
		
		
		private function arrowWait():void
		{
			TweenMax.delayedCall(2, animateArrow);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			if(mugBitmap){
				if (clip.resultImage.contains(mugBitmap)){
					clip.resultImage.removeChild(mugBitmap);
				}
			}
			if (coffeeBitmap){
				if (clip.contains(coffeeBitmap)){
					clip.removeChild(coffeeBitmap);
				}
			}
			TweenMax.killDelayedCallsTo(animateArrow);
			TweenMax.killTweensOf(clip.btnNext.arrow);
		}
		
		
		//coffee mug image from BuzzFeed
		private function imageLoaded(e:Event):void
		{	
			mugBitmap = new Bitmap(e.target.content.bitmapData);
			mugBitmap.smoothing = true;
			mugBitmap.width = 470;
			mugBitmap.height = 470;
			
			clip.resultImage.addChild(mugBitmap);
			TweenMax.to(clip.resultImage, .5, {alpha:1});
			
			animateArrow();
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			trace("image error",e.toString());
		}
		
		
		//recommended coffee image
		private function image2Loaded(e:Event):void
		{	
			coffeeBitmap = new Bitmap(e.target.content.bitmapData);
			coffeeBitmap.smoothing = true;
			coffeeBitmap.width = 533;
			coffeeBitmap.height = 666;
			coffeeBitmap.x = 1090;
			coffeeBitmap.y = 1040;
			clip.addChild(coffeeBitmap);
			TweenMax.to(coffeeBitmap, .5, {alpha:1});
			
			animateArrow();
		}
		
		
		private function image2Error(e:IOErrorEvent):void
		{
			trace("image error",e.toString());
		}
		
		
		private function nextPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextPressed);
			dispatchEvent(new Event(COMPLETE));
		}
			
	}
}