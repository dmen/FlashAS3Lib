package com.gmrmarketing.humana.rrbighead
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
		
		private var myContainer:DisplayObjectContainer;
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
		private var tim:TimeoutHelper;
		
		private var shutter:Sound;
		private var countBeep:Sound;
		
		
		public function TakePhoto():void
		{
			clip = new mcTakePhoto();			
			
			vid = new Video(1405, 800);//800 was 791
			cam = Camera.getCamera();
			cam.setQuality(0, 90);//bandwidth, quality
			cam.setMode(1405, 800, 24, false);//width, height, fps, favorArea
			displayData = new BitmapData(1405, 800);
			displayBMP = new Bitmap(displayData, "auto", true);
			displayMatrix = new Matrix( -1, 0, 0, 1, 1405, 0);	//for mirroring camera
			vid.attachCamera(cam);
			
			displayBMP.x = -20;
			displayBMP.y = 239;
			clip.addChildAt(displayBMP, 0);//behind the BG graphic
			
			camTimer = new Timer(1000 / 24);			
			
			tim = TimeoutHelper.getInstance();
			
			shutter = new sndCam();
			countBeep = new sndBeep();			
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
			
			clip.alpha = 0;			
			clip.counter.alpha = .2;
			clip.counter.theText.text = "3";
			
			clip.whiteFlash.visible = false;
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, startCountdown, false, 0, true);
			
			//vid.attachCamera(cam);
			
			camTimer.addEventListener(TimerEvent.TIMER, camUpdate, false, 0, true);
			camTimer.start(); //start calling camUpdate
			
			tim.buttonClicked();//reset timeout
			
			TweenMax.to(clip, 1, { alpha:1, delay:.25, onComplete:showing } );
			//TweenMax.from(clip.theText, 1, { alpha:0, x:"100", delay:.5 } );
		}
		
		
		//called at 24fps
		private function camUpdate(e:TimerEvent):void
		{
			displayData.draw(vid, displayMatrix, null, null, null, true);			
		}
		
		
		public function hide():void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, startCountdown);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			
			
			camTimer.removeEventListener(TimerEvent.TIMER, camUpdate);
			camTimer.stop();
		}
		
		public function killCam():void
		{
			//vid.attachCamera(null);
		}
		/**
		 * 1405 x 800 bmd
		 * @return
		 */
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
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, startCountdown);
			TweenMax.to(clip.counter, .5, { alpha:1 } );
			curCount = 3;
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, updateCount, false, 0, true);
			timer.start();
		}
		
		
		private function updateCount(e:TimerEvent):void
		{
			curCount--;
			clip.counter.theText.text = String(curCount);			
			
			if (curCount == 0) {
				timer.stop();
				shutter.play();
				clip.whiteFlash.visible = true;
				clip.whiteFlash.alpha = 1;
				camTimer.reset();//stops calling campUpdate() and updating display
				TweenMax.to(clip.whiteFlash, 1, { alpha:0, onComplete:picTaken } );
			}else {
				countBeep.play();
			}
		}
		
		
		private function picTaken():void
		{
			dispatchEvent(new Event(PIC_TAKEN));
		}
	}
	
}