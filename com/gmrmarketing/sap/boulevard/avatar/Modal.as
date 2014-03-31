package com.gmrmarketing.sap.boulevard.avatar
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;	
	import com.greensock.easing.*;
	
	public class Modal extends EventDispatcher 
	{
		public static const SHOWING:String = "dialogShowing";
		public static const HIDING:String = "dialogHiding";		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		private var autoDelay:int;
		
		public function Modal()
		{
			clip = new mcModal();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(message:String, title:String = "ALERT!", autoHide:Boolean = false, showClose:Boolean = false, delay:int = 3, fullBlack:Boolean = false):void
		{			
			if (!container.contains(clip)) {
				container.addChild(clip);				
			}
			clip.alpha = 1;
			if (fullBlack) {
				clip.bg.alpha = 1;
			}else{
				clip.bg.alpha = .75;
			}
			clip.dialog.y = 510;
			clip.dialog.alpha = 0;
			clip.dialog.theTitle.text = title;
			clip.dialog.theText.text = message;
			
			if(showClose){
				clip.btnClose.alpha = 1;
				clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			}else {
				clip.btnClose.alpha = 0;
				clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			}			
			
			autoDelay = delay;
			
			if (autoHide) {
				TweenMax.to(clip.dialog, .5, { y:310, alpha:1, ease:Back.easeOut } );
				TweenMax.delayedCall(autoDelay, hide);
			}else {
				TweenMax.to(clip.dialog, .5, { y:310, alpha:1, ease:Back.easeOut, onComplete:showing } );
			}
		}		
		
		
		private function showing():void
		{	
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide(e:MouseEvent = null):void
		{			
			TweenMax.to(clip, .5, { alpha:0, onComplete:done } );
			TweenMax.to(clip.btnClose, .5, { alpha:0 } );
		}
		
		
		public function done():void
		{			
			dispatchEvent(new Event(HIDING));
		}
		
		public function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
		}
		
	}
	
}