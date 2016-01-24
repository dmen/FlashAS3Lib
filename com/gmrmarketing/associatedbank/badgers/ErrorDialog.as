package com.gmrmarketing.associatedbank.badgers
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class ErrorDialog
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function ErrorDialog()
		{
			clip = new mcError();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(m:String):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theText.text = m;
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
			TweenMax.to(clip, .5, { alpha:0, delay:2, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
	}
	
}