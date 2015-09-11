package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import flash.filesystem.File;
	import com.gmrmarketing.utilities.GUID;	
	import com.gmrmarketing.utilities.Utility;
	
	
	public class Main extends MovieClip
	{
		private var vb:VideoBackground;
		private var intro:Intro;
		private var instructions:Instructions;
		private var capture:Capture;
		private var review:Review;
		private var email:Email;
		private var thanks:Thanks;
		private var queue:Queue;
		
		private var vidContainer:Sprite;
		private var mainContainer:Sprite;
		private var aGUID:String;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();

			vidContainer = new Sprite();
			mainContainer = new Sprite();
			
			addChild(vidContainer);
			addChild(mainContainer);
			
			vb = new VideoBackground(vidContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			instructions = new Instructions();
			instructions.container = mainContainer;
			
			capture = new Capture();
			capture.container = mainContainer;
			
			review = new Review();
			review.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			queue = new Queue();
			
			init();
		}
		
		
		private function init(e:Event = null):void
		{
			instructions.removeEventListener(Instructions.CANCEL, init);
			instructions.hide();
			
			capture.removeEventListener(Capture.CANCEL, init);
			capture.hide();
			
			intro.addEventListener(Intro.BEGIN, showInstructions, false, 0, true);
			intro.show();
		}
		
		
		private function showInstructions(e:Event):void
		{
			intro.removeEventListener(Intro.BEGIN, showInstructions);
			intro.hide();
			//thanks.show();
			instructions.addEventListener(Instructions.COMPLETE, showCapture, false, 0, true);
			instructions.addEventListener(Instructions.CANCEL, init, false, 0, true);
			instructions.show();
		}
		
		
		private function showCapture(e:Event = null):void
		{
			instructions.removeEventListener(Instructions.CANCEL, init);
			instructions.removeEventListener(Instructions.COMPLETE, showCapture);
			instructions.hide();
			
			capture.addEventListener(Capture.COMPLETE, captureComplete, false, 0, true);
			capture.addEventListener(Capture.CANCEL, init, false, 0, true);
			capture.show();
		}
		
		
		private function captureComplete(e:Event=null):void
		{
			capture.hide();
			capture.removeEventListener(Capture.COMPLETE, captureComplete);
			capture.removeEventListener(Capture.CANCEL, init);
			
			review.show();
			review.addEventListener(Review.CANCELED, reRecord, false, 0, true);
			review.addEventListener(Review.OKED, videoGood, false, 0, true);
		}
		
		
		private function reRecord(e:Event):void
		{
			review.hide();
			review.removeEventListener(Review.CANCELED, reRecord);
			review.removeEventListener(Review.OKED, videoGood);
			showCapture();
		}
		
		
		private function videoGood(e:Event):void
		{
			review.hide();
			review.removeEventListener(Review.CANCELED, reRecord);
			review.removeEventListener(Review.OKED, videoGood);
			
			email.show();
			email.addEventListener(Email.BACK, emailBack, false, 0, true);
			email.addEventListener(Email.COMPLETE, showThanks, false, 0, true);
		}
		private function emailBack(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, showThanks);
			email.removeEventListener(Email.BACK, emailBack);
			email.hide();
			
			captureComplete();
		}
		
		
		/**
		 * called when user enters a valid email
		 * Good to add video and email to the queue
		 * 
		 * @param	e
		 */
		private function showThanks(e:Event):void
		{
			email.hide(); 
			email.removeEventListener(Email.COMPLETE, showThanks);
			email.removeEventListener(Email.BACK, emailBack);
			
			thanks.show();
			
			aGUID = GUID.create();
			capture.addEventListener(Capture.VID_READY, videoDoneProcessing);
			capture.stitchVideo(aGUID);
		}
		
		
		/**
		 * called once video has been processed by stitcher (ffmpeg)
		 * @param	e
		 */
		private function videoDoneProcessing(e:Event):void
		{		
			capture.removeEventListener(Capture.VID_READY, videoDoneProcessing);
			
			queue.add( { video:File.applicationStorageDirectory.nativePath + "\\" + capture.fileName, email:email.email, guid:aGUID, timestamp:Utility.hubbleTimeStamp() } );
			
			thanks.hide();
			intro.addEventListener(Intro.BEGIN, showInstructions, false, 0, true);
			intro.show();			
		}		
		
	}
	
}