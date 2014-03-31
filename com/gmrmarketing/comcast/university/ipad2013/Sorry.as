package com.gmrmarketing.comcast.university.ipad2013
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.media.*;
	
	public class Sorry extends EventDispatcher
	{
		public static const SORRY_SHOWING:String = "sorryShowing";
		public static const SORRY_COMPLETE:String = "sorryComplete";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var sorry:Sound;
		
		
		public function Sorry() 
		{
			clip = new mcSorry();
			sorry = new audSorry();
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
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, sorryComplete, false, 0, true);
			
			clip.y = clip.height;//put at screen bottom
			TweenMax.to(clip, 1, { y:0, onComplete:showing } );//tween up to show
			
			sorry.play();
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SORRY_SHOWING));
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function sorryComplete(e:MouseEvent):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, sorryComplete);
			dispatchEvent(new Event(SORRY_COMPLETE));
		}
		
	}
	
}