package com.gmrmarketing.png.gifphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class EmailPhone extends EventDispatcher
	{
		public static const COMPLETE:String = "empComplete";
		public static const SHOWING:String = "empShowing";
		public static const BACK:String = "empBack";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		private var tim:TimeoutHelper;
		private var myData:Array;
		private var myType:String; //email,text,both - set in show()
		
		
		public function EmailPhone()
		{
			myData = [];
			clip = new mcEmailPhone();
			tim = TimeoutHelper.getInstance();
			kbd = new KeyBoard();
			//kbd.addEventListener(KeyBoard.KEYFILE_LOADED, initkbd, false, 0, true);
			kbd.loadKeyFile("kbd3.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * 
		 * @param	whichType String one of email,text,both
		 */
		public function show(whichType:String):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if(!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
			}
			myType = whichType;
			
			switch(myType) {
				case "both":
					clip.theTitle.text = "Please Enter Email address and/or Phone";
					clip.email.x = 431;
					clip.phone.x = 1000;
					clip.email.visible = true;
					clip.phone.visible = true;
					clip.email.theCheck.visible = false;
					//clip.email.theCheck2.visible = false;//commented for Puffs Kiss Cry
					clip.phone.theCheck.visible = false;
					
					kbd.setFocusFields([[clip.email.theText, 0],[clip.phone.theText, 12]]);
					break;
				case "email":
					clip.theTitle.text = "Please Enter Email Address";
					clip.email.x = 751;
					clip.phone.visible = false;
					clip.email.visible = true;
					clip.email.theCheck.visible = false;
					//clip.email.theCheck2.visible = false; //commented for Puffs Kiss Cry
					kbd.setFocusFields([[clip.email.theText, 0]]);
					break;
				case "text":
					clip.theTitle.text = "Please Enter Phone";
					clip.phone.x = 710;
					clip.phone.visible = true;
					clip.email.visible = false;
					clip.phone.theCheck.visible = false;
					kbd.setFocusFields([[clip.phone.theText, 12]]);
					break;
			}
			
			kbd.x = 240;
			kbd.y = 760;
			kbd.alpha = 0;
			
			clip.phone.theText.restrict = "-0-9";
			clip.email.theText.text = "";
			clip.phone.theText.text = "";
			
			clip.email.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleEmailAge, false, 0, true);
			//clip.email.btnCheck2.addEventListener(MouseEvent.MOUSE_DOWN, toggleEmailOptIn, false, 0, true); //commented for Puffs Kiss Cry
			clip.phone.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, togglePhoneOptIn, false, 0, true);
			
			clip.btnAdd.addEventListener(MouseEvent.MOUSE_DOWN, addPerson, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, doBack, false, 0, true);
			
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			clip.stage.addEventListener(KeyboardEvent.KEY_DOWN, physicalKeyPressed, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		
		/**
		 * returns an array of objects containing keys:
		 * email:String, phone:String, opt:Boolean
		 */
		public function get data():Array
		{
			return myData;
		}
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		private function toggleEmailAge(e:MouseEvent):void
		{
			clip.email.theCheck.visible = clip.email.theCheck.visible ? false : true;
		}
		private function toggleEmailOptIn(e:MouseEvent):void
		{
			clip.email.theCheck2.visible = clip.email.theCheck2.visible ? false : true;
		}
		private function togglePhoneOptIn(e:MouseEvent):void
		{
			clip.phone.theCheck.visible = clip.phone.theCheck.visible ? false : true;
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					clip.stage.removeEventListener(KeyboardEvent.KEY_DOWN, physicalKeyPressed);
					myContainer.removeChild(clip);
				}
				if(myContainer.contains(kbd)){
					myContainer.removeChild(kbd);
				}
			}			
			
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			clip.btnAdd.removeEventListener(MouseEvent.MOUSE_DOWN, addPerson);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, doBack);
			clip.email.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleEmailOptIn);
			//clip.email.btnCheck2.removeEventListener(MouseEvent.MOUSE_DOWN, toggleEmailOptIn);//commented for Puffs Kiss Cry
			clip.phone.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, togglePhoneOptIn);
		}
		
		
		//called from Main.finish()
		public function clear():void
		{
			myData = [];
		}
		
		
		private function keyPressed(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function physicalKeyPressed(e:KeyboardEvent):void
		{
			tim.buttonClicked();
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
			TweenMax.to(kbd, .5, { y:682, alpha:1, ease:Back.easeOut } );
		}
		
		
		/**
		 * called when the addPerson button is pressed
		 * limits number of entries to five
		 * @param	e
		 */
		private function addPerson(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			var good:int = 3;
			
			if (clip.email.theText.text != "") {
				if (!Validator.isValidEmail(clip.email.theText.text)) {
					message("Please enter a valid email address");
					good = 0;
				}else {
					good = 1;
				}
				if (good) {
					if (!clip.email.theCheck.visible) {
						message("You must be at least 13 years of age");
						good = 0;
					}
				}
			}
			
			if (clip.phone.theText.text != "") {
				if (!Validator.isValidPhoneNumber(clip.phone.theText.text)) {
					message("Please enter a valid phone number with area code");
					good = 0;
				}else {
					good = 1;
				}
				if (good) {
					if (!clip.phone.theCheck.visible) {
						message("\nYou must accept the SMS terms");
						good = 0;
					}
				}
			}
			
			if (good == 1) {
				if (myData.length < 5) {
				
					var ph:String = clip.phone.theText.text;
					var clPh:String = ph.replace(/\-/g, "");
					
					var newEntry:Object = { email:clip.email.theText.text, phone:clPh };// , opt:clip.email.theCheck2.visible };//commented for Puffs Kiss Cry
					myData.push(newEntry);
					message("New Data Added");
					clip.email.theText.text = "";
					clip.phone.theText.text = "";
					clip.email.theCheck.visible = false;//age > 13
					//clip.email.theCheck2.visible = false;//opt-in //commented for Puffs Kiss Cry
					clip.phone.theCheck.visible = false;//sms accept
					kbd.setFocus(0);//reset to email
				}else {
					message("Maximum entries reached");
				}
			}else if(good == 3){
				message("No Data to Add");
			}
		}
		
		/**
		 * Called when the next button is pressed by the user
		 * @param	e
		 */
		private function doNext(e:MouseEvent):void
		{
			var good:int = 3;
		
			if (clip.email.theText.text != "") {
				if (!Validator.isValidEmail(clip.email.theText.text)) {
					message("Please enter a valid email address");
					good = 0;
				}else {
					good = 1;
				}
				if (good) {
					if (!clip.email.theCheck.visible) {
						message("You must be at least 13 years of age");
						good = 0;
					}
				}
			}
			
			if (clip.phone.theText.text != "" && good != 0) {
				if (!Validator.isValidPhoneNumber(clip.phone.theText.text)) {
					message("Please enter a valid phone number with area code");
					good = 0;
				}else {
					good = 1;
				}
				if (good) {
					if (!clip.phone.theCheck.visible) {
						message("You must accept the SMS terms");
						good = 0;
					}
				}
			}
			
			if (good == 1) {
				if (myData.length < 5) {
				
					var ph:String = clip.phone.theText.text;
					var clPh:String = ph.replace(/\-/g, "");
					
					var newEntry:Object = { email:clip.email.theText.text, phone:clPh, opt:clip.email.theCheck.visible };
					myData.push(newEntry);
					dispatchEvent(new Event(COMPLETE));
				}else {
					//user has final data in fields but list alread has five items
					message("Maximum of five entries reached");
					clip.email.theText.text = "";
					clip.phone.theText.text = "";
				}
				
			}else if(good == 3){
				//fields are blank
				if (myData.length > 0) {
					dispatchEvent(new Event(COMPLETE));
					
				}else{
					if (myType == "email") {
						message("Please enter at least one email");
					}else if (myType == "text") {
						message("Please enter at least one phone number");
					}else {
						message("Please enter an email or phone number");
					}
				}
			}
			
		}
		
		
		private function doBack(e:MouseEvent):void
		{
			dispatchEvent(new Event(BACK));
		}
		
		
		private function message(m:String):void
		{
			clip.theTitle.text = m;			
			TweenMax.to(clip.theTitle, .5, { alpha:0, delay:2, onComplete:doTitle } );
		}
		
		
		private function doTitle():void
		{
			switch(myType) {
				case "both":
					clip.theTitle.text = "Please Enter Email Address and Phone";
					break;
				case "email":
					clip.theTitle.text = "Please Enter Email Address";
					break;
				case "text":
					clip.theTitle.text = "Please Enter Phone";
					break;
			}
			TweenMax.to(clip.theTitle, .5, { alpha:1 } );
		}
	}
	
}