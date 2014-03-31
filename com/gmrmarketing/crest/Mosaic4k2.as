package com.gmrmarketing.crest
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;	
	import flash.display.Sprite;
	import fl.motion.Color;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.getTimer;
	import flash.utils.Timer;

	
	public class Mosaic4k extends MovieClip
	{				
		private var tiles:Array;
		private var tileLoader:Loader;		
		
		private const SERVER_TILE_WIDTH:int = 40; //individual tile size in the catalog image
		private const SERVER_TILE_HEIGHT:int = 30;
		
		private const TOTAL_TILES:int = 10540; //minimum number of tiles to use - if there are less tiles in the
		//catalog then they will be duplicated.
		
		private var tileWidth:int = 7; //average tile size
		private var tileHeight:int = 5;
		
		private var catX:int; //position in the tile catalog
		private var catY:int;
		private var curX:int; //position in mosaic
		private var curY:int;
		private var imX:int; //position on stage for placing tiles
		private var imY:int;
		
		private var mosaic:BitmapData; //library mosaic image to get average colors from
		private var targetImage:BitmapData;//blank 4000 x 3000 image to copy tiles into
		private var tileRect:Rectangle;
		private var tilePoint:Point;		
		private var elapsed:Number;
		private var tileCatalog:Bitmap; //image of the master tile image
		
		private var drawTimer:Timer;		
		
		private var tile:BitmapData;
		private var zeroPoint:Point = new Point(0, 0);
		
		private var tint:Color;		
		
		private var points:Array;
		private var pointIndex:int;
		
		private var zoomSlider:theSlider; //library clip
		
		private var xZoomRatio:Number;
		private var yZoomRatio:Number;
		private var sliderStart:int;		
		
		private var target:Bitmap;
		
		private var scaleMatrix:Matrix;
		
		private var tileList:XMLList;
		private var tileXMLLoader:URLLoader = new URLLoader();
		
		
		private var percentDialog:indicator; //library clip
		
		
		
		public function Mosaic4k() 
		{				
			tileLoader = new Loader(); //master tile catalog image from server
			tile = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);
			
			mosaic = new mosaicBmd(880, 448); //library image			
			
			//empty, black image on stage
			targetImage = new BitmapData(4960, 2525, false, 0x000000);
			target = new Bitmap(targetImage);			
			addChild(target);			
			target.scaleX = .177; //to fit to 880 x 448
			target.scaleY = .177;
			
			tint = new Color();
			
			tilePoint = new Point();
			scaleMatrix = new Matrix(); //used for scaling the mosaic tiles
			scaleMatrix.scale(SERVER_TILE_WIDTH / 6, SERVER_TILE_HEIGHT / 4);
			
			zoomSlider = new theSlider(); //library clip
			zoomSlider.x = 188;
			zoomSlider.y = 347;
			addChild(zoomSlider);
			zoomSlider.slider.buttonMode = true;
			zoomSlider.slider.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
			xZoomRatio = .00425;
			yZoomRatio = .00433;
			sliderStart = zoomSlider.slider.x;
			
			percentDialog = new indicator(); //library clip
			
			loadTileImage("tile100-2.jpg");
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, dragSlider, false, 0, true);
		}
		
		
		private function dragSlider(e:Event):void
		{
			if(zoomSlider.mouseX >= 9 && zoomSlider.mouseX <= 209){
				zoomSlider.slider.x = zoomSlider.mouseX;
			}
			var delta:Number = zoomSlider.slider.x - sliderStart;
			target.scaleX = delta * xZoomRatio + .15; //initial scaleX and scaleY are .15 and .134
			target.scaleY = delta * yZoomRatio + .134;
			
			//center image when scaling			
			var wDelta:Number = (target.width - 600) / 2;
			var hDelta:Number = (target.height - 400) / 2;			
			target.x = -wDelta;
			target.y = -hDelta;
		}
		
		
		private function endDrag(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, dragSlider);
		}
		
		
		/**
		 * Called from Constructor - loads the tile catalog
		 * @param	url - tile catalog url
		 */
		public function loadTileImage(url:String):void
		{	
			addChild(percentDialog);
			percentDialog.x = 190;
			percentDialog.y = 175;
			percentDialog.theText.text = "loading tiles";
			percentDialog.bar.scaleX = 0;
			
			tileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, tilesLoaded, false, 0, true);
			tileLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
			tileLoader.load(new URLRequest(url));
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal;
			percentDialog.bar.scaleX = percentDownloaded;			
		}
		
		
		private function xmlProgress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal;
			percentDialog.bar.scaleX = percentDownloaded;
		}
		
		
		private function xmlLoaded(e:Event):void
		{			
			tileXMLLoader.removeEventListener(Event.COMPLETE, xmlLoaded);
			tileXMLLoader.removeEventListener(ProgressEvent.PROGRESS, xmlProgress);
			tileXML = new XML(e.target.data);
			
			removeChild(percentDialog);			
			
			generateMosaic();
		}
		
		
		/**
		 * Called when master tile catalog is done loading
		 * loads the xml data containing the codes for each tile
		 * @param	e
		 */
		private function tilesLoaded(e:Event):void
		{
			tileCatalog = e.target.content;
			tileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, tilesLoaded);
			tileLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);		
			
			percentDialog.theText.text = "loading XML data";
			
			tileXMLLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			tileXMLLoader.addEventListener(ProgressEvent.PROGRESS, xmlProgress, false, 0, true);
			tileXMLLoader.load(new URLRequest("tileData.xml"));			
		}
		
		
		
		private function generateMosaic():void
		{			
			catX = 0; //x,y within the tile catalog image
			catY = 0;
			curX = 0; //x,y within mosaic for taking averages
			curY = 0;
			imX = 0; //x,y inside targetImage
			imY = 0;
			
			elapsed = getTimer();	
			
			pointIndex = 0;
			
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
			tint.setTint(averageRGB(j), .75);
			tint.alphaMultiplier = .7;
			
			//create a bitmap at server tile size and then draw catalog tile into it with tinting
			var tmp:BitmapData = new BitmapData(SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT);
			tmp.draw(j, scaleMatrix);
			tmp.draw(tile, null, tint);
			
			//place tinted tile into targetImage
			targetImage.copyPixels(tmp, new Rectangle(0, 0, SERVER_TILE_WIDTH, SERVER_TILE_HEIGHT), new Point(imX, imY));			
			
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
			
			pointIndex++;			
			
			if(pointIndex >= TOTAL_TILES){
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