/**
 * One photo
 * Instantiated by ModelDetail.as
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import fl.motion.MatrixTransformer;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.Bitmap;
	import flash.filters.DropShadowFilter;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Photo
	{
		private var container:DisplayObjectContainer;
		private var loader:Loader;		
		
		private var offsetX:Number;
		private var offsetY:Number;
		
		private var dropShadow:DropShadowFilter;
		
		private var initX:int;
		private var initY:int;
		private var initScale:Number;
		private var timeoutHelper:TimeoutHelper;
		
		
		
		public function Photo($container:DisplayObjectContainer, fileName:String, $initX:int = 0, $initY:int = 0, $initScale:Number = .4)
		{
			container = $container;
			initX = $initX;
			initY = $initY;
			initScale = $initScale;
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			dropShadow = new DropShadowFilter(0, 0, 0, .8, 5, 5, 1, 2);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, photoLoaded);
			loader.load(new URLRequest(fileName));
			
			container.addChild(loader);
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(loader);
			
			loader.removeEventListener(TransformGestureEvent.GESTURE_ZOOM, scaleObj);
			loader.removeEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
			loader.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);			
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveClip);
			
			TweenMax.to(loader, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			loader.filters = [];
			if (container.contains(loader)) {
				container.removeChild(loader);
			}			
			loader.unload();
		}
		
		
		private function photoLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;			
			
			loader.filters = [dropShadow];
			
			loader.x = Math.round(Math.random() * 1366);
			loader.y = Math.round(Math.random() * 768);
			loader.scaleX = loader.scaleY = initScale;
			loader.alpha = 0;
			loader.doubleClickEnabled = true;
			
			TweenMax.to(loader, 1, {alpha:1, x:initX, y:initY, ease:Back.easeOut } );
			
			loader.addEventListener(TransformGestureEvent.GESTURE_ZOOM, scaleObj, false, 0, true);			
			loader.addEventListener(MouseEvent.MOUSE_DOWN, dragBegin);
			loader.addEventListener(MouseEvent.DOUBLE_CLICK, autoZoom);
			loader.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		
		private function scaleObj(e:TransformGestureEvent):void 
		{		
			timeoutHelper.buttonClicked();
			
			container.setChildIndex(loader, container.numChildren - 1);
			
			var locX:Number = e.localX;
			var locY:Number = e.localY;
			var stX:Number = e.stageX;
			var stY:Number = e.stageY;
			var prevScaleX:Number = loader.scaleX;//currentClip
			var prevScaleY:Number = loader.scaleY;
			var mat:Matrix;
			var externalPoint:Point = new Point(stX, stY);
			var internalPoint:Point = new Point(locX, locY);
			loader.scaleX *= e.scaleX;//currentClip
			loader.scaleY *= e.scaleY;
			
			if(e.scaleX > 1 && loader.scaleX > 1.5){
				loader.scaleX = prevScaleX;
				loader.scaleY = prevScaleY;
			}
			if(e.scaleY > 1 && loader.scaleY > 1.5){
				loader.scaleX = prevScaleX;
				loader.scaleY = prevScaleY;
			}
			if(e.scaleX < 1 && loader.scaleX < 0.2){
				loader.scaleX = prevScaleX;
				loader.scaleY = prevScaleY;
			}
			if(e.scaleY < 1 && loader.scaleY < 0.2){
				loader.scaleX = prevScaleX;
				loader.scaleY = prevScaleY;
			}
			
			mat = loader.transform.matrix.clone();
			MatrixTransformer.matchInternalPointWithExternal(mat, internalPoint, externalPoint);
			loader.transform.matrix = mat;
		}
		
		
		/**
		 * Called by double tapping the photo - zooms back to initial scale and location
		 * @param	e
		 */
		private function autoZoom(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			TweenMax.to(loader, .5, { scaleX:initScale, scaleY:initScale, x:initX, y:initY } );
		}
		
		
		private function dragBegin(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			container.setChildIndex(loader, container.numChildren - 1);
			
			offsetX = e.stageX - loader.x;
			offsetY = e.stageY - loader.y;
			
			container.stage.addEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		} 
		
		
		private function moveClip(e:MouseEvent):void
		{
			loader.x = e.stageX - offsetX;
			loader.y = e.stageY - offsetY;			
		}
		
		
		private function stopDragging(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			container.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveClip);
		}
	}
	
}