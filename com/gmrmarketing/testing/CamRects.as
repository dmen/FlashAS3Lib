package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.greensock.*;
	import flash.geom.ColorTransform;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.events.*;
	import com.gmrmarketing.testing.RectFinder;
	import com.gmrmarketing.utilities.SliderV;
	
	public class CamRects extends MovieClip
	{
		private const CAM_WIDTH:int = 1920;
		private const CAM_HEIGHT:int = 1080;
		
		private var invertTransform:ColorTransform;
		private var cam:Camera;
		private var vid:Video;
		private var buffer:BitmapData;
		private var display:Bitmap;
		private var textDisplay:Bitmap;
		private var rectFinder:RectFinder;
		private var rectsShowing:Boolean;
		private var slider:SliderV;
		private var currentThreshold:int;
		
		
		public function CamRects()
		{
			rectFinder = new RectFinder();
			
			currentThreshold = 80;
			thresh.text = String(currentThreshold);
			
			slider = new SliderV(slidermc, track);
			slider.addEventListener(SliderV.DRAGGING, updateThreshold, false, 0, true);
			
			cam = Camera.getCamera();
			cam.setMode(CAM_WIDTH, CAM_HEIGHT, 24, false);
			cam.setQuality(0, 88);

			vid = new Video(CAM_WIDTH, CAM_HEIGHT);
			vid.attachCamera(cam);
			
			buffer = new BitmapData(CAM_WIDTH, CAM_HEIGHT, false, 0xffffff);
			display = new Bitmap(buffer);
			addChildAt(display,0);
			
			rectsShowing = false;
			
			btnGetRects.addEventListener(MouseEvent.CLICK, getRects, false, 0, true);
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		private function getRects(e:MouseEvent):void
		{
			if(!rectsShowing){
				var bmd:BitmapData = rectFinder.createRects(buffer);
				textDisplay = new Bitmap(bmd);
				addChildAt(textDisplay,1);
				rectsShowing = true;
			}else {
				removeChild(textDisplay);
				rectsShowing = false;
			}
		}
		
		
		private function updateThreshold(e:Event):void
		{
			currentThreshold = Math.round(slider.getPosition() * 250);
			thresh.text = String(currentThreshold);
		}
		
		
		private function update(e:Event):void
		{                              
			TweenMax.to(vid, 0, {colorMatrixFilter:{threshold:currentThreshold}});              
			buffer.draw(vid);
			//b.colorTransform(b.rect, invertTransform);     //invert the black /white
		}

	}
	
}