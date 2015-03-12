/**
 * Used by ComboBox.as
 */
package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;	
	
	
	public class ComboSlider extends Sprite
	{
		public static const DRAGGING:String = "sliderBeingDragged";
		public static const BEGIN_DRAG:String = "sliderStartedDragging";
		public static const END_DRAG:String = "sliderEndedDragging";
		
		private var slide:Sprite;
		private var track:Sprite;
		private var clickOffset:int; //prevents snapping of slide to mouse pos when initially clicked
		
		
		public function ComboSlider()
		{
			track = new Sprite();
			slide = new Sprite();
		}
		
		
		public function init(w:int, h:int):void
		{
			var g:Graphics = track.graphics;
			g.beginFill(0x333333, 1);
			g.drawRect(0, 0, w, h);
			g.endFill();
			
			g = slide.graphics;
			g.beginFill(0x777777, 1);
			g.drawRect(0, 0, w, Math.floor(h * .45));
			
			addChild(track);
			addChild(slide);
			
			slide.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
		}
		
		
		/**
		 * Returns slider position as a normalized decimal from 0 - 1
		 * @return Number
		 */
		public function getPosition():Number
		{
			return slide.y / (track.height - slide.height);
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{		
			clickOffset = slide.mouseY;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			addEventListener(Event.ENTER_FRAME, updateDrag, false, 0, true);
			
			dispatchEvent(new Event(BEGIN_DRAG));
		}
		
		
		private function updateDrag(e:Event):void
		{			
			slide.y = mouseY - clickOffset;
			
			//limit extents
			if (slide.y < 0) {
				slide.y = 0;
			}
			if (slide.y + slide.height > track.height) {
				slide.y = track.height - slide.height;
			}		
			dispatchEvent(new Event(DRAGGING));			
		}
		
		
		private function endDrag(e:MouseEvent):void
		{			
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			removeEventListener(Event.ENTER_FRAME, updateDrag);				
			dispatchEvent(new Event(END_DRAG));
		}
		
		
	}
	
}