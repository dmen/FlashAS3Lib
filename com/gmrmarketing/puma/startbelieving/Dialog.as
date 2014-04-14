package com.gmrmarketing.puma.startbelieving
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	
	public class Dialog
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Dialog() 
		{
			clip = new mcDialog(); //lib clip
			clip.x = 685;
			clip.y = 330;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(mess:String):void
		{
			clip.theText.text = mess;
			clip.theText.y = Math.round(28 + ((225 - clip.theText.textHeight) * .5));
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
			TweenMax.delayedCall(2, closeDialog);
		}
		
		
		private function closeDialog():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:killDialog } );
		}
		
		
		private function killDialog():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}