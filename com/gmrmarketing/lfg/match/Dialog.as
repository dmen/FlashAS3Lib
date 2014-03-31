package com.gmrmarketing.lfg.match
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import com.greensock.TweenLite;
	
	
	public class Dialog extends EventDispatcher
	{
		public static const PLAY_AGAIN:String = "playAgain";		
		
		private var clip:MovieClip;
		private var winClip:MovieClip;
		private var container:DisplayObjectContainer;
		private var startTime:int;
		private var speed:Number; //degrees per millisecond
		private const fullRotation:int = 5; //rotate once in x seconds
		
		
		public function Dialog()
		{
			clip = new clipDialog();
			clip.x = 276;
			clip.y = 214;
			
			winClip = new clipWinDialog();			
			
			speed = (360 / fullRotation) / 1000;
		}
		
		
		public function show($container:DisplayObjectContainer, message:String):void
		{
			container = $container;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			if (container.contains(winClip)) {
				winClip.btnAgain.removeEventListener(MouseEvent.MOUSE_DOWN, again);
				container.removeChild(winClip);
			}
			
			clip.theText.text = message;
			clip.addEventListener(Event.ENTER_FRAME, updateRotator, false, 0, true);
			startTime = getTimer();
		}
		
		
		public function hide():void
		{			
			if(container){
				if (container.contains(clip)) {
					clip.removeEventListener(Event.ENTER_FRAME, updateRotator);
					TweenLite.to(clip, .5, { alpha:0, onComplete:kill } );					
				}
			}
		}
		
		private function kill():void
		{
			container.removeChild(clip);
		}
		
		public function showWin($container:DisplayObjectContainer, time:String, didWin:Boolean):void
		{
			container = $container;
			
			if (!container.contains(winClip)) {
				container.addChild(winClip);
			}
			
			winClip.alpha = 0;
			
			if (didWin) {
				winClip.resultText.text = "CONGRATULATIONS!";
				winClip.theText.text = "You completed the game with " + time + " seconds remaining!";
			}else {
				winClip.resultText.text = "SORRY!";
				winClip.theText.text = "Your time has run out, better luck next time.";
			}
			
			winClip.btnAgain.addEventListener(MouseEvent.MOUSE_DOWN, again, false, 0, true);
			
			TweenLite.to(winClip, 1, { alpha:1 } );
		}
		
		
		public function hideWin():void
		{
			if(container){
				if (container.contains(winClip)) {
					winClip.btnAgain.removeEventListener(MouseEvent.MOUSE_DOWN, again);
					TweenLite.to(winClip, .5, { alpha:0, onComplete:killWin } );					
				}
			}
		}
		
		
		private function killWin():void
		{
			container.removeChild(winClip);			
		}
		
		
		/**
		 * Called by clicking theplay again button
		 * @param	e
		 */
		private function again(e:MouseEvent):void
		{
			dispatchEvent(new Event(PLAY_AGAIN));
		}
		
		
		
		/**
		 * Rotate the object - elapsed ms * speed
		 * @param	e
		 */
		private function updateRotator(e:Event):void
		{	
			clip.rotator.rotation += (getTimer() - startTime) * speed;
		}
		
	}
	
}