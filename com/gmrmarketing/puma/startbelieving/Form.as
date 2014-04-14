package com.gmrmarketing.puma.startbelieving
{
	import flash.display.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;	
	import com.gmrmarketing.intel.girls20.ComboBox;
	import com.gmrmarketing.utilities.GUID;
	
	public class Form extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const SHOW_TERMS:String = "showTerms";
		public static const RESTART:String = "restart";
		public static const NO_TERMS:String = "noTerms";
		public static const BLANK_FIELDS:String = "blankFields";
		public static const BAD_EMAIL:String = "badEmail";
		public static const NO_GENDER:String = "noGender";
		public static const FORM_GOOD:String = "formGood";		
		
		private var clip:MovieClip;		
		private var gender:ComboBox;
		private var kbd:KeyBoard;
		private var container:DisplayObjectContainer;
		private var guid:String;
		
		public function Form()
		{
			clip = new mcForm(); //lib clip
			
			gender = new ComboBox("Select a gender");
			gender.populate(["Male","Female"]);
			clip.addChild(gender);
			gender.x = 979;
			gender.y = 442;
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KEYFILE_LOADED, kbdInit, false, 0, true);
			kbd.loadKeyFile("keyboard.xml");
		}
		
		
		private function kbdInit(e:Event):void
		{
			kbd.removeEventListener(KeyBoard.KEYFILE_LOADED, kbdInit);
			clip.addChild(kbd);
			kbd.x = 450;
			kbd.y = 700;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{	
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.fname.text = "";
			clip.lname.text = "";
			clip.email.text = "";
			guid = "";
			
			clip.fname.maxChars = 25;
			clip.lname.maxChars = 25;
			clip.email.maxChars = 32;
			
			clip.alpha = 0;
			gender.reset();//shows select gender message
			
			clip.checkNews.gotoAndStop(1); //unchecked
			clip.checkTerms.gotoAndStop(1); //unchecked
			clip.btnCheckNews.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheckNews, false, 0, true);
			clip.btnCheckTerms.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheckTerms, false, 0, true);
			
			clip.btnTerms.addEventListener(MouseEvent.MOUSE_DOWN, showTerms, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitForm, false, 0, true);
			clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doRestart, false, 0, true);
			
			kbd.setFocusFields([clip.fname, clip.lname, clip.email]);
			TweenMax.to(clip, 1, { alpha:1, onComplete:formShowing } );
		}
		
		
		public function hide():void
		{
			clip.btnCheckNews.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheckNews);
			clip.btnCheckTerms.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheckTerms);
			clip.btnTerms.removeEventListener(MouseEvent.MOUSE_DOWN, showTerms);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, submitForm);
			clip.btnRestart.removeEventListener(MouseEvent.MOUSE_DOWN, doRestart);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function formShowing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function toggleCheckNews(e:MouseEvent):void
		{
			if (clip.checkNews.currentFrame == 1) {
				clip.checkNews.gotoAndStop(2);
			}else {
				clip.checkNews.gotoAndStop(1);
			}
		}
		
		
		private function toggleCheckTerms(e:MouseEvent):void
		{
			if (clip.checkTerms.currentFrame == 1) {
				clip.checkTerms.gotoAndStop(2);
			}else {
				clip.checkTerms.gotoAndStop(1);
			}
		}
		
		
		private function showTerms(e:MouseEvent):void
		{
			dispatchEvent(new Event(SHOW_TERMS));
		}
		
		
		private function doRestart(e:MouseEvent):void
		{
			dispatchEvent(new Event(RESTART));
		}
		
		
		private function submitForm(e:MouseEvent):void
		{
			if (clip.checkTerms.currentFrame == 2) {
				if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "") {
					dispatchEvent(new Event(BLANK_FIELDS));
				}else if (gender.getSelection() == gender.getResetMessage()) {
					dispatchEvent(new Event(NO_GENDER));
				}else {
					if (!Validator.isValidEmail(clip.email.text)) {
						dispatchEvent(new Event(BAD_EMAIL));
					}else {
						//good to go
						guid = GUID.create();
						dispatchEvent(new Event(FORM_GOOD));
					}
				}
			}else {
				//didn't accept terms
				dispatchEvent(new Event(NO_TERMS));
			}
		}
		
		
		public function getData():Object
		{
			var formData:Object = { };
			formData.fname = clip.fname.text;
			formData.lname = clip.lname.text;
			formData.email = clip.email.text;
			formData.optin = clip.checkNews.currentFrame == 1 ? "false" : "true";
			formData.guid = guid;
			return formData;
		}
		
	}
	
}