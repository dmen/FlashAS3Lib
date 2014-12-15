package com.gmrmarketing.holiday2014
{
	import flash.events.*;
	import flash.display.*;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Take extends EventDispatcher
	{
		public static const TAKE:String = "takePressed";
		public static const BWPRESED:String = "bwPressed";
		public static const COLORPRESSED:String = "colorPressed";
		private const rc:Number = .30;
		private const gc:Number = .59;
		private const bc:Number = .11;
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var cam:Camera;
		private var theVideo:Video;
		private var displayData:BitmapData;
		private var display:Bitmap;
		private var camTimer:Timer;
		private var camScaler:Matrix;
		private var useBW:Boolean;
		
		private var theHeff:BitmapData;
		private var heffShowing:Boolean;
		
		public function Take():void
		{			
			clip = new mcTake();
			
			displayData = new BitmapData(1442, 811);			
			display = new Bitmap(displayData, "auto", true);			
			display.x = 249;//camMask at 565,87
			display.y = 86;	
			
			camScaler = new Matrix(-1, 0, 0, 1, 1442, 0);//mirror cam
			//camScaler.scale(.751, .751); //scales to 1920x1080 to 1442x811
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1442, 811, 24);	
			
			theVideo = new Video(1442, 811);
			theVideo.attachCamera(cam);
			
			theHeff = new heffBMD();					
			heffShowing = false;
			
			useBW = false;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function heff():void
		{
			heffShowing = !heffShowing;			
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			heffShowing = false;
			
			clip.x = 1920;
			TweenMax.to(clip, .5, { x: 0, delay:.5, ease:Back.easeOut, ease:Linear.easeNone } );
			
			clip.addChildAt(display,0);
			display.mask = clip.camMask;
			display.alpha = 0;
			TweenMax.to(display, .5, { alpha:1, delay:1 } );
			camTimer.start();//call camUpdate()
			
			clip.btnPic1.addEventListener(MouseEvent.MOUSE_DOWN, picColor, false, 0, true);
			clip.btnPic2.addEventListener(MouseEvent.MOUSE_DOWN, picBW, false, 0, true);
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { x: -1920, ease:Back.easeIn, onComplete:kill } );
		}
		
		
		/**
		 * returns the current color and black and white camera image
		 * Both are 811x811
		 * @return
		 */
		public function getPic():Array
		{
			displayData.lock();
			//color
			displayData.draw(theVideo, camScaler, null, null, null, true);
			
			if (heffShowing) {
				displayData.copyPixels(theHeff, new Rectangle(0, 0, 617, 716), new Point(520, 113), null, null, true);
			}
			
			var colorImage:BitmapData = new BitmapData(811, 811);
			var bwImage:BitmapData = new BitmapData(811, 811);
			
			colorImage.copyPixels(displayData, new Rectangle(clip.camMask.x - display.x, 0, 811, 811), new Point(0, 0));
			
			//bw image
			displayData.applyFilter(displayData, displayData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));			
			
			
			bwImage.copyPixels(displayData, new Rectangle(clip.camMask.x - display.x, 0, 811, 811), new Point(0, 0));
			
			displayData.unlock();
			
			return new Array(colorImage, bwImage);
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			clip.outline.x = 84;//reset to color side
			clip.btnPic1.removeEventListener(MouseEvent.MOUSE_DOWN, picColor);
			clip.btnPic2.removeEventListener(MouseEvent.MOUSE_DOWN, picBW);
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);
		}
		
		
		public function picColor(e:MouseEvent = null):void
		{
			TweenMax.to(clip.outline, .5, { x:84, ease:Back.easeOut } );
			useBW = false;			
			dispatchEvent(new Event(COLORPRESSED));			
		}
		
		public function isColor():Boolean
		{
			return !useBW;
		}
		
		public function picBW(e:MouseEvent = null):void
		{
			TweenMax.to(clip.outline, .5, { x:285, ease:Back.easeOut } );
			useBW = true;
			dispatchEvent(new Event(BWPRESED));
		}
		
		
		private function takePic(e:MouseEvent):void
		{
			dispatchEvent(new Event(TAKE));
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{			
			displayData.draw(theVideo, camScaler, null, null, null, true);				
			
			if (heffShowing) {
				displayData.copyPixels(theHeff, new Rectangle(0, 0, 617, 716), new Point(520, 113), null, null, true);
			}
			
			if (useBW) {
				displayData.applyFilter(displayData, displayData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
			}
		}		
		
	}
	
}