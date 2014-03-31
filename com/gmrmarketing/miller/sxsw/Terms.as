package com.gmrmarketing.miller.sxsw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;	
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	
	
	public class Terms extends EventDispatcher
	{	
		public static const TERMS_CLOSED:String = "theTermsWasClosed";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Terms()
		{			
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;			
			
			clip = new theTerms(); //lib clip
			clip.alpha = 0;			
			container.addChild(clip);
			TweenMax.to(clip, .5, { alpha:1 } );			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeTerms, false, 0, true);			
		}		
		
		
		//called from Main if the app times out
		public function hide():void
		{					
			if (clip) {
				clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeTerms);
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}			
			clip = null;			
		}
		
		
		private function closeTerms(e:MouseEvent):void
		{
			e.stopImmediatePropagation();			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeTerms);
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			container.removeChild(clip);
			clip = null;			
			dispatchEvent(new Event(TERMS_CLOSED));
		}		
		
	}
	
}