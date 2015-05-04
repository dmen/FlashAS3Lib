package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.esurance.sxsw_2015.photobooth.WhiteFlash;
	
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "takePhotoShowing";
		public static const TAKE_PRESSED:String = "takeButtonPressed";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		private var whiteFlash:WhiteFlash;
		private var countdown:Countdown;
		private var threePhotos:Array;
		
		
		public function TakePhoto():void
		{
			clip = new mcTakePhoto();//library
			
			cam = new CamPic();
			cam.init(1280, 800, 0, 0, 0, 0, 30);
			cam.show(clip.camPic);//black box behind bg image	- 1093x615
			
			whiteFlash = new WhiteFlash(1920, 1080);
			whiteFlash.container = clip;
			
			countdown = new Countdown();
			countdown.container = clip;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.btnCancel.x = 2100;
			clip.btnRetake.x = 2100;
			clip.btnPrint.x = 2100;
			
			clip.btnTake.scaleX = clip.btnTake.scaleY = 0;
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, updateGlow);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function showing():void
		{
			clip.addEventListener(Event.ENTER_FRAME, updateGlow);
			TweenMax.to(clip.btnTake, 1, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePressed);
			threePhotos = [];
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function updateGlow(e:Event):void
		{
			TweenMax.to(clip.xfin, 0, { glowFilter: { color:0x33ccff, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
			TweenMax.to(clip.year, 0, { glowFilter: { color:0xff9999, alpha:.2 + Math.random()*.8, blurX:5, blurY:5 } } );
		}
		
		
		private function takePressed(e:MouseEvent):void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePressed);
			countdown.addEventListener(Countdown.COUNT_COMPLETE, showFlash, false, 0, true);
			countdown.show();
		}
		
		
		private function showFlash(e:Event):void
		{			
			countdown.hide();
			whiteFlash.show();
			TweenMax.delayedCall(.2, showPhoto);
		}
		
		
		private function showPhoto():void
		{	
			threePhotos.push(cam.getDisplay());//1280x800 bitmapData
			if (threePhotos.length < 3) {
				countdown.show();
			}
		}
		
	}	
	
}