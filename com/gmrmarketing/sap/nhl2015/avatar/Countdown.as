/**
 * Circle ticker and white flash 
 */

package com.gmrmarketing.sap.nhl2015.avatar
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	
	
	public class Countdown extends EventDispatcher
	{
		public static const WHITE_FLASH:String = "whiteFlashShowing";
		public static const FLASH_COMPLETE:String = "flashFadedOut";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var count:int;
		private var countTimer:Timer;
		
		private const degToRad:Number = 0.0174532925; //PI / 180
		private const LINE_THICKNESS:int = 35;
		private const BASE_COLOR:Number = 0x3A5679;
		private const MAIN_COLOR:Number = 0xE5b227;
		
		private var step:int;
		private var countHolder:Sprite;
		private var base:Sprite;
		
		private const theY:int = 200;
		private var radius:int = 100;
		
		
		public function Countdown()
		{
			countHolder = new Sprite();
			base = new Sprite();
			base.filters = [new DropShadowFilter(0, 0, 0x000000, .8, 5, 5)];
			draw_arc(base.graphics, 960, theY, radius, 0, 360, BASE_COLOR);
			
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
			
			countTimer = new Timer(1000);
			countTimer.addEventListener(TimerEvent.TIMER, updateCount, false, 0, true);			
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.addChild(base);
			base.scaleX = base.scaleY = .75;
			TweenMax.to(base, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			clip.addChild(countHolder);
			clip.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
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
		}
		
		
		private function updateCount(e:TimerEvent):void
		{
			count--;			
			
			clip.theNumber.theText.text = String(count);
			draw_arc(countHolder.graphics, 960, theY, radius, 0, 120*count, MAIN_COLOR);
			
			if (count == 0) {				
				//clip.numCount.theText.text = "";
				countTimer.removeEventListener(TimerEvent.TIMER, updateCount);
				countTimer.stop();
				dispatchEvent(new Event(WHITE_FLASH));				
			}
		}
		
		
		public function doFlash():void
		{
			clip.theFlash.alpha = 1;
			TweenMax.to(clip.theFlash, .5, { alpha:0, onComplete:flashFaded } );
			//TweenMax.delayedCall(.25, flashFaded);
		}
		
		
		private function flashFaded():void
		{
			dispatchEvent(new Event(FLASH_COMPLETE));
		}
		
		
		private function onEnterFrame(e:Event):void
		{           
			step++;
			if (step > 20) {
				step = 0;
				clip.removeEventListener(Event.ENTER_FRAME, onEnterFrame);				
				countTimer.start();				
			}else{		
				draw_arc(countHolder.graphics, 960, theY, radius, 0, 18 * step, MAIN_COLOR);
			}
        }
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineColor:Number, lineAlpha:Number = 1):void
		{
			g.clear();
			g.lineStyle(LINE_THICKNESS, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:int = (angle_to) - (angle_from);
			var steps:int = angle_diff * 1;//1 is precision... use higher numbers for more.
			var angle:int = angle_from;
			var px:Number = center_x + radius * Math.cos((angle-90) * degToRad);//sub 90 here and below to rotate the arc to start at 12oclock
			var py:Number = center_y + radius * Math.sin((angle-90) * degToRad);

			g.moveTo(px, py);

			for (var i:int = 1; i <= steps; i++) {
				angle = angle_from + angle_diff / steps * i;
				g.lineTo(center_x + radius * Math.cos((angle-90) * degToRad), center_y + radius * Math.sin((angle-90) * degToRad));
			}
		}
		
	}
	
}