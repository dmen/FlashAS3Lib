package com.rimv.utils
{

	/**
   @author    	RimV 
   @class     	DynamicScroller2 inherit DynamicScroller - create rollover effect
   @package   	Utilities
	*/
   
	
	import flash.display.*;
	import com.rimv.utils.DynamicScroller;
	import flash.events.MouseEvent;
	import gs.TweenMax;
	import gs.easing.*;
	
	public class DynamicScroller2 extends DynamicScroller
	{
		// parameters
		private var tTime:Number = 0.5;
		
		// misc vars
		private var isDown:Boolean = false;
		
		public function get transitionTime():Number
		{
			return tTime;
		}
		
		public function set transitionTime(nu:Number):void
		{
			this.tTime = nu;
		}
		
		// constructor
		public function DynamicScroller2()
		{
			super();
			// Rollover effect scrubber
			scrubber.addEventListener(MouseEvent.ROLL_OVER, scrubberOver);
			scrubber.addEventListener(MouseEvent.ROLL_OUT, scrubberOut);
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberDown2);
			// rollover effect right / left button
			leftButton.addEventListener(MouseEvent.ROLL_OVER, leftButtonOver);
			leftButton.addEventListener(MouseEvent.ROLL_OUT, leftButtonOut);
			rightButton.addEventListener(MouseEvent.ROLL_OVER, rightButtonOver);
			rightButton.addEventListener(MouseEvent.ROLL_OUT, rightButtonOut);
		}
		
		// Scrubber Roll Over
		private function scrubberOver(e:MouseEvent = null):void
		{
			TweenMax.to(scrubber.scrubberOverClip , tTime, { alpha:1} );
		}
		
		// Scrubber Roll Out
		private function scrubberOut(e:MouseEvent = null):void
		{
			if (!isDown)
			TweenMax.to(scrubber.scrubberOverClip, tTime, { alpha:0 } );
		}
		
		// Scrubber Down
		private function scrubberDown2(e:MouseEvent = null):void
		{
			isDown = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, scrubberUp2);
		}
		
		// Scrubber Up
		private function scrubberUp2(e:MouseEvent = null):void
		{
			isDown = false;
			TweenMax.to(scrubber.scrubberOverClip, tTime, { alpha:0 } );
		}
		
		// left / right roll over / out
		private function leftButtonOver(e:MouseEvent = null):void
		{
			TweenMax.to(leftButton.over , tTime, { alpha:1} );
		}
		
		private function leftButtonOut(e:MouseEvent = null):void
		{
			TweenMax.to(leftButton.over , tTime, { alpha:0} );
		}
		
		private function rightButtonOver(e:MouseEvent = null):void
		{
			TweenMax.to(rightButton.over , tTime, { alpha:1} );
		}
		
		private function rightButtonOut(e:MouseEvent = null):void
		{
			TweenMax.to(rightButton.over , tTime, { alpha:0} );
		}
		
	}
	
	
}