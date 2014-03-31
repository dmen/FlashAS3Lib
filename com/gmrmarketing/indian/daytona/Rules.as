package com.gmrmarketing.indian.daytona
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;	
	import com.greensock.TweenMax;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Rules
	{
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;		
		private var theFrame:int;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Rules()
		{
			timeoutHelper = TimeoutHelper.getInstance();
			clip = new rules(); //lib clip			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}		
		
	
		public function show(which:int):void
		{			
			theFrame = which;
			
			clip.addEventListener(Event.ADDED_TO_STAGE, addListener);
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;			
			
			TweenMax.to(clip, .5, { alpha:1 } );
			
			timeoutHelper.changeInterval(300000); //5 minutes for reading
		}
		
		
		private function addListener(e:Event):void
		{
			clip.gotoAndStop(theFrame);
			
			clip.removeEventListener(Event.ADDED_TO_STAGE, addListener);				
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, close, false, 0, true);
		}
		
		
		public function hide():void
		{
			kill();
		}
		
		
		private function close(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked(); //resets interval to the one set by Main
			
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, close);
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
	}	
	
}