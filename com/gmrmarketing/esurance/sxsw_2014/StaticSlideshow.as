package com.gmrmarketing.esurance.sxsw_2014
{
	import flash.display.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	
	public class StaticSlideshow extends EventDispatcher
	{		
		private var container:DisplayObjectContainer;
		private var numSlides:int;
		private var slides:XMLList;
		private var currSlide:int; //index in slides
		private var loader:Loader;
		private var imageContainer:Sprite;
		
		
		
		public function StaticSlideshow()
		{
			imageContainer = new Sprite();			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, badImage);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function setXML($slides:XMLList):void
		{
			slides = $slides;			
		}
		
		
		public function show():void
		{
			if (!container.contains(imageContainer)) {
				container.addChild(imageContainer);
			}
			clearImages();
			numSlides = slides.length();
			currSlide = -1;
			showNext();
		}
		
		
		private function clearImages():void
		{
			while (imageContainer.numChildren) {
				imageContainer.removeChildAt(0);
			}
		}
		
		
		private function showNext():void
		{
			currSlide++;
			if (currSlide >= numSlides) {
				currSlide = 0;
			}
			loader.load(new URLRequest(slides[currSlide]));
		}
		
		
		private function imageLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);			
			b.smoothing = true;
			
			var res:BitmapData = new BitmapData(1920, 1080);
			var m:Matrix = new Matrix();
			m.scale(1920 / b.width, 1080 / b.height);
			res.draw(b.bitmapData, m, null, null, null, true);
			var disp:Bitmap = new Bitmap(res, "auto", true);
			
			disp.alpha = 0;
			imageContainer.addChild(disp);
			TweenMax.to(disp, 1, { alpha:1, onComplete:waitForNext } );
		}
		
		
		private function badImage(e:IOErrorEvent):void
		{
			trace("Image was not found - check XML",e.toString());
		}
		
		
		private function waitForNext():void
		{
			//remove previous one behind the new one
			if (imageContainer.numChildren > 1) {
				imageContainer.removeChildAt(0);
			}
			TweenMax.delayedCall(slides[currSlide].@time, showNext);
		}
		
		
		public function hide():void
		{
			TweenMax.killAll();
			clearImages();
			if (container.contains(imageContainer)) {
				container.removeChild(imageContainer);
			}
		}
		
	}	
}