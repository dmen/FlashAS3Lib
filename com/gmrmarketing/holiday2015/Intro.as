
package com.gmrmarketing.holiday2015
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	

	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		public static const HIDDEN:String = "introHidden";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var restartTimer:Timer;
		
		
		public function Intro()
		{
			restartTimer = new Timer(10000, 1);
			clip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(e:TimerEvent = null):void
		{
			restartTimer.reset();
			restartTimer.removeEventListener(TimerEvent.TIMER, show);
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);				
			}
			clip.alpha = 1;
			
			clip.textBox.s1.scaleX = clip.textBox.s1.scaleY = 0;
			clip.textBox.s2.scaleX = clip.textBox.s2.scaleY = 0;
			clip.textBox.s3.scaleX = clip.textBox.s3.scaleY = 0;
			clip.textBox.s4.scaleX = clip.textBox.s4.scaleY = 0;
			clip.textBox.s5.scaleX = clip.textBox.s5.scaleY = 0;
			clip.textBox.s6.scaleX = clip.textBox.s6.scaleY = 0;
			clip.textBox.s7.scaleX = clip.textBox.s7.scaleY = 0;
			clip.textBox.s8.scaleX = clip.textBox.s8.scaleY = 0;
			clip.textBox.s9.scaleX = clip.textBox.s9.scaleY = 0;
			clip.textBox.s10.scaleX = clip.textBox.s10.scaleY = 0;
			clip.textBox.s11.scaleX = clip.textBox.s11.scaleY = 0;
			clip.textBox.s12.scaleX = clip.textBox.s12.scaleY = 0;
			clip.textBox.s13.scaleX = clip.textBox.s13.scaleY = 0;
			clip.textBox.s14.scaleX = clip.textBox.s14.scaleY = 0;
			clip.textBox.s15.scaleX = clip.textBox.s15.scaleY = 0;
			clip.textBox.s16.scaleX = clip.textBox.s16.scaleY = 0;
			clip.textBox.s17.scaleX = clip.textBox.s17.scaleY = 0;
			clip.textBox.s18.scaleX = clip.textBox.s18.scaleY = 0;
			
			clip.outline.gotoAndStop(1);
			clip.outline.alpha = 1;
			
			clip.blackBar.y = 1080;
			clip.textBox.scaleX = clip.textBox.scaleY = 0;			
			TweenMax.to(clip.textBox, .5, { scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:showOutline } );
			
			myContainer.addEventListener(MouseEvent.MOUSE_DOWN, screenClicked, false, 0, true);
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.textBox);
			
			restartTimer.reset();
			restartTimer.removeEventListener(TimerEvent.TIMER, doRestart);
			
			myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, screenClicked);
			
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			TweenMax.killTweensOf(clip.blackBar);
			TweenMax.killTweensOf(clip.outline);			
			
			TweenMax.killTweensOf(clip.textBox.s1);
			TweenMax.killTweensOf(clip.textBox.s2);
			TweenMax.killTweensOf(clip.textBox.s3);
			TweenMax.killTweensOf(clip.textBox.s4);
			TweenMax.killTweensOf(clip.textBox.s5);
			TweenMax.killTweensOf(clip.textBox.s6);
			TweenMax.killTweensOf(clip.textBox.s7);
			TweenMax.killTweensOf(clip.textBox.s8);
			TweenMax.killTweensOf(clip.textBox.s9);
			TweenMax.killTweensOf(clip.textBox.s10);
			TweenMax.killTweensOf(clip.textBox.s11);
			TweenMax.killTweensOf(clip.textBox.s12);
			TweenMax.killTweensOf(clip.textBox.s13);
			TweenMax.killTweensOf(clip.textBox.s14);
			TweenMax.killTweensOf(clip.textBox.s15);
			TweenMax.killTweensOf(clip.textBox.s16);
			TweenMax.killTweensOf(clip.textBox.s17);
			TweenMax.killTweensOf(clip.textBox.s18);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function showOutline():void
		{
			clip.outline.gotoAndPlay(2);
			TweenMax.to(clip.blackBar, .5, { y:975, ease:Back.easeOut, delay:1.75 } );
			
			clip.textBox.s1.scaleX = clip.textBox.s1.scaleY = 0;
			clip.textBox.s2.scaleX = clip.textBox.s2.scaleY = 0;
			clip.textBox.s3.scaleX = clip.textBox.s3.scaleY = 0;
			clip.textBox.s4.scaleX = clip.textBox.s4.scaleY = 0;
			clip.textBox.s5.scaleX = clip.textBox.s5.scaleY = 0;
			clip.textBox.s6.scaleX = clip.textBox.s6.scaleY = 0;
			clip.textBox.s7.scaleX = clip.textBox.s7.scaleY = 0;
			clip.textBox.s8.scaleX = clip.textBox.s8.scaleY = 0;
			clip.textBox.s9.scaleX = clip.textBox.s9.scaleY = 0;
			clip.textBox.s10.scaleX = clip.textBox.s10.scaleY = 0;
			clip.textBox.s11.scaleX = clip.textBox.s11.scaleY = 0;
			clip.textBox.s12.scaleX = clip.textBox.s12.scaleY = 0;
			clip.textBox.s13.scaleX = clip.textBox.s13.scaleY = 0;
			clip.textBox.s14.scaleX = clip.textBox.s14.scaleY = 0;
			clip.textBox.s15.scaleX = clip.textBox.s15.scaleY = 0;
			clip.textBox.s16.scaleX = clip.textBox.s16.scaleY = 0;
			clip.textBox.s17.scaleX = clip.textBox.s17.scaleY = 0;
			clip.textBox.s18.scaleX = clip.textBox.s18.scaleY = 0;
			
			var sc:Number;
			var ro:Number = 30 + 40 * Math.random();
			var del:Number;
			for (var i:int = 0; i < 18; i++) {
				sc = .5 + Math.random(); //.5 to 1.5
				del = 1.5 + 9 * Math.random();
				TweenMax.to(clip.textBox["s" + String(i + 1)], 1, { alpha:.9, rotation:String(ro), scaleX:sc, scaleY:sc, delay:del} );
				TweenMax.to(clip.textBox["s" + String(i + 1)], 3, { scaleX:0, scaleY:0, alpha:0, rotation:String(ro), delay:.9+del} );
			}
			
			restartTimer.delay = 15000;
			restartTimer.addEventListener(TimerEvent.TIMER, doRestart, false, 0, true);
			restartTimer.start();
		}
		
		
		private function scaleBack(star:MovieClip):void
		{
			TweenMax.to(star, 3, { scaleX:0, scaleY:0, alpha:0} );
		}
		
		
		private function doRestart(e:TimerEvent):void
		{
			restartTimer.reset();
			restartTimer.removeEventListener(TimerEvent.TIMER, doRestart);
			
			TweenMax.to(clip.outline, 1, { alpha:0 } );
			TweenMax.to(clip.textBox, 1, { scaleX:0, scaleY:0, ease:Back.easeIn, delay:.75 } );
			TweenMax.to(clip.blackBar, .5, { y:1080, ease:Back.easeIn, delay:1.5 } );
		
			restartTimer.delay = 5000;
			restartTimer.addEventListener(TimerEvent.TIMER, show, false, 0, true);			
			restartTimer.start();
		}
		
		
		private function screenClicked(e:MouseEvent):void
		{
			restartTimer.reset();
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}