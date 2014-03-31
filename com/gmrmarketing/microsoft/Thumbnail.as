package com.gmrmarketing.microsoft
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.utils.ByteArray;
	
	
	public class Thumbnail extends MovieClip
	{
		private var loader:Loader;
		private var myData:BitmapData;
		private var myBMP:Bitmap;
		
		private var fullSizeData:BitmapData;		
		
		
		public function Thumbnail()
		{
			fullSizeData = new BitmapData(600, 400);
			
			myData = new BitmapData(pic.width, pic.height);
			myBMP = new Bitmap(myData, "auto", true);
			addChild(myBMP);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
		}
		
		public function loadImage(im:String):void
		{
			loader.load(new URLRequest(im));			
		}
		
		
		public function getBitmapData():BitmapData
		{
			return fullSizeData;
		}
		
		
		public function getByteArray():ByteArray
		{
			return fullSizeData.getPixels(new Rectangle(0, 0, fullSizeData.width, fullSizeData.height));
		}
		
		
		private function imageLoaded(e:Event):void
		{			
			var bmp:Bitmap = Bitmap(loader.content); //full size image
			
			var xs:Number = pic.width / bmp.width;
			var ys:Number = pic.height / bmp.height;
			
			var m:Matrix = new Matrix();
			m.scale(xs, ys);
			
			myData.draw(bmp, m);
			
			xs = fullSizeData.width / bmp.width;
			ys = fullSizeData.height / bmp.height;
			m = new Matrix();
			m.scale(xs, ys);
			fullSizeData.draw(bmp, m);
		}		
		
	}
	
}