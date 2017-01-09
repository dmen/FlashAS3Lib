package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class ReviewPhoto
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var display:Bitmap;
		
		
		public function ReviewPhoto()
		{
			clip = new mcReview();
			
			display = new Bitmap();
			display.x = 156;
			display.y = 370;//same loc as video in Review
			
			clip.addChild(display);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(bmd:BitmapData):void
		{		
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			display.bitmapData = bmd;
			
			clip.title.x = 1920;
			clip.subTitle.text = 1920;
			display.alpha = 0;
			
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut});
			TweenMax.to(clip.subTitle, .5, {x:150, ease:Expo.easeOut, delay:.1});
			TweenMax.to(display, .5, {alpha:1});
		}
		
		
		public function hide():void
		{
			TweenMax.to(display, .5, {alpha:0});
			TweenMax.to(clip.title, .5, {x:-1500, ease:Expo.easeIn});
			TweenMax.to(clip.subTitle, .5, {x:-1500, ease:Expo.easeIn, delay:.1, onComplete:kill});
		}
		
		
		public function kill():void
		{			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
		}
	}
	
}