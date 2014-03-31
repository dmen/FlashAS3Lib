package com.gmrmarketing.jimbeam.boldchoice
{
	import com.gmrmarketing.utilities.IOSSpinner;
	import com.greensock.TweenMax;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	
	public class AgeGate extends EventDispatcher
	{
		public static const AGEGATE_ADDED:String = "ageGateFadedIn";
		public static const PASSED:String = "ageVerified";
		public static const FAILED:String = "notOldEnough";
		
		private var container:DisplayObjectContainer;
		
		private var clip:MovieClip;
		private var monthSpinner:IOSSpinner;
		private var daySpinner:IOSSpinner;
		private var yearSpinner:IOSSpinner;
		
		private var theBirthDate:String; //user bdate as entered on the spinners
		
		
		
		public function AgeGate() 
		{
			clip = new theAgeGate(); //lib clip
			
			var months:Array = new Array("JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER");
			var days:Array = new Array();
			for (var i:int = 1; i < 32; i++) {
				days.push(String(i));
			}
			var cur:Date = new Date();
			var years:Array = new Array();
			for (i = cur.getFullYear(); i > 1910; i--) {
				years.push(String(i));
			}		
			
			monthSpinner = new IOSSpinner();
			monthSpinner.setChoices(months);
			
			daySpinner = new IOSSpinner();
			daySpinner.setChoices(days);
			
			yearSpinner = new IOSSpinner();
			yearSpinner.setChoices(years);			
			
			monthSpinner.show(clip, 54, 675);
			daySpinner.show(clip, 208, 675);
			yearSpinner.show(clip, 358, 675);
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{	
			theBirthDate = "";
			
			clip.btnEnter.addEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate, false, 0, true);
			clip.btnEnter.buttonMode = true;
			
			container = $container;
			clip.alpha = 0;
			container.addChild(clip);
			
			monthSpinner.resetSpinner();
			daySpinner.resetSpinner();
			yearSpinner.resetSpinner();
			monthSpinner.enable();
			daySpinner.enable();
			yearSpinner.enable();
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:clipAdded } );
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(AGEGATE_ADDED));
		}
		
		public function hide():void
		{
			clip.btnEnter.removeEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate);
			container.removeChild(clip);
			monthSpinner.disable();
			daySpinner.disable();
			yearSpinner.disable();
		}
		
		
		public function getBirthDate():String
		{
			return theBirthDate;
		}
		
		
		private function checkBirthDate(e:MouseEvent):void
		{
			var today:Date = new Date();
			var bDay:Date = new Date(parseInt(yearSpinner.getStringChoice()), monthSpinner.getIndexChoice(), parseInt(daySpinner.getStringChoice()));
			
			var yrs:int = today.getFullYear() - bDay.getFullYear();
			
			if (today.getMonth() < bDay.getMonth() || (today.getMonth() == bDay.getMonth() && bDay.getDay() < today.getDay())) {
				yrs--;
			}
			
			if (yrs < 21) {							
				dispatchEvent(new Event(FAILED));
			}else {				
				theBirthDate = String(bDay.getMonth() + 1) + "-" + String(bDay.getDay()) + "-" + String(bDay.getFullYear());
				dispatchEvent(new Event(PASSED));
			}
		}
	}
	
}