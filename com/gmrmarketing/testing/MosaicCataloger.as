package com.gmrmarketing.testing
{	
	import flash.display.Loader;	
	import flash.display.Sprite;	
	import flash.display.Stage;
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.utils.getTimer;
	import fl.controls.TextArea;
	
	
	
	public class MosaicCataloger extends EventDispatcher
	{
		
		private var images:Array;
		private var xmlLoader:URLLoader;
		private var imageLoader:Loader;
		private var xml:String;
		private var infoArea:TextArea;
		private var curY:int;
		private var container:Stage;
		
		private const SQUARE:int = 110;
		
		
		public function MosaicCataloger($container:Stage, $infoArea:TextArea) 
		{ 
			container = $container;
			infoArea = $infoArea;
		}
		
		
		public function getImageList(xmlURL:URLRequest):void
		{
			images = new Array();
			curY = 0;
			xmlLoader = new URLLoader();
			imageLoader = new Loader();
			xml = "<catalog>\n";
			
			xmlLoader.addEventListener(Event.COMPLETE, imagesXMLLoaded);
			xmlLoader.load(xmlURL);	
		}
		
		
		private function imagesXMLLoaded(e:Event):void
		{
			var theImages:XMLList = new XML(e.target.data).image;
			
			for (var i:int = 0; i < theImages.length(); i++) {
				images.push(theImages[i].toString());
			}
			loadImage();		
		}
		
		
		private function loadImage():void
		{
			if (images.length > 0) {
				
				var im = images.splice(0, 1)[0];
				infoArea.appendText("loading:" + im + "\n" );
				xml += "\t<image>\n\t\t<filename>" + im + "</filename>\n";
				imageLoader.load(new URLRequest(im));
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, processImage, false, 0, true);
				imageLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progress, false, 0, true);
				
			}else {
				
				//done
				xml += "</catalog>";				
				trace(xml);
			}
		}
		
		
		private function progress(e:ProgressEvent):void
		{
			var percentDownloaded = e.bytesLoaded / e.bytesTotal * 100;
		}
		
		
		private function processImage(e:Event):void
		{
			
			var t:Number = getTimer();
			var bit:Bitmap = e.target.content;
			infoArea.appendText("loaded - " + bit.width + " x " + bit.height + "\n");
			infoArea.appendText("processing\n");
			var m:Matrix = new Matrix();
			m.scale(SQUARE / bit.width, SQUARE / bit.height);
			var j:BitmapData = new BitmapData(SQUARE, SQUARE, false, 0x9999BB);
			
			j.draw(bit, m);
			var b:Bitmap = new Bitmap(j);
			container.addChild(b);
			b.x = 145;
			b.y = 66;
			
			var av:uint = averageRGB(bit.bitmapData);
			var avg:String = av.toString(16);
			var c:BitmapData = new BitmapData(SQUARE, SQUARE, false, av);
			var d:Bitmap = new Bitmap(c);
			container.addChild(d);
			d.x = 286;
			d.y = 66;
			
			infoArea.appendText("average: " + avg + "\n");
			infoArea.appendText("time: " + (getTimer() - t) + " ms\n\n");
			infoArea.verticalScrollPosition = infoArea.textHeight;
			
			xml += "\t\t<color>" + avg + "</color>\n\t</image>\n"
			
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, processImage);
			imageLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			
			loadImage();
		}
		
		
		/**
		 * Called from process image
		 * 
		 * @param	source BitmapData of the loaded image
		 * @return uint - the average color of the image
		 */
		private function averageRGB( source:BitmapData ):uint
		{
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
		 
			var count:Number = 0;
			var pixel:Number;
		 
			for (var x:int = 0; x < source.width; x++)
			{
				for (var y:int = 0; y < source.height; y++)
				{
					pixel = source.getPixel(x, y);
		 
					red += pixel >> 16 & 0xFF;
					green += pixel >> 8 & 0xFF;
					blue += pixel & 0xFF;
		 
					count++
				}
			}
		 
			red /= count;
			green /= count;
			blue /= count;
			
			infoArea.appendText("analyzed: " + count + " pixels\n");
			
			return red << 16 | green << 8 | blue;
		}
			
	}
	
}