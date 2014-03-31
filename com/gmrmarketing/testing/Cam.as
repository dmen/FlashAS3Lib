package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.media.Video;
	import flash.media.Camera;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.events.*;
	import flash.geom.Point;
	import flash.filters.ColorMatrixFilter;

	
	
	public class Cam extends MovieClip
	{
		private var theVideo:Video;
		private var cam:Camera;
		
		private var blank:BitmapData; //initial image with no subject
		private var diff:BitmapData;
		private var diffBMP:Bitmap;
		private var alph:BitmapData;
		private var res:BitmapData; //result image
		private var vid:BitmapData;
		
		private var perlinData:BitmapData;
		private var perlin:Bitmap;
		private var offsets:Array;
		
		private var colMatrix:Array;
		private var colFilter:ColorMatrixFilter;
				
		private var capture:btnCapture;
		
		
		public function Cam()
		{			
			offsets = new Array(new Point(0, 0), new Point(10, 10));
			
			blank = new BitmapData(800, 600);
			diff = new BitmapData(800, 600);
			alph = new BitmapData(800, 600);
			res = new BitmapData(800, 600);
			vid = new BitmapData(800, 600);
			
			perlinData = new BitmapData(800, 600);
			perlin = new Bitmap(perlinData);
			
			diffBMP = new Bitmap(res);
			
			colMatrix = new Array(1,0,0,0,-100,0,1,0,0,-100,0,0,1,0,-100,0,0,0,1,0);
			colFilter = new ColorMatrixFilter(colMatrix);
			
			capture = new btnCapture();
			
			cam = Camera.getCamera();
			//cam.addEventListener(ActivityEvent.ACTIVITY, activityHandler);

			if (cam) {
				connectCamera();
			}
		}
		
		
		private function connectCamera():void
		{
			cam.setMode(800, 600, 30);
			
			theVideo = new Video(cam.width, cam.height);
            theVideo.attachCamera(cam);			
			addChild(theVideo);
			
			addChild(capture);
			capture.x = 27;
			capture.y = 568;
			capture.addEventListener(MouseEvent.CLICK, captureBlank, false, 0, true);
		}
		
		
		private function activityHandler(e:ActivityEvent):void {
            trace("cam activity: ", e);
        }
		
		
		
		private function captureBlank(e:MouseEvent):void
		{		
			blank.draw(theVideo);
			removeChild(theVideo);
			removeChild(capture);
			addChild(perlin);
			addChild(diffBMP);			
			addEventListener(Event.ENTER_FRAME, showDifference);
		}
		
		
		
		private function showDifference(e:Event):void
		{			
			diff.draw(blank); //draw in original empty image of background
			
			//diff.draw(theVideo, null, null, BlendMode.DIFFERENCE); //draw in current video over it			
			
			
			res.draw(theVideo);
			//change brightness and contrast of the difference image
			var a:Bitmap = new Bitmap(diff);			
			a.filters = [colFilter];
			//res.draw(a);
			//alph.draw(a);
			
			//res.fillRect(res.rect, 0x00000000);
			//res.threshold(a.bitmapData, a.bitmapData.rect, new Point(0, 0), "!=", 0xFF000000, 0xFFFF0000, 0xFFFFFFFF, false);
			//res.threshold(alph, alph.rect, new Point(0, 0), ">", 0xFF000000, 0xFFFF0000, 0xFFFFFFFF, false);
			
			
			
			/*
			vid.draw(theVideo);
			res.copyPixels(vid, vid.rect, new Point(), alph, new Point());
			*/
			//updatePerlin();
		}
		
		private function updatePerlin():void
		{
			perlinData.perlinNoise(400, 300, 3, 5, false, true, BitmapDataChannel.GREEN, false, offsets);
			offsets[0].x += 3;
			offsets[0].y += 3;
			offsets[1].x += 3;
			offsets[1].y -= 3;
		}

	}
	
}