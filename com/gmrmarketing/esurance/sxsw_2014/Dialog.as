package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Dialog extends EventDispatcher
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
		
		
		public function show(message:String):void
		{
			if (container) {
				if (!container.contains(clip)) {
					container.addChild(clip);
					clip.x = (1920 - clip.width) * .5;
					clip.y = (1080 - clip.height) * .5;
				}
			}
			clip.theText.text = message;
			clip.alpha = 0;
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		
		public function hide(e:MouseEvent = null):void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
		}
		
		
	}	
}