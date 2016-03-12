
package com.gmrmarketing.comcast.nascar.broadcaster
{
	import com.adobe.air.logging.FileTarget;
	import com.gmrmarketing.utilities.queue.*;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.filesystem.File;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
		
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		
		private var intro:Intro;
		private var select:Select;
		private var capture:Capture;
		private var review:Review;
		private var thanks:Thanks;
		
		private var queue:Queue;
		
		private var cq:CornerQuit;		
		private var tim:TimeoutHelper;
		
		
		public function Main()
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			Mouse.hide();

			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			select = new Select();
			select.container = mainContainer;
			
			capture = new Capture();
			capture.container = mainContainer;
			
			review = new Review();
			review.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			queue = new Queue();
			queue.fileName = "comcastNascar2016";
			queue.service = new WebService();
			queue.start();
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			tim.init(120000);			
			
			init();
		}
		
		
		private function init():void
		{
			tim.stopMonitoring();
			
			intro.addEventListener(Intro.COMPLETE, showInstructions);
			intro.show();
		}
		
		
		private function showInstructions(e:Event):void
		{
			tim.startMonitoring();
			
			intro.removeEventListener(Intro.COMPLETE, showInstructions);
			intro.hide();
			
			select.addEventListener(Select.COMPLETE, showCapture, false, 0, true);
			select.addEventListener(Select.QUIT, reset, false, 0, true);
			select.show();
		}
		
		
		private function showCapture(e:Event = null):void
		{
			select.removeEventListener(Select.COMPLETE, showCapture);
			select.removeEventListener(Select.QUIT, reset);
			select.hide();
			
			capture.addEventListener(Capture.COMPLETE, showReview, false, 0, true);
			capture.show(select.selection);//1,2,3
		}
		
		
		private function showReview(e:Event):void
		{
			capture.removeEventListener(Capture.COMPLETE, showReview);
			capture.hide();
			
			review.addEventListener(Review.COMPLETE, saveVideo, false, 0, true);
			review.addEventListener(Review.RETAKE, retakeVideo, false, 0, true);
			review.addEventListener(Review.CANCEL, reset, false, 0, true);
			review.show(capture.fileName);//GUID+RFID
		}
		
		
		private function saveVideo(e:Event):void
		{	
			var o:Object = { };
			o.rfid = intro.RFID;			
			o.video = capture.fileName;//GUID + RFID
			o.pubRelease = review.pubRelease; //boolean
			queue.add(o);
			
			review.removeEventListener(Review.COMPLETE, saveVideo);
			review.removeEventListener(Review.RETAKE, retakeVideo);
			review.removeEventListener(Review.CANCEL, reset);
			review.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, reset, false, 0, true);
			thanks.show();
		}
		
		
		private function retakeVideo(e:Event):void
		{
			review.removeEventListener(Review.COMPLETE, saveVideo);
			review.removeEventListener(Review.RETAKE, retakeVideo);
			review.removeEventListener(Review.CANCEL, reset);
			review.hide();
			
			showCapture();
		}
		
		
		private function reset(e:Event):void
		{	
			select.removeEventListener(Select.COMPLETE, showCapture);
			select.hide();
			
			capture.removeEventListener(Capture.COMPLETE, showReview);
			capture.hide();
			
			review.removeEventListener(Review.COMPLETE, saveVideo);
			review.removeEventListener(Review.RETAKE, retakeVideo);
			review.removeEventListener(Review.CANCEL, reset);
			review.hide();
			
			thanks.removeEventListener(Thanks.COMPLETE, reset);
			thanks.hide();
			
			init();
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}