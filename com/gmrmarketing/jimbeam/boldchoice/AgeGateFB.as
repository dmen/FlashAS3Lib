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
	
	
	public class AgeGateFB extends EventDispatcher
	{
		public static const AGEGATE_ADDED:String = "ageGateFadedIn";
		public static const PASSED:String = "ageVerified";
		public static const FAILED:String = "notOldEnough";
		
		private var container:DisplayObjectContainer;
		
		private var clip:MovieClip;
		private var theBirthDate:String; //user bdate as entered
		
		
		
		public function AgeGateFB() 
		{
			clip = new theAgeGate(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{	
			container = $container;
			
			theBirthDate = "";
			
			clip.btnEnter.addEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate, false, 0, true);
			clip.btnEnter.buttonMode = true;
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.mm.text = "MM";
			clip.dd.text = "DD";
			clip.yy.text = "YY";
			clip.mm.restrict = "0-9";
			clip.dd.restrict = "0-9";
			clip.yy.restrict = "0-9";
			clip.mm.addEventListener(MouseEvent.MOUSE_DOWN, clearMM, false, 0, true);
			clip.dd.addEventListener(MouseEvent.MOUSE_DOWN, clearDD, false, 0, true);
			clip.yy.addEventListener(MouseEvent.MOUSE_DOWN, clearYY, false, 0, true);
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:clipAdded } );
		}
		
		private function clearMM(e:MouseEvent):void
		{
			if (clip.mm.text == "MM") {
				clip.mm.text = "";
			}
		}
		private function clearDD(e:MouseEvent):void
		{
			if (clip.dd.text == "DD") {
				clip.dd.text = "";
			}
		}
		private function clearYY(e:MouseEvent):void
		{
			if (clip.yy.text == "YY") {
				clip.yy.text = "";
			}
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(AGEGATE_ADDED));
		}
		
		public function hide():void
		{
			clip.btnEnter.removeEventListener(MouseEvent.MOUSE_DOWN, checkBirthDate);
			container.removeChild(clip);
			clip.mm.removeEventListener(MouseEvent.MOUSE_DOWN, clearMM);
			clip.dd.removeEventListener(MouseEvent.MOUSE_DOWN, clearDD);
			clip.yy.removeEventListener(MouseEvent.MOUSE_DOWN, clearYY);
		}
		
		
		public function getBirthDate():String
		{
			return theBirthDate;
		}
		
		
		private function checkBirthDate(e:MouseEvent):void
		{
			var today:Date = new Date();
			var bDay:Date = new Date(parseInt(clip.yy.text), parseInt(clip.mm.text), parseInt(clip.dd.text));
			
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