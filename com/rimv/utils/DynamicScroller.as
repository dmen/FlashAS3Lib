package com.rimv.utils
{
	/**
   @author    	RimV 
   @class     	DynamicScroller
   @package   	Utilities
	*/
   
	import flash.display.*;
	import flash.events.*;
	import com.rimv.utils.DynamicScrollerEvent;
	import flash.geom.Rectangle;
	
   public class DynamicScroller extends MovieClip
   {
   
	   // scroller component
	   public var scrubber:MovieClip;
	   public var leftButton:MovieClip;
	   public var rightButton:MovieClip;
	   public var base:MovieClip;
	   public var TOTAL:Number = 10;
	   
	   // misc var
	   private var range:Number;
	   private var end:Number;
	   private var originalWidth:Number = 500;
	   private var currentWidth:Number = 500;
	   
	   // parameter
	   private var step:Number = 10;
	   
	   public function get scrollerStep():Number
	   {
		   return step;
	   }
	   
	   public function set scrollerStep(step:Number):void
	   {
		   this.step = step;
	   }
	   
	   public function set value(n:Number):void
	   {
			scrubber.x = n * range + leftButton.width;
	   }
	   
	   public function get value():Number
	   {
		   return (scrubber.x - leftButton.width) / range;
	   }
	   
	   
	   public function DynamicScroller()
	   {
		  buttonMode = true;
		   // assign component
		  scrubber = this["_scrubber"];
		  leftButton = this["_leftButton"];
		  rightButton = this["_rightButton"];
		  base = this["_base"];
		  range = base.width - leftButton.width * 2 - scrubber.width;
		  end = base.width - scrubber.width - rightButton.width;
		  // assign event
		  scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubberDown);
		  leftButton.addEventListener(MouseEvent.CLICK, leftButtonClick);
		  rightButton.addEventListener(MouseEvent.CLICK, rightButtonClick);
		  base.addEventListener(MouseEvent.CLICK, baseClick);
	   }
	   
	   // Event Handler
	   private function scrubberDown(e:MouseEvent = null):void
	   {
		  scrubber.startDrag(false, new Rectangle(leftButton.width, scrubber.y, range, 0));
		  stage.addEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
		  stage.addEventListener(MouseEvent.MOUSE_UP, scrubberUp);
	   }
	   
	   private function scrubberMove(e:MouseEvent = null):void
	   {
		   var value:Number = (scrubber.x - leftButton.width) / range;
		   dispatchEvent(new DynamicScrollerEvent(DynamicScrollerEvent.ONCHANGE, value));
	   }
	   
	   private function scrubberUp(e:MouseEvent = null):void
	   {
		   scrubber.stopDrag();
		   stage.removeEventListener(MouseEvent.MOUSE_UP, scrubberUp);
		   stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrubberMove);
	   }
	   
	   private function leftButtonClick(e:MouseEvent = null):void
	   {
			var value:Number = ((scrubber.x - leftButton.width) / range) - 1 / TOTAL;
			value = (value < 0) ? 0 : value;
			scrubber.x = value * range + leftButton.width;
			dispatchEvent(new DynamicScrollerEvent(DynamicScrollerEvent.ONCHANGE, value));
	   }
	   
	   private function rightButtonClick(e:MouseEvent = null):void
	   {
			var value:Number = ((scrubber.x - leftButton.width) / range) + 1 / TOTAL;
			value = (value > 1) ? 1 : value;
			scrubber.x = value * range + leftButton.width;
			dispatchEvent(new DynamicScrollerEvent(DynamicScrollerEvent.ONCHANGE, value));
	   }
	   
	   private function baseClick(e:MouseEvent = null):void
	   {
		   var targetX:Number = (base.mouseX / originalWidth) * currentWidth;
		   if (targetX  < leftButton.width + scrubber.width * .5) targetX = leftButton.width + scrubber.width * .5;
		   if (targetX  > end - scrubber.width * .5) targetX = end + scrubber.width * .5;
		   scrubber.x = targetX - scrubber.width * .5;
		   var value:Number = (scrubber.x - leftButton.width) / range;
		   dispatchEvent(new DynamicScrollerEvent(DynamicScrollerEvent.ONCHANGE, value));
		   
	   }
	   
	   // resize scroller length
	   public function resize(width:Number):void
	   {
		  // resize base and relocate component position
		  base.width = width;
		  currentWidth = width;
		  rightButton.x = base.width - rightButton.width;
		  scrubber.x = leftButton.width;
		  // recalculate
		  range = base.width - leftButton.width * 2 - scrubber.width;
		  end = base.width - scrubber.width - rightButton.width;
	   }
   }
	
}