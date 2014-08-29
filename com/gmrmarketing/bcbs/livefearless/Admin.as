package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	
	public class Admin extends EventDispatcher
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Admin() 
		{
			clip = new mcAdmin();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}else {
				//move to top
				container.removeChild(clip);
				container.addChild(clip);
			}
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			clip.btnClear.addEventListener(MouseEvent.MOUSE_DOWN, doClear, false, 0, true);
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		
		public function moveToTop():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
				container.addChild(clip);
			}
		}
		
		private function doClear(e:MouseEvent):void
		{
			clip.theText.text = "";
			clip.theText.scrollV = clip.theText.numLines;	
		}
		
		public function displayDebug(mess:String):void
		{			
			clip.theText.appendText(mess + "\n");
			clip.theText.scrollV = clip.theText.numLines;			
		}
		
		
		public function hide(e:MouseEvent = null):void
		{			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			clip.btnClear.removeEventListener(MouseEvent.MOUSE_DOWN, doClear);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}		
		
	}
	
}