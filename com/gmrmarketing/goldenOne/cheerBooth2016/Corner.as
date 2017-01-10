package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.Utility;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.*;
	
	
	public class Corner extends EventDispatcher
	{
		public static const SCREENTOUCHED:String = "screenClicked";//anywhere on the screen clicked
		public static const CORNERCLICKED:String = "cornerButtonClicked";//base button at bottom right
		public static const CANCELCLICKED:String = "cancelButtonClicked";//record again, etc		
		public static const COUNTERELAPSED:String = "countdownExpired";
		public static const VIDEOREPLAY:String = "btnVideoPressed";		
		
		private var clip:MovieClip;
		private var drawing:Sprite;//for drawing the arc into
		private var myContainer:DisplayObjectContainer;		
		
		private var timeRemaining:int;
		private var anglePerMS:Number;		
		private var currentTimer:Number;
		
		
		public function Corner()
		{
			clip = new mcCorner();
			drawing = new Sprite();
			drawing.mouseEnabled = false;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}			
		}
		
		
		public function showTouchToStart():void
		{
			//reset
			if(clip.theCircle.cornerButton){
				clip.theCircle.cornerButton.removeEventListener(MouseEvent.MOUSE_DOWN, cornerClicked);
			}
			if (myContainer.contains(drawing)){
				drawing.graphics.clear();
				myContainer.removeChild(drawing);
			}
			if(clip.theCircle.btnRecordAgain){
				clip.theCircle.btnRecordAgain.removeEventListener(MouseEvent.MOUSE_DOWN, cancelSave);
			}
			if(clip.theCircle.btnCancel){
				clip.theCircle.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			}
			
			
			clip.theCircle.gotoAndStop(1);//touch screen to start			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, screenClicked, false, 0, true);
			TweenMax.to(clip.theCorner, .5, {colorTransform:{tint:0xFF0000, tintAmount:0}});			
		}
		
		
		private function screenClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(SCREENTOUCHED));
		}
		
		
		public function showInstructions(isVideo:Boolean):void
		{		
			clip.theCircle.gotoAndStop(2);
			
			if (isVideo){
				clip.theCircle.theText.text = "RECORD\nYOUR VIDEO";
			}else{
				clip.theCircle.theText.text = "TAKE\nYOUR PHOTO";
			}
			
			clip.theCircle.cornerButton.addEventListener(MouseEvent.MOUSE_DOWN, cornerClicked, false, 0, true);			
		}
		
		
		private function cornerClicked(e:MouseEvent):void
		{			
			dispatchEvent(new Event(CORNERCLICKED));
		}
		
		
		public function showStartRecord(isVideo:Boolean):void
		{
			if (!myContainer.contains(drawing)){
				myContainer.addChild(drawing);
			}
			drawing.graphics.clear();
			
			TweenMax.to(clip.theCorner, 2, {colorTransform:{tint:0xFF0000, tintAmount:.6}});	
			clip.theCircle.gotoAndStop(3);
			if (isVideo){
				clip.theCircle.theText.text = "RECORD";
			}else{
				clip.theCircle.theText.text = "GET READY";
			}
			timeRemaining = 5;
			clip.theCircle.countdown.theText.text = timeRemaining.toString();
			clip.theCircle.countdown.scaleX = clip.theCircle.countdown.scaleY = 1.5;
			TweenMax.to(clip.theCircle.countdown, 1, {scaleX:1, scaleY:1, onComplete:timeElapsed});
		}
		
		
		private function timeElapsed():void
		{			
			timeRemaining--;
			clip.theCircle.countdown.theText.text = timeRemaining.toString();			
			
			if (timeRemaining == 0){
				dispatchEvent(new Event(COUNTERELAPSED));//calls Main.startCountdownFinished
			}else{
				clip.theCircle.countdown.scaleX = clip.theCircle.countdown.scaleY = 1.5;
				TweenMax.to(clip.theCircle.countdown, 1, {scaleX:1, scaleY:1, onComplete:timeElapsed});
			}
		}
		
		
		//corner shows recording...
		public function showRecording():void
		{
			timeRemaining = 5000;//milliseconds
			anglePerMS = 360.0 / timeRemaining;
			currentTimer = getTimer();
			clip.theCircle.gotoAndStop(4);
			clip.theCircle.recTime.text = 1 + int(timeRemaining / 1000);
			clip.theCircle.cornerButton.addEventListener(MouseEvent.MOUSE_DOWN, cornerClicked, false, 0, true);	
			clip.addEventListener(Event.ENTER_FRAME, updateArc, false, 0, true);
		}
		
		
		private function updateArc(e:Event):void
		{
			var delta:Number = getTimer() - currentTimer;
			if (delta > timeRemaining){
				//delta = 15000;
				clip.theCircle.recTime.text = "0"
				Utility.drawArc(drawing.graphics, 1601, 981, 35, 0, 360, 3, 0x000000, 1);
				clip.removeEventListener(Event.ENTER_FRAME, updateArc);
				dispatchEvent(new Event(COUNTERELAPSED));
			}else{
				clip.theCircle.recTime.text = 1 + int((timeRemaining - delta) / 1000);				
				Utility.drawArc(drawing.graphics, 1601, 981, 35, 0, anglePerMS * delta, 3, 0xff0000, 1);
			}
		}
		
		
		public function stopRecording():void
		{
			//delta = 15000;
			clip.theCircle.recTime.text = "0"
			Utility.drawArc(drawing.graphics, 1601, 981, 35, 0, 360, 3, 0x000000, 1);
			clip.removeEventListener(Event.ENTER_FRAME, updateArc);
		}
		
		
		//shows save and continue
		public function showSave(isVideo:Boolean):void
		{
			if (myContainer.contains(drawing)){
				myContainer.removeChild(drawing);
			}
			drawing.graphics.clear();
			clip.theCircle.gotoAndStop(5);//save & continue
			if(isVideo){
				clip.theCircle.btnRecordAgain.theText.text = "RECORD AGAIN";
			}else{
				clip.theCircle.btnRecordAgain.theText.text = "RETAKE PHOTO";
			}
			TweenMax.to(clip.theCorner, 2, {colorTransform:{tintAmount:0}});//back to blue
			clip.theCircle.btnRecordAgain.addEventListener(MouseEvent.MOUSE_DOWN, cancelSave, false, 0, true);
			clip.theCircle.btnVideo.addEventListener(MouseEvent.MOUSE_DOWN, replayVideo, false, 0, true);
			clip.theCircle.cornerButton.addEventListener(MouseEvent.MOUSE_DOWN, cornerClicked, false, 0, true);	
		}
		
		private function replayVideo(e:MouseEvent):void
		{
			dispatchEvent(new Event(VIDEOREPLAY));
		}
		
		private function cancelSave(e:MouseEvent):void
		{
			clip.theCircle.btnRecordAgain.removeEventListener(MouseEvent.MOUSE_DOWN, cancelSave);
			clip.theCircle.btnVideo.removeEventListener(MouseEvent.MOUSE_DOWN, replayVideo);
			dispatchEvent(new Event(CANCELCLICKED));
		}
		
		private function cancelEmail(e:MouseEvent):void
		{
			clip.theCircle.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelEmail);
			dispatchEvent(new Event(CANCELCLICKED));
		}
		
		
		//finish and send photo/video - email/form screen
		public function showFinish(isVideo:Boolean):void
		{			
			clip.theCircle.btnRecordAgain.removeEventListener(MouseEvent.MOUSE_DOWN, cancelSave);
			clip.theCircle.btnVideo.removeEventListener(MouseEvent.MOUSE_DOWN, replayVideo);
			clip.theCircle.gotoAndStop(6);
			clip.theCircle.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelEmail, false, 0, true);
			if(isVideo){
				clip.theCircle.theText.text = "FINISH &\nSEND VIDEO";
			}else{
				clip.theCircle.theText.text = "FINISH &\nSEND PHOTO";
			}
		}
		
		
		public function showThanks():void
		{
			clip.theCircle.gotoAndStop(7);
		}
	}
	
}