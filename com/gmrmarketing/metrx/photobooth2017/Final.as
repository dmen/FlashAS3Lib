package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Final extends EventDispatcher 
	{
		public static const COMPLETE:String = "finalComplete";
		public static const SHOWING:String = "finalShowing";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		public function Final()
		{
			clip = new mcFinal();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.x = 0;
			clip.thanks.alpha = 0;
			clip.hash.alpha = 0;
			clip.title.scaleY = 0;
			clip.bottles.scaleX = 0;
			clip.tread.x = 1920;
			
			TweenMax.to(clip.tread, .5, {x:0, ease:Expo.easeOut});
			TweenMax.to(clip.bottles, .5, {scaleX:1, ease:Expo.easeOut, delay:.3});
			TweenMax.to(clip.title, .5, {scaleY:1, ease:Expo.easeOut, delay:.4});
			TweenMax.to(clip.thanks, .5, {alpha:1, delay:.5});
			TweenMax.to(clip.hash, .5, {alpha:1, delay:.6, onComplete:sendShowing});
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function sendShowing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
	}
	
}