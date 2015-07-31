package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	public class WinLose extends EventDispatcher
	{
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		public function WinLose()
		{
			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(which:String):void
		{
			if (which == "win") {
				clip = new mcWin();
			}else {
				clip = new mcLose();
			}
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		
		
	}
	
}