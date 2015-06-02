package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class TapToBegin extends EventDispatcher
	{	
		public static const COMPLETE:String = "complete";
		private var monthSpinner:Spinner;
		private var daySpinner:Spinner;
		private var yearSpinner:Spinner;
		private var myContainer:DisplayObjectContainer;
		private var textClip:MovieClip; //provide dob text in the lib
		
		
		public function TapToBegin()
		{
			
			textClip = new mcBegin();
			
			monthSpinner = new Spinner();
			monthSpinner.setChoices(["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]);
			
			daySpinner = new Spinner();
			daySpinner.setChoices(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"])
			
			yearSpinner = new Spinner();
			var a:Array = [];
			for (var i:int = 1920; i < 2016; i++) {
				a.push(String(i));
			}
			yearSpinner.setChoices(a);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
			
			monthSpinner.container = myContainer;
			daySpinner.container = myContainer;
			yearSpinner.container = myContainer;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(textClip)) {
				myContainer.addChild(textClip);
			}
			
			textClip.theText.text = "PLEASE PROVIDE YOUR DATE OF BIRTH";
			
			monthSpinner.show(635, 550);
			daySpinner.show(935, 550);			
			yearSpinner.show(1235, 550);
			monthSpinner.setStringChoice("June");
			daySpinner.setStringChoice("15");
			yearSpinner.setStringChoice("1990");
			
			textClip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submit, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(textClip)) {
				myContainer.removeChild(textClip);
			}
			monthSpinner.hide();
			daySpinner.hide();
			yearSpinner.hide();
		}
		
		
		private function submit(e:MouseEvent):void
		{
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
				textClip.theText.text = "THANK YOU";
				TweenMax.delayedCall(1, complete);
			}else {
				textClip.theText.text = "YOU MUST BE 21 TO PARTICIPATE";
				TweenMax.to(textClip.theText, 1, { alpha:0, delay:2, onComplete:resetText } );
			}
		}
		
		public function get dob():String
		{
			return yearSpinner.getStringChoice() + "-" + monthSpinner.getStringChoice() + "-" + daySpinner.getStringChoice();
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		

		private function resetText():void
		{
			textClip.theText.text = "PLEASE PROVIDE YOUR DATE OF BIRTH";
				TweenMax.to(textClip.theText, 1, { alpha:1 } );
		}
		
	}
	
}