package com.gmrmarketing.comcast.university.matchup
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	
	public class Dialog extends EventDispatcher
	{
		public static const YES_PLEASE:String = "yesPlease";
		public static const NO_THANKS:String = "noThanks";
		public static const LEADER:String = "addLeader";
		
		private var clip:MovieClip;
		private var winClip:MovieClip;
		private var container:DisplayObjectContainer;
		private var startTime:int;
		private var speed:Number; //degrees per millisecond
		private const fullRotation:int = 5; //rotate once in x seconds
		
		
		public function Dialog()
		{
			TweenPlugin.activate([TintPlugin]);
			
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
				winClip.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, noThanks);
				winClip.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, yesPlease);
				//winClip.btnLeader.removeEventListener(MouseEvent.MOUSE_DOWN, addLeader);
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
		
		
		public function disableLeader():void
		{
			//winClip.btnLeader.removeEventListener(MouseEvent.MOUSE_DOWN, addLeader);
			//winClip.btnLeader.alpha = .4;
		}
		
		private function kill():void
		{
			container.removeChild(clip);
		}
		
		public function showWin($container:DisplayObjectContainer, time:String, points:int):void
		{
			container = $container;
			
			if (!container.contains(winClip)) {
				container.addChild(winClip);
			}
			
			winClip.alpha = 0;	
			winClip.theText.text = "You matched all the cards in " + time + " seconds";
			winClip.theText2.text = "and scored " + String(points) + " points";
			winClip.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, yesPlease, false, 0, true);
			winClip.btnYes.addEventListener(MouseEvent.MOUSE_OVER, yesHighlight, false, 0, true);
			winClip.btnYes.addEventListener(MouseEvent.MOUSE_OUT, removeYesHighlight, false, 0, true);
			winClip.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, noThanks, false, 0, true);
			winClip.btnNo.addEventListener(MouseEvent.MOUSE_OVER, noHighlight, false, 0, true);
			winClip.btnNo.addEventListener(MouseEvent.MOUSE_OUT, removeNoHighlight, false, 0, true);
			//winClip.btnLeader.addEventListener(MouseEvent.MOUSE_DOWN, addLeader, false, 0, true);
			TweenLite.to(winClip, 1, { alpha:1 } );
		}
		
		
		private function yesHighlight(e:MouseEvent):void
		{
			TweenLite.to(winClip.theYes, 0, {tint:0xE41720});			
		}
		
		private function noHighlight(e:MouseEvent):void
		{
			TweenLite.to(winClip.theNo, 0, {tint:0xE41720});			
		}
		
		private function removeYesHighlight(e:MouseEvent):void
		{
			TweenLite.to(winClip.theYes, 0, {tint:null});			
		}
		
		private function removeNoHighlight(e:MouseEvent):void
		{
			TweenLite.to(winClip.theNo, 0, {tint:null});			
		}
		
		
		public function hideWin():void
		{
			if(container){
				if (container.contains(winClip)) {
					winClip.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, noThanks);
					winClip.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, yesPlease);
					//winClip.btnLeader.removeEventListener(MouseEvent.MOUSE_DOWN, addLeader);
					TweenLite.to(winClip, .5, { alpha:0, onComplete:killWin } );					
				}
			}
		}
		
		
		private function killWin():void
		{
			container.removeChild(winClip);
			
		}
		
		/**
		 * Called by clicking the yes share my score button in the win dialog
		 * @param	e
		 */
		private function yesPlease(e:MouseEvent):void
		{
			dispatchEvent(new Event(YES_PLEASE));
		}
		
		
		/**
		 * Called by clicking the 'no, tell them later' button in the win dialog
		 * @param	e
		 */
		private function noThanks(e:MouseEvent):void
		{			
			dispatchEvent(new Event(NO_THANKS));
		}
		
		
		/**
		 * Called by pressing the leader board button in the win dialog
		 * @param	e
		 */
		private function addLeader(e:MouseEvent):void
		{
			dispatchEvent(new Event(LEADER));
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