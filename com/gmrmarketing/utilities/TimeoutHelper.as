/**
 * Singleton Timeout Helper
 * 
 * Instantiated by any classes that need to 
 * reset the timeout handler on a button press
 * 
 * Main listens for the TIMED_OUT dispatch
 * 
 * Usage
 * 
 * in the Main class -
 * import com.gmrmarketing.utilities.TimeoutHelper;
 * 
 * constructor-
   timeoutHelper = TimeoutHelper.getInstance();
   timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
   timeoutHelper.init(120000);
   timeoutHelper.startMonitoring();
 * 
 * Call your init method within doReset()
 * 
 * In any other classes that need to notify Main that some user generated event has occured
 * and to reset the timeout, call buttonClicked() 
 * 
 * import com.gmrmarketing.utilities.TimeoutHelper;
 * 
 * timeoutHelper = TimeoutHelper.getInstance();
 * 
 * timeoutHelper.buttonClicked();
 */

package com.gmrmarketing.utilities
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class TimeoutHelper extends EventDispatcher
	{
		private static var instance:TimeoutHelper;
		public static const TIMED_OUT:String = "appTimedOut";
		
		private var timeout:Timer;
		private var interval:int;
		
		private var running:Boolean;
		
		
		
		public function TimeoutHelper(p_key:SingletonBlocker)
		{			
		}
		
		
		/**
		 * Returns the single instance of TimeoutHelper
		 * @return
		 */
		public static function getInstance():TimeoutHelper 
		{
			if (instance == null) {
				instance = new TimeoutHelper(new SingletonBlocker());
			}
			return instance;
		}
		
		
		/**
		 * Initializes the timer
		 * calls timedOut() when specified interval is up
		 * Default is 2 min
		 */
		public function init(ms:int = 120000):void
		{
			interval = ms;
			timeout = new Timer(interval, 1);
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
		}
		
		
		/**
		 * restarts monitoring if stopMonitoring has been called
		 */
		public function startMonitoring():void
		{
			if (!timeout) { init();}
			timeout.start();
			running = true;
		}
		
		
		/**
		 * Stops the timer
		 */
		public function stopMonitoring():void
		{
			if (timeout) {
				running = false;
				timeout.reset();
			}
		}
		
		
		/**
		 * Resets and restarts the timer
		 */
		public function buttonClicked():void
		{	
			if(timeout){
				timeout.reset();
				if(running){
					timeout.start();
				}
			}
		}
		
		
		/**
		 * Temporarily changes the interval - will be reset 
		 * to the original interval when buttonClicked is called
		 * 
		 * @param	newInt
		 */
		public function changeInterval(newInt:int):void
		{
			if(timeout){
				timeout.delay = newInt;
				timeout.start();
			}
		}
		
		
		/**
		 * Dispatches TIMED_OUT
		 * @param	e
		 */
		private function timedOut(e:TimerEvent):void
		{			
			buttonClicked();
			dispatchEvent(new Event(TIMED_OUT));
		}
	}	
}

internal class SingletonBlocker {}