package com.gmrmarketing.humana.rrbighead
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class Dialog extends EventDispatcher
	{		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var wait:Timer;
		
		
		public function Dialog()
		{
			clip = new mcDialog();
			clip.x = 960;//dialog clip has center reg point
			clip.y = 490;
			
			wait = new Timer(15000, 1);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(message:String):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theText.text = message;
			clip.theText.y = Math.round((392 - clip.theText.textHeight) * .5);
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, dialogPressed, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1 } );
			
			wait.addEventListener(TimerEvent.TIMER, removeDialog);
			wait.start();			
		}
		
		
		private function dialogPressed(e:MouseEvent):void
		{
			removeDialog();
		}
		
		
		private function removeDialog(e:TimerEvent = null):void
		{
			wait.reset();
			wait.removeEventListener(TimerEvent.TIMER, removeDialog);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, dialogPressed);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}			
		}		
		
	}
	
}