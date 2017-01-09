package com.gmrmarketing.holiday2016.overlayBooth
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
		private var buildTimer:Timer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			buildTimer = new Timer(15000, 1);			
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
			
			clip.alpha = 1;
			TweenMax.killTweensOf(clip.btnTouch);
			
			clip.btnTouch.y = 1080;
			clip.backFlower.scaleY = 0;
			clip.backFlower.scaleX = 1;
			clip.yellowBar.scaleX = 0;
			clip.toucan.scaleY = 0;
			clip.germanium.scaleX = clip.germanium.scaleY = 0;
			clip.tex1.scaleX = clip.tex1.scaleY = 0;
			clip.tex2.scaleX = clip.tex2.scaleY = 0;			
			clip.parrot.scaleX = 0;
			clip.parrot.y = 280;
			clip.butterfly.scaleX = clip.butterfly.scaleY = 0;
			
			TweenMax.to(clip.tex1, .5, {scaleX:1, scaleY:1, ease:Back.easeOut});
			TweenMax.to(clip.tex2, .5, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.3});
			
			TweenMax.to(clip.toucan, .3, {scaleY:1, ease:Back.easeOut, delay:.7});
			TweenMax.to(clip.germanium, .3, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:.8});
			
			TweenMax.to(clip.parrot, .4, {scaleX:1, y:380, ease:Back.easeOut, delay:1});
			TweenMax.to(clip.butterfly, .4, {scaleX:1, scaleY:1, ease:Back.easeOut, delay:1.6});
			
			TweenMax.to(clip.backFlower, .4, {scaleY:1, ease:Back.easeOut, delay:1.2});
			
			TweenMax.to(clip.yellowBar, .75, {scaleX:1, ease:Expo.easeOut, delay:1.5, onComplete:coolFactor});
			
			TweenMax.to(clip.btnTouch, .5, {y:977, ease:Linear.easeNone, delay:2, onComplete:buttonWide});
			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, screenTouched, false, 0, true);			
			
			buildTimer.addEventListener(TimerEvent.TIMER, rebuild, false, 0, true);
			buildTimer.start();
		}
		
		
		private function coolFactor():void
		{
			TweenMax.to(clip.tex1, 20, {scaleX:.8, scaleY:.8, ease:Linear.easeIn});
			TweenMax.to(clip.tex2, 20, {scaleX:.8, scaleY:.8,ease:Linear.easeIn});
			TweenMax.to(clip.toucan, 20, {scaleX:1.25, scaleY:1.25, ease:Linear.easeIn});
			TweenMax.to(clip.parrot, 20, {scaleX:1.4, scaleY:1.4, ease:Linear.easeIn});
			TweenMax.to(clip.backFlower, 20, {scaleY:1.35, scaleX:1.3, ease:Linear.easeIn});
			TweenMax.to(clip.butterfly, 20, {scaleX:1.35, scaleY:1.35, ease:Linear.easeIn});
			TweenMax.to(clip.germanium, 20, {scaleX:1.5, scaleY:1.5, ease:Linear.easeIn});
		}
		
		
		public function hide():void
		{
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, screenTouched);
			buildTimer.reset();
			
			TweenMax.killAll();
			/*
			TweenMax.killDelayedCallsTo(show);
			
			TweenMax.killTweensOf(clip.tex1);
			TweenMax.killTweensOf(clip.tex2);
			TweenMax.killTweensOf(clip.btnTouch);
			TweenMax.killTweensOf(clip.toucan);
			TweenMax.killTweensOf(clip.yellowBar);
			TweenMax.killTweensOf(clip.parrot);
			TweenMax.killTweensOf(clip.backFlower);
			TweenMax.killTweensOf(clip.butterfly);
			TweenMax.killTweensOf(clip.germanium);
			*/
			TweenMax.to(clip.btnTouch, .4, {y:1080, ease:Linear.easeNone});
			TweenMax.to(clip.yellowBar, .3, {scaleX:0, ease:Expo.easeIn, delay:.1});
			TweenMax.to(clip.backFlower, .4, {scaleY:0, ease:Back.easeIn, delay:.2});
			TweenMax.to(clip.parrot, .4, {scaleX:0, y:280, ease:Back.easeIn, delay:.3});
			TweenMax.to(clip.butterfly, .4, {scaleX:0, scaleY:0, delay:.4});
			TweenMax.to(clip.toucan, .3, {scaleY:0, ease:Back.easeIn, delay:.5});
			TweenMax.to(clip.germanium, .3, {scaleY:0, scaleX:0, ease:Back.easeIn, delay:.6});
			TweenMax.to(clip.tex1, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.8});
			TweenMax.to(clip.tex2, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.9, onComplete:kill});
		}
		
		
		private function kill():void
		{
			dispatchEvent(new Event(HIDDEN));
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function buttonWide():void
		{
			TweenMax.to(clip.btnTouch, 6, {scaleX:1.2, ease:Linear.easeNone, delay:.5, onComplete:buttonNormal});
		}
		
		
		private function buttonNormal():void
		{
			TweenMax.to(clip.btnTouch, 6, {scaleX:1, ease:Linear.easeNone, delay:.5, onComplete:buttonWide});
		}
		
		
		private function rebuild(e:TimerEvent):void
		{
			TweenMax.killAll();
			/*
			TweenMax.killTweensOf(clip.tex1);
			TweenMax.killTweensOf(clip.tex2);
			TweenMax.killTweensOf(clip.btnTouch);
			TweenMax.killTweensOf(clip.toucan);
			TweenMax.killTweensOf(clip.yellowBar);
			TweenMax.killTweensOf(clip.parrot);
			TweenMax.killTweensOf(clip.backFlower);
			TweenMax.killTweensOf(clip.butterfly);
			TweenMax.killTweensOf(clip.germanium);
			*/
			TweenMax.to(clip.btnTouch, .4, {y:1080, ease:Linear.easeNone});
			TweenMax.to(clip.yellowBar, .3, {scaleX:0, ease:Linear.easeIn, delay:.1});
			TweenMax.to(clip.backFlower, .4, {scaleY:0, ease:Back.easeIn, delay:.2});
			TweenMax.to(clip.parrot, .4, {scaleX:0, y:280, ease:Back.easeIn, delay:.3});
			TweenMax.to(clip.butterfly, .4, {scaleX:0, scaleY:0, delay:.4});
			TweenMax.to(clip.toucan, .3, {scaleY:0, ease:Back.easeIn, delay:.5});
			TweenMax.to(clip.germanium, .3, {scaleY:0, scaleX:0, ease:Back.easeIn, delay:.6});
			TweenMax.to(clip.tex1, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.8});
			TweenMax.to(clip.tex2, .4, {scaleX:0, scaleY:0, ease:Back.easeIn, delay:.9, onComplete:waitOneSec});
		}
		
		private function waitOneSec():void
		{
			TweenMax.delayedCall(2, show);
		}
		
		private function screenTouched(e:MouseEvent):void
		{			
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_DOWN, screenTouched);
			buildTimer.reset();
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}