package com.gmrmarketing.miller.gifphotobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Email extends EventDispatcher
	{
		public static const SHOWING:String = "emailShowing";
		public static const COMPLETE:String = "emailComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		
		private var tim:TimeoutHelper;
		
		
		public function Email()
		{
			clip = new mcEmail();
			
			tim = TimeoutHelper.getInstance();
			
			kbd = new KeyBoard();
			//kbd.addEventListener(KeyBoard.KEYFILE_LOADED, initkbd, false, 0, true);
			kbd.loadKeyFile("kbd.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		
		public function hide():void
		{
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if(myContainer.contains(kbd)){
					myContainer.removeChild(kbd);
				}
			}
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			clip.bem1.removeEventListener(MouseEvent.MOUSE_DOWN, toggleEm1);
			clip.bem2.removeEventListener(MouseEvent.MOUSE_DOWN, toggleEm2);
			clip.bem2.removeEventListener(MouseEvent.MOUSE_DOWN, toggleEm3);
			clip.bph1.removeEventListener(MouseEvent.MOUSE_DOWN, togglePh1);
			clip.bph2.removeEventListener(MouseEvent.MOUSE_DOWN, togglePh2);
			clip.bph3.removeEventListener(MouseEvent.MOUSE_DOWN, togglePh3);
			clip.btnFinish.removeEventListener(MouseEvent.MOUSE_DOWN, submit);
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if(!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
			}
			
			clip.em1.text = "";
			clip.em2.text = "";
			clip.em3.text = "";
			
			//check x's
			clip.cem1.visible = false;
			clip.cem2.visible = false;
			clip.cem3.visible = false;
			
			//buttons
			clip.bem1.addEventListener(MouseEvent.MOUSE_DOWN, toggleEm1, false, 0, true);
			clip.bem2.addEventListener(MouseEvent.MOUSE_DOWN, toggleEm2, false, 0, true);
			clip.bem3.addEventListener(MouseEvent.MOUSE_DOWN, toggleEm3, false, 0, true);
			
			clip.ph1.text = "";
			clip.ph2.text = "";
			clip.ph3.text = "";
			clip.ph1.restrict = "-0-9";
			clip.ph2.restrict = "-0-9";
			clip.ph3.restrict = "-0-9";
			
			//check x's
			clip.cph1.visible = false;
			clip.cph2.visible = false;
			clip.cph3.visible = false;
			
			//buttons
			clip.bph1.addEventListener(MouseEvent.MOUSE_DOWN, togglePh1, false, 0, true);
			clip.bph2.addEventListener(MouseEvent.MOUSE_DOWN, togglePh2, false, 0, true);
			clip.bph3.addEventListener(MouseEvent.MOUSE_DOWN, togglePh3, false, 0, true);
			
			kbd.x = 90;
			kbd.y = 1080;
			
			clip.dialog.visible = false;
			clip.btnFinish.addEventListener(MouseEvent.MOUSE_DOWN, submit, false, 0, true);			
			
			kbd.setFocusFields([[clip.em1, 0], [clip.em2, 0], [clip.em3, 0], [clip.ph1, 12], [clip.ph2, 12], [clip.ph3, 12]]);		
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		private function keyPressed(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		/**
		 * returns an object with email, phone, opt1, opt2, opt3 keys
		 */
		public function get data():Object
		{
			var o:Object = { };
			
			var em:String = "";
			if (clip.em1.text != "") {
				em += clip.em1.text;
			}
			if (clip.em2.text != "") {
				em += "," + clip.em2.text;
			}
			if (clip.em3.text != "") {
				em += "," + clip.em3.text;
			}
			
			var ph:String = "";
			if (clip.ph1.text != "") {
				ph += clip.ph1.text;
			}
			if (clip.ph2.text != "") {
				ph += "," + clip.ph2.text;
			}
			if (clip.ph3.text != "") {
				ph += "," + clip.ph3.text;
			}
			
			o.email = em;
			o.phone = ph;
			
			//email opt-ins			
			if (clip.em1.text != "" && clip.cem1.visible) {
				o.opt1 = true;
			}else {
				o.opt1 = false;
			}
			if (clip.em2.text != "" && clip.cem2.visible) {
				o.opt2 = true;
			}else {
				o.opt2 = false;
			}
			if (clip.em3.text != "" && clip.cem3.visible) {
				o.opt3 = true;
			}else {
				o.opt3 = false;
			}
			
			return o;
		}
		
		
		private function toggleEm1(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cem1.visible) {
				clip.cem1.visible = false;
			}else {
				clip.cem1.visible = true;
			}
		}
		
		private function toggleEm2(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cem2.visible) {
				clip.cem2.visible = false;
			}else {
				clip.cem2.visible = true;
			}
		}
		
		private function toggleEm3(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cem3.visible) {
				clip.cem3.visible = false;
			}else {
				clip.cem3.visible = true;
			}
		}
		
		
		private function togglePh1(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cph1.visible) {
				clip.cph1.visible = false;
			}else {
				clip.cph1.visible = true;
			}
		}
		
		private function togglePh2(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cph2.visible) {
				clip.cph2.visible = false;
			}else {
				clip.cph2.visible = true;
			}
		}
		
		private function togglePh3(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.cph3.visible) {
				clip.cph3.visible = false;
			}else {
				clip.cph3.visible = true;
			}
		}
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
			TweenMax.to(kbd, .5, { y:695, ease:Back.easeOut } );
		}		
		
		private function submit(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			var good:Boolean = true;
			
			if (clip.em1.text != "") {
				if (!Validator.isValidEmail(clip.em1.text)) {
					message("Please enter a valid email address");
					good = false;
				}/*else {
					//email valid
					if (!clip.cem1.visible) {
						//valid but opt-in not checked
						message("You must accept the email opt-in");
						good = false;
					}
				}*/
			}
			if (clip.em2.text != "") {
				if (!Validator.isValidEmail(clip.em2.text)) {
					message("Please enter a valid email address");
					good = false;
				}/*else {
					//email valid
					if (!clip.cem2.visible) {
						//valid but opt-in not checked
						message("You must accept the email opt-in");
						good = false;
					}
				}*/
			}
			if (clip.em3.text != "") {
				if (!Validator.isValidEmail(clip.em3.text)) {
					message("Please enter a valid email address");
					good = false;
				}/*else {
					//email valid
					if (!clip.cem3.visible) {
						//valid but opt-in not checked
						message("You must accept the email opt-in");
						good = false;
					}
				}*/
			}
			
			if (clip.ph1.text != "") {
				if (!Validator.isValidPhoneNumber(clip.ph1.text)) {
					message("Please enter a valid phone number with area code");
					good = false;
				}else {
					//email valid
					if (!clip.cph1.visible) {
						//valid but opt-in not checked
						message("You must agree to the SMS terms");
						good = false;
					}
				}
			}
			if (clip.ph2.text != "") {
				if (!Validator.isValidPhoneNumber(clip.ph2.text)) {
					message("Please enter a valid phone number with area code");
					good = false;
				}else {
					//email valid
					if (!clip.cph2.visible) {
						//valid but opt-in not checked
						message("You must agree to the SMS terms");
						good = false;
					}
				}
			}
			if (clip.ph3.text != "") {
				if (!Validator.isValidPhoneNumber(clip.ph3.text)) {
					message("Please enter a valid phone number with area code");
					good = false;
				}else {
					//email valid
					if (!clip.cph3.visible) {
						//valid but opt-in not checked
						message("You must agree to the SMS terms");
						good = false;
					}
				}
			}
			
			if (clip.em1.text == "" && clip.em2.text == "" && clip.em3.text == "" && clip.ph1.text == "" && clip.ph2.text == "" && clip.ph3.text == "") {
				message("Please provide at least one email or phone number");
				good = false;
			}
			
			if (good) {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
		
		private function message(m:String):void
		{
			clip.dialog.theText.text = m;
			clip.dialog.theText.y = Math.floor((clip.dialog.height - clip.dialog.theText.textHeight) * .5);
			clip.dialog.visible = true;
			clip.dialog.alpha = 0;
			clip.dialog.y = 300;
			TweenMax.to(clip.dialog, .5, { y:360, alpha:1, ease:Back.easeOut } );
			TweenMax.to(clip.dialog, .5, { alpha:0, delay:2, onComplete:hideDialog } );
		}
		
		
		private function hideDialog():void
		{
			clip.dialog.visible = false;
		}
	}
	
}