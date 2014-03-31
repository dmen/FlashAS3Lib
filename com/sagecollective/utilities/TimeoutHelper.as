/**
 * Singleton Timeout Helper
 * 
 * Instantiated by any classes that need to 
 * reset the timout handler on a button press
 * 
 * Main listend for the TIMED_OUT dispatch
 * 
 * Any other classes call buttonClicked() to
 * reset the timeout interval
 */

package com.sagecollective.utilities
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
		
		
		
		public function TimeoutHelper(p_key:SingletonBlocker)
		{			
		}
		
		
		public static function getInstance():TimeoutHelper 
		{
			if (instance == null) {
				instance = new TimeoutHelper(new SingletonBlocker());
			}
			return instance;
		}
		
		
		/**
		 * calls timedOut() when specified interval is up
		 */
		public function init():void
		{
			timeout = new Timer(90000, 1);
			timeout.addEventListener(TimerEvent.TIMER, timedOut, false, 0, true);
		}
		
		
		public function startMonitoring():void
		{
			if (!timeout) { init();}
			timeout.start();
		}
		
		
		public function stopMonitoring():void
		{
			timeout.reset();
		}
		
		
		/**
		 * Resets and restarts the timer
		 */
		public function buttonClicked():void
		{
			timeout.reset();
			timeout.start();
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