package com.gmrmarketing.esurance.usopen_2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	public class Dialog
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		public function Dialog()
		{
			clip = new mcDialog();			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(mess:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.x = 209;
			clip.y = 244;
			clip.alpha = 0;
			clip.theText.text = mess;
			TweenLite.to(clip, 1, { alpha:1, y:144, easing:Back.easeOut } );
			TweenLite.delayedCall(3, hide);
		}
		
		
		private function hide():void
		{
			TweenLite.to(clip, 1, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
	}
	
}