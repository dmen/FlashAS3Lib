package com.gmrmarketing.crest
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.getTimer;

	public class Mosaic extends EventDispatcher
	{
		private var tileXMLLoader:URLLoader;		
		private var tiles:Array;
		private var tileLoader:Loader;
		private var tileIndex:int;		
		private var stage:Stage;
		
		private const TARGET_WIDTH:int = 900;
		private const TARGET_PIXELS:int = 450000; //900 x 500 mosaic image
		private var tileSize:int; //size to scale tiles to to fit all tiles to image
		
		private var curX:int;
		private var curY:int;
		private var tilesPerRow:int;
		
		private var targetImage:BitmapData; //library
		private var tileRect:Rectangle;
		private var tilePoint:Point;
		private var scaleMatrix:Matrix;
		
		private var elapsed:Number;
		//private var allTiles:Array;
		
		public function Mosaic($stage:Stage) 
		{
			stage = $stage;
			
			tileXMLLoader = new URLLoader();	
			tileLoader = new Loader();
			tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, tileLoaded, false, 0, true);
			
			targetImage = new mosaicBmd(900, 500);
			var t = new Bitmap(targetImage);
			stage.addChild(t);
			
			tilePoint = new Point();
			scaleMatrix = new Matrix();
		}
		
		
		
		public function loadXML(url:String):void
		{			
			tileXMLLoader.addEventListener(Event.COMPLETE, tileListLoaded, false, 0, true);
			tileXMLLoader.load(new URLRequest(url));
		}
		
		
		
		private function tileListLoaded(e:Event):void
		{
			tileXMLLoader.removeEventListener(Event.COMPLETE, tileListLoaded);
			var tileList:XMLList = new XML(e.target.data).image;
			tiles = new Array();
			for each(var image:XML in tileList) {
				tiles.push({fileName:image.toString()});
			}
			
			var ppt:int = Math.ceil(TARGET_PIXELS / tiles.length);
			tileSize = Math.ceil(Math.sqrt(ppt));
			tileRect = new Rectangle(0, 0, tileSize, tileSize);
			
			
			tilesPerRow = Math.ceil(TARGET_WIDTH / tileSize);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		
		public function randomizeTiles():void
		{
			var newTiles:Array = new Array();
			var ind:int;
			while (tiles.length > 0) {
				ind = Math.floor(Math.random() * tiles.length);
				newTiles.push(tiles.splice(ind, 1)[0]);
			}
			tiles = newTiles;
		}
		
		
		public function generateMosaic():void
		{
			tileIndex = 0;
			curX = 0;
			curY = 0;
			//allTiles = new Array();
			loadTile();			
			elapsed = getTimer();
			//targetImage.lock();
		}
		
		private function loadTile():void
		{
			tileLoader.load(new URLRequest(tiles[tileIndex].fileName));
			
		}
		
		private function tileLoaded(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			scaleMatrix.identity();
			scaleMatrix.scale(tileSize / bit.width, tileSize / bit.height);
			var j:BitmapData = new BitmapData(tileSize, tileSize);
			j.draw(bit, scaleMatrix);
			
			//allTiles.push(j);
			
			//var b:Bitmap = new Bitmap(j);
			
			//container.addChild(b);
			//b.x = curX;
			//b.y = curY;
			tilePoint.x = curX;
			tilePoint.y = curY;
			targetImage.copyPixels(j, tileRect, tilePoint);
			
			curX += tileSize;
			if (tileIndex % tilesPerRow == 0 && tileIndex != 0) {
				curX = 0;
				curY += tileSize;
			}
			
			tileIndex++;
			
			if(tileIndex < tiles.length){
				loadTile();
			}else {
				//targetImage.unlock();
				trace(getTimer() - elapsed);
			}
		}
	
		
		
		private function averageRGB( source:BitmapData ):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
		 
			var count:Number = 0;
			var pixel:Number;
		 
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
		 
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;
		 
					count++
				}
			}
		 
			red /= count;
			green /= count;
			blue /= count;
			
			//trace("analyzed", count, "pixels");
			
			return red << 16 | green << 8 | blue;
		}
	}
	
}