package com.gmrmarketing.angostura
{	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	
	
	public class BaseBottle extends Sprite
	{		
		public static const START_POURING:String = "bottleStartPouring";
		public static const STOP_POURING:String = "bottleStopPouring";
		public static const STOP_DRAGGING:String = "bottleStopDragging";
		
		private const XBUFFER:int = 30;
		private const YBUFFER:int = 80;
		
		private var glass:MovieClip;
		private var pouring:Boolean;
		
		
		/**
		 * Constructor is called by calling super() from the sub classes
		 * 
		 * @param	$glass
		 */
		public function BaseBottle($glass:MovieClip)
		{			
			glass = $glass;			
			addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);			
		}
		
		private function beginDrag(e:MouseEvent):void
		{
			startDrag();
			pourCheck();			
			stage.addEventListener(MouseEvent.MOUSE_UP, dragStop, false, 0, true);
		}
		
		/**
		 * Called by stage listener for mouse up
		 * ie the user let go da button...
		 */
		public function dragStop(e:MouseEvent):void
		{
			stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, dragStop);
			TweenLite.to(this, .4, { rotation:0 } );
			removeEventListener(Event.ENTER_FRAME, checkForStopPour);			
			dispatchEvent(new Event(STOP_DRAGGING));
		}
		
		private function pourCheck():void
		{
			addEventListener(Event.ENTER_FRAME, checkForPour, false, 0, true);
		}
		
		private function checkForPour(e:Event):void
		{
			if (Math.abs(x - glass.x) < XBUFFER && (glass.y - y < YBUFFER && glass.y - y > 0)) {				
				TweenLite.to(this, .4, { rotation: -95, onComplete:dispatchStart } );
				removeEventListener(Event.ENTER_FRAME, checkForPour);
				addEventListener(Event.ENTER_FRAME, checkForStopPour);	
			}			
		}
		
		/**
		 * Called by TweenLite once the bottle is rotated
		 */
		private function dispatchStart():void
		{
			dispatchEvent(new Event(START_POURING));						
		}
		
		/**
		 * Called on EnterFrame while the bottle is near the glass
		 * Checks if the bottle moves too far from the glass - if it
		 * does a stop_pouring is dispatched
		 * 
		 * @param	e
		 */
		private function checkForStopPour(e:Event):void
		{			
			if (Math.abs(x - glass.x) > XBUFFER || (glass.y - y > YBUFFER || glass.y - y < 0)) {		
				TweenLite.to(this, .4, { rotation: 0, onComplete:pourCheck } );
				removeEventListener(Event.ENTER_FRAME, checkForStopPour);
				dispatchEvent(new Event(STOP_POURING));
			}
		}
		
	}
	
}