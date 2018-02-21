/**
 * Slider
 * Horizontal or Vertical
 * 
 * Usage:
	 
	 import com.gmrmarketing.utilities.Slider;
	 
	 var slider:Slider = new Slider(slide, track, "h"); //horizontal slider "v" for vertical
	 slider.addEventListener(Slider.DRAGGING, doSomethingWhileDragging, false, 0, true);
	 
 * 
 * Slider and Track clips must have top left reg points
 */

package com.gmrmarketing.utilities
{
	import flash.display.*;	
	import flash.events.*;
	import com.greensock.TweenMax; //for tweening slider when calling reset() or setPosition()
	
	
	public class Slider extends EventDispatcher
	{
		public static const DRAGGING:String = "sliderBeingDragged";
		public static const BEGIN_DRAG:String = "sliderStartedDragging";
		public static const END_DRAG:String = "sliderEndedDragging";
		
		private var slide:MovieClip;
		private var track:MovieClip;
		private var container:DisplayObjectContainer;
		private var direction:String; //"h" or "v"
		private var minE:int; //min extent - determined by track
		private var maxE:int; //max extent
		private var range:int; //full range of slider
		private var clickOffset:int; //prevents snapping of slide to mouse pos when initially clicked
		private var startPos:int; //initial screen position of the slide - used when resetSlider is called
		
		
		/**
		 * Constructor
		 * @param	$slide Slide clip - must be top-left registered
		 * @param	$track		Track clip - must be top-left registered
		 * @param	$direction "h" or "v" to make a horizontal or vertical slider
		 */
		public function Slider($slide:MovieClip, $track:MovieClip, $direction:String = "h")
		{
			slide = $slide;
			track = $track;
			direction = $direction;
			
			if(direction == "h"){
				minE = track.x;
				maxE = minE + track.width;
				range = (maxE - slide.width) - minE;
				startPos = slide.x;
			}else {
				minE = track.y;
				maxE = minE + track.height;
				range = (maxE - slide.height) - minE;
				startPos = slide.y;
			}			
			
			container = slide.parent;
			
			slide.buttonMode = true;
			slide.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);			
		}
		
		
		/**
		 * Returns slider position as a normalized decimal from 0 - 1
		 * @return Number
		 */
		public function getPosition():Number
		{
			if(direction == "h"){
				return (slide.x - minE) / range;
			}else {
				return (slide.y - minE) / range;
			}
		}
		
		
		/**
		 * Sets the slider to the given normalized position
		 * @param	ratio Number 0 - 1
		 */
		public function setPosition(ratio:Number):void
		{
			var pos:Number = minE + (range * ratio);
			
			if(direction == "h"){
				TweenMax.to(slide, .5, { x:pos, onUpdate:dragging } );
			}else {
				TweenMax.to(slide, .5, { y:pos, onUpdate:dragging } );
			}	
		}
		
		
		/**
		 * Tweens the slider to it's starting position
		 * This is the initial on-screen position of the slide
		 * when the class is instantiated
		 */
		public function reset():void
		{
			if(direction == "h"){
				TweenMax.to(slide, .5, { x:startPos, onUpdate:dragging } );
			}else {
				TweenMax.to(slide, .5, { y:startPos, onUpdate:dragging } );
			}					
		}
		
		
		/**
		 * Returns a reference to the slide clip
		 * @return MovieClip reference
		 */
		public function getSlide():MovieClip
		{
			return slide;
		}
		
		
		/**
		 * Returns a reference to the track clip
		 * @return MovieClip reference
		 */
		public function getTrack():MovieClip
		{
			return track;
		}		
		
		
		/**
		 * Called when the slide is clicked on
		 * dispatches a BEGIN_DRAG event
		 * @param	e MOUSE_DOWN
		 */
		private function beginDrag(e:MouseEvent):void
		{		
			if (direction == "h") {
				clickOffset = slide.mouseX;
			}else {
				clickOffset = slide.mouseY;
			}
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			container.addEventListener(Event.ENTER_FRAME, updateDrag, false, 0, true);
			
			dispatchEvent(new Event(BEGIN_DRAG));
		}
		
		
		/**
		 * Called when the mouse is released after clicking on the slide
		 * dispatches a END_DRAG event
		 * @param	e MOUSE_UP
		 */
		private function endDrag(e:MouseEvent):void
		{			
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			container.removeEventListener(Event.ENTER_FRAME, updateDrag);	
			
			dispatchEvent(new Event(END_DRAG));
		}
		
		
		/**
		 * Called by ENTER_FRAME while the slide is being dragged
		 * Continually dispatches DRAGGING events
		 * @param	e ENTER_FRAME
		 */
		private function updateDrag(e:Event):void
		{
			if(direction == "h"){
				
				slide.x = container.stage.mouseX - clickOffset;
				
				//limit extents
				if (slide.x < minE) {
					slide.x = minE;
				}
				if (slide.x + slide.width > maxE) {
					slide.x = maxE - slide.width;
				}
				
			}else {
				
				slide.y = container.stage.mouseY - clickOffset;
				
				//limit extents
				if (slide.y < minE) {
					slide.y = minE;
				}
				if (slide.y + slide.height > maxE) {
					slide.y = maxE - slide.height;
				}	
			}
			
			dispatchEvent(new Event(DRAGGING));			
		}
		
		
		/**
		 * Called by TweenMax update when the slider is resetting or being set
		 */
		private function dragging():void
		{
			dispatchEvent(new Event(DRAGGING));	
		}
		
	}
	
}