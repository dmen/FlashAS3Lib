package com.gmrmarketing.testing 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Kaleidoscope
	{
		private var canvasData:BitmapData;
		private var canvas:Bitmap;
		private var image:BitmapData;		
		
		private var m:Matrix;
		private var widthRatio:Number;
		private var heightRatio:Number;
		
		private var tileData:BitmapData;
		private var tile:Bitmap;
		private var offScreenBuffer:BitmapData;
		
		private var kalContainer:Sprite;
		private const ZERO_POINT:Point = new Point(0, 0);
		
		private var mainContainer:DisplayObjectContainer;
		
		private var bigData:BitmapData;
		
		
		
		
		public function Kaleidoscope(kContainer:DisplayObjectContainer)
		{
			mainContainer = kContainer;
			
			kalContainer = new Sprite();
			
			m = new Matrix();
			image = new kal();			
			
			tileData = new BitmapData(600, 400, true, 0xffffffff);
			tile = new Bitmap(tileData);
			
			bigData = new BitmapData(1500, 1500);
			
			mainContainer.addChild(tile);
			
			offScreenBuffer = new BitmapData(500, 500, true, 0x00000000);			
			
			//image we're copying from the kaliedoscope image is 200 x 173		
			widthRatio = image.width /mainContainer.width;
			heightRatio = image.height / mainContainer.height;			
			
			var a:Sprite = createTriangle();
			kalContainer.addChild(a);
			a.y = 200;
			a.x = 200;			
			
			var b:Sprite = createTriangle();
			kalContainer.addChild(b);
			b.rotation = 180;
			b.y = 200;
			b.x = 400;
			
			var c:Sprite = createTriangle();
			kalContainer.addChild(c);
			c.rotation = 60;
			c.x = 250;
			c.y = 113;
			
			var d:Sprite = createTriangle();
			kalContainer.addChild(d);
			d.rotation = -60;
			d.x = 250;
			d.y = 286;
			
			var e:Sprite = createTriangle();
			kalContainer.addChild(e);
			e.rotation = 120;
			e.x = 350;
			e.y = 114;
			
			var f:Sprite = createTriangle();
			kalContainer.addChild(f);
			f.rotation = -120;
			f.x = 350;
			f.y = 286;
			
			canvasData = new BitmapData(200, 173, true, 0x00ff0000);
			canvas = new Bitmap(canvasData, "auto", true);
			
			mainContainer.addEventListener(Event.ENTER_FRAME, update, false, 0, true);			
		}
		
		
		public function getTile():BitmapData
		{
			bigData.copyPixels(tileData, tileData.rect, new Point(460, 650)); //trunk
			bigData.copyPixels(tileData, tileData.rect, new Point(-25, 1100)); //hood
					
			bigData.copyPixels(tileData, tileData.rect, new Point(969, 663)); //drivers door
			bigData.copyPixels(tileData, tileData.rect, new Point(969, 1063)); //front fenders
			bigData.copyPixels(tileData, tileData.rect, new Point(566, 1100)); //passenger door	
			bigData.copyPixels(tileData, tileData.rect, new Point(969, 264)); //rear drivers fender
			
			return bigData;
		}
		
		
		
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
		
		
		
		private function update(e:Event):void
		{			
			canvasData.copyPixels(image, new Rectangle(widthRatio * mainContainer.mouseX, heightRatio * mainContainer.mouseY, 200, 173), ZERO_POINT);			
			
			for (var i:int = 0; i < kalContainer.numChildren; i++) {
				Bitmap(Sprite(kalContainer.getChildAt(i)).getChildAt(0)).bitmapData.draw(canvasData);
			}
			
			offScreenBuffer.draw(kalContainer);
			
			//used for the corners
			var m:Matrix = new Matrix(); 
			m.scale(.3, .3);
			
			tileData.draw(offScreenBuffer);
			m.translate(0, 10);
			tileData.draw(offScreenBuffer, m, null, null, null, true);
			m.translate(420, 0);
			tileData.draw(offScreenBuffer, m, null, null, null, true);
			m.translate(0, 270);
			tileData.draw(offScreenBuffer, m, null, null, null, true);
			m.translate(-420, 0);
			tileData.draw(offScreenBuffer, m, null, null, null, true);
		}
	}	
}