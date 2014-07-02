package com.gmrmarketing.rbc.etransfer
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	
	public class Privacy extends EventDispatcher
	{
		public static const CLOSE_PRIVACY:String = "closePrivacy";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		
		public function Privacy()
		{
			clip = new mcPrivacy();	
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
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, closePrivacy, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		public function hide():void
		{
			TweenMax.to(clip, 1, { alpha:0, onComplete:killClip } );
		}
		
		private function closePrivacy(e:MouseEvent):void
		{
			clip.btn.removeEventListener(MouseEvent.MOUSE_DOWN, closePrivacy);
			dispatchEvent(new Event(CLOSE_PRIVACY));
		}
		
		private function killClip():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}
	
}