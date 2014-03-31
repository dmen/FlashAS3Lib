package com.gmrmarketing.nissan.next
{
	import com.greensock.easing.Circ;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	
	
	public class CircleTest extends MovieClip
	{
		private var offsetX:Number;
		private var offsetY:Number;
		private var container:Sprite;
		private var currentClip:MovieClip;
		
		public function CircleTest()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			
			container = new Sprite();
			
			var circLabels:Array = new Array("Exercise", "Outdoors", "Strength", "Stability", "Freedom");
			
			for (var i:int = 0; i < circLabels.length; i++) {
				var m:MovieClip = new circ(); //lib clip
				m.theText.text = circLabels[i];
				m.x = 250 + 240 * i;
				m.y = 400;
				container.addChild(m);
				m.addEventListener(TransformGestureEvent.GESTURE_ZOOM, scaleObj, false, 0, true);
				//m.addEventListener(TransformGestureEvent.GESTURE_ROTATE , rotateObj, false, 0, true);
				m.addEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			
			addChild(container);
			
			for each (var item:String in Multitouch.supportedGestures) {
				trace("gesture " + item);
			}
		}
		
		
		private function scaleObj(e:TransformGestureEvent):void
		{
			currentClip = MovieClip(e.currentTarget);
			container.setChildIndex(currentClip, container.numChildren - 1);
			currentClip.scaleX *= e.scaleX;
			currentClip.scaleY *= e.scaleY;
		}
		
		/*
		private function rotateObj (e:TransformGestureEvent):void
		{
			currentClip = MovieClip(e.currentTarget);
			currentClip.rotation += e.rotation;
		}*/
		
		
		private function dragBegin(e:MouseEvent):void
		{
			currentClip = MovieClip(e.currentTarget);
			container.setChildIndex(currentClip, container.numChildren - 1);
			offsetX = e.stageX - currentClip.x;
			offsetY = e.stageY - currentClip.y;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		} 
		
		
		private function moveClip(e:MouseEvent):void
		{
			currentClip.x = e.stageX - offsetX;
			currentClip.y = e.stageY - offsetY;			
		}
		
		
		private function stopDragging(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		}
 
	}
	
}