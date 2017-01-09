package com.gmrmarketing.testing
{	
	import flash.display.*;	
	import flash.geom.Rectangle;
	import flash.media.Camera;	
	import flash.media.Video;
	import flash.events.*;
	import net.hires.debug.Stats;
	import com.rainbowcreatures.*; 
	
	public class IRTest extends MovieClip
	{
		private var cam:Camera;
		private var theVideo:Video;
		private const maxBlobs:int = 1;
		private var blobs:Array;
		private const FLOOD_FILL_COLOR:Number = 0xFF0000;
		private const PROCESSED_COLOR:Number = 0x00FF00;
		private const minWidth:int = 5;
		private const minHeight:int = 5;
		private const maxWidth:int = 25;
		private const maxHeight:int = 25;
		private var r:BitmapData;
		
		private var overlay:Sprite;
		private var encoder:FWVideoEncoder;
		
		
		public function IRTest()
		{			
			cam = Camera.getCamera();
			cam.setMode(320, 213, 30);
			
			theVideo = new Video(320, 213);
			theVideo.attachCamera(cam);
			
			r = new BitmapData(320, 213, false, 0);
			
			addChild(theVideo);	
			
			overlay = new Sprite();
			addChild(overlay);
			addChild(new Stats());
			
			encoder = FWVideoEncoder.getInstance(); 
			
			cam.addEventListener(Event.VIDEO_FRAME, findBlobs);
		}
		
		
		
		public function findBlobs(e:Event):void
		{
			//var i:int = 0;
			var mainRect:Rectangle;
			blobs = [];
			var blobRect:Rectangle;
			
			cam.drawToBitmapData(r);
			
			//while (i < maxBlobs)
			//{
				// get the rectangle containing only white pixels
				mainRect = r.getColorBoundsRect(0xffffffff, 0xffffffff);

				// exit if the rectangle is empty
				if (mainRect.isEmpty()) return;// break;

				// get the first column of the rectangle
				var x:int = mainRect.x;

				// examine pixel by pixel unless you find the first white pixel
				for (var y:uint = mainRect.y; y < mainRect.y + mainRect.height; y++)
				{
					if (r.getPixel32(x, y) == 0xffffffff)
					{
						// fill it with some color
						r.floodFill(x, y, FLOOD_FILL_COLOR);

						// get the bounds of the filled area - this is the blob
						blobRect = r.getColorBoundsRect(0xffffffff, FLOOD_FILL_COLOR);

						// check if it meets the min and max width and height
						if (blobRect.width > minWidth && blobRect.width < maxWidth && blobRect.height > minHeight && blobRect.height < maxHeight)
						{
							// if so, add the blob rectangle to the array
							//var blob:Object = {};
							//blob.rect = blobRect;
							//blobs.push(blob);
							
							overlay.graphics.clear();
							overlay.graphics.lineStyle(1, 0x00ff00);
							overlay.graphics.drawRect(blobRect.x, blobRect.y, blobRect.width, blobRect.height);
						}

						// mark blob as processed with some other color
						r.floodFill(x, y, PROCESSED_COLOR);
					}
				}

				// increase number of detected blobs
				//i++;
			//}
			/*
			if(blobs.length){
				overlay.graphics.clear();
				overlay.graphics.lineStyle(1, 0x00ff00);
				overlay.graphics.drawRect(blobs[0].rect.x, blobs[0].rect.y, blobs[0].rect.width, blobs[0].rect.height);
			}
			*/
		}
		
		
	}
	
}