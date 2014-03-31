package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ScratchTest2 extends MovieClip
	{
		private const STAGE_WIDTH:int = 1920;
		private const STAGE_HEIGHT:int = 1080;
		
		//number of pixels in the circular cover - used to fill the rects array
		private const PIXELS_IN_COVER:int = 76453;
		
		private const SOURCE_RECT:Rectangle = new Rectangle(0, 0, STAGE_WIDTH, STAGE_HEIGHT)
		private const DEST_POINT:Point = new Point(0, 0);
		
		//number of pixels that need to be removed in order to have the cover scratched off enough - 60%
		private const ENOUGH_PIXELS:int = Math.floor(PIXELS_IN_COVER * .6);		
		
		//contains the number of pixels remaining in each scratch area
		private var rects:Array;
		
		//background and cover images
		private var bg:BitmapData;
		private var cov1:BitmapData;
		private var cov2:BitmapData;
		private var cov3:BitmapData;
		private var cov4:BitmapData;
		private var cov5:BitmapData;
		private var cov6:BitmapData;
		
		//original covers - not touched by scratching - for copyPixeling when the cover is not scratched in
		private var ocov1:BitmapData;
		private var ocov2:BitmapData;
		private var ocov3:BitmapData;
		private var ocov4:BitmapData;
		private var ocov5:BitmapData;
		private var ocov6:BitmapData;
		
		//visual representation
		private var canvas:BitmapData;
		private var canvasBMP:Bitmap;		

		//drawing contains the line drawn by the mouse
		private var drawing:Sprite;
		
		//drawingData is a bitmap copy of drawing - uses draw method to copy drawing
		private var drawingData:BitmapData;
		
		//last mouse position
		private var lastPoint:Point;
		
		//scratched contains the indexes of the scratched covers - used to get the number of pixels remaining in a cover from the rects array
		private var scratched:Array;
		//the number of covers that have been scratched in - 3 is the max
		private var scratchedCount:int;
		
		//c is the number of pixels that threshold affects
		private	var c:uint;
		
		
		
		
		
		public function ScratchTest2():void
		{			
			lastPoint = new Point(0, 0);
			
			canvas = new BitmapData(STAGE_WIDTH, STAGE_HEIGHT);
			canvasBMP = new Bitmap(canvas);
			addChild(canvasBMP);
			
			drawing = new Sprite();			
			
			init();
			addIcons();
		}
		
		
		
		private function init():void
		{
			rects = new Array(PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER);
			
			//library clips
			bg = new background(STAGE_WIDTH, STAGE_HEIGHT);
			//six original covers to be scratched off
			cov1 = new cover1(STAGE_WIDTH, STAGE_HEIGHT);
			cov2 = new cover2(STAGE_WIDTH, STAGE_HEIGHT);
			cov3 = new cover3(STAGE_WIDTH, STAGE_HEIGHT);
			cov4  = new cover4(STAGE_WIDTH, STAGE_HEIGHT);
			cov5 = new cover5(STAGE_WIDTH, STAGE_HEIGHT);
			cov6  = new cover6(STAGE_WIDTH, STAGE_HEIGHT);
			
			ocov1 = new cover1(STAGE_WIDTH, STAGE_HEIGHT);
			ocov2 = new cover2(STAGE_WIDTH, STAGE_HEIGHT);
			ocov3 = new cover3(STAGE_WIDTH, STAGE_HEIGHT);
			ocov4  = new cover4(STAGE_WIDTH, STAGE_HEIGHT);
			ocov5 = new cover5(STAGE_WIDTH, STAGE_HEIGHT);
			ocov6  = new cover6(STAGE_WIDTH, STAGE_HEIGHT);			
			
			//initial blit - so you can see the image
			canvas.copyPixels(bg, SOURCE_RECT, DEST_POINT);			
			canvas.copyPixels(cov1, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			canvas.copyPixels(cov2, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			canvas.copyPixels(cov3, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			canvas.copyPixels(cov4, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			canvas.copyPixels(cov5, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			canvas.copyPixels(cov6, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);
			
			drawingData = new BitmapData(STAGE_WIDTH, STAGE_HEIGHT, true, 0x00000000);
			
			drawing.graphics.clear();
			drawing.graphics.lineStyle(42, 0xff000000);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrawing);
			
			scratched = new Array();
			scratchedCount = 0;
		}

		
		
		/**
		 * Adds the match icons to the background bitmapData object
		 */
		private function addIcons():void
		{
			var iconPositions:Array = new Array( { x:420, y:375 }, { x:908, y:375 }, { x:1424, y:375 }, { x:420, y:764 }, { x:908, y:764 }, { x:1424, y:764 } );
			var icon:BitmapData;
			var winner:Number = Math.random();
			if (winner > .8) {
				//20 percent chance
				icon = new iconTV();
			}else if (winner > .6) {
				//40 percent chance
				icon = new iconPhone();
			}else {
				//60 percent chance
				icon = new iconMouse();
			}			
	
			//add icons to bg
			for (var i:int = 0; i < iconPositions.length; i++) {
				bg.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(iconPositions[i].x, iconPositions[i].y));				
			}
		}
		
		
		
		/**
		 * Called on stage mouseDown
		 * @param	e MOUSE_DOWN event
		 */
		private function startDrawing(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, updateDrawing);
			lastPoint.x = mouseX;
			lastPoint.y = mouseY;
			drawing.graphics.moveTo(lastPoint.x, lastPoint.y);
		}
		
		
		
		/**
		 * Called on enter frame while the user is dragging the mouse/finger
		 * @param	e ENTER_FRAME event
		 */
		private function updateDrawing(e:Event):void
		{
			drawing.graphics.lineTo(mouseX, mouseY);
			lastPoint.x = mouseX;
			lastPoint.y = mouseY;
			drawingData.draw(drawing); //draws sprite image into bitmapData
			
			cov1.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			cov2.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			cov3.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			cov4.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			cov5.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			cov6.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);			
		
			c = cov1.threshold(cov1, SOURCE_RECT, DEST_POINT, "==", 0xff000000, 0x00000000);
			rects[0] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(0) == -1){
					scratchedCount++;
					scratched.push(0);
				}
			}
			
			c = cov2.threshold(cov2, SOURCE_RECT, DEST_POINT ,"==", 0xff000000, 0x00000000);
			rects[1] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(1) == -1){
					scratchedCount++;
					scratched.push(1);
				}
			}
			
			c = cov3.threshold(cov3, SOURCE_RECT, DEST_POINT ,"==", 0xff000000, 0x00000000);
			rects[2] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(2) == -1){
					scratchedCount++;
					scratched.push(2);
				}
			}
			
			c = cov4.threshold(cov4, SOURCE_RECT, DEST_POINT ,"==", 0xff000000, 0x00000000);
			rects[3] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(3) == -1){
					scratchedCount++;
					scratched.push(3);
				}
			}
			
			c = cov5.threshold(cov5, SOURCE_RECT, DEST_POINT ,"==", 0xff000000, 0x00000000);
			rects[4] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(4) == -1){
					scratchedCount++;
					scratched.push(4);
				}
			}
			
			c = cov6.threshold(cov6, SOURCE_RECT, DEST_POINT ,"==", 0xff000000, 0x00000000);
			rects[5] -= c;
			if (c > 0 && scratchedCount < 3) {
				if(scratched.indexOf(5) == -1){
					scratchedCount++;
					scratched.push(5);
				}
			}
			
			//blit the images onto the canvas so it can be seen
			//copy the cov images if that cover has been scratched in or copy the original if not scratched in
			canvas.copyPixels(bg, SOURCE_RECT, DEST_POINT);
			if(scratched.indexOf(0) != -1){
				canvas.copyPixels(cov1, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov1, SOURCE_RECT, DEST_POINT, ocov1, DEST_POINT, true);
			}
			if(scratched.indexOf(1) != -1){
				canvas.copyPixels(cov2, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov2, SOURCE_RECT, DEST_POINT, ocov2, DEST_POINT, true);
			}
			if(scratched.indexOf(2) != -1){
				canvas.copyPixels(cov3, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov3, SOURCE_RECT, DEST_POINT, ocov3, DEST_POINT, true);
			}
			if(scratched.indexOf(3) != -1){
				canvas.copyPixels(cov4, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov4, SOURCE_RECT, DEST_POINT, ocov4, DEST_POINT, true);
			}
			if (scratched.indexOf(4) != -1) {
				canvas.copyPixels(cov5, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov5, SOURCE_RECT, DEST_POINT, ocov5, DEST_POINT, true);
			}
			if (scratched.indexOf(5) != -1) {
				canvas.copyPixels(cov6, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov6, SOURCE_RECT, DEST_POINT, ocov6, DEST_POINT, true);
			}			
			
			//test for completion
			if (rects[scratched[0]] <= ENOUGH_PIXELS && rects[scratched[1]] <= ENOUGH_PIXELS && rects[scratched[2]] <= ENOUGH_PIXELS) {
				endGame();
			}
		}
		
		
		
		/**
		 * Called on stage mouseUp
		 * @param	e MOUSE_UP event
		 */
		private function endDrawing(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
		}
		
		
		
		/**
		 * Called from updateDrawing once enough pixels are removed in three areas
		 */
		private function endGame():void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrawing);			
			
			trace("winner");			
		}

	}
	
}