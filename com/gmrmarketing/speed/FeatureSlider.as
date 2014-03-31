package com.gmrmarketing.speed
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	public class FeatureSlider extends EventDispatcher
	{
		public static const DRAGGING:String = "sliderBeingDragged";		
		
		private var slider:MovieClip;
		private var track:MovieClip;
		private var myStage:Stage;
		private var initY:int;
		private var range:int;
		
		public function FeatureSlider($slider:MovieClip, $track:MovieClip, theStage:Stage)
		{
			slider = $slider;
			track = $track;
			myStage = theStage;
			initY = slider.y;
			slider.buttonMode = true;
			range = track.height;
			slider.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);			
		}		
				
		
		private function beginDrag(e:MouseEvent):void
		{	
			slider.startDrag(false, new Rectangle(slider.x, track.y, 0, track.height));
			myStage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			myStage.addEventListener(Event.ENTER_FRAME, dragSlider, false, 0, true);
		}
		
		
		private function endDrag(e:MouseEvent = null):void
		{			
			slider.stopDrag();
			myStage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			myStage.removeEventListener(Event.ENTER_FRAME, dragSlider);
		}
		
		public function getNormalizedDelta():Number 
		{
			return (slider.y - initY) / range;
		}
		private function dragSlider(e:Event = null):void
		{
			dispatchEvent(new Event(DRAGGING));			
		}		
		
	}	
}