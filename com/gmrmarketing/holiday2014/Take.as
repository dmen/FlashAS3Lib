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
		
		
		public function Take():void
		{			
			clip = new mcTake();
			
			displayData = new BitmapData(1442, 811);			
			display = new Bitmap(displayData, "auto", true);			
			display.x = 229;//camMask at 544
			display.y = 87;	
			
			camScaler = new Matrix(-1, 0, 0, 1, 1442, 0);//mirror cam
			//camScaler.scale(.751, .751); //scales to 1920x1080 to 1442x811
			
			camTimer = new Timer(1000 / 24); //24 fps cam update
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate);
			
			cam = Camera.getCamera();
			cam.setMode(1442, 811, 24);	
			
			theVideo = new Video(1442, 811);
			theVideo.attachCamera(cam);
			
			useBW = false;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			clip.x = 1920;
			TweenMax.to(clip, .5, { x: 0, delay:.5, ease:Back.easeOut, ease:Linear.easeNone } );
			
			clip.addChild(display);
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
		 * returns the current camera image
		 * @return
		 */
		public function getPic():BitmapData
		{
			var b:BitmapData = new BitmapData(811, 811);
			b.copyPixels(displayData, new Rectangle(clip.camMask.x - display.x, 0, 811, 811), new Point(0, 0));
			return b;
		}
		
		
		private function kill():void
		{			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			clip.outline.x = 63;//reset to color side
			clip.btnPic1.removeEventListener(MouseEvent.MOUSE_DOWN, picColor);
			clip.btnPic2.removeEventListener(MouseEvent.MOUSE_DOWN, picBW);
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);
		}
		
		
		private function picColor(e:MouseEvent):void
		{
			TweenMax.to(clip.outline, .5, { x:63, ease:Back.easeOut } );
			useBW = false;
		}
		
		
		private function picBW(e:MouseEvent):void
		{
			TweenMax.to(clip.outline, .5, { x:265, ease:Back.easeOut } );
			useBW = true;			
		}
		
		
		private function takePic(e:MouseEvent):void
		{
			dispatchEvent(new Event(TAKE));
		}
		
		
		private function camUpdate(e:TimerEvent):void
		{			
			displayData.draw(theVideo, camScaler, null, null, null, true);
			
			if (useBW) {
				displayData.applyFilter(displayData, displayData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
			}
		}		
		
	}
	
}