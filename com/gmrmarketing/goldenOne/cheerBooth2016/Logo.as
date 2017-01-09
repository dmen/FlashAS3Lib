package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	
	public class Logo
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		public function Logo()
		{
			clip = new mcLogo();
			clip.x = 1500;
			clip.y = 0;
			clip.glimmer.x = -80;
			clip.glimmer.cacheAsBitmap = true;
			clip.masker.cacheAsBitmap = true;
			clip.glimmer.mask = clip.masker;
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
			beginGlimmer();			
		}
		
		
		private function beginGlimmer():void
		{
			clip.glimmer.x = -80;
			TweenMax.to(clip.glimmer, 1, {x:300, ease:Linear.easeNone, onComplete:endGlimmer});
		}
		
		
		private function endGlimmer():void
		{
			TweenMax.delayedCall(5 + Math.random() * 5, beginGlimmer);
		}
	}
	
}