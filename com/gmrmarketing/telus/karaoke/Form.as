package com.gmrmarketing.telus.karaoke
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.GUID;
	
	
	public class Form extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const SHOW_PRIVACY:String = "showPrivacy";
		public static const RESTART:String = "restart";
		public static const NO_PRIVACY:String = "noPrivacy";
		public static const BLANK_FIELDS:String = "blankFields";
		public static const BAD_EMAIL:String = "badEmail";
		public static const FORM_GOOD:String = "formGood";		
		
		private var clip:MovieClip;
		private var guid:String;
		
		private var kbd:KeyBoard;
		private var container:DisplayObjectContainer;
		
		
		public function Form()
		{
			clip = new mcForm(); //lib clip
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KEYFILE_LOADED, kbdInit, false, 0, true);
			kbd.loadKeyFile("telus_keyboard.xml");
		}
		
		
		private function kbdInit(e:Event):void
		{
			kbd.removeEventListener(KeyBoard.KEYFILE_LOADED, kbdInit);
			clip.addChild(kbd);
			kbd.x = 450;
			kbd.y = 655;
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
			clip.song.text = "";
			guid = "";
			
			clip.alpha = 0;
			clip.theCheck.gotoAndStop(1); //unchecked
			clip.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck, false, 0, true);
			clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, showPrivacy, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, submitForm, false, 0, true);
			clip.btnRestart.addEventListener(MouseEvent.MOUSE_DOWN, doRestart, false, 0, true);
			
			kbd.setFocusFields([clip.fname, clip.lname, clip.email, clip.song]);
			TweenMax.to(clip, 1, { alpha:1, onComplete:formShowing } );
		}
		
		
		public function hide():void
		{
			clip.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleCheck);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, showPrivacy);
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
		
		
		private function toggleCheck(e:MouseEvent):void
		{
			if (clip.theCheck.currentFrame == 1) {
				clip.theCheck.gotoAndStop(2);
			}else {
				clip.theCheck.gotoAndStop(1);
			}
		}
		
		
		private function showPrivacy(e:MouseEvent):void
		{
			dispatchEvent(new Event(SHOW_PRIVACY));
		}
		
		
		private function doRestart(e:MouseEvent):void
		{
			dispatchEvent(new Event(RESTART));
		}
		
		
		private function submitForm(e:MouseEvent):void
		{
			if (clip.theCheck.currentFrame == 2) {
				if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "" || clip.song.text == "") {
					dispatchEvent(new Event(BLANK_FIELDS));
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
				//didn't check privacy
				dispatchEvent(new Event(NO_PRIVACY));
			}
		}
		
		
		public function getData():Object
		{
			var formData:Object = { };
			formData.fname = clip.fname.text;
			formData.lname = clip.lname.text;
			formData.email = clip.email.text;
			formData.song = clip.song.text;
			formData.guid = guid;
			return formData;
		}
		
	}
	
}