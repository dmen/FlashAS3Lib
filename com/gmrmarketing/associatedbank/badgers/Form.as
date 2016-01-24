package com.gmrmarketing.associatedbank.badgers
{
	import flash.events.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Form extends EventDispatcher
	{
		public static const COMPLETE:String = "FormComplete";//dispatched from validate()
		public static const FORM_ERROR:String = "FormError";//dispatched from showError()
		
		private var clip:MovieClip;
		//private var clip2:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var errorString:String;
		
		private var rules:MovieClip;
		private var privacy:MovieClip;
		
		
		
		public function Form()
		{
			clip = new mcForm();
			rules = new mcRules();
			privacy = new mcPrivacy();
			//clip2 = new mcForm2();
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
			clip.c16.gotoAndStop(1);
			
			//clip.inParty.text = "";
			//clip.inParty.tabIndex = 1;			
			clip.fname.text = "";
			clip.fname.tabIndex = 1;
			clip.lname.text = "";
			clip.lname.tabIndex = 2;
			clip.email.text = "";
			clip.email.tabIndex = 3;
			clip.mobile.text = "";
			clip.mobile.tabIndex = 4;
			clip.zip.text = "";
			clip.zip.tabIndex = 5;
			
			clip.zip.restrict = "0-9";
			clip.zip.maxChars = 5;
			clip.mobile.restrict = "0-9\\-";
			clip.mobile.maxChars = 12;
			//clip.inParty.restrict = "0-9";
			//clip.inParty.maxChars = 3;			
			
			clip.c1.addEventListener(MouseEvent.MOUSE_DOWN, toggle12, false, 0, true);
			clip.c2.addEventListener(MouseEvent.MOUSE_DOWN, toggle12, false, 0, true);
			
			clip.c3.addEventListener(MouseEvent.MOUSE_DOWN, toggle34, false, 0, true);
			clip.c4.addEventListener(MouseEvent.MOUSE_DOWN, toggle34, false, 0, true);
			
			clip.c5.addEventListener(MouseEvent.MOUSE_DOWN, toggle56, false, 0, true);			
			clip.c6.addEventListener(MouseEvent.MOUSE_DOWN, toggle56, false, 0, true);
			
			clip.c7.addEventListener(MouseEvent.MOUSE_DOWN, toggle78, false, 0, true);			
			clip.c8.addEventListener(MouseEvent.MOUSE_DOWN, toggle78, false, 0, true);
			
			clip.c9.addEventListener(MouseEvent.MOUSE_DOWN, toggle910, false, 0, true);			
			clip.c10.addEventListener(MouseEvent.MOUSE_DOWN, toggle910, false, 0, true);
			
			clip.c11.addEventListener(MouseEvent.MOUSE_DOWN, toggle1112, false, 0, true);			
			clip.c12.addEventListener(MouseEvent.MOUSE_DOWN, toggle1112, false, 0, true);
			
			clip.c13.addEventListener(MouseEvent.MOUSE_DOWN, toggle1314, false, 0, true);			
			clip.c14.addEventListener(MouseEvent.MOUSE_DOWN, toggle1314, false, 0, true);
			
			clip.c15.addEventListener(MouseEvent.MOUSE_DOWN, toggle1516, false, 0, true);			
			clip.c16.addEventListener(MouseEvent.MOUSE_DOWN, toggle1516, false, 0, true);
			
			clip.btnTake.theText.text = "NEXT";
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, validate, false, 0, true);
			
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			//clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, showPrivacy, false, 0, true);
			
			/*
			//FORM 2
			clip2.c15.gotoAndStop(1);
			clip2.c16.gotoAndStop(1);
			clip2.c17.gotoAndStop(1);
			clip2.c18.gotoAndStop(1);
			
			clip2.fname1.text = "";
			clip2.fname1.tabIndex = 1;		
			clip2.email1.text = "";
			clip2.email1.tabIndex = 2;	
			clip2.fname2.text = "";
			clip2.fname2.tabIndex = 3;	
			clip2.email2.text = "";
			clip2.email2.tabIndex = 4;
			
			clip2.c15.addEventListener(MouseEvent.MOUSE_DOWN, toggle1516, false, 0, true);			
			clip2.c16.addEventListener(MouseEvent.MOUSE_DOWN, toggle1516, false, 0, true);
			
			clip2.c17.addEventListener(MouseEvent.MOUSE_DOWN, toggle1718, false, 0, true);			
			clip2.c17.addEventListener(MouseEvent.MOUSE_DOWN, toggle1718, false, 0, true);
			
			clip2.btnTake.theText.text = "TAKE PHOTOS";
			clip2.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, validate2, false, 0, true);
			clip2.btnBack.theText.text = "BACK";
			clip2.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, goBack, false, 0, true);
			*/
		}
		
		
		private function showRules(e:MouseEvent):void
		{
			myContainer.addChild(rules);
			rules.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeRules, false, 0, true);
		}
		
		private function closeRules(e:MouseEvent):void
		{
			rules.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeRules);
			if (myContainer) {
				if (myContainer.contains(rules)) {
					myContainer.removeChild(rules);
				}
			}
		}
		
		private function showPrivacy(e:MouseEvent):void
		{
			myContainer.addChild(privacy);
			privacy.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closePrivacy, false, 0, true);
		}
		
		
		private function closePrivacy(e:MouseEvent):void
		{
			privacy.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePrivacy);
			if (myContainer) {
				if (myContainer.contains(privacy)) {
					myContainer.removeChild(privacy);
				}
			}
		}
		
		
		
		public function hide():void
		{
			clip.c1.removeEventListener(MouseEvent.MOUSE_DOWN, toggle12);
			clip.c2.removeEventListener(MouseEvent.MOUSE_DOWN, toggle12);
			
			clip.c3.removeEventListener(MouseEvent.MOUSE_DOWN, toggle34);
			clip.c4.removeEventListener(MouseEvent.MOUSE_DOWN, toggle34);
			
			clip.c5.removeEventListener(MouseEvent.MOUSE_DOWN, toggle56);			
			clip.c6.removeEventListener(MouseEvent.MOUSE_DOWN, toggle56);
			
			clip.c7.removeEventListener(MouseEvent.MOUSE_DOWN, toggle78);			
			clip.c8.removeEventListener(MouseEvent.MOUSE_DOWN, toggle78);
			
			clip.c9.removeEventListener(MouseEvent.MOUSE_DOWN, toggle910);			
			clip.c10.removeEventListener(MouseEvent.MOUSE_DOWN, toggle910);
			
			clip.c11.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1112);			
			clip.c12.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1112);
			
			clip.c13.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1314);			
			clip.c14.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1314);
			
			clip.c15.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1516);			
			clip.c16.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1516);
			
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, validate);
			
			//FORM 2
			/*
			clip2.c15.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1516);			
			clip2.c16.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1516);
			
			clip2.c17.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1718);			
			clip2.c17.removeEventListener(MouseEvent.MOUSE_DOWN, toggle1718);
			
			clip2.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, validate2);
			clip2.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, goBack);			
			*/
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				/*
				if (myContainer.contains(clip2)) {
					myContainer.removeChild(clip2);
				}*/
			}
			
		}
		
		
		/**
		 * Called from validate once form data part 1 is valid
		 */
		/*
		private function show2():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (!myContainer.contains(clip2)) {
				myContainer.addChild(clip2);
			}			
		}
		
		
		private function goBack(e:MouseEvent):void
		{
			
			if (myContainer.contains(clip2)) {
				myContainer.removeChild(clip2);
			}			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
		}
		*/
		
		public function get data():Object
		{
			var data:Object = { };
			data.askEmail = clip.c1.currentFrame == 2 ? 5177 : 5178;
			
			//data.numInParty = clip.inParty.text;
			
			data.over18 =  clip.c7.currentFrame == 2 ? 5183 : 5184;
			
			data.fname = clip.fname.text;
			data.lname = clip.lname.text;
			data.email = clip.email.text;
			data.mobile = clip.mobile.text;
			data.zip = clip.zip.text;
			
			data.acknowledge = clip.c3.currentFrame == 2 ? 5304 : 5305;
			data.permission = clip.c13.currentFrame == 2 ? 5200 : 5201;
			data.currentCustomer =  clip.c9.currentFrame == 2 ? 5194 : 5195;
			data.checking = clip.c11.currentFrame == 2 ? 5196 : 5197;			
			data.willingToBeContacted = clip.c5.currentFrame == 2 ? 5198 : 5199;
			
			data.futureCommunication = clip.c15.currentFrame == 2 ? 5181 : 5182;
			
			//form 2
			/*
			data.ackEmail1 = clip2.c15.currentFrame == 2 ? 5306 : 5307;
			data.fname1 = clip2.fname1.text;
			data.email1 = clip2.email1.text;
			
			data.ackEmail2 = clip2.c17.currentFrame == 2 ? 5308 : 5309;
			data.fname2 = clip2.fname2.text;
			data.email2 = clip2.email2.text;			
			*/
			
			return data;
		}		
		
		/**
		 * Returns the last errorString set in showError()
		 */
		public function get error():String
		{
			return errorString;
		}
		
		
		private function toggle12(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("1") != -1) {
				clip.c1.gotoAndStop(2);
				clip.c2.gotoAndStop(1);
			}else {
				clip.c1.gotoAndStop(1);
				clip.c2.gotoAndStop(2);
			}
		}
		
		
		private function toggle34(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("3") != -1) {
				clip.c3.gotoAndStop(2);
				clip.c4.gotoAndStop(1);
			}else {
				clip.c3.gotoAndStop(1);
				clip.c4.gotoAndStop(2);
			}
		}
		
		
		private function toggle56(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("5") != -1) {
				clip.c5.gotoAndStop(2);
				clip.c6.gotoAndStop(1);
			}else {
				clip.c5.gotoAndStop(1);
				clip.c6.gotoAndStop(2);
			}			
		}
		
		
		private function toggle78(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("7") != -1) {
				clip.c7.gotoAndStop(2);
				clip.c8.gotoAndStop(1);
			}else {
				clip.c7.gotoAndStop(1);
				clip.c8.gotoAndStop(2);
			}			
		}
		
		
		private function toggle910(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("9") != -1) {
				clip.c9.gotoAndStop(2);
				clip.c10.gotoAndStop(1);
			}else {
				clip.c9.gotoAndStop(1);
				clip.c10.gotoAndStop(2);
			}			
		}
		
		
		private function toggle1112(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("11") != -1) {
				clip.c11.gotoAndStop(2);
				clip.c12.gotoAndStop(1);
			}else {
				clip.c11.gotoAndStop(1);
				clip.c12.gotoAndStop(2);
			}			
		}
		
		
		private function toggle1314(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("13") != -1) {
				clip.c13.gotoAndStop(2);
				clip.c14.gotoAndStop(1);
			}else {
				clip.c13.gotoAndStop(1);
				clip.c14.gotoAndStop(2);
			}			
		}
		
		private function toggle1516(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("15") != -1) {
				clip.c15.gotoAndStop(2);
				clip.c16.gotoAndStop(1);
			}else {
				clip.c15.gotoAndStop(1);
				clip.c16.gotoAndStop(2);
			}			
		}
		
		//these two for form 2
		/*
		private function toggle1516(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("15") != -1) {
				clip2.c15.gotoAndStop(2);
				clip2.c16.gotoAndStop(1);
			}else {
				clip2.c15.gotoAndStop(1);
				clip2.c16.gotoAndStop(2);
			}			
		}
		
		
			private function toggle1718(e:MouseEvent):void
		{
			var m:MovieClip = e.currentTarget as MovieClip;
			if (m.name.indexOf("17") != -1) {
				clip2.c17.gotoAndStop(2);
				clip2.c18.gotoAndStop(1);
			}else {
				clip2.c17.gotoAndStop(1);
				clip2.c18.gotoAndStop(2);
			}			
		}
		*/
		
		private function validate(e:MouseEvent):void
		{
			//dispatchEvent(new Event(COMPLETE));
			if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "" || clip.zip.text == "" ) {
				showError("Please complete all required form fields.");
			}else {				
				if ((clip.c1.currentFrame == 1 && clip.c2.currentFrame == 1) || (clip.c3.currentFrame == 1 && clip.c4.currentFrame == 1) || (clip.c5.currentFrame == 1 && clip.c6.currentFrame == 1) || (clip.c7.currentFrame == 1 && clip.c8.currentFrame == 1) || (clip.c9.currentFrame == 1 && clip.c10.currentFrame == 1) || (clip.c11.currentFrame == 1 && clip.c12.currentFrame == 1) || (clip.c13.currentFrame == 1 && clip.c14.currentFrame == 1) || (clip.c15.currentFrame == 1 && clip.c16.currentFrame == 1)) {
					showError("Please answer all required questions.");
					
				}else {
					if (Validator.isValidEmail(clip.email.text)) {
						
						if (String(clip.zip.text).length == 5) {						
													
							//show2();
							dispatchEvent(new Event(COMPLETE));
							
						}else {
							showError("Please enter a five digit zip code.");
						}
						
					}else {
						showError("The email address is not valid.");
					}
				}
			}
		}
		
		/*
		private function validate2(e:MouseEvent):void
		{
			if (clip2.email1.text != "" && clip2.c15.currentFrame != 2) {
				showError("Please agree to the rules.");
			}else if (clip2.email2.text != "" && clip2.c17.currentFrame != 2) {
				showError("Please agree to the rules.");
			}else {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		*/
		
		private function showError(m:String):void
		{
			errorString = m;
			dispatchEvent(new Event(FORM_ERROR));
		}
		
	}
	
}