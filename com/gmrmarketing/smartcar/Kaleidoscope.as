package com.gmrmarketing.smartcar 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Kaleidoscope extends EventDispatcher
	{
		//dispatched from update() whenever the image changes
		public static const KALEID_CHANGED:String = "kaleidoscopeUpdated";
		
		private var canvasData:BitmapData; //chunk from the main source image is copied into this
		private var canvas:Bitmap;
		private var image:BitmapData; //the main source image for the kaleidoscope		
		
		private var controlRect:Rectangle; //the area on screen for controlling the kaleidoscope via mouse pos
		private var widthRatio:Number; //set in setImage()
		private var heightRatio:Number;
		
		private var tileData:BitmapData; //400x346 bitmapData - contains the kaleidoscope image
		private var tile:Bitmap; //the composed image that is shown within mainContainer	
		
		private var kalContainer:Sprite; //holds the slices
		private const ZERO_POINT:Point = new Point(0, 0);
		
		private var mainContainer:DisplayObjectContainer;	
		
		//stores last mouse pos - so bitmap only updates if mouse actually moves
		private var oldX:int;
		private var oldY:int;
		private var mx:int; //current mouse pos
		private var my:int;
		
		private var isDrawing:Boolean; //flag toggled by mouseClick - allows
		
		
		
		/**
		 * Constructor
		 * @param	kContainer
		 */
		public function Kaleidoscope()
		{	
			isDrawing = false;
			
			tileData = new BitmapData(400, 346, true, 0xffffffff);
			//tile = new Bitmap(tileData);
			
			//mainContainer.addChild(tile);
			
			//container for the slices - not on display list
			//this is drawn into tileData in update()
			kalContainer = new Sprite();
			
			var a:Sprite = createTriangle();
			kalContainer.addChild(a);
			a.x = 100;
			a.y = 173;						
			
			var b:Sprite = createTriangle();
			kalContainer.addChild(b);
			b.rotation = 180;			
			b.x = 300;
			b.y = 173;
			
			var c:Sprite = createTriangle();
			kalContainer.addChild(c);
			c.rotation = 60;
			c.x = 150;
			c.y = 87;
			
			var d:Sprite = createTriangle();
			kalContainer.addChild(d);
			d.rotation = -60;
			d.x = 150;
			d.y = 259;
			
			var e:Sprite = createTriangle();
			kalContainer.addChild(e);
			e.rotation = 120;
			e.x = 250;
			e.y = 87;
			
			var f:Sprite = createTriangle();
			kalContainer.addChild(f);
			f.rotation = -120;
			f.x = 250;
			f.y = 259;
			
			canvasData = new BitmapData(200, 173, true, 0x00ff0000);			
		}
		
		public function setPoint(kPoint:Point = null):void
		{
			if (kPoint == null) {
				oldX = controlRect.x;
				oldY = controlRect.y;
				//trace("kaleid.setPoint - null", oldX, oldY);
			}else {
				oldX = kPoint.x;
				oldY = kPoint.y;
				//trace("kaleid.setPoint", oldX, oldY);
			}
		}
		
		
		public function setContainer(c:DisplayObjectContainer):void
		{
			mainContainer = c;
			mainContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, toggleDrawing, false, 0, true);
			mainContainer.stage.addEventListener(MouseEvent.MOUSE_UP, toggleDrawing, false, 0, true);
		}
		
		
		/**
		 * Changes the background color of the kaliedoscope
		 * @param	newColor
		 */
		public function setBGColor(newColor:uint):void
		{
			//trace("kaleid.setBGColor", newColor);
			tileData.fillRect(new Rectangle(0, 0, tileData.width, tileData.height), newColor);			
			update(null, true);
		}
		
		
		/**
		 * Sets the source image that is used to draw the kaliedoscope from
		 * @param	newImage
		 */
		public function setImage(newImage:BitmapData):void
		{			
			image = newImage;			
			widthRatio = image.width / controlRect.width;
			heightRatio = image.height / controlRect.height;
			
			var i:BitmapData = new BitmapData(image.width + 200, image.height + 173, false, 0x000000);
			i.copyPixels(image, new Rectangle(0, 0, image.width, image.height), new Point(0, 0));
			
			image = i;
			
			update(null, true);
		}
		
		
		public function setControlArea(rect:Rectangle):void
		{
			controlRect = rect;			
		}
		
		
		/**
		 * Adds the enter frame listener so the kaleidoscope updates via mouse position
		 */
		public function start():void
		{
			mainContainer.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		public function isRunning():Boolean
		{
			return mainContainer.hasEventListener(Event.ENTER_FRAME);
		}
		
		/**
		 * Removes the enter frame listener and stops the kaleidoscope from updating
		 */
		public function stop():void
		{
			mainContainer.removeEventListener(Event.ENTER_FRAME, update);
		}
			
		
		/**
		 * Returns the 400x346 bitmapData object of the current kaleidoscope image
		 * Set in update()
		 * 
		 * @return BitmapData
		 */
		public function getTile():BitmapData
		{			
			return tileData;
		}
		
		
		/**
		 * Creates a 200x173 sprite containing a bitmap masked with a triangle
		 * @return
		 */
		private function createTriangle():Sprite
		{
			var triMask:Shape = new Shape();
			triMask.graphics.beginFill(0xffff0000, 1);
			triMask.graphics.moveTo(100, 0);
			triMask.graphics.lineTo(200, 173);
			triMask.graphics.lineTo(0, 173);
			triMask.graphics.lineTo(100, 0);
			triMask.graphics.endFill();			
			
			var s:Sprite = new Sprite();
			var a:Bitmap = new Bitmap(new BitmapData(200, 173, true, 0xff000000), "auto", true);
			
			s.addChild(a);
			s.addChild(triMask);
			
			a.mask = triMask;
			
			return s;
		}
		
		public function getTilePoint():Point
		{
			return new Point(oldX, oldY);
		}
		/**
		 * Runs on enter frame
		 * if mouse is within the control area then grab a 200x173 section from image
		 * based on mouse position and then copy that into each of the kaleidoscope slices
		 * 
		 * @param	e Enter Frame event
		 */
		private function update(e:Event = null, force:Boolean = false):void
		{		
			mx = mainContainer.mouseX;
			my = mainContainer.mouseY;
			
			if(isDrawing || force){
				if ((controlRect.contains(mx, my) && (oldX != mx || oldY != my)) || force) {
					
					if (force) {
						//new Rectangle(0, 0, 200, 173)
						//trace("force update");
						canvasData.copyPixels(image, new Rectangle(widthRatio * (oldX - controlRect.x), heightRatio * (oldY - controlRect.y), 200, 173), ZERO_POINT);						
					}else {
						//only update oldX,oldY if mouse is in controlRect
						oldX = mx;
						oldY = my;
						canvasData.copyPixels(image, new Rectangle(widthRatio * (mx - controlRect.x), heightRatio * (my - controlRect.y), 200, 173), ZERO_POINT);						
					}
					
					for (var i:int = 0; i < kalContainer.numChildren; i++) {
						Bitmap(Sprite(kalContainer.getChildAt(i)).getChildAt(0)).bitmapData.draw(canvasData);
					}
					
					tileData.draw(kalContainer);
					
					//trace("update", oldX, oldY);
					dispatchEvent(new Event(KALEID_CHANGED));
				}
			}			
		}
		
		
		/**
		 * Called by MOUSE_DOWN MOUSE_UP on mainContainer.stage
		 */
		private function toggleDrawing(e:MouseEvent):void
		{			
			mx = mainContainer.mouseX;
			my = mainContainer.mouseY;
			if (!isDrawing && controlRect.contains(mx, my)) {
				isDrawing = true;			
			}else {
				isDrawing = false;
			}			
		}
	}	
}