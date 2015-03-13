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
			var slideHeight:int = Math.floor(h * .45);
			g.drawRect(0, 0, w, slideHeight);
			g.endFill();
			
			//draw horizontal lines in the slider
			var linesPercentV:Number = .33; //lines take up 1/3 of the vertical space of the slider
			var linesPercentH:Number = .5; //lines take up 1/2 of the horizontal space of the slider
			g.lineStyle(1, 0xaaaaaa);			
			var startY:int = Math.floor((slideHeight - (slideHeight * linesPercentV)) * .5);
			var endY:int = startY + slideHeight * linesPercentV;
			var startX:int = Math.floor((w - (w * linesPercentH)) * .5);
			var endX:int = startX + w * linesPercentH;
			while(startY <= endY){
				g.moveTo(startX, startY);
				g.lineTo(endX, startY);
				startY += 3;
			}
			
			addChild(track);
			addChild(slide);
			
			slide.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
		}
		
		
		/**
		 * Resets the slide to the top of the track
		 */
		public function reset():void
		{
			slide.y = 0;
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