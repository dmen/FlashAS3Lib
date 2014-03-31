package com.gmrmarketing.nissan
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import com.dynamicflash.util.Base64;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import com.greensock.TweenMax;
	
	
	public class PhotoViewer extends MovieClip
	{
		private const TOP_BUFFER:int = 1200; //distance big image is placed from top of screen
		
		private const ORIGINAL_WIDTH:int = 500; //original dimensions from the photo booth
		private const ORIGINAL_HEIGHT:int = 600;
		private const HSCALE:Number = .216; //500 * .216 = 108
		private const VSCALE:Number = .216 //600 * .216 = 129.6
		private const SCALED_WIDTH:int = 108;
		private const SCALED_HEIGHT:int = 129;		
		
		private var fileList:Array;
		private var fileIndex:int;
		
		private var byteLoader:Loader; //for loading of the images
		private var bigByteLoader:Loader; //for loading of the individual big image
		private var bgLoader:Loader; //for loading the background image
		
		private var swfKit:SWFKitFiles;
		
		private var startX:int;
		private var startY:int;		
	
		private var mainBitmapData:BitmapData;
		private var mainBitmap:Bitmap;
		
		private var fileTimer:Timer; //for checking the folder contents
		
		private var bigImageData:BitmapData;
		private var bigImage:Bitmap;
		private var bigImageTimer:Timer; //used for showing the big image for a set period
		
		private var imageShadow:DropShadowFilter;
		
		private var picLogo:smallLogo; //lib clip
		private var logo:Bitmap;
		
		
		public function PhotoViewer()
		{
			swfKit = new SWFKitFiles();
			
			picLogo = new smallLogo(50, 365);
			logo = new Bitmap(picLogo);
			
			fileTimer = new Timer(3000);
			fileTimer.addEventListener(TimerEvent.TIMER, checkFiles, false, 0, true);
			
			startX = stage.stageWidth; //top left when screen is rotated 90
			startY = 0;
			
			mainBitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, true);
			mainBitmap = new Bitmap(mainBitmapData);
			
			addChild(mainBitmap);
			
			//add in the background from the library
			mainBitmapData.draw(new background(1920,1080));
			
			byteLoader = new Loader();
			byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded, false, 0, true);
			
			bigByteLoader = new Loader();
			bigByteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bigBytesLoaded, false, 0, true);
			
			//original images are 500 x 600 - scaled to 1.2 so 600 x 720
			bigImageData = new BitmapData(820, 620, false, 0xFFFFFF); //10 pixel border
			bigImage = new Bitmap(bigImageData);
			var m:Matrix = new Matrix();
			m.translate(18, 20);
			bigImageData.draw(logo, m);
			
			imageShadow = new DropShadowFilter(1, 0, 0x000000, .9, 7, 7, 1, 2, false, false);
			bigImage.filters = [imageShadow];
			
			bigImageTimer = new Timer(10000, 1);
			bigImageTimer.addEventListener(TimerEvent.TIMER, removeBigImage, false, 0, true);
	
			refreshFileList();
			if(fileIndex != -1){
				loadImage();
			}else {
				fileTimer.start();
			}
		}
		
		
		
		/**
		 * Resets the fileList array to the list of images in the images folder
		 */
		private function refreshFileList():void
		{
			fileList = new Array();
			
			var files:Array = swfKit.getFiles();
			var file:String;
			var fileArray:Array;
			
			for (var i:int = 0; i < files.length; i++) {
				fileArray = files[i].split("\\");
				fileList.push(fileArray[fileArray.length - 1]);
			}			
			
			//start at the last file in the list
			fileIndex = fileList.length - 1;
		}
		
		
		/**
		 * Loads a base64 encoded image
		 */
		private function loadImage():void
		{
			var ba:ByteArray = Base64.decodeToByteArray(swfKit.readFile(fileList[fileIndex]));
			byteLoader.loadBytes(ba);
		}
		
		
		
		/**
		 * Called from checkFiles() if a new file is found in the folder
		 */
		private function loadNewestImage():void
		{
			var ba:ByteArray = Base64.decodeToByteArray(swfKit.readFile(fileList[fileList.length - 1]));
			bigByteLoader.loadBytes(ba);
		}
		
		
		
		private function bigBytesLoaded(e:Event):void
		{
			var aloader:Loader = (e.target as LoaderInfo).loader;
			var bmp:Bitmap = Bitmap(aloader.content);
			bmp.smoothing = true;
			
			bigImage.height = 600;
			bigImage.width = 720;			
			bigImage.x = stage.stageWidth - TOP_BUFFER;
			bigImage.y = Math.floor((stage.stageHeight - bigImage.height) / 2); //center vertically
			bigImage.alpha = 1;
			
			var m:Matrix = new Matrix();
			m.scale(1.2, 1.2); //375 x 450
			m.rotate(Math.PI / 2); //rotate 90º
			m.translate(810, 10);
			
			bigImageData.draw(bmp, m);
			addChild(bigImage);			
			
			bigImageTimer.start();
		}
		
		
		private function removeBigImage(e:TimerEvent):void
		{
			TweenMax.to(bigImage, 1, { x:stage.stageWidth - SCALED_HEIGHT, y:0, width:SCALED_HEIGHT, height:SCALED_WIDTH, alpha:0, onComplete:killBigImage } );
		}
		
		
		private function killBigImage():void
		{
			removeChild(bigImage);
		}
		
		
		private function bytesLoaded(e:Event):void
		{	
			var aloader:Loader = (e.target as LoaderInfo).loader;
			var bmp:Bitmap = Bitmap(aloader.content);
			bmp.smoothing = true;
			
			var m:Matrix = new Matrix();
			
			m.scale(HSCALE, VSCALE);
			m.rotate(Math.PI / 2); //rotate 90º
			m.translate(startX, startY);
			
			mainBitmapData.draw(bmp, m);
			
			startY += SCALED_WIDTH;
			if (startY >= stage.stageHeight) {
				startY = 0;
				startX -= SCALED_HEIGHT;
				if (startX <= 0) {
					//stop drawing
					fileIndex = 0;
				}
			}
			
			fileIndex--;
			if (fileIndex > -1) {
				loadImage();
			}else {
				//done drawing - listen for new image
				fileTimer.start();
			}
		}
		
		
		
		/**
		 * Called by fileTimer every 5 seconds until a change is found then the
		 * timer is stopped and the images are redrawn
		 * 
		 * @param	e TIMER TimerEvent
		 */
		private function checkFiles(e:TimerEvent):void
		{
			//current list of images is in fileList
			var files:Array = swfKit.getFiles();
			
			if (files.length != fileList.length) {
				//something changed
				fileTimer.reset();				
				
				startX = stage.stageWidth;
				startY = 0;				
				
				refreshFileList();
				loadNewestImage();
				loadImage();				
			}
		}
		
	}
	
}