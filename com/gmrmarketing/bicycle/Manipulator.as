package com.gmrmarketing.bicycle
{
	import flash.display.*
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.*;
	
	
	public class Manipulator extends EventDispatcher
	{
		private var myObject:DisplayObjectContainer;
		private var manLayer:Sprite; //new layer for the manipulator	
		private var angleOffset:Number;
		private var centReg:Boolean = false; //center registration point
		
		private var ltDot:Sprite;
		private var lbDot:Sprite;
		private var rtDot:Sprite;
		private var rbDot:Sprite;
		private var cDot:Sprite;
		
		//invis dots for positioning
		private var ltDot2:Sprite;
		private var rtDot2:Sprite;
		private var rbDot2:Sprite;
		
		private var initScalePoint:Point; //initial mouse loc for scaling		
		private var initScale:Number;
		
		private var showing:Boolean = false;
		
		private var dragOK:Boolean = true;
		
		
		public function Manipulator()
		{	
			manLayer = new Sprite(); //manipulator layer			
			
			ltDot = new manipDelete();
			lbDot = new Sprite();
			lbDot.graphics.beginFill(0x000000, 1);
			lbDot.graphics.drawCircle(0, 0, 4);
			
			//right top for scaling
			rtDot = new manipScale();
			
			//right bottom is for rotation
			rbDot = new manipRotate();
			
			//center for moving
			cDot = new Sprite();
			cDot.graphics.beginFill(0xAAFF00, 0);
			cDot.graphics.drawRect(0, 0, 1, 1);
			
			
			//invis dots for positioning
			ltDot2 = new Sprite();
			ltDot2.graphics.beginFill(0xFF0000, 0);
			ltDot2.graphics.drawCircle(0, 0, 10);
			rtDot2 = new Sprite();
			rtDot2.graphics.beginFill(0x000000, 0);
			rtDot2.graphics.drawCircle(0, 0, 10);
			rbDot2 = new Sprite();
			rbDot2.graphics.beginFill(0x000000, 0);
			rbDot2.graphics.drawCircle(0, 0, 10);
		}
		
		public function isShowing():Boolean
		{
			return showing;
		}
		
		public function setObject(obj:*):void
		{
			myObject = obj;					
		}
		
		
		public function show():void
		{	
			var bounds:Rectangle = myObject.getBounds(myObject);
			
			//invis dots
			manLayer.addChild(ltDot2);
			manLayer.addChild(rtDot2);
			manLayer.addChild(rbDot2);
			
			//normal dots
			manLayer.addChild(cDot);
			manLayer.addChild(ltDot);
			manLayer.addChild(lbDot);
			manLayer.addChild(rtDot);
			manLayer.addChild(rbDot);			
			
			manLayer.x = bounds.x;
			manLayer.y = bounds.y;
			
			manLayer.graphics.lineStyle(1, 0x000000, 1);
			manLayer.graphics.drawRect(0, 0, bounds.width, bounds.height);			
			
			ltDot.x = 0;
			ltDot.y = 0;
			lbDot.y = bounds.height;			
			rtDot.x = bounds.width;
			rtDot.y = 0;
			rbDot.x = bounds.width;
			rbDot.y = bounds.height;
			cDot.width = bounds.width;
			cDot.height = bounds.height;
			
			ltDot2.x = 0;
			ltDot2.y = 0;
			rtDot2.x = rtDot.x;
			rtDot2.y = rtDot.y;
			rbDot2.x = rbDot.x;
			rbDot2.y = rbDot.y;
			
			ltDot.addEventListener(MouseEvent.CLICK, deleteIcon, false, 0, true);
			ltDot.addEventListener(MouseEvent.MOUSE_DOWN, stopDragDelete, false, 0, true);
			rtDot.addEventListener(MouseEvent.MOUSE_DOWN, startScale, false, 0, true);
			rbDot.addEventListener(MouseEvent.MOUSE_DOWN, startRotation, false, 0, true);
			cDot.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
			
			myObject.stage.addEventListener(MouseEvent.MOUSE_UP, endManipulations, false, 0, true);
			
			myObject.addChild(manLayer);
			
			ltDot.scaleX = ltDot.scaleY = 1 / myObject.scaleX;
			rtDot.scaleX = rtDot.scaleY = 1 / myObject.scaleX;
			rbDot.scaleX = rbDot.scaleY = 1 / myObject.scaleX;
			
			ltDot.x = ltDot2.x;
			ltDot.y = ltDot2.y;
			rtDot.x = rtDot2.x;
			rtDot.y = rtDot2.y;
			rbDot.x = rbDot2.x;
			rbDot.y = rbDot2.y;
			
			showing = true;
			
			startMove();
		}
		
		
		
		public function hide():void
		{				
			manLayer.graphics.clear();
			
			ltDot.removeEventListener(MouseEvent.CLICK, deleteIcon);
			ltDot.removeEventListener(MouseEvent.MOUSE_DOWN, stopDragDelete);
			rtDot.removeEventListener(MouseEvent.MOUSE_DOWN, startScale);			
			rbDot.removeEventListener(MouseEvent.MOUSE_DOWN, startRotation);
			cDot.removeEventListener(MouseEvent.MOUSE_DOWN, startMove);			
			
			while (manLayer.numChildren) {
				manLayer.removeChildAt(0); //remove all dots
			}
			if(myObject != null){
				myObject.stage.removeEventListener(MouseEvent.MOUSE_UP, endManipulations);
				if (myObject.contains(manLayer)) {
					myObject.removeChild(manLayer);
				}
			}
			showing = false;
		}
		
		private function deleteIcon(e:MouseEvent):void
		{
			if (MovieClip(myObject).isInitials) {
				dispatchEvent(new Event("killInitials"));
			}else {
				dispatchEvent(new Event("killIcon"));
			}
		}
		
		public function getIcon():DisplayObjectContainer
		{
			return myObject;
		}
		
		public function nullMyObject():void
		{
			myObject = null;
		}
		
		private function startMove(e:MouseEvent = null):void
		{
			if(dragOK){
				MovieClip(myObject).startDrag(false);
			}
		}
		
		
		
		private function startRotation(e:MouseEvent):void
		{	
			var position:Number = Math.atan2(myObject.parent.mouseY - myObject.y, myObject.parent.mouseX - myObject.x);	
			var angle:Number = (position / Math.PI) * 180;	
			angleOffset = myObject.rotation - angle;
			myObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateRotation, false, 0, true);
			dragOK = false;
			doStopDrag();
		}
		
		
		private function updateRotation(e:Event):void
		{	
			var position:Number = Math.atan2(myObject.parent.mouseY - myObject.y, myObject.parent.mouseX - myObject.x);	
			myObject.rotation = (position / Math.PI) * 180 + angleOffset;
		}
		
		
		private function startScale(e:MouseEvent):void
		{
			initScalePoint = new Point(myObject.stage.mouseX, myObject.stage.mouseY);
			initScale = myObject.scaleX;			
			myObject.stage.addEventListener(MouseEvent.MOUSE_MOVE, updateScale, false, 0, true);
			dragOK = false;
			doStopDrag();
		}
		
		
		private function updateScale(e:Event):void
		{
			var xDist:Number = myObject.stage.mouseX - initScalePoint.x;					
			myObject.scaleX = myObject.scaleY = initScale + (xDist / 100);
			
			ltDot.scaleX = ltDot.scaleY = 1 / myObject.scaleX;
			rtDot.scaleX = rtDot.scaleY = 1 / myObject.scaleX;
			rbDot.scaleX = rbDot.scaleY = 1 / myObject.scaleX;
			
			ltDot.x = ltDot2.x;
			ltDot.y = ltDot2.y;
			rtDot.x = rtDot2.x;
			rtDot.y = rtDot2.y;
			rbDot.x = rbDot2.x;
			rbDot.y = rbDot2.y;
		}		
		
		
		private function endManipulations(e:MouseEvent = null):void
		{
			myObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateRotation);
			myObject.stage.removeEventListener(MouseEvent.MOUSE_MOVE, updateScale);
			dragOK = true;
			doStopDrag();
		}
		
		/**
		 * called by mouseDown on the delete button
		 * @param	e
		 */
		private function stopDragDelete(e:MouseEvent):void
		{
			dragOK = false;
			doStopDrag();
		}
		
		private function doStopDrag():void
		{
			MovieClip(myObject).stopDrag();	
		}
	}
	
}