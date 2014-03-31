package com.gmrmarketing.comcast.scratchoff
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	
	public class Main extends Sprite
	{
		private var beerOne:beer1;
		private var beerTwo:beer2;
		private var beerThree:beer3;
		
		private var beers:BitmapData;
		
		private var frameCount:int;
		
		private var drawBmp:BitmapData;
		private var draw2:Sprite;
		private var lastPoint:Point;
		
		private var diffBmpData:BitmapData;
		private var diffImage:Bitmap;
		
		private var rectList:Array;
		
		
		public function Main()
		{
			rectList = new Array(new Rectangle(22, 64, 115, 115), new Rectangle(182, 64, 115, 115), new Rectangle(22, 205, 115, 115),
			new Rectangle(182, 205, 115, 115), new Rectangle(22, 344, 115, 115), new Rectangle(182, 344, 115, 115));
			
			beerOne = new beer1(115, 115);
			beerTwo = new beer2(115, 115);
			beerThree = new beer3(115, 115);
				
			beers = new BitmapData(320, 480, true, 0x00ffffff);

			var sRect:Rectangle = new Rectangle(0,0,115,115);

			beers.copyPixels(beerOne, sRect, new Point(22, 64));
			beers.copyPixels(beerTwo, sRect, new Point(182, 64));
			beers.copyPixels(beerThree, sRect, new Point(22, 205));
			beers.copyPixels(beerTwo, sRect, new Point(182, 205));
			beers.copyPixels(beerOne, sRect, new Point(22, 344));
			beers.copyPixels(beerThree, sRect, new Point(182, 344));
			
			drawBmp = new BitmapData(320, 480, true, 0x00000000);
			
			draw2 = new Sprite();
			draw2.graphics.lineStyle(24, 0x000000);
			lastPoint = new Point(0, 0);
			
			diffBmpData = new BitmapData(320, 480, true, 0x00ffffff);
			diffImage = new Bitmap(diffBmpData);
			addChild(diffImage);
			
			frameCount = 0;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDraw);
		}		

		
		private final function beginDraw(e:MouseEvent):void
		{
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, moveMouse);
			lastPoint.x = mouseX; lastPoint.y = mouseY;
			draw2.graphics.moveTo(lastPoint.x, lastPoint.y);
			addEventListener(Event.ENTER_FRAME, moveMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDraw);
		}

		
		private final function endDraw(e:MouseEvent):void
		{
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse);
			removeEventListener(Event.ENTER_FRAME, moveMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
		}
			
		
		private final function moveMouse(e:Event):void
		{
			frameCount++;
			if(frameCount == 4){
				frameCount = 0;
				checkRects();
				draw2.graphics.lineTo(mouseX, mouseY);
				lastPoint.x = mouseX; lastPoint.y = mouseY;
				drawBmp.draw(draw2);
				//drawBmp.copyPixels(brush,brushRect,new Point(mouseX - 10, mouseY - 17),null,null,true);
				diffBmpData.copyPixels(beers, new Rectangle(0,0,320,480), new Point(0,0), drawBmp, null, true);
			}			
		}
		
		private final function checkRects():void
		{
			for (var i:int = 0; i < rectList.length; i++) {
				if (Rectangle(rectList[i]).contains(mouseX, mouseY)) {
					beers.copyPixels(beerOne, new Rectangle(0, 0, 115, 115), new Point(Rectangle(rectList[i]).x, Rectangle(rectList[i]).y));
					break;
				}
			}
		}
	}	
}