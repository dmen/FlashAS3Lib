package com.gmrmarketing.miller.gifphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class AgeGate extends EventDispatcher
	{
		public static const COMPLETE:String = "complete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var monthSpinner:Spinner;
		private var daySpinner:Spinner;
		private var yearSpinner:Spinner;
		private var tim:TimeoutHelper;
		
		private var spinContainer:Sprite;
		
		public function AgeGate()
		{
			clip = new mcAgeGate();
			spinContainer = new Sprite();
			
			tim = TimeoutHelper.getInstance();
			
			monthSpinner = new Spinner();
			monthSpinner.setChoices(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]);
			
			var a:Array = [];
			daySpinner = new Spinner();
			for (var i:int = 1; i < 32; i++) {
				a.push(String(i));
			}
			daySpinner.setChoices(a)
			
			yearSpinner = new Spinner();
			a = [];
			for (i = 1920; i < 2016; i++) {
				a.push(String(i));
			}
			yearSpinner.setChoices(a);
			
			monthSpinner.container = spinContainer;
			daySpinner.container = spinContainer;
			yearSpinner.container = spinContainer;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;		
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
				myContainer.addChild(spinContainer);
			}
			//clip.cacheAsBitmap = true;
			//myContainer.cacheAsBitmap = true;
			
			clip.theText.text = "PLEASE ENTER YOUR DATE OF BIRTH";
			
			monthSpinner.show(597, 445);
			daySpinner.show(857, 445);			
			yearSpinner.show(1117, 445);
			monthSpinner.setStringChoice("June");
			daySpinner.setStringChoice("15");
			yearSpinner.setStringChoice("1990");
			
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submit, false, 0, true);
			
			clip.alpha = 0;
			clip.theBlack.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.to(clip.theBlack, 1, { alpha:.85, delay:.5 } );
		}
		
		
		public function hide():void
		{
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
					myContainer.removeChild(spinContainer);
				}
			}
			monthSpinner.hide();
			daySpinner.hide();
			yearSpinner.hide();
			
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submit);
		}
		
		public function get defaultDOB():String 
		{
			return "1900-01-01";
		}
		
		public function get dob():String
		{
			return yearSpinner.getStringChoice() + "-" + monthSpinner.getStringChoice() + "-" + daySpinner.getStringChoice();
		}
		
		
		private function submit(e:MouseEvent):void
		{
			tim.buttonClicked();
			var bday:Date = new Date(yearSpinner.getIndexChoice() + 1920, monthSpinner.getIndexChoice(), daySpinner.getIndexChoice() + 1);
			var now:Date = new Date();
			var age:int = now.fullYear - bday.fullYear;
			if(now.month < bday.month){
				age--;
			}
			if(now.month == bday.month){
				if(now.date < bday.date){
					age--;
				}
			}
			if (age >= 21) {
				clip.theText.text = "THANK YOU";
				TweenMax.delayedCall(1, complete);
			}else {
				clip.theText.text = "YOU MUST BE 21 TO PARTICIPATE";
				TweenMax.to(clip.theText, 1, { alpha:0, delay:2, onComplete:resetText } );
			}
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function resetText():void
		{
			clip.theText.text = "PLEASE ENTER YOUR DATE OF BIRTH";
			TweenMax.to(clip.theText, 1, { alpha:1 } );
		}
	}
	
}