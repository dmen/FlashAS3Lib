package com.gmrmarketing.microsoft.halo5
{
	import flash.display.*;
	import flash.events.*;	
	import flash.geom.*;
	import flash.filters.BlurFilter;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;	
	
	
	public class HeadShape extends EventDispatcher
	{
		private var head:MovieClip;
		private var maskSprite:Sprite;
		private var myContainer:DisplayObjectContainer;
		private var g:Graphics; //head.graphics ref
		private var msg:Graphics; //maskSprite.graphics ref
		private var maskData:BitmapData;//contains the filled in head shape used for a mask
		private var blur:BlurFilter;
		private var size:Object;
		private var handles:Array;//used for iterating through to rotate the grips
		
		public function HeadShape()
		{
			head = new mcHeadPoints();//library movieClip with handles h1-h8
			maskSprite = new Sprite();
			
			msg = maskSprite.graphics;
			g = head.graphics;
			
			blur = new BlurFilter(10, 10, 2);//applied to maskData
			
			handles = [head.h1, head.h2, head.h3, head.h4, head.h5, head.h6, head.h7, head.h8, head.h9, head.h10, head.h11];
		}
		
		
		public function setSize(w:int, h:int):void
		{
			size = { width:w, height:h };
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;			
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(head)) {
				myContainer.addChild(head);//headPoints
			}
			
			head.x = 944;
			head.y = 333;
			
			head.addEventListener(Event.ENTER_FRAME, drawLines, false, 0, true);
			
			head.h1.addEventListener(MouseEvent.MOUSE_DOWN, dragH1, false, 0, true);
			head.h2.addEventListener(MouseEvent.MOUSE_DOWN, dragH2, false, 0, true);
			head.h3.addEventListener(MouseEvent.MOUSE_DOWN, dragH3, false, 0, true);
			head.h4.addEventListener(MouseEvent.MOUSE_DOWN, dragH4, false, 0, true);
			head.h5.addEventListener(MouseEvent.MOUSE_DOWN, dragH5, false, 0, true);
			head.h6.addEventListener(MouseEvent.MOUSE_DOWN, dragH6, false, 0, true);
			head.h7.addEventListener(MouseEvent.MOUSE_DOWN, dragH7, false, 0, true);
			head.h8.addEventListener(MouseEvent.MOUSE_DOWN, dragH8, false, 0, true);
			head.h9.addEventListener(MouseEvent.MOUSE_DOWN, dragH9, false, 0, true);
			head.h10.addEventListener(MouseEvent.MOUSE_DOWN, dragH10, false, 0, true);
			head.h11.addEventListener(MouseEvent.MOUSE_DOWN, dragH11, false, 0, true);
			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(head)) {
				myContainer.removeChild(head);//headPoints
			}
			
			head.h1.removeEventListener(MouseEvent.MOUSE_DOWN, dragH1);
			head.h2.removeEventListener(MouseEvent.MOUSE_DOWN, dragH2);
			head.h3.removeEventListener(MouseEvent.MOUSE_DOWN, dragH3);
			head.h4.removeEventListener(MouseEvent.MOUSE_DOWN, dragH4);
			head.h5.removeEventListener(MouseEvent.MOUSE_DOWN, dragH5);
			head.h6.removeEventListener(MouseEvent.MOUSE_DOWN, dragH6);
			head.h7.removeEventListener(MouseEvent.MOUSE_DOWN, dragH7);
			head.h8.removeEventListener(MouseEvent.MOUSE_DOWN, dragH8);
			head.h9.removeEventListener(MouseEvent.MOUSE_DOWN, dragH9);
			head.h10.removeEventListener(MouseEvent.MOUSE_DOWN, dragH10);
			head.h11.removeEventListener(MouseEvent.MOUSE_DOWN, dragH11);
			
			head.removeEventListener(Event.ENTER_FRAME, drawLines);
		}
		
		
		/**
		 * Returns the maskData bitmapData instance
		 * updated in drawLines()
		 */
		public function get mask():BitmapData
		{
			return maskData;
		}
		
		
		/**
		 * Toggles the visibility of the head clip
		 * Head clip contains the handles
		 */
		public function toggleHandles():void
		{
			if(head.visible){
				head.visible = false;
			}else {
				head.visible = true;	
			}
		}
		
		private function dragH1(e:MouseEvent):void
		{	
			head.h1.startDrag();
		}
		
		private function dragH2(e:MouseEvent):void
		{	
			head.h2.startDrag();
		}
		
		private function dragH3(e:MouseEvent):void
		{	
			head.h3.startDrag();
		}
		
		private function dragH4(e:MouseEvent):void
		{	
			head.h4.startDrag();
		}
		
		private function dragH5(e:MouseEvent):void
		{	
			head.h5.startDrag();
		}
		
		private function dragH6(e:MouseEvent):void
		{	
			head.h6.startDrag();
		}
		
		private function dragH7(e:MouseEvent):void
		{	
			head.h7.startDrag();
		}
		
		private function dragH8(e:MouseEvent):void
		{	
			head.h8.startDrag();
		}
		
		private function dragH9(e:MouseEvent):void
		{	
			head.h8.startDrag();
		}
		
		private function dragH10(e:MouseEvent):void
		{	
			head.h8.startDrag();
		}
		
		private function dragH11(e:MouseEvent):void
		{	
			head.h8.startDrag();
		}
		
		
		private function endDrag(e:MouseEvent):void
		{
			//check handle bounds
			head.stopDrag();
		}
		
		
		/**
		 * 
		 * @param	e ENTER_FRAME event
		 */
		private function drawLines(e:Event):void
		{	
			for (var i:int = 0; i < 11; i++) {
				trace(i, handles[i].x);
				var dx:int = 600 - handles[i].x;
				var dy:int = 335 - handles[i].y;
				var ang:Number = Math.atan2(dy, dx);
				handles[i].rotation = ang;
			}
			msg.clear();
			msg.beginFill(0x00ff00, 1);
			//msg.drawRect(0, 0, 550, 400);
			
			g.clear();			
			g.lineStyle(.5, 0x000000);
			
			var beziers:Object = BezierPlugin.bezierThrough([ { x:head.h1.x, y:head.h1.y }, { x:head.h2.x, y:head.h2.y }, { x:head.h3.x, y:head.h3.y }, { x:head.h4.x, y:head.h4.y },{ x:head.h5.x, y:head.h5.y },{ x:head.h6.x, y:head.h6.y },{ x:head.h7.x, y:head.h7.y },{ x:head.h8.x, y:head.h8.y },{ x:head.h9.x, y:head.h9.y },{ x:head.h10.x, y:head.h10.y },{ x:head.h11.x, y:head.h11.y },{ x:head.h1.x, y:head.h1.y }], 1, true);
			var bx:Array = beziers.x; //the "x" Beziers
			var by:Array = beziers.y; //the "y" Beziers
			
			g.moveTo(bx[0].a, by[0].a);
			msg.moveTo(bx[0].a, by[0].a);
			
			for (var i:int = 0; i < bx.length; i++) {
				g.curveTo(bx[i].b, by[i].b, bx[i].c, by[i].c);
				msg.curveTo(bx[i].b, by[i].b, bx[i].c, by[i].c);
			}
			
			msg.endFill();
			
			//create the maskData - this is just the filled-in head shape, as determined by the handle positions
			maskData = new BitmapData(size.width, size.height, true, 0x00ffffff);
			maskData.draw(maskSprite, null, null, null, null, true);
			maskData.applyFilter(maskData, new Rectangle(0, 0, size.width, size.height), new Point(0,0), blur);
		}
		
	}
	
}