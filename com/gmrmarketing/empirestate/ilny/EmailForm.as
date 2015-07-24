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
			kbdBG.graphics.beginFill(0xFF000000, 1);
			kbdBG.graphics.drawRect(0, 0, 1920, 477);
			kbdBG.graphics.endFill();
			//kbdBG.x = 0;
			//kbdBG.y = 1443;//screen bottom
			
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
			clip.theForm.textEnter.alpha = 0;
			clip.theForm.textEnter.theText.text = "Enter your information below.";
			clip.theForm.fname.scaleX = clip.theForm.fname.scaleY = 0;
			clip.theForm.lname.scaleX = clip.theForm.lname.scaleY = 0;
			clip.theForm.email.scaleX = clip.theForm.email.scaleY = 0;
			clip.theForm.zip.scaleX = clip.theForm.zip.scaleY = 0;
			clip.theForm.heart.alpha = 0;
			TweenMax.to(clip.theForm.heart, 0, { colorMatrixFilter: { saturation:0 }} );//gray
			clip.theForm.optin.alpha = 0;
			clip.theForm.optin.theText.text = "OPT-IN TO NEWSLETTER";
			//clip.theForm.btnSend.y = 1080;//915
			
			TweenMax.to(clip.theForm.textEnter, .5, { alpha:1 } );
			TweenMax.to(clip.theForm.fname, .5, { scaleX:1, scaleY:1, delay:.6 } );
			TweenMax.to(clip.theForm.lname, .5, { scaleX:1, scaleY:1, delay:.8 } );
			TweenMax.to(clip.theForm.email, .5, { scaleX:1, scaleY:1, delay:1 } );
			TweenMax.to(clip.theForm.zip, .5, { scaleX:1, scaleY:1, delay:1.2 } );
			
			TweenMax.to(clip.theForm.heart, .5, { alpha:1, delay:1.3 } );
			TweenMax.to(clip.theForm.optin, .5, { alpha:1, delay:1.3 } );
			
			//TweenMax.to(clip.theForm.btnSend, .5, { y:915, delay:1.5, ease:Back.easeOut } );
			
			clip.theForm.btnOptin.addEventListener(MouseEvent.MOUSE_DOWN, optin);
			clip.theForm.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, submit);
			clip.theForm.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backToMap);
			
			clip.theForm.fname.theText.text = "FIRST NAME";
			clip.theForm.lname.theText.text = "LAST NAME";
			clip.theForm.email.theText.text = "EMAIL@ADDRESS.COM";
			clip.theForm.zip.theText.text = "ZIP CODE";
			clip.theForm.zip.theText.restrict = "0-9";
			
			clip.theForm.fname.addEventListener(MouseEvent.MOUSE_DOWN, clearFname);
			clip.theForm.fname.addEventListener(FocusEvent.FOCUS_IN, clearFname);
			clip.theForm.lname.addEventListener(MouseEvent.MOUSE_DOWN, clearLname);
			clip.theForm.lname.addEventListener(FocusEvent.FOCUS_IN, clearLname);
			clip.theForm.email.addEventListener(MouseEvent.MOUSE_DOWN, clearEmail);
			clip.theForm.email.addEventListener(FocusEvent.FOCUS_IN, clearEmail);
			clip.theForm.zip.addEventListener(MouseEvent.MOUSE_DOWN, clearZip);
			clip.theForm.zip.addEventListener(FocusEvent.FOCUS_IN, clearZip);
			
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
			
			if(clip.theForm.fname.theText.text == "FIRST NAME"){
				clip.theForm.fname.theText.text = "";
			}
			
			if (clip.theForm.lname.theText.text == "") {
				clip.theForm.lname.theText.text = "LAST NAME";
			}
			if (clip.theForm.email.theText.text == "") {
				clip.theForm.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.theForm.zip.theText.text == "") {
				clip.theForm.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearLname(e:Event):void
		{
			showKeyboard();
			
			if(clip.theForm.lname.theText.text == "LAST NAME"){
				clip.theForm.lname.theText.text = "";
			}
			
			if (clip.theForm.fname.theText.text == "") {
				clip.theForm.fname.theText.text = "FIRST NAME";
			}
			if (clip.theForm.email.theText.text == "") {
				clip.theForm.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.theForm.zip.theText.text == "") {
				clip.theForm.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearEmail(e:Event):void
		{
			showKeyboard();
			
			if(clip.theForm.email.theText.text == "EMAIL@ADDRESS.COM"){
				clip.theForm.email.theText.text = "";
			}
			
			if (clip.theForm.lname.theText.text == "") {
				clip.theForm.lname.theText.text = "LAST NAME";
			}
			if (clip.theForm.fname.theText.text == "") {
				clip.theForm.fname.theText.text = "FIRST NAME";
			}
			if (clip.theForm.zip.theText.text == "") {
				clip.theForm.zip.theText.text = "ZIP CODE";
			}
		}
		
		
		private function clearZip(e:Event):void
		{
			showKeyboard();
			
			if(clip.theForm.zip.theText.text == "ZIP CODE"){
				clip.theForm.zip.theText.text = "";
			}
			
			if (clip.theForm.lname.theText.text == "") {
				clip.theForm.lname.theText.text = "LAST NAME";
			}
			if (clip.theForm.email.theText.text == "") {
				clip.theForm.email.theText.text = "EMAIL@ADDRESS.COM";
			}
			if (clip.theForm.fname.theText.text == "") {
				clip.theForm.fname.theText.text = "FIRST NAME";
			}
		}
		
		public function hide():void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
			TweenMax.to(kbd, .5, { alpha:0 } );
			TweenMax.to(kbdBG, .5, { alpha:0 } );
		}
		private function kill():void
		{
			clip.theForm.y = 373;
			clip.topBar.y = 0;
			clip.logo.y = 162;
			clip.logo.scaleX = clip.logo.scaleY = 1;
			
			clip.theForm.btnOptin.removeEventListener(MouseEvent.MOUSE_DOWN, optin);
			clip.theForm.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, submit);
			clip.theForm.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backToMap);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(kbd)) {
				myContainer.removeChild(kbd);
				myContainer.removeChild(kbdBG);
			}
			clip.theForm.fname.removeEventListener(MouseEvent.MOUSE_DOWN, clearFname);
			clip.theForm.fname.removeEventListener(FocusEvent.FOCUS_IN, clearFname);
			clip.theForm.lname.removeEventListener(MouseEvent.MOUSE_DOWN, clearLname);
			clip.theForm.lname.removeEventListener(FocusEvent.FOCUS_IN, clearLname);
			clip.theForm.email.removeEventListener(MouseEvent.MOUSE_DOWN, clearEmail);
			clip.theForm.email.removeEventListener(FocusEvent.FOCUS_IN, clearEmail);
			clip.theForm.zip.removeEventListener(MouseEvent.MOUSE_DOWN, clearZip);
			clip.theForm.zip.removeEventListener(FocusEvent.FOCUS_IN, clearZip);
			
			kbdShowing = false;
			kbd.removeEventListener(KeyBoard.KBD, resetTim);
		}
		
		
		private function showKeyboard():void
		{
			tim.buttonClicked();
			
			if (!kbdShowing) {
				
				TweenMax.to(clip.theForm, .5, {y:-37});//373
				TweenMax.to(clip.topBar, .5, {y:-180});//0
				TweenMax.to(clip.logo, .5, {scaleX:.5, scaleY:.5, y:68});//y:162
				
				kbdShowing = true;
				myContainer.addChild(kbdBG);
				kbd.alpha = 1;
				kbdBG.alpha = 0;
				kbdBG.y = 623;
				
				myContainer.addChild(kbd);
				kbd.x = 229;
				kbd.y = 1080 + kbd.height;
				kbd.setFocusFields([[clip.theForm.fname.theText, 0], [clip.theForm.lname.theText, 0], [clip.theForm.email.theText, 0], [clip.theForm.zip.theText, 5]]);
				kbd.addEventListener(KeyBoard.KBD, resetTim, false, 0, true);
				
				TweenMax.to(kbdBG, .3, { alpha:.85 } );				
				
				TweenMax.to(kbd, .5, { y:636 } );
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
				TweenMax.to(clip.theForm.heart, 0, { colorMatrixFilter: { saturation:1 }} );//red
				clip.theForm.optin.theText.text = "YOU ARE OPTED-IN TO THE NEWSLETTER";
			}else {
				TweenMax.to(clip.theForm.heart, 0, { colorMatrixFilter: { saturation:0 }} );//gray
				clip.theForm.optin.theText.text = "OPT-IN TO NEWSLETTER";
			}
		}
		
		
		private function submit(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.theForm.lname.theText.text == "" || clip.theForm.lname.theText.text == "LAST NAME" || clip.theForm.fname.theText.text == "" || clip.theForm.fname.theText.text == "FIRST NAME" || clip.theForm.email.theText.text == "" || clip.theForm.email.theText.text == "EMAIL@ADDRESS.COM" || clip.theForm.zip.theText.text == ""  || clip.theForm.zip.theText.text == "ZIP CODE") {
				error("All fields are required.");
			}else{
			
				if (Validator.isValidEmail(clip.theForm.email.theText.text)) {
					
					if (clip.theForm.zip.theText.text.length != 5) {
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
			o.fname = clip.theForm.fname.theText.text;
			o.lname = clip.theForm.lname.theText.text;
			o.email = clip.theForm.email.theText.text;
			o.zipcode = clip.theForm.zip.theText.text;
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
			clip.theForm.textEnter.theText.text = m;
			TweenMax.to(clip.theForm.textEnter.theText, 0, { tint:0xEE2E24 } );
			clip.theForm.textEnter.alpha = 1;
			TweenMax.to(clip.theForm.textEnter, 1, { alpha:0, delay:2, onComplete:errorDone } );
		}
		
		
		private function errorDone():void
		{
			TweenMax.to(clip.theForm.textEnter.theText, 0, { tint:0xFFFFFF } );
			clip.theForm.textEnter.theText.text = "Enter your information below.";
			TweenMax.to(clip.theForm.textEnter, .3, { alpha:1 } );
		}
		
	}
	
}