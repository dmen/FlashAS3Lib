package com.gmrmarketing.testing
{		
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	
	public final class ScratchTile extends Sprite
	{		
		private static var brush:BitmapData;
		private static var brushRect:Rectangle;
		
		private var reveal:BitmapData;
		private var draw:BitmapData;
		private var diffBmpData:BitmapData;
		private var diffImage:Bitmap;
		
		public function ScratchTile($reveal:BitmapData, $brush:BitmapData)
		{	
			reveal = $reveal;
			brush = $brush;
			brushRect = new Rectangle(0, 0, brush.width, brush.height);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private final function init(e:Event):void
		{
			//image we draw into
			 draw = new BitmapData(115, 115, true, 0x00000000);

			//image we see - the image to be scratched off composited with the alpha of the draw image
			diffBmpData = new BitmapData(115, 115, true, 0x00ffffff);
			diffImage = new Bitmap(diffBmpData);
			addChild(diffImage);

			addEventListener(MouseEvent.MOUSE_DOWN, beginDraw);			
		}		

		private final function beginDraw(e:MouseEvent):void
		{
			addEventListener(MouseEvent.MOUSE_MOVE, moveMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDraw);
		}
		
		private final function endDraw(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, moveMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDraw);
			
			var num:uint = diffBmpData.threshold(diffBmpData,new Rectangle(0,0,320,480),new Point(0,0),"==",0x00000000);
			//trace(num);
		}
		
		private final function moveMouse(e:MouseEvent):void
		{
			draw.copyPixels(brush,brushRect,new Point(mouseX - 10, mouseY - 17),null,null,true);
			diffBmpData.copyPixels(reveal, new Rectangle(0,0,115,115), new Point(0,0), draw, null, true);
		}

	}
	
}