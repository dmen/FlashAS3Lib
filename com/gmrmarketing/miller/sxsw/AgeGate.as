package com.gmrmarketing.miller.sxsw
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.sagecollective.utilities.TimeoutHelper;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.IOSSpinner;
	
	
	public class AgeGate extends EventDispatcher
	{
		public static const GATE_ADDED:String = "ageGateAdded";
		public static const UNDER_AGE:String = "underAge";
		public static const AGE_VERIFIED:String = "ageVerified";
		public static const TERMS_CLICKED:String = "termsBtnClicked";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var monthSpinner:IOSSpinner;
		private var daySpinner:IOSSpinner;
		private var yearSpinner:IOSSpinner;
		
		private var currentBirthdate:String;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function AgeGate()
		{
			timeoutHelper = TimeoutHelper.getInstance();
			clip = new age_gate(); //lib clip
			
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
			
			monthSpinner = new IOSSpinner(161, 50, 17);
			monthSpinner.setChoices(months);
			
			daySpinner = new IOSSpinner(161, 50, 17);
			daySpinner.setChoices(days);
			
			yearSpinner = new IOSSpinner(161, 50, 17);
			yearSpinner.setChoices(years);			
			
			monthSpinner.show(clip, 585, 327);
			daySpinner.show(clip, 827, 327);
			yearSpinner.show(clip, 1069, 327);
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{			
			container = $container;			
			
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, checkAge, false, 0, true);
			clip.btnTerms.addEventListener(MouseEvent.MOUSE_DOWN, openTerms, false, 0, true);
			
			monthSpinner.resetSpinner();
			daySpinner.resetSpinner();
			yearSpinner.resetSpinner();
			monthSpinner.enable();
			daySpinner.enable();
			yearSpinner.enable();
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:clipAdded } );			
		}
		
		
		public function fade():void
		{
			TweenMax.to(clip, 1, { alpha:0 } );
		}
		
		
		public function hide():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, checkAge);
			clip.btnTerms.removeEventListener(MouseEvent.MOUSE_DOWN, openTerms);
			
			monthSpinner.disable();
			daySpinner.disable();
			yearSpinner.disable();
		}
		
		
		private function openTerms(e:MouseEvent):void
		{
			dispatchEvent(new Event(TERMS_CLICKED));
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(GATE_ADDED));
		}
		
		
		private function ageGateClick(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		private function checkAge(e:MouseEvent):void
		{
			var today:Date = new Date();
			var bDay:Date = new Date(parseInt(yearSpinner.getStringChoice()), monthSpinner.getIndexChoice(), parseInt(daySpinner.getStringChoice()));
			
			var yrs:int = today.getFullYear() - bDay.getFullYear();
			
			if (today.getMonth() < bDay.getMonth() || (today.getMonth() == bDay.getMonth() && bDay.getDay() < today.getDay())) {
				yrs--;
			}
			
			if (yrs < 21) {							
				dispatchEvent(new Event(UNDER_AGE));
			}else {				
				//theBirthDate = String(bDay.getMonth() + 1) + "-" + String(bDay.getDay()) + "-" + String(bDay.getFullYear());
				dispatchEvent(new Event(AGE_VERIFIED));
			}
		}
		
	}
	
}