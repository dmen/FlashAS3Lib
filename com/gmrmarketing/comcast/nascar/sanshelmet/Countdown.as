/**
 * Circle ticker and white flash 
 * used by main
 */

package com.gmrmarketing.comcast.nascar.sanshelmet
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const WHITE_FLASH:String = "flash";
		public static const FLASH_COMPLETE:String = "flashFadedOut";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var count:int;
				
		private var step:int;
		private var circ:Sprite;
		private var tweenOb:Object;
		private const theX:int = 990;
		private const theY:int = 660;		
		private var radius:int = 100;
		
		
		public function Countdown()
		{
			tweenOb = new Object();
			circ = new Sprite();			
			Utility.drawArc(circ.graphics, theX, theY, radius, 0, 360, 5, 0xffffff, 1);			
			clip = new mcCount();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{		
			count = 3;
			step = 0;
			clip.theNumber.theText.text = String(count);
			clip.alpha = 1;
			clip.theFlash.alpha = 0;
			
			if(!clip.contains(circ)){
				clip.addChild(circ);
			}
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			
			circ.scaleX = circ.scaleY = .75;
			TweenMax.to(circ, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:nextCount } );			
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}	
			if(clip.contains(circ)){
				clip.removeChild(circ);
			}
		}
		
		
		private function nextCount():void
		{
			tweenOb.ang = 0;
			circ.graphics.clear();
			Utility.drawArc(circ.graphics, theX, theY, radius, 0, 360, 5, 0xffffff, 1);	
			TweenMax.to(tweenOb, 1, { ang:360, onUpdate:drawTimeArc, onComplete:decCount } );
		}
		
		private function drawTimeArc():void
		{
			Utility.drawArc(circ.graphics, theX, theY, radius, 0, tweenOb.ang, 5, 0x333333, 1);
		}
		
		private function decCount():void
		{
			count--;
			clip.theNumber.theText.text = String(count);
			if (count == 0) {
				dispatchEvent(new Event(WHITE_FLASH));
			}else {
				nextCount();
			}
		}
		
		
		public function doFlash():void
		{
			clip.theFlash.alpha = 1;
			TweenMax.to(clip.theFlash, .5, { alpha:0, onComplete:flashFaded } );			
		}
		
		
		private function flashFaded():void
		{
			dispatchEvent(new Event(FLASH_COMPLETE));
		}
		
	}
	
}