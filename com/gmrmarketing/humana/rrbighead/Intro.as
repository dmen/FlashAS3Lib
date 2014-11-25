package com.gmrmarketing.humana.rrbighead
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	

	public class Intro extends EventDispatcher
	{
		public static const BEGIN:String = "btnPressed";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var btnTimer:Timer;
		
		public function Intro()
		{
			clip = new mcIntro();//lib
			btnTimer = new Timer(7500);
			btnTimer.addEventListener(TimerEvent.TIMER, animButton, false, 0, true);
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
			
			clip.girl.rotation = -90; //to 0
			clip.welcome.x = -1110; //to 16
			clip.theText.alpha = 0;
			clip.btn.x = -474; //to 96
			
			TweenMax.to(clip.welcome, 1, { x:16, ease:Back.easeOut } );
			TweenMax.to(clip.theText, 1.5, { alpha:1, delay:.7 } );
			TweenMax.to(clip.btn, .5, { x:96, ease:Back.easeOut, delay:.8 } );
			TweenMax.to(clip.girl, 1, { rotation:0, delay:1, ease:Bounce.easeOut } );
			
			btnTimer.start(); //calls animButton
			
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, btnPressed);
		}
		
		
		private function animButton(e:TimerEvent):void
		{
			TweenMax.to(clip.btn, .25, { x:200, ease:Bounce.easeOut } );
			TweenMax.to(clip.btn, .5, { x:96, ease:Bounce.easeOut, delay:.3 } );
		}
		
		
		public function showCount(count:int):void
		{
			clip.printCount.text = String(count);
		}
		
		
		public function hide():void
		{
			clip.btn.removeEventListener(MouseEvent.MOUSE_DOWN, btnPressed);
			btnTimer.stop();
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function btnPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(BEGIN));
		}
		
	}
	
}