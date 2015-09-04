package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip
	{
		private var vb:VideoBackground;
		private var intro:Intro;
		private var instructions:Instructions;
		private var capture:Capture;
		private var review:Review;
		private var email:Email;
		private var thanks:Thanks;
		
		private var vidContainer:Sprite;
		private var mainContainer:Sprite;
		
		
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
			//email.show();/*
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
		
		private function showThanks(e:Event):void
		{
			email.hide(); 
			email.removeEventListener(Email.COMPLETE, showThanks);
			email.removeEventListener(Email.BACK, emailBack);
			
			thanks.show();
			thanks.addEventListener(Thanks.COMPLETE, doReset, false, 0, true);
		}
		
		
		private function doReset(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, doReset);
			thanks.hide();
			intro.addEventListener(Intro.BEGIN, showInstructions, false, 0, true);
			intro.show();
		}
		
	}
	
}