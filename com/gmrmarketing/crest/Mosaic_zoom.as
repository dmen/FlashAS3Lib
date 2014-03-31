package com.gmrmarketing.crest
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.Sprite;
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
	
	public class Mosaic_zoom extends EventDispatcher
	{				
		private var tiles:Array;
		private var tileLoader:Loader;				
		private var container:Sprite;
		
		private const SERVER_TILE_WIDTH:int = 50; //loaded tiles are 30x30
		private const SERVER_TILE_HEIGHT:int = 50;
		private const TOTAL_TILES:int = 10000; //minimum number of tiles to use - if there are less tiles in the
		//catalog then they will be duplicated. If more tiles in the catalog then that number is used.		
		private const MOSAIC_WIDTH:int = 600;
		private const MOSAIC_HEIGHT:int = 400;
		
		private var targetPixels:int; //total pixels in the mosaic - w * h
		
		private var tileWidth:int;
		private var tileHeight:int;
		
		private var catX:int; //position in the tile catalog
		private var catY:int;
		private var curX:int; //position in mosaic
		private var curY:int;
		private var imX:int; //position on stage for placing tiles
		private var imY:int;
		
		private var mosaic:BitmapData; //library mosaic image to get average colors from
		private var targetImage:BitmapData;//blank image to copy tiles into
		private var tileRect:Rectangle;
		private var tilePoint:Point;		
		//private var totalTiles:int; //total number of tiles in the master tile image
		private var elapsed:Number;
		private var tileCatalog:Bitmap; //image of the master tile image
		
		private var drawTimer:Timer;		
		
		private var tile:BitmapData;		
		private var zeroPoint:Point = new Point(0, 0);
		
		private var tint:Color;
		
		private var points:Array;
		private var tileIndex:int;
		
		private var totalTiles:int;
		
		
		
		public function Mosaic_zoom($container:Sprite) 
		{
			container = $container;
			
			tileLoader = new Loader(); //master tile catalog image from server
			tile = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);			
			
			mosaic = new mosaicBmd(MOSAIC_WIDTH, MOSAIC_HEIGHT); //library image			
			targetPixels = MOSAIC_WIDTH * MOSAIC_HEIGHT; //total pixels in mosaic target
			
			tint = new Color();
			tilePoint = new Point();			
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
			var catalogTiles = (tileCatalog.width / SERVER_TILE_WIDTH) * (tileCatalog.height / SERVER_TILE_HEIGHT);
			if (catalogTiles > tt) {
				tt = catalogTiles;
			}			
			
			var currentArea = SERVER_TILE_WIDTH * SERVER_TILE_HEIGHT;
			//targetPixels calculated in constructor - total pixels in the mosaic target
			var targetArea:Number = targetPixels / tt; //mosaic target pixels per tile - for getting average;

			var ratio:Number = targetArea / currentArea;

			//size of individual tiles in the mosaic for getting average from
			tileWidth = Math.ceil(SERVER_TILE_WIDTH * Math.sqrt(ratio));
			tileHeight = Math.ceil(SERVER_TILE_HEIGHT * Math.sqrt(ratio));
			
			trace("Tile size: ", tileWidth, "x", tileHeight);
			
			var tilesPerRow:int = Math.floor(MOSAIC_WIDTH / tileWidth);
			var tilesPerCol:int = Math.floor(MOSAIC_HEIGHT / tileHeight);
			
			totalTiles = tilesPerRow * tilesPerCol;
			tileIndex = 0;
			trace("totalTiles computed: ", totalTiles);
			
			generateMosaic();
		}
		
		
		
		public function generateMosaic():void
		{			
			catX = 0; //x,y within the tile catalog
			catY = 0;
			curX = 0; //x,y within mosaic for taking averages
			curY = 0;
			imX = 0; //x,y on stage
			imY = 0;
			
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
			//tile is a bitmapdata with that is SERVER_TILE_WIDTH x SERVER_TILE_HEIGHT
			//ie one tile within the tile catalog
			tileRect = new Rectangle(catX, catY, SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);		
			tile.copyPixels(tileCatalog.bitmapData, tileRect, zeroPoint);
				
			//get a chunk from the mosaic for averaging
			var j:BitmapData = new BitmapData(tileWidth, tileHeight);			
			j.copyPixels(mosaic, new Rectangle(curX,  curY, tileWidth, tileHeight), zeroPoint);
			
			//set tint within the color object
			var tintTile:BitmapData = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);	
			tint.setTint(averageRGB(j), .7);
			//tint.alphaMultiplier = .8;
			
			//create a bitmap at server tile size and then draw catalog tile into it with tinting
			
			tintTile.draw(tile, null, tint);
			
			var temp:Bitmap = new Bitmap(tintTile);
			container.addChild(temp);			
			temp.x = imX;
			temp.y = imY;
			
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
			
			//increment mosaic points
			curX += tileWidth;
			imX += SERVER_TILE_WIDTH;
			
			if (curX >= mosaic.width) {
				curX = 0;
				curY += tileHeight;
				
				imX = 0;
				imY += SERVER_TILE_HEIGHT;
			}
			
			tileIndex++;			
			
			if(tileIndex >= totalTiles){
				drawTimer.stop();
				drawTimer.removeEventListener(TimerEvent.TIMER, drawTile);
				trace(getTimer() - elapsed);
				
				trace(container.width, container.height);
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