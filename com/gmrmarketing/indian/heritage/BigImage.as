/**
 * Fullscreen image called from clicking on image in image detail screen
 */
package com.gmrmarketing.indian.heritage
{	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.net.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DropShadowFilter;
	
	
	public class BigImage extends EventDispatcher
	{
		private var loader:Loader;
		private var container:DisplayObjectContainer;
		private var modal:MovieClip;
		private var big:Bitmap;
		private var timeoutHelper:TimeoutHelper;
		private var close:MovieClip;
		private var imageContainer:Sprite;//for centering the loaded image
		private var shadow:DropShadowFilter;
		
		
		public function BigImage()
		{
			loader = new Loader();
			
			imageContainer = new Sprite();
			imageContainer.x = 960;//centered on 1920x1080
			imageContainer.y = 540;
			
			shadow = new DropShadowFilter(0, 0, 0, .8, 10, 10, .8, 2);
			
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function init($container:DisplayObjectContainer, $close:MovieClip, $modal:MovieClip):void
		{
			container = $container;
			close = $close;
			modal = $modal;
		}		
		
		
		public function loadImage(image:String):void
		{
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			loader.load(new URLRequest("images/" + image));
			timeoutHelper.buttonClicked();
		}
		
		
		private function imageLoaded(e:Event):void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			
			big = Bitmap(e.target.content);
			big.smoothing = true;
			
			big.x = - Math.round(big.width * .5);
			big.y = - Math.round(big.height * .5);
			
			container.addChild(modal);
			modal.alpha = 0;
			
			imageContainer.addChild(big);
			//imageContainer.filters = [shadow];
			
			container.addChild(imageContainer);
			imageContainer.alpha = 0;
			imageContainer.scaleX = imageContainer.scaleY = .5;
			
			container.addChild(close);
			close.alpha = 0;
			
			TweenMax.to(imageContainer, 1, { alpha:1, scaleX:1, scaleY:1 } );
			TweenMax.to(modal, .5, { alpha:1, delay:.5 } );
			TweenMax.to(close, .5, { alpha:1, delay:.5 } );
			
			container.addEventListener(MouseEvent.MOUSE_DOWN, removeImage, false, 0, true);
		}
		
		
		private function removeImage(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			container.removeEventListener(MouseEvent.MOUSE_DOWN, removeImage);
			
			//kill any tweens from imageLoaded()
			TweenMax.killTweensOf(imageContainer);
			TweenMax.killTweensOf(modal);
			TweenMax.killTweensOf(close);
			
			//fade out the image
			TweenMax.to(imageContainer, .5, { alpha:0 } );
			TweenMax.to(close, .5, { alpha:0 } );
			TweenMax.to(modal, .5, { alpha:0, onComplete:hide } );			
		}
		
		
		/**
		 * Called by tween from removeImage()
		 * Called by Main.doReset() if the timeoutHelper times out
		 */
		public function hide():void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			
			//kill any tweens from imageLoaded()
			TweenMax.killTweensOf(imageContainer);
			TweenMax.killTweensOf(modal);
			TweenMax.killTweensOf(close);
			
			if (container && big) {
				if (container.contains(imageContainer)) {
					container.removeChild(imageContainer);
					imageContainer.removeChild(big);
					//imageContainer.filters = [];
					container.removeChild(modal);
					container.removeChild(close);
				}
			}
		}
		
	}
	
}