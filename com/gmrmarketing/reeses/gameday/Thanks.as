package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Thanks extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.tLine.scale = 0;
			clip.bLine.scaleX = 0;
			clip.thankYou.scaleY = 0;
			clip.wrap.alpha = 0;
			clip.yourVideo.alpha = 0;
			clip.animRing.alpha = 0;
			
			TweenMax.to(clip.thankYou, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.tLine, .5, { scaleX:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.bLine, .5, { scaleX:1, delay:.4, ease:Back.easeOut } );
			TweenMax.to(clip.wrap, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.yourVideo, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.animRing, .5, { alpha:1, delay:.75 } );
			
			clip.addEventListener(Event.ENTER_FRAME, updateRing, false, 0, true);
		}
		
		
		private function updateRing(e:Event):void
		{
			clip.animRing.rotation += 5;
		}
		
		
		public function hide():void
		{
			clip.addEventListener(Event.ENTER_FRAME, updateRing);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}			
		}
		
	}
	
}