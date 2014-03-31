/**
 * Loads and displays images within the provided container
 * 
 * Instantiated by Main.as
 */
package com.gmrmarketing.htc.movies
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.htc.movies.ConfigData;
	import flash.utils.Timer;
	
	
	public class ImageDisplay
	{
		private var images:Array;
		private var index:int; //index in images
		private var container:Sprite;
		
		private var containerX:int;
		private var containerY:int;
		private var containerWidth:int;
		private var containerHeight:int;
		
		private var viewTime:int;
		
		
		public function ImageDisplay($container:Sprite, area:Rectangle)
		{
			container = $container;
			
			viewTime = Math.floor(10 + Math.random() * 7); //10 - 16
			
			containerX = area.x;
			containerY = area.y;
			containerWidth = area.width;
			containerHeight = area.height;
		}
		
		
		/**
		 * Called from Main.refreshImagesComplete()
		 * @param	theImages
		 */
		public function setImageList(theImages:Array):void
		{
			images = theImages.concat();
			index = -1;
			removeOld();
			loadNextImage();
		}
		
		
		private function loadNextImage(e:TimerEvent = null):void
		{
			index++;
			if (index >= images.length) {
				index = 0;
			}
			
			var	imageLoader:Loader = new Loader();
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, urlError, false, 0, true);
			
			try{
				imageLoader.load(new URLRequest(ConfigData.IMAGE_PATH + images[index]));
			}catch (e:Error) {				
				loadNextImage();
			}			
		}
		
		
		/**
		 * IOError - File Not Found
		 * loads the next image when a file not found is encountered
		 * @param	e
		 */
		private function urlError(e:Event):void
		{			
			loadNextImage();
		}
		
		
		/**
		 * Called on COMPLETE when an image is done loading
		 * @param	e
		 */
		private function imageLoaded(e:Event):void
		{
			var lo:Loader = Loader(e.currentTarget.loader);			
			
			var bmp:Bitmap = Bitmap(e.target.content);
			bmp.smoothing = true;
			//bmp.bitmapData.copyPixels(frenchOverlay, new Rectangle(0, 0, frenchOverlay.width, frenchOverlay.height), new Point(0, bmp.height - frenchOverlay.height));
			
			//size to fit container						
			var ratio:Number = Math.max(containerWidth / lo.width, containerHeight / lo.height);			
			lo.width *= ratio;
			lo.height *= ratio;
			
			//make a scaling container
			var s:Sprite = new Sprite();				
			container.addChild(s);
			
			s.x = Math.floor(containerWidth * .5);
			s.y = Math.floor(containerHeight * .5);			
			
			s.addChild(lo);
			lo.x -= lo.width * .5;
			lo.y -= lo.height * .5;
			
			if (ConfigData.USE_KEN_BURNS) {
				TweenMax.to(lo, 0, { colorMatrixFilter: { amount:1, brightness:3, saturation:3 } } );
				TweenMax.to(lo, 3, { colorMatrixFilter:{amount:0, brightness:1, saturation:1}, onComplete:removeOld } );
				TweenMax.to(s, viewTime + 2, { scaleX:ConfigData.SCALE_AMOUNT, scaleY:ConfigData.SCALE_AMOUNT, overwrite:0, ease:Linear.easeNone } );
			}else {
				s.alpha = 0;
				TweenMax.to(s, 2, { alpha:1, onComplete:removeOld } );
			}
			
			var a:Timer = new Timer(viewTime * 1000, 1);
			a.addEventListener(TimerEvent.TIMER, loadNextImage, false, 0, true);
			a.start();
		}
		
		
		/**
		 * Called by TweenMax whenever a new image is done fading in
		 * removes the prior image at index 0
		 */
		private function removeOld():void
		{
			while (container.numChildren > 1) {				
				var c:Sprite = Sprite(container.removeChildAt(0));//the scaling container
				var b:Loader = Loader(c.removeChildAt(0));
				b.unload();//unload the bitmap				
			}
		}
		
	}
	
}