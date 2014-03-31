package com.gmrmarketing.nokia.transparentphone
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.File;
	import flash.display.Loader;
	import flash.net.*;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	public class Photos extends Sprite
	{
		private var folder:File;
		private var files:Array;
		private var index:int;		
		private var bg:Shape;
		private var images:Array;//containes references to the last two images on screen
		private var par:DisplayObjectContainer;
		
		public function Photos()
		{
			bg = new Shape();
			bg.graphics.beginFill(0x0FFFFFF, 1);
			bg.graphics.drawRect(0, 0, 1080, 1920);
			bg.graphics.endFill();
			
			images = new Array();
			
			folder = File.desktopDirectory.resolvePath("nokia_images");
		}
		
		/**
		 * Returns true if the folder exists and there's at least one file in it
		 * @return
		 */
		public function exists():Boolean
		{			
			files = new Array();
			if (folder.exists) {
				try{
					files = folder.getDirectoryListing();				
				}catch (e:Error) {
					
				}		
			}			
			return files.length == 0 ? false : true;
		}
		
		
		/**
		 * Only called if exists returns true
		 */
		public function show():void
		{
			par = this.parent;
			index = 0;
			addChild(bg);			
			loadNext();			
		}
		
		public function hide():void
		{
			par.removeChild(this);
		}
		public function unHide():void
		{
			par.addChild(this);
		}
		
		
		private function loadNext(e:TimerEvent = null):void
		{			
			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(files[index].url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			loader.load(req);
		}
		
		
		private function imageLoaded(e:Event):void
		{
			var bmp:Bitmap = e.target.content as Bitmap;
			bmp.smoothing = true;
			var myImage:BitmapData = bmp.bitmapData;
			if (myImage.width > 1080 || myImage.height > 1920) {
				
				var ratio:Number = Math.min(1080 / myImage.width, 1920 / myImage.height);
				bmp.width *= ratio;
				bmp.height *= ratio;
			}
			
			var toX:int = Math.floor((1080 - bmp.width) * .5);
			bmp.x = toX;
			bmp.y = Math.floor((1920 - bmp.height) * .5);
				
			//myImage.width, myImage.height
			images.push(bmp);
			
			if (images.length == 1) {
				//first image added
				bmp.alpha = 0;
				addChild(bmp);
				TweenMax.to(bmp, 2, { alpha:1, onComplete:waitForNext } );
			}else {
				//second image - first one already showing
				bmp.x = 1100;
				addChild(bmp);
				TweenMax.to(images[0], 2, { x: -1080, onComplete:removeImage } );
				TweenMax.to(images[1], 2, { x:toX, onComplete:waitForNext } );
			}			
			
			index++;
			if (index >= files.length) {
				index = 0;
			}
		}
		
		private function removeImage():void
		{
			var a:Bitmap = images.shift(); //remove first image
			removeChild(a);
		}
		
		private function waitForNext():void
		{
			var a:Timer = new Timer(3000, 1);
			a.addEventListener(TimerEvent.TIMER, loadNext, false, 0, true);
			a.start();
		}
	}
	
}