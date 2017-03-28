package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		public static const HIDDEN:String = "introHidden";
		
		private var sr1:SlideReveal;
		private var sr2:SlideReveal;
		private var sr3:SlideReveal;
		
		private var badge1:MovieClip;
		private var badge2:MovieClip;
		private var badge3:MovieClip;
		
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var wait:Timer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			
			wait = new Timer(3000, 1);			
			
			sr1 = new SlideReveal(new shoeTread1(), 6);
			sr2 = new SlideReveal(new shoeTread2(), 6);
			sr3 = new SlideReveal(new shoeTread3(), 6);
			
			sr1.x = 842;// 840;
			sr1.y = 96;// 106;
			sr1.rotation = -26;
			sr1.scaleY = 1.01;
			
			sr2.x = 842;// 840;
			sr2.y = 96;// 106;
			sr2.rotation = -26;
			sr2.scaleY = 1.01;
			
			sr3.x = 842;// 840;
			sr3.y = 96;// 106;
			sr3.rotation = -26;
			sr3.scaleY = 1.01;
			
			badge1 = new mcBadgeRookie();
			badge2 = new mcBadgeWeekend();
			badge3 = new mcBadgeLegend();
			
			badge1.scaleX = badge1.scaleY = .8;
			badge2.scaleX = badge2.scaleY = .8;
			badge3.scaleX = badge3.scaleY = .8;
			
			badge1.x = 1420;
			badge1.y = 300;
			badge2.x = 1420;
			badge2.y = 300;
			badge3.x = 1420;
			badge3.y = 300;
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
			
			if(!clip.contains(sr1)){
				clip.addChild(sr1);
			}
			if(!clip.contains(sr2)){
				clip.addChild(sr2);
			}
			if(!clip.contains(sr3)){
				clip.addChild(sr3);
			}
			
			clip.x = 0;
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, introDone, false, 0, true);
			
			begin();
		}
		
		
		public function hide():void
		{
			wait.reset();
			wait.removeEventListener(TimerEvent.TIMER, hideSr1);
			wait.removeEventListener(TimerEvent.TIMER, hideSr2);
			wait.removeEventListener(TimerEvent.TIMER, hideSr3);
			
			TweenMax.killTweensOf(badge1);
			TweenMax.killTweensOf(badge2);
			TweenMax.killTweensOf(badge3);
			
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		
		private function kill():void
		{	
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			if (clip.contains(badge1)){
				clip.removeChild(badge1);
			}
			if (clip.contains(badge2)){
				clip.removeChild(badge2);
			}
			if (clip.contains(badge3)){
				clip.removeChild(badge3);
			}
			if (clip.contains(sr1)){
				clip.removeChild(sr1);
			}
			if (clip.contains(sr2)){
				clip.removeChild(sr2);
			}
			if (clip.contains(sr3)){
				clip.removeChild(sr3);
			}
			
			
			dispatchEvent(new Event(HIDDEN));
		}
		
		
		private function begin():void
		{
			if (clip.contains(badge3)){
				clip.removeChild(badge3);
			}
			
			sr1.addEventListener(SlideReveal.SHOWING, sr1Showing, false, 0, true);
			sr1.reveal();
		}
		
		
		private function sr1Showing(e:Event):void
		{
			if (!clip.contains(badge1)){
				clip.addChild(badge1);
			}
			badge1.alpha = 0;
			TweenMax.to(badge1, .75, {alpha:1, delay:.25});
			
			wait.addEventListener(TimerEvent.TIMER, hideSr1, false, 0, true);
			wait.start();
		}
		
		
		private function hideSr1(e:TimerEvent):void
		{
			wait.removeEventListener(TimerEvent.TIMER, hideSr1);
			
			sr1.addEventListener(SlideReveal.HIDDEN, sr1Hidden, false, 0, true);
			sr1.hide();
			
			TweenMax.to(badge1, .5, {alpha:0});
		}
		
		private function sr1Hidden(e:Event):void
		{		
			sr1.removeEventListener(SlideReveal.HIDDEN, sr1Hidden);
			
			sr2.addEventListener(SlideReveal.SHOWING, sr2Showing, false, 0, true);
			sr2.reveal();
		}
		
		
		private function sr2Showing(e:Event):void
		{
			if (clip.contains(badge1)){
				clip.removeChild(badge1);
			}
			if (!clip.contains(badge2)){
				clip.addChild(badge2);
			}
			badge2.alpha = 0;
			TweenMax.to(badge2, .75, {alpha:1, delay:.25});
			
			wait.addEventListener(TimerEvent.TIMER, hideSr2, false, 0, true);
			wait.start();
		}
		
		
		private function hideSr2(e:TimerEvent):void
		{
			wait.removeEventListener(TimerEvent.TIMER, hideSr2);
			
			sr2.addEventListener(SlideReveal.HIDDEN, sr2Hidden, false, 0, true);
			sr2.hide();
			
			TweenMax.to(badge2, .5, {alpha:0});
		}
		
		private function sr2Hidden(e:Event):void
		{
			sr2.removeEventListener(SlideReveal.HIDDEN, sr2Hidden);
			
			sr3.addEventListener(SlideReveal.SHOWING, sr3Showing, false, 0, true);
			sr3.reveal();
		}
		
		
		private function sr3Showing(e:Event):void
		{
			if (clip.contains(badge2)){
				clip.removeChild(badge2);
			}
			if (!clip.contains(badge3)){
				clip.addChild(badge3);
			}
			
			badge3.alpha = 0;
			TweenMax.to(badge3, .75, {alpha:1, delay:.25});
			
			wait.addEventListener(TimerEvent.TIMER, hideSr3, false, 0, true);
			wait.start();
		}
		
		
		private function hideSr3(e:TimerEvent):void
		{
			wait.removeEventListener(TimerEvent.TIMER, hideSr3);
			
			sr3.addEventListener(SlideReveal.HIDDEN, sr3Hidden, false, 0, true);
			sr3.hide();
			
			TweenMax.to(badge3, .5, {alpha:0});
		}
		
		
		private function sr3Hidden(e:Event):void
		{
			sr3.removeEventListener(SlideReveal.HIDDEN, sr3Hidden);
			begin();
		}
		
		
		private function introDone(e:MouseEvent):void
		{
			sr1.kill();
			sr2.kill();
			sr3.kill();
			wait.reset();
			
			sr1.removeEventListener(SlideReveal.SHOWING, sr1Showing);
			sr1.removeEventListener(SlideReveal.HIDDEN, sr1Hidden);
			
			sr2.removeEventListener(SlideReveal.SHOWING, sr2Showing);
			sr2.removeEventListener(SlideReveal.HIDDEN, sr2Hidden);
			
			sr3.removeEventListener(SlideReveal.SHOWING, sr3Showing);
			sr3.removeEventListener(SlideReveal.HIDDEN, sr3Hidden);
			
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, introDone);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
	}
	
}