package com.gmrmarketing.humana.rrbighead
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	
	public class ThankYou extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var theTimer:Timer;
		
		private var im:Bitmap;
		
		public function ThankYou()
		{
			clip = new mcThanks();
			theTimer = new Timer(30000, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		//pic comes in at 800x800
		public function show(pic:BitmapData):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			var m:Matrix = new Matrix();
			m.scale(.8125, .8125); //to scale 800x800 to 650x650
			
			var bmd:BitmapData = new BitmapData(650, 650);
			bmd.draw(pic, m, null, null, null, true);
			im = new Bitmap(bmd);
			im.x = 1188;
			im.y = 311;
			myContainer.addChild(im);
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if(im){
					if(myContainer.contains(im)){
						myContainer.removeChild(im);
					}
				}
			}
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
			
			theTimer.addEventListener(TimerEvent.TIMER, timedOut);
			theTimer.start();
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, interruptTimer, false, 0, true);
		}
		
		
		private function interruptTimer(e:MouseEvent):void
		{			
			theTimer.reset();
			timedOut();
		}
		
		
		private function timedOut(e:TimerEvent = null):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, interruptTimer);
			theTimer.removeEventListener(TimerEvent.TIMER, timedOut);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}