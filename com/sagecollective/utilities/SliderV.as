/**
 * Simple Vertical Slider
 */
	 
package com.sagecollective.utilities
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.*;	
	
	
	public class SliderV extends EventDispatcher
	{
		public static const DRAGGING:String = "SliderBeingDragged";
		
		private var slide:DisplayObject;
		private var minY:int;
		private var maxY:int;
		private var range:int;
		private var clickOffset:int;
		private var theStage:Stage;
		
		private var originalSliderY:int;
		
		
		public function SliderV($slide:DisplayObject, track:MovieClip)
		{
			slide = $slide;
			minY = track.y;
			maxY = track.y + track.height - slide.height;
			range = maxY - minY;
			
			originalSliderY = slide.y;			
			
			theStage = slide.stage;
			
			slide.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			
			MovieClip(slide).buttonMode = true;
		}
		
		
		/**
		 * Returns slider position as a decimal from 0 - 1
		 * @return Number
		 */
		public function getPosition():Number
		{			
			return (slide.y - minY) / range;
		}
		
		
		/**
		 * positions the slider back to it's initial starting location
		 */
		public function resetSlider():void
		{
			slide.y = originalSliderY;
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			clickOffset = slide.mouseY;			
			slide.addEventListener(Event.ENTER_FRAME, updateDrag, false, 0, true);
			theStage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		private function updateDrag(e:Event):void
		{
			slide.y = theStage.mouseY - clickOffset;			
			
			if (slide.y < minY) { slide.y = minY; }
			if (slide.y > maxY) { slide.y = maxY; }
			
			dispatchEvent(new Event(DRAGGING));
		}
		
		
		private function endDrag(e:MouseEvent):void
		{			
			slide.removeEventListener(Event.ENTER_FRAME, updateDrag);
		}
	}
	
}