package com.gmrmarketing.nissan.rodale2013
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
		public static const COMPLETE:String = "dialogDone";
		public static const THANKS_DONE:String = "thanksDone";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var wait:Timer;
		
		
		public function Dialog()
		{
			clip = new mcDialog();
			clip.x = 538;
			clip.y = 300;
			wait = new Timer(15000, 1); //15 sec
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(message:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = message;
			clip.theText.y = Math.round((392 - clip.theText.textHeight) * .5);
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, dialogPressed, false, 0, true);
			
			wait.addEventListener(TimerEvent.TIMER, done, false, 0, true);
			wait.start();			
		}
		
		
		public function thanks():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.theText.text = "Thank You!";
			clip.theText.y = Math.round((392 - clip.theText.textHeight) * .5);
			
			TweenMax.to(clip, 1, { alpha:0, delay:2, onComplete:kill } );
		}
		
		
		private function dialogPressed(e:MouseEvent):void
		{
			done();
		}
		
		
		private function done(e:TimerEvent = null):void
		{
			kill();
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function kill():void
		{
			wait.reset();
			wait.removeEventListener(TimerEvent.TIMER, done);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, dialogPressed);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.alpha = 1;
			dispatchEvent(new Event(THANKS_DONE));
		}
		
		
	}
	
}