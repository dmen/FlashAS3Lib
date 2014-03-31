package com.gmrmarketing.crest
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import fl.motion.Color;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;

	import com.gmrmarketing.crest.TilePoints;
	
	public class Mosaic2 extends EventDispatcher
	{				
		private var tiles:Array;
		private var tileLoader:Loader;				
		private var stage:Stage;		
		
		private const SERVER_TILE_WIDTH:int = 50; //loaded tiles are 30x30
		private const SERVER_TILE_HEIGHT:int = 50;
		private const TOTAL_TILES:int = 7500; //minimum number of tiles to use - if less tiles in the
		//catalog then they will be duplicated
		
		private var targetWidth:int;	
		private var targetPixels:int;
		
		private var tileSize:int; //size the loaded tiles need to be in order for all of them to fit the mosaic		
		
		private var catX:int; //position in the tile catalog
		private var catY:int;
		
		private var tilesPerRow:int;
		
		private var mosaic:BitmapData; //library mosaic image to get average colors from
		private var targetImage:BitmapData;//blank image to copy tiles into
		private var tileRect:Rectangle;
		private var tilePoint:Point;
		private var scaleMatrix:Matrix;
		//private var totalTiles:int; //total number of tiles in the master tile image
		private var elapsed:Number;
		private var tileCatalog:Bitmap; //image of the master tile image
		
		private var drawTimer:Timer;
		private var columnCount:int;
		
		private var tile:BitmapData;
		private var zeroPoint:Point = new Point(0, 0);
		
		private var tint:Color;
		
		private var points:Array;
		private var pointIndex:int;
		
		public function Mosaic2($stage:Stage) 
		{
			stage = $stage;			
			
			tileLoader = new Loader(); //master tile catalog image from server
			tile = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);
			
			mosaic = new mosaicBmd(stage.width, stage.height);
			targetWidth = stage.width;
			targetPixels = mosaic.width * mosaic.height;
			
			var tt:Bitmap = new Bitmap(mosaic);
			stage.addChild(tt);
			
			//empty, black image on stage
			targetImage = new BitmapData(stage.width, stage.height, false, 0x000000);				
			var t = new Bitmap(targetImage);
			stage.addChild(t);
			
			tint = new Color();
			tilePoint = new Point();			
			scaleMatrix = new Matrix();
			
			pointIndex = 0;
		}
		
		
		
		public function loadTileImage(url:String):void
		{			
			tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, tilesLoaded, false, 0, true);
			tileLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
			tileLoader.load(new URLRequest(url));
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal * 100;
		}
		
		
		/**
		 * Called when master tile catalog is done loading
		 * @param	e
		 */
		private function tilesLoaded(e:Event):void
		{
			tileCatalog = e.target.content;
			tileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, tilesLoaded);
			tileLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			var tt:int = TOTAL_TILES;
			var totalTiles = (tileCatalog.width / SERVER_TILE_WIDTH) * (tileCatalog.height / SERVER_TILE_HEIGHT);
			if (totalTiles > tt) {
				tt = totalTiles;
			}
			//var ppt:int = Math.ceil(targetPixels / totalTiles); //pixels per tile
			
			var ppt:int = Math.ceil(targetPixels / tt); //pixels per tile
			tileSize = Math.ceil(Math.sqrt(ppt));
			
			var tp:TilePoints = new TilePoints();
			points = tp.init(stage.width, stage.height, tileSize, tileSize);
			
			scaleMatrix.identity();			
			scaleMatrix.scale(tileSize / SERVER_TILE_WIDTH, tileSize / SERVER_TILE_HEIGHT);
			
			tilesPerRow = Math.ceil(targetWidth / tileSize); //tiles per row in the mosaic
			generateMosaic();
		}
		
		
		
		public function generateMosaic():void
		{			
			catX = 0; //x,y within the tile catalog image
			catY = 0;
			
			columnCount = 0;
			
			elapsed = getTimer();			
			drawTimer = new Timer(2);
			drawTimer.addEventListener(TimerEvent.TIMER, drawTile, false, 0, true);
			drawTimer.start();
		}
	
		
		/**
		 * Called every n milliseconds by timer
		 * @param	e
		 */
		private function drawTile(e:TimerEvent):void
		{		
			var curPoint = points[pointIndex];
			
			tileRect = new Rectangle(catX, catY, SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);		
			tile.copyPixels(tileCatalog.bitmapData, tileRect, zeroPoint); //original tile from the catalog
			
			var tmp:Bitmap = new Bitmap(tile);
			
			var j:BitmapData = new BitmapData(tileSize, tileSize);
			//j.copyPixels(mosaic, new Rectangle(curX,  curY, tileSize, tileSize), zeroPoint);
			j.copyPixels(mosaic, new Rectangle(curPoint.x,  curPoint.y, tileSize, tileSize), zeroPoint);
			tint.setTint(averageRGB(j), .7);
			//tint.alphaMultiplier = .8;
			
			j.draw(tile, scaleMatrix, tint);	
			
			targetImage.copyPixels(j, new Rectangle(0, 0, tileSize, tileSize), curPoint);			
			
			//increment catalog points
			catX += SERVER_TILE_WIDTH;
			if (catX >= tileCatalog.width) {
				catX = 0;
				catY += SERVER_TILE_HEIGHT;
				if (catY >= tileCatalog.height) {
					catY = 0;
					catX = 0;
				}
			}			
			
			pointIndex++;			
			
			if(pointIndex >= points.length){
				drawTimer.stop();
				drawTimer.removeEventListener(TimerEvent.TIMER, drawTile);
				trace(getTimer() - elapsed);
			}
		}
	
		
		
		private function averageRGB( source:BitmapData ):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;			
			var count:int = 0;			
			var pixel:Number;
		 
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
		 
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;					
					count++;
				}
			}
		 
			red /= count;
			green /= count;
			blue /= count;
			
			return red << 16 | green << 8 | blue;
		}
	}
	
}