package com.gmrmarketing.pm.quickdraw
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import org.wiiflash.Wiimote;
	import flash.utils.getTimer;
	
	public class Intro extends Sprite
	{
		public const COMPLETE:String = "introIsComplete";
		public const CONTENT_LOADED:String = "introIsLoaded";
		
		private var loader:Loader;
		private var controller:IController;
		private var startHolsterTime:Number;
		private var numberTimer:Timer;
		private var num:int = 3;
		private var myClip:MovieClip;
		
		
		public function Intro(c:IController)
		{
			controller = c;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, assignClip, false, 0, true);
			loader.load(new URLRequest("wii_intro.swf"));
			addChild(loader);
			
			numberTimer = new Timer(1000);
			numberTimer.addEventListener(TimerEvent.TIMER, changeNumber, false, 0, true);
		}
		
		
		/**
		 * Called on load complete
		 * @param	e
		 */
		private function assignClip(e:Event):void
		{
			myClip = MovieClip(loader.content);
			dispatchEvent(new Event(CONTENT_LOADED)); //engine listens
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, assignClip);
			myClip.theText.text = "PRESS TRIGGER TO START";
		}
		
		
		/**
		 * Called from engine when the trigger is pressed on the wiimote
		 * starts calling checkForHolstered
		 */
		public function begin():void
		{
			myClip.theText.text = "HOLSTER PISTOL";
			addEventListener(Event.ENTER_FRAME, checkForHolstered, false, 0, true);
		}
		
		
		/**
		 * Called by enter frame - checks if the wiimote is pointing down - tilt > 1
		 * if it is, it gets the current time and starts calling checkForContinue
		 * which runs for 3 sec
		 * @param	e
		 */
		private function checkForHolstered(e:Event):void
		{
			if (controller.getTilt() >= 1) {				
				myClip.theText.text = "STARTING IN " + num;
				removeEventListener(Event.ENTER_FRAME, checkForHolstered);
				addEventListener(Event.ENTER_FRAME, checkForContinue, false, 0, true);
				startHolsterTime = getTimer();
				numberTimer.start();
			}
		}
		
		
		/**
		 * Checks to see the controller remains holstered
		 * if it does then a complete is dispatched to the engine and the timer stops
		 * if the tilt becomes less than 1 then the timer starts over and Holster Pistol is displayed
		 * 
		 * @param	e
		 */
		private function checkForContinue(e:Event):void
		{
			if (controller.getTilt() >= 1) {
				if (getTimer() - startHolsterTime > 3000) {
					removeEventListener(Event.ENTER_FRAME, checkForContinue);
					numberTimer.stop();
					numberTimer.removeEventListener(TimerEvent.TIMER, changeNumber);
					dispatchEvent(new Event(COMPLETE));
				}
			}else {
				removeEventListener(Event.ENTER_FRAME, checkForContinue);
				begin();
				numberTimer.reset();
				num = 3;
			}
		}
		
		
		private function changeNumber(e:TimerEvent):void
		{
			num--;
			if (num < 1) { num = 1; }
			myClip.theText.text = "STARTING IN " + num;
		}
	}
	
}