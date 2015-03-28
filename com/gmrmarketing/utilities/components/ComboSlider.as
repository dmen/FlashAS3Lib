/**
 * Used by ComboBox.as
 * Vertical slider for scrolling comboBox items
 */
package com.gmrmarketing.utilities.components
{
	import flash.display.*;
	import flash.events.*;	
	import flash.filters.DropShadowFilter;
	
	
	public class ComboSlider extends Sprite
	{
		public static const DRAGGING:String = "sliderBeingDragged";		
		private var slide:Sprite;
		private var slideColor:Number;
		private var track:Sprite;
		private var trackColor:Number;
		private var clickOffset:int; //prevents snapping of slide to mouse pos when initially clicked
		private var myWidth:int = 0;
		private var myHeight:int = 0;
		
		public function ComboSlider()
		{
			track = new Sprite();
			slide = new Sprite();
			//colors();
		}
		
		
		public function colors(tc:Number = 0x333333, sc:Number = 0x777777):void
		{			
			trackColor = tc;
			slideColor = sc;
			init();
		}
		
		
		public function init(w:int = 0, h:int = 0):void
		{			
			if (w != 0) {
				myWidth = w;
			}
			if (h != 0) {
				myHeight = h;
			}
			
			var g:Graphics = track.graphics;
			g.clear();
			g.beginFill(trackColor, 1);
			g.drawRect(0, 0, myWidth, myHeight);
			g.endFill();
			
			//add an inner shadow
			//track.filters = [new DropShadowFilter(0, 0, 0, 1, 4, 4, 1, 2, true)];
			
			//draw left edge on track
			//g.lineStyle(1, 0x000000, .4);
			//g.moveTo(0, 0);
			//g.lineTo(0, myHeight);
			
			g = slide.graphics;
			g.clear();
			g.beginFill(slideColor, 1);
			var slideHeight:int = Math.floor(myHeight * .4);
			g.drawRoundRect(1, 0, myWidth, slideHeight, 6, 6);
			g.endFill();
			
			//draw horizontal lines in the slider
			var linesPercentV:Number = .33; //lines take up 1/3 of the vertical space of the slider
			var linesPercentH:Number = .5; //lines take up 1/2 of the horizontal space of the slider
						
			var startY:int = Math.floor((slideHeight - (slideHeight * linesPercentV)) * .5);
			var endY:int = startY + slideHeight * linesPercentV;
			var startX:int = Math.floor((myWidth - (myWidth * linesPercentH)) * .5);
			var endX:int = startX + myWidth * linesPercentH;
			while (startY <= endY) {
				g.lineStyle(1, 0xffffff, .5);
				g.moveTo(startX, startY);
				g.lineTo(endX, startY);
				g.lineStyle(1, 0x000000, .3);
				g.moveTo(startX, startY+1);
				g.lineTo(endX, startY+1);
				startY += 3;
			}
			/*
			//draw edge highlights on the slider
			g.lineStyle(1, 0xffffff, .4);
			g.moveTo(1, myHeight * .4);
			g.lineTo(1, 0);
			g.lineTo(myWidth, 0);			
			
			g.lineStyle(1, 0x000000, .4);
			g.moveTo(myWidth - 1, 0);
			g.lineTo(myWidth - 1, myHeight * .4);
			g.lineTo(1, myHeight * .4);
			*/
			addChild(track);
			addChild(slide);
			
			//add an inner shadow
			slide.filters = [new DropShadowFilter(0, 0, 0, .6, 2, 2, 1, 2, true)];
			
			slide.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			track.addEventListener(MouseEvent.MOUSE_DOWN, trackClick, false, 0, true);
		}
		
		
		public function ghost():void
		{
			slide.alpha = .3;
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
		
		
		private function trackClick(e:MouseEvent):void
		{
			var ratio:Number = Math.max(0, Math.min(1, (track.mouseY - (slide.height * .5)) / (track.height - slide.height)));
			slide.y = (track.height - slide.height) * ratio;
			dispatchEvent(new Event(DRAGGING));
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{		
			clickOffset = slide.mouseY;			
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			addEventListener(Event.ENTER_FRAME, updateDrag, false, 0, true);
		}
		
		
		private function updateDrag(e:Event = null):void
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
		}
		
		
	}
	
}