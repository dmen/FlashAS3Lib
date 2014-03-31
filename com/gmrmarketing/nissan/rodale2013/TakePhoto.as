package com.gmrmarketing.nissan.rodale2013
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CamPic;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.media.Sound;
	
	public class TakePhoto extends EventDispatcher
	{
		public static const TAKE_SHOWING:String = "takeShowing";
		public static const PIC_TAKEN:String = "picTaken";
		
		private var container:DisplayObjectContainer;
		private var clip:MovieClip;
		private var timer:Timer;
		private var curCount:int;
		private var cam:CamPic;
		private var thePic:BitmapData;
		private var btnTake:Button;
		private var tim:TimeoutHelper;
		
		private var shutter:Sound;
		private var countBeep:Sound;
		
		
		public function TakePhoto():void
		{
			clip = new mcTakePhoto();
			cam = new CamPic();
			cam.init(1405, 791, 0, 0, 1405, 791, 24, true);//1405x791 is the size of camHolder clip on stage
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
			cam.show(clip.camHolder);
			
			tim.buttonClicked();
			
			TweenMax.to(clip, 1, { alpha:1, delay:.25, onComplete:showing } );
			TweenMax.from(clip.theText, 1, { alpha:0, x:"100", delay:.5 } );
		}
		
		
		public function hide():void
		{
			btnTake.removeEventListener(Button.PRESSED, startCountdown);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			cam.dispose();
		}
		
		
		public function getPic():BitmapData
		{
			return thePic;
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
				thePic = cam.getDisplay(false);
				TweenMax.from(clip.whiteFlash, .5, { alpha:1, onComplete:picTaken } );
			}
		}
		
		
		private function picTaken():void
		{
			dispatchEvent(new Event(PIC_TAKEN));
		}
	}
	
}