package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		
		public function Thanks()
		{
			clip = new mcThanks();
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(email:Boolean):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if (email) {
				clip.theText.text = "Your photo has printed and will be\nemailed to you shortly!";
				clip.exit.y = 612;
			}else {
				clip.theText.text = "Your photo has printed.";
				clip.exit.y = 532;
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateGlow);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);			
			dispatchEvent(new Event(SHOWING));
			TweenMax.delayedCall(10, thanksComplete);
		}
		
		
		private function thanksComplete():void
		{
			tim.buttonClicked();			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function updateGlow(e:Event):void
		{
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
	}
	
}