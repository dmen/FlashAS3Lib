package com.gmrmarketing.associatedbank.badgers
{
	import flash.events.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Form_nov extends EventDispatcher
	{
		public static const COMPLETE:String = "FormComplete";//dispatched from validate()
		public static const FORM_ERROR:String = "FormError";//dispatched from showError()
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var errorString:String;
		
		private var rules:MovieClip;
		private var privacy:MovieClip;
		
		
		
		public function Form_nov()
		{
			clip = new mcForm();
			rules = new mcRules();
			privacy = new mcPrivacy();
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
			
			//reset checks and fields
			clip.c1.gotoAndStop(1);
			clip.c2.gotoAndStop(1);
			clip.c3.gotoAndStop(1);
			clip.c4.gotoAndStop(1);
			clip.c5.gotoAndStop(1);
			clip.c6.gotoAndStop(1);
			clip.c7.gotoAndStop(1);
			clip.c8.gotoAndStop(1);
			clip.c9.gotoAndStop(1);
			clip.c10.gotoAndStop(1);
			clip.c11.gotoAndStop(1);
			clip.c12.gotoAndStop(1);
			clip.c13.gotoAndStop(1);
			clip.c14.gotoAndStop(1);
			clip.c15.gotoAndStop(1);
			
			clip.numPeople.text = "";
			clip.numPeople.tabIndex = 1;
			clip.numPeople.restrict = "0-9";
			clip.numPeople.maxChars = 3;
			
			clip.fname.text = "";
			clip.fname.tabIndex = 2;
			clip.lname.text = "";
			clip.lname.tabIndex = 3;
			clip.email.text = "";
			clip.email.tabIndex = 4;
			clip.email2.text = "";
			clip.email2.tabIndex = 5;
			clip.mobile.text = "";
			clip.mobile.tabIndex = 6;			
			clip.mobile.restrict = "0-9\\-";
			clip.mobile.maxChars = 12;
			
			clip.c1.addEventListener(MouseEvent.MOUSE_DOWN, toggle123, false, 0, true);
			clip.c2.addEventListener(MouseEvent.MOUSE_DOWN, toggle123, false, 0, true);			
			clip.c3.addEventListener(MouseEvent.MOUSE_DOWN, toggle123, false, 0, true);
			
			clip.c4.addEventListener(MouseEvent.MOUSE_DOWN, toggle45, false, 0, true);			
			clip.c5.addEventListener(MouseEvent.MOUSE_DOWN, toggle45, false, 0, true);
			
			clip.c6.addEventListener(MouseEvent.MOUSE_DOWN, toggle67, false, 0, true);			
			clip.c7.addEventListener(MouseEvent.MOUSE_DOWN, toggle67, false, 0, true);
			
			clip.c8.addEventListener(MouseEvent.MOUSE_DOWN, toggle89, false, 0, true);			
			clip.c9.addEventListener(MouseEvent.MOUSE_DOWN, toggle89, false, 0, true);
			
			clip.c10.addEventListener(MouseEvent.MOUSE_DOWN, toggle1011, false, 0, true);			
			clip.c11.addEventListener(MouseEvent.MOUSE_DOWN, toggle1011, false, 0, true);
			
			clip.c12.addEventListener(MouseEvent.MOUSE_DOWN, toggle1213, false, 0, true);			
			clip.c13.addEventListener(MouseEvent.MOUSE_DOWN, toggle1213, false, 0, true);
			
			clip.c14.addEventListener(MouseEvent.MOUSE_DOWN, toggle1415, false, 0, true);			
			clip.c15.addEventListener(MouseEvent.MOUSE_DOWN, toggle1415, false, 0, true);			
			
			clip.btnTake.theText.text = "NEXT";
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, validate, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.c1.removeEventListener(MouseEvent.MOUSE_DOWN, toggle123);
			clip.c2.removeEventListener(MouseEvent.MOUSE_DOWN, toggle123);			
			clip.c3.removeEventListener(MouseEvent.MOUSE_DOWN, toggle123);
			
			clip.c4.removeEventListener(MouseEvent.MOUSE_DOWN, toggle45);			
			clip.c5.removeEventListener(MouseEvent.MOUSE_DOWN, toggle45);	
			
			clip.c6.removeEventListener(MouseEvent.MOUSE_DOWN, toggle67);			
			clip.c7.removeEventListener(MouseEvent.MOUSE_DOWN, toggle67);
			
			clip.c8.removeEventListener(MouseEvent.MOUSE_DOWN, toggle89);
			clip.c9.removeEventListener(MouseEvent.MOUSE_DOWN, toggle89);
			
			clip.c10.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1011);			
			clip.c11.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1011);
			
			clip.c12.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1213);
			clip.c13.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1213);
			
			clip.c14.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1415);			
			clip.c15.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1415);
			
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, validate);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}			
			}			
		}
		
		
		public function get data():Object
		{
			var data:Object = { };
			
			data.numPeople = clip.numPeople.text;
			
			if (clip.c1.currentFrame == 2){
				data.firstTime = 5179;
			}else if (clip.c2.currentFrame == 2){
				data.firstTime = 5180;
			}else{
				data.firstTime = 7004;
			}
			
			data.futureCommunication = clip.c4.currentFrame == 2 ? 5177 : 5178;
			data.willingToBeContacted = clip.c6.currentFrame == 2 ? 5198 : 5199;			
			data.over18 =  clip.c8.currentFrame == 2 ? 5183 : 5184;
			data.currentCustomer =  clip.c10.currentFrame == 2 ? 5194 : 5195;
			data.checking = clip.c12.currentFrame == 2 ? 5196 : 5197;
			data.permission = clip.c14.currentFrame == 2 ? 5200 : 5201;
			
			data.fname = clip.fname.text;
			data.lname = clip.lname.text;
			data.email = clip.email.text;
			data.email2 = clip.email2.text;
			data.mobile = clip.mobile.text;	
			
			return data;
		}
		
		
		/**
		 * Returns the last errorString set in showError()
		 */
		public function get error():String
		{
			return errorString;
		}
		
		
		private function toggle123(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			
			if (m.name.indexOf("1") != -1) {
				clip.c1.gotoAndStop(2);//check c1
				clip.c2.gotoAndStop(1);
				clip.c3.gotoAndStop(1);
			}else if (m.name.indexOf("2") != -1) {
				clip.c1.gotoAndStop(1);//check c2
				clip.c2.gotoAndStop(2);
				clip.c3.gotoAndStop(1);
			}else{
				clip.c1.gotoAndStop(1);//check c3
				clip.c2.gotoAndStop(1);
				clip.c3.gotoAndStop(2);
			}
		}
		
		
		private function toggle45(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("4") != -1) {
				clip.c4.gotoAndStop(2);
				clip.c5.gotoAndStop(1);
			}else {
				clip.c4.gotoAndStop(1);
				clip.c5.gotoAndStop(2);
			}
		}
		
		
		private function toggle67(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("6") != -1) {
				clip.c6.gotoAndStop(2);
				clip.c7.gotoAndStop(1);
			}else {
				clip.c6.gotoAndStop(1);
				clip.c7.gotoAndStop(2);
			}			
		}
		
		
		private function toggle89(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("8") != -1) {
				clip.c8.gotoAndStop(2);
				clip.c9.gotoAndStop(1);
			}else {
				clip.c8.gotoAndStop(1);
				clip.c9.gotoAndStop(2);
			}			
		}
		
		
		private function toggle1011(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("10") != -1) {
				clip.c10.gotoAndStop(2);
				clip.c11.gotoAndStop(1);
			}else {
				clip.c10.gotoAndStop(1);
				clip.c11.gotoAndStop(2);
			}			
		}
		
		
		private function toggle1213(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("12") != -1) {
				clip.c12.gotoAndStop(2);
				clip.c13.gotoAndStop(1);
			}else {
				clip.c12.gotoAndStop(1);
				clip.c13.gotoAndStop(2);
			}			
		}
		
		
		private function toggle1415(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("14") != -1) {
				clip.c14.gotoAndStop(2);
				clip.c15.gotoAndStop(1);
			}else {
				clip.c14.gotoAndStop(1);
				clip.c15.gotoAndStop(2);
			}			
		}
		
		
		private function validate(e:MouseEvent):void
		{
			if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "" ) {
				showError("Please complete all required form fields.");
			}else {				
				if ((clip.c1.currentFrame == 1 && clip.c2.currentFrame == 1 && clip.c3.currentFrame == 1) || (clip.c4.currentFrame == 1 && clip.c5.currentFrame == 1) || (clip.c6.currentFrame == 1 && clip.c7.currentFrame == 1) || (clip.c8.currentFrame == 1 && clip.c9.currentFrame == 1) || (clip.c10.currentFrame == 1 && clip.c11.currentFrame == 1) || (clip.c12.currentFrame == 1 && clip.c13.currentFrame == 1) || (clip.c14.currentFrame == 1 && clip.c15.currentFrame == 1)) {
					showError("Please answer all required questions.");
					
				}else {
					if (Validator.isValidEmail(clip.email.text)) {						
						
						dispatchEvent(new Event(COMPLETE));						
						
					}else {
						showError("The email address is not valid.");
					}
				}
			}
		}
		
		
		private function showError(m:String):void
		{
			errorString = m;
			dispatchEvent(new Event(FORM_ERROR));
		}
		
	}
	
}