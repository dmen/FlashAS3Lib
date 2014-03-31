/**
 * Generic numeric stepper
 * 
 * Used By:
 *		Corona ATP
 */

package com.sagecollective.utilities
{
	import flash.events.*;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	public class NumericStepper extends EventDispatcher
	{
		public static const CLICKED:String = "buttonClicked";
		
		private var curNum:int;
		private var theField:TextField;
		private var pauseTimer:Timer;
		private var speedTimer:Timer;
		private var theMin:int;
		private var theMax:int;
		
		private var btnUp:DisplayObject;
		private var btnDown:DisplayObject;
		
		/**
		 * CONSTRUCTOR
		 * 
		 * @param	upButton Reference to the up / increase button
		 * @param	downButton Reference to the down / decrease button
		 * @param	numField Text field to use for display
		 * @param	min The minimum number the stepper can display
		 * @param	max The maximum number the stepper can display
		 */
		public function NumericStepper(upButton:DisplayObject, downButton:DisplayObject, numField:TextField, min:int, max:int)
		{
			btnUp = upButton;
			btnDown = downButton;
			
			curNum = parseInt(numField.text);
			theField = numField;
			
			theMin = min;
			theMax = max;
			
			pauseTimer = new Timer(500, 1); //wait 1/2 sec before speed stepping	
			speedTimer = new Timer(50); //50ms between steps when in speed mode			
			
			btnUp.addEventListener(MouseEvent.MOUSE_DOWN, beginUp, false, 0, true);
			btnUp.addEventListener(Event.ADDED_TO_STAGE, addStageListeners);
			btnDown.addEventListener(MouseEvent.MOUSE_DOWN, beginDown, false, 0, true);					
		}
		
		
		private function addStageListeners(e:Event):void
		{
			btnUp.stage.addEventListener(MouseEvent.MOUSE_UP, stopFast, false, 0, true);			
		}
		
		/**
		 * Retrieves the current number of the stepper
		 * @return
		 */
		public function getNum():int
		{
			return curNum;
		}
		
		
		/**
		 * Removes listeners and disables the stepper
		 */
		public function disable():void
		{
			btnUp.removeEventListener(MouseEvent.MOUSE_DOWN, beginUp);
			btnUp.stage.removeEventListener(MouseEvent.MOUSE_UP, stopFast);
			
			btnDown.removeEventListener(MouseEvent.MOUSE_DOWN, beginDown);
			btnDown.stage.removeEventListener(MouseEvent.MOUSE_UP, stopFast);
			
			btnUp.stage.removeEventListener(MouseEvent.MOUSE_UP, stopFast);
		}
		
		
		
		// PRIVATE
		
		private function beginUp(e:MouseEvent):void
		{
			inc();
			pauseTimer.addEventListener(TimerEvent.TIMER, fastUp, false, 0, true);			
			pauseTimer.start();
		}
		
		private function fastUp(e:TimerEvent):void
		{			
			speedTimer.addEventListener(TimerEvent.TIMER, inc, false, 0, true);
			speedTimer.start();
		}
		
		private function stopFast(e:MouseEvent):void
		{
			pauseTimer.stop();
			pauseTimer.removeEventListener(TimerEvent.TIMER, fastUp);
			pauseTimer.removeEventListener(TimerEvent.TIMER, fastDown);
			
			speedTimer.stop();
			speedTimer.removeEventListener(TimerEvent.TIMER, inc);
			speedTimer.removeEventListener(TimerEvent.TIMER, dec);
		}
		
		private function beginDown(e:MouseEvent):void
		{
			dec();
			pauseTimer.addEventListener(TimerEvent.TIMER, fastDown, false, 0, true);			
			pauseTimer.start();
		}
		
		private function fastDown(e:TimerEvent):void
		{			
			speedTimer.addEventListener(TimerEvent.TIMER, dec, false, 0, true);
			speedTimer.start();
		}
		
		private function inc(e:TimerEvent = null):void
		{			
			curNum++;
			if (curNum > theMax) { curNum = theMax; }
			update();
		}
		
		private function dec(e:TimerEvent = null):void
		{
			curNum--;
			if (curNum < theMin) { curNum = theMin; }
			update();
		}
		
		private function update():void
		{
			dispatchEvent(new Event(CLICKED));
			theField.text = String(curNum);
		}
		
	}
	
}