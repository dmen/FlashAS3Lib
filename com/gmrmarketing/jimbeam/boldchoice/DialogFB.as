/**
 * Displays a modal message dialog for three seconds
 */

package com.gmrmarketing.jimbeam.boldchoice 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class DialogFB extends EventDispatcher
	{
		public static const DIALOG_REMOVED:String = "dialogRemoved";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var clipTimer:Timer;
		
		
		public function DialogFB()
		{
			clip = new the_dialog(); //lib clip
			clipTimer = new Timer(3000, 1);
			
		}
		
		
		/**
		 * Shows the timer for three seconds and then hides and removes it
		 * @param	$container
		 * @param	message
		 */
		public function show($container:DisplayObjectContainer, message:String):void
		{
			container = $container;
			clip.theText.text = message;
			clip.alpha = 0;
			
			clip.theText.y = 180 + ((174 - clip.theText.textHeight) / 2);
			
			container.addChild(clip);
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:startTimer } );
		}
		
		
		private function startTimer():void
		{
			clipTimer.addEventListener(TimerEvent.TIMER, removeDialog, false, 0, true);
			clipTimer.start();
		}
		
		
		private function removeDialog(e:TimerEvent):void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:killDialog } );
		}
		
		
		private function killDialog():void
		{
			dispatchEvent(new Event(DIALOG_REMOVED));
			
			container.removeChild(clip);
			clipTimer.removeEventListener(TimerEvent.TIMER, removeDialog);
		}
		
		
	}
	
}