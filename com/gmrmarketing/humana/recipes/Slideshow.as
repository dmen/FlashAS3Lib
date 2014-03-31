package com.gmrmarketing.humana.recipes
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;	
	import com.greensock.TweenMax;	
	import flash.net.*;
	import flash.display.Bitmap;
	
	
	public class Slideshow extends EventDispatcher
	{		
		public static const NEW_SLIDE:String = "viewingNewImage";
		
		private var container:DisplayObjectContainer;
		private var images:Array;
		private var imageIndex:int;		
		private var loader:Loader;
		
		
		
		public function Slideshow()
		{
			loader = new Loader();
			images = new Array();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}

		
		/**
		 * 
		 * @param	$container
		 * @param	$images Array of objects containing image, title and index properties
		 */
		public function show($images:Array):void
		{		
			if(images.length == 0){
				images = $images;
				imageIndex = 0;
				images = rand(images);
							
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError, false, 0, true);
				
				loadNextImage();
			}
		}
		
		
		private function rand(array:Array):Array
		{
			var newArray:Array = new Array();
			while(array.length > 0){
				newArray.push(array.splice(Math.floor(Math.random() * array.length), 1)[0]);
			}
			return newArray;
		}
		
		
		/**
		 * stops any current loading and then empties the container
		 */
		public function hide():void
		{
			TweenMax.killAll();
			try{
				loader.close();
			}catch (e:Error) {
				
			}
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);			
			while (container.numChildren) {
				container.removeChildAt(0);
			}
			images = new Array();
		}
		
		
		public function getSelectedRecipeIndex():int
		{
			return images[imageIndex].index;
		}
		
		
		public function getCurrentRecipeTitle():String
		{
			return images[imageIndex].title;
		}
		
		
		private function loadNextImage():void
		{			
			loader.load(new URLRequest(images[imageIndex].image));
		}
				
		private function ioError(e:IOErrorEvent):void
		{
			trace("ioError");
			trace(images[imageIndex].image);
		}
		
		private function imageLoaded(e:Event):void
		{
			dispatchEvent(new Event(NEW_SLIDE));
			
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;
			b.x = 801;
			
			container.addChild(b);
			
			TweenMax.to(b, .75, { x:0 } );			
			TweenMax.delayedCall(5, removeLast );
		}
		
		
		/**
		 * Removes the prior bitmap from the container
		 */
		private function removeLast():void
		{		
			if(container.numChildren > 2){
				container.removeChildAt(0);
			}
			
			imageIndex++;
			if (imageIndex >= images.length) {
				imageIndex = 0;
			}
			
			loadNextImage();
		}
	}
	
}