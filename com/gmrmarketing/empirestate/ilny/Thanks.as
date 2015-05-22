package com.gmrmarketing.empirestate.ilny
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Thanks extends EventDispatcher
	{
		public static const SHOWING:String = "thanksShowing";
		public static const COMPLETE:String = "thanksComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Thanks()
		{
			clip = new mcThanks();
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
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
			TweenMax.delayedCall(10, complete);		
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		private function complete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}