package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Instructions extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Instructions()
		{
			clip = new mcInstructions();
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
			clip.step1.x = 1920;
			clip.step2.x = 1920;
			clip.step3.x = 1920;
			
			clip.step1.bullet.scaleX = clip.step1.bullet.scaleY = 0;
			clip.step2.bullet.scaleX = clip.step2.bullet.scaleY = 0;
			clip.step3.bullet.scaleX = clip.step3.bullet.scaleY = 0;
			
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut, delay:.4});//wait for previous screen to hide
			TweenMax.to(clip.step1, .5, {x:128, ease:Expo.easeOut, delay:.5});
			TweenMax.to(clip.step1.bullet, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.8});
			TweenMax.to(clip.step2, .5, {x:128, ease:Expo.easeOut, delay:.6});
			TweenMax.to(clip.step2.bullet, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.9});
			TweenMax.to(clip.step3, .5, {x:128, ease:Expo.easeOut, delay:.7});
			TweenMax.to(clip.step3.bullet, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1});
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip.title, .5, {x:-1500, ease:Expo.easeIn});
			TweenMax.to(clip.step1, .5, {x:-1500, ease:Expo.easeIn, delay:.1});
			TweenMax.to(clip.step2, .5, {x:-1500, ease:Expo.easeIn, delay:.2});
			TweenMax.to(clip.step3, .5, {x:-1500, ease:Expo.easeIn, delay:.3, onComplete:kill});
		}
		
		
		public function kill():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
	}
	
}