package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class ThankYou extends EventDispatcher
	{
		public static const THANKYOU_SHOWING:String = "thanksShowing";
		public static const THANKYOU_COMPLETE:String = "thanksComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function ThankYou() 
		{
			clip = new mcThanks();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, thanksComplete, false, 0, true);
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(THANKYOU_SHOWING));
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function thanksComplete(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, thanksComplete);
			dispatchEvent(new Event(THANKYOU_COMPLETE));
		}
		
	}
	
}