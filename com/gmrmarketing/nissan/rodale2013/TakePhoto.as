package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CamPic;	
	import flash.geom.Matrix;
	import flash.media.Video;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.media.Sound;
	import flash.media.Camera;	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const TAKE_SHOWING:String = "takeShowing";
		public static const PIC_TAKEN:String = "picTaken";
		
		private var container:DisplayObjectContainer;
		private var clip:MovieClip;
		private var timer:Timer;
		private var curCount:int;
		
		private var cam:Camera;
		private var vid:Video;
		private var camTimer:Timer;
		private var displayMatrix:Matrix;
		private var displayData:BitmapData;
		private var displayBMP:Bitmap;
		
		private var thePic:BitmapData;
		private var btnTake:Button;
		private var tim:TimeoutHelper;
		
		private var shutter:Sound;
		private var countBeep:Sound;
		
		
		public function TakePhoto():void
		{
			clip = new mcTakePhoto();			
			
			vid = new Video(1405, 791);
			cam = Camera.getCamera();
			cam.setQuality(0, 90);//bandwidth, quality
			cam.setMode(1405, 791, 24, false);//width, height, fps, favorArea
			displayData = new BitmapData(1405, 791);
			displayBMP = new Bitmap(displayData, "auto", true);
			displayMatrix = new Matrix( -1, 0, 0, 1, 1405, 0);	
			
			displayBMP.x = -58;
			displayBMP.y = 188;
			clip.addChildAt(displayBMP, 1);
			
			camTimer = new Timer(1000 / 24);
			
			btnTake = new Button(clip, "red", "Take Photo", 1400, 614);	
			tim = TimeoutHelper.getInstance();
			
			shutter = new sndCam();
			countBeep = new sndBeep();			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.alpha = 0;
			clip.countdown.pulse.scaleX = clip.countdown.pulse.scaleY = 0;
			clip.countdown.pulse.alpha = 1;
			clip.countdown.alpha = .2;
			clip.countdown.theText.text = "3";
			
			btnTake.addEventListener(Button.PRESSED, startCountdown, false, 0, true);
			
			vid.attachCamera(cam);
			
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate, false, 0, true);
			camTimer.start(); //start calling camUpdate
			
			tim.buttonClicked();//reset timeout
			
			TweenMax.to(clip, 1, { alpha:1, delay:.25, onComplete:showing } );
			TweenMax.from(clip.theText, 1, { alpha:0, x:"100", delay:.5 } );
		}
		
		private function camUpdate(e:TimerEvent):void
		{
			displayData.draw(vid, displayMatrix, null, null, null, true);			
		}
		
		public function hide():void
		{
			btnTake.removeEventListener(Button.PRESSED, startCountdown);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			
			vid.attachCamera(null);
			camTimer.removeEventListener(TimerEvent.TIMER, camUpdate);
			camTimer.reset();
		}
		
		
		public function getPic():BitmapData
		{
			return displayData;
		}
		
		
		private function showing():void
		{			
			dispatchEvent(new Event(TAKE_SHOWING));
		}
		
		
		private function startCountdown(e:Event):void
		{
			countBeep.play();
			tim.buttonClicked();
			btnTake.removeEventListener(Button.PRESSED, startCountdown);
			TweenMax.to(clip.countdown.pulse, .5, { scaleX:1, scaleY:1, alpha:0} );
			TweenMax.to(clip.countdown, .5, { alpha:1 } );
			curCount = 3;
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, updateCount, false, 0, true);
			timer.start();
		}
		
		
		private function updateCount(e:TimerEvent):void
		{
			curCount--;
			clip.countdown.theText.text = String(curCount);
			
			if (curCount != 0) {
				countBeep.play();
				clip.countdown.pulse.scaleX = clip.countdown.pulse.scaleY = .1;
				clip.countdown.pulse.alpha = 1;
				TweenMax.to(clip.countdown.pulse, .5, { scaleX:1, scaleY:1, alpha:0 } );
			}
			
			if (curCount == 0) {
				timer.stop();
				shutter.play();
				//thePic = cam.getDisplay(false);
				TweenMax.from(clip.whiteFlash, .5, { alpha:1, onComplete:picTaken } );
			}
		}
		
		
		private function picTaken():void
		{
			dispatchEvent(new Event(PIC_TAKEN));
		}
	}
	
}