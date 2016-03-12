
package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var timer:Timer;
		private var tim:TimeoutHelper;
		
		public function Thanks()
		{
			clip = new mcThanks();
			clip.x = 112;
			clip.y = 90;
			
			tim = TimeoutHelper.getInstance();
			
			timer = new Timer(10000, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.hLinesTop.scaleY = 0;
			clip.titleText.alpha = 0;
			clip.subText.alpha = 0;
			clip.xfinZone.alpha = 0;
			clip.xfinNascar.alpha = 0;
			clip.hLinesBottom.scaleX = 0;
			
			TweenMax.to(clip.hLinesTop, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.titleText, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.subText, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.hLinesBottom, .5, { scaleX:1, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.xfinZone, 1, { alpha:1, delay:1.5 } );
			TweenMax.to(clip.xfinNascar, 1, { alpha:1, delay:1.75 } );
			
			timer.addEventListener(TimerEvent.TIMER, thanksDone, false, 0, true);
			timer.start();
		}
		
		
		private function thanksDone(e:TimerEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function hide():void
		{
			timer.reset();
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
	}
	
}