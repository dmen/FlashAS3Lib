package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*
	import com.greensock.TweenMax;	
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Validator;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class EmailForm extends EventDispatcher
	{
		public static const COMPLETE:String = "formComplete";
		public static const BACK:String = "backToMap";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var opt:Boolean;
		private var kbd:KeyBoard;
		private var kbdBG:Sprite;
		private var kbdShowing:Boolean;
		private var tim:TimeoutHelper;
		
		public function EmailForm()
		{
			opt = false;
			clip = new mcEmail();
			
			kbdBG = new Sprite();
			kbdBG.graphics.beginFill(0x000000, 1);
			kbdBG.graphics.drawRect(0, 0, 1920, 544);
			kbdBG.graphics.endFill();
			
			tim = TimeoutHelper.getInstance();
			
			kbd = new KeyBoard();			
			kbd.loadKeyFile("kbd.xml");//site kiosk kbd for 1920x1080
			
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
			clip.alpha = 1;
			clip.textEnter.alpha = 0;
			clip.textEnter.theText.text = "Enter your information below.";
			clip.fname.scaleX = clip.fname.scaleY = 0;
			clip.lname.scaleX = clip.lname.scaleY = 0;
			clip.email.scaleX = clip.email.scaleY = 0;
			clip.zip.scaleX = clip.zip.scaleY = 0;
			clip.heart.alpha = 0;
			TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:0 }} );//gray
			clip.optin.alpha = 0;
			clip.optin.theText.text = "OPT-IN TO NEWSLETTER";
			clip.btnSend.y = 1080;//915
			
			TweenMax.to(clip.textEnter, .5, { alpha:1 } );
			TweenMax.to(clip.fname, .5, { scaleX:1, scaleY:1, delay:.6 } );
			TweenMax.to(clip.lname, .5, { scaleX:1, scaleY:1, delay:.8 } );
			TweenMax.to(clip.email, .5, { scaleX:1, scaleY:1, delay:1 } );
			TweenMax.to(clip.zip, .5, { scaleX:1, scaleY:1, delay:1.2 } );
			
			TweenMax.to(clip.heart, .5, { alpha:1, delay:1.3 } );
			TweenMax.to(clip.optin, .5, { alpha:1, delay:1.3 } );
			
			TweenMax.to(clip.btnSend, .5, { y:915, delay:1.5, ease:Back.easeOut } );
			
			clip.btnOptin.addEventListener(MouseEvent.MOUSE_DOWN, optin);
			clip.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, submit);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backToMap);
			
			clip.fname.theText.text = "FIRST NAME";
			clip.lname.theText.text = "LAST NAME";
			clip.email.theText.text = "EMAIL@ADDRESS.COM";
			clip.zip.theText.text = "ZIP CODE";
			clip.zip.theText.restrict = "0-9";
			
			clip.fname.addEventListener(MouseEvent.MOUSE_DOWN, clearFname);
			clip.fname.addEventListener(FocusEvent.FOCUS_IN, clearFname);
			clip.lname.addEventListener(MouseEvent.MOUSE_DOWN, clearLname);
			clip.lname.addEventListener(FocusEvent.FOCUS_IN, clearLname);
			clip.email.addEventListener(MouseEvent.MOUSE_DOWN, clearEmail);
			clip.email.addEventListener(FocusEvent.FOCUS_IN, clearEmail);
			clip.zip.addEventListener(MouseEvent.MOUSE_DOWN, clearZip);
			clip.zip.addEventListener(FocusEvent.FOCUS_IN, clearZip);
			
			kbdShowing = false;
		}
		
		
		private function backToMap(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(BACK));
		}
		
		
		private function clearFname(e:Event):void
		{
			showKeyboard();
			
			if(clip.fname.theText.text == "FIRST NAME"){
				clip.fname.theText.text = "";
			}
			
			if (clip.lname.theText.text == "") {
				clip.lname.theText.text = "LAST NAME";
			}
			if (clip.email.theText.text == "") {
				clip.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.zip.theText.text == "") {
				clip.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearLname(e:Event):void
		{
			showKeyboard();
			
			if(clip.lname.theText.text == "LAST NAME"){
				clip.lname.theText.text = "";
			}
			
			if (clip.fname.theText.text == "") {
				clip.fname.theText.text = "FIRST NAME";
			}
			if (clip.email.theText.text == "") {
				clip.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.zip.theText.text == "") {
				clip.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearEmail(e:Event):void
		{
			showKeyboard();
			
			if(clip.email.theText.text == "EMAIL@ADDRESS.COM"){
				clip.email.theText.text = "";
			}
			
			if (clip.lname.theText.text == "") {
				clip.lname.theText.text = "LAST NAME";
			}
			if (clip.fname.theText.text == "") {
				clip.fname.theText.text = "FIRST NAME";
			}
			if (clip.zip.theText.text == "") {
				clip.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearZip(e:Event):void
		{
			showKeyboard();
			
			if(clip.zip.theText.text == "ZIP CODE"){
				clip.zip.theText.text = "";
			}
			
			if (clip.lname.theText.text == "") {
				clip.lname.theText.text = "LAST NAME";
			}
			if (clip.email.theText.text == "") {
				clip.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.fname.theText.text == "") {
				clip.fname.theText.text = "FIRST NAME";
			}
		}
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		private function kill():void
		{
			clip.btnOptin.removeEventListener(MouseEvent.MOUSE_DOWN, optin);
			clip.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, submit);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backToMap);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(kbd)) {
				myContainer.removeChild(kbd);
				myContainer.removeChild(kbdBG);
			}
			clip.fname.removeEventListener(MouseEvent.MOUSE_DOWN, clearFname);
			clip.fname.removeEventListener(FocusEvent.FOCUS_IN, clearFname);
			clip.lname.removeEventListener(MouseEvent.MOUSE_DOWN, clearLname);
			clip.lname.removeEventListener(FocusEvent.FOCUS_IN, clearLname);
			clip.email.removeEventListener(MouseEvent.MOUSE_DOWN, clearEmail);
			clip.email.removeEventListener(FocusEvent.FOCUS_IN, clearEmail);
			clip.zip.removeEventListener(MouseEvent.MOUSE_DOWN, clearZip);
			clip.zip.removeEventListener(FocusEvent.FOCUS_IN, clearZip);
			
			kbdShowing = false;
			kbd.removeEventListener(KeyBoard.KBD, resetTim);
		}
		
		
		private function showKeyboard():void
		{
			tim.buttonClicked();
			if (!kbdShowing) {
				kbdShowing = true;
				myContainer.addChild(kbdBG);
				kbdBG.alpha = 0;
				myContainer.addChild(kbd);
				kbd.x = 229;
				kbd.y = -kbd.height;//96;
				kbd.setFocusFields([[clip.fname.theText, 0], [clip.lname.theText, 0], [clip.email.theText, 0], [clip.zip.theText, 5]]);
				kbd.addEventListener(KeyBoard.KBD, resetTim, false, 0, true);
				
				TweenMax.to(kbdBG, .3, { alpha:.85 } );
				TweenMax.to(kbd, .5, { y:76 } );
			}
		}
		
		
		private function resetTim(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function optin(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			opt = !opt;
			if(opt){
				TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:1 }} );//red
				clip.optin.theText.text = "YOU ARE OPTED-IN TO THE NEWSLETTER";
			}else {
				TweenMax.to(clip.heart, 0, { colorMatrixFilter: { saturation:0 }} );//gray
				clip.optin.theText.text = "OPT-IN TO NEWSLETTER";
			}
		}
		
		
		private function submit(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.lname.theText.text == "" || clip.lname.theText.text == "LAST NAME" || clip.fname.theText.text == "" || clip.fname.theText.text == "FIRST NAME" || clip.email.theText.text == "" || clip.email.theText.text == "EMAIL@ADDRESS.COM" || clip.zip.theText.text == ""  || clip.zip.theText.text == "ZIP CODE") {
				error("All fields are required.");
			}else{
			
				if (Validator.isValidEmail(clip.email.theText.text)) {
					
					if (clip.zip.theText.text.length != 5) {
						error("Please enter a valid zip code.");
					}else{					
						dispatchEvent(new Event(COMPLETE));
					}
					
				}else {
					error("Please enter a valid email address.");
				}
			}
		}
		
		/**
		 * Called from Main.formComplete()
		 * returns the userData
		 */
		public function get data():Object
		{
			var o:Object = { };
			o.fname = clip.fname.theText.text;
			o.lname = clip.lname.theText.text;
			o.email = clip.email.theText.text;
			o.zipcode = clip.zip.theText.text;
			o.optin = opt ? "true" : "false";
			return o;
		}
		
		
		/**
		 * Shows the message in the Enter your information below text
		 * turns it red, fades it out, then shows enter your info again...
		 * @param	m
		 */
		private function error(m:String):void
		{
			clip.textEnter.theText.text = m;
			TweenMax.to(clip.textEnter.theText, 0, { tint:0xEE2E24 } );
			clip.textEnter.alpha = 1;
			TweenMax.to(clip.textEnter, 1, { alpha:0, delay:2, onComplete:errorDone } );
		}
		
		
		private function errorDone():void
		{
			TweenMax.to(clip.textEnter.theText, 0, { tint:0xFFFFFF } );
			clip.textEnter.theText.text = "Enter your information below.";
			TweenMax.to(clip.textEnter, .3, { alpha:1 } );
		}
		
	}
	
}