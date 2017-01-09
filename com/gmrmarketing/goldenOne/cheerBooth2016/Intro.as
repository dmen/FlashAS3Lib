package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Intro extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			clip.title.x = 1920;
			clip.subTitle.x = 1920;
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut, delay:.4});//wait for thanks to clear out - all but first time
			TweenMax.to(clip.subTitle, .5, {x:150, ease:Expo.easeOut, delay:.5});
		}
		
		
		public function hide():void
		{
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