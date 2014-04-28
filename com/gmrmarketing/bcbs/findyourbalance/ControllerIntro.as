/**
 * Form data collection
 */
package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.display.*;
	import flash.events.*;	
	import com.gmrmarketing.intel.girls20.ComboBox;
	import com.gmrmarketing.utilities.US_StateList;
	import com.gmrmarketing.utilities.Validator;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class ControllerIntro extends EventDispatcher
	{
		public static const START:String = "startPressed";
		public static const REQUIRED:String = "fieldsRequired";
		public static const EMAIL:String = "badEmail";
		public static const PHONE:String = "badPhone";
		public static const RULES:String = "rulesNotChecked";
		public static const STATE:String = "noState";
		public static const SHOW_RULES:String = "showTheRules";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var statesDropdown:ComboBox;
		private var kbd:KeyBoard;
		private var kSound:Sound;
		private var chan:SoundChannel;
		private var vol:SoundTransform;
		
		public function ControllerIntro()
		{
			clip = new mcIntro();//lib clip			
			statesDropdown = new ComboBox("Select State");			
			statesDropdown.populate(US_StateList.getStates());
			clip.addChild(statesDropdown);
			statesDropdown.x = 206;
			statesDropdown.y = 416;
			
			kbd = new KeyBoard();
			kbd.addEventListener(KeyBoard.KEYFILE_LOADED, kbdInit, false, 0, true);
			kbd.loadKeyFile("android_1280x400.xml");
			
			kSound = new soundKbd();
		}
		
		
		private function kbdInit(e:Event):void
		{
			/*
			if (!container.contains(kbd)) {
				container.addChild(kbd);
			}
			*/
			kbd.x = 0;
			kbd.y = 388;
			kbd.setFocusFields([clip.fname, clip.lname, clip.email, clip.phone]);			
			kbd.addEventListener(KeyBoard.KBD, kbdSound, false, 0, true);
		}
		
		
		private function kbdSound(e:Event):void
		{
			vol = new SoundTransform(.2);		
			chan = kSound.play();
			chan.soundTransform = vol;
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
			
			statesDropdown.setSelection("");
			statesDropdown.reset();			
			
			clip.fname.text = "";
			clip.lname.text = "";
			clip.email.text = "";
			clip.phone.text = "";			
			
			clip.fname.maxChars = 25;
			clip.lname.maxChars = 1;//just last initial
			clip.email.maxChars = 35;			
			
			clip.phone.restrict = "-0-9";
			clip.phone.maxChars = 12;
			
			clip.check.gotoAndStop(1);//reset rules check
			
			clip.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, startClicked, false, 0, true);
			clip.btnCheck.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRulesClicked, false, 0, true);
			
			clip.kbdOpen1.addEventListener(MouseEvent.MOUSE_DOWN, openKbd1, false, 0, true);
			clip.kbdOpen2.addEventListener(MouseEvent.MOUSE_DOWN, openKbd2, false, 0, true);
			clip.kbdOpen3.addEventListener(MouseEvent.MOUSE_DOWN, openKbd3, false, 0, true);
			clip.kbdOpen4.addEventListener(MouseEvent.MOUSE_DOWN, openKbd4, false, 0, true);
			clip.kbdClose.addEventListener(MouseEvent.MOUSE_DOWN, closeKbd, false, 0, true);
		}
		
		private function openKbd1(e:MouseEvent):void
		{
			if (!container.contains(kbd)) {
				container.addChild(kbd);
			}
			kbd.setFocus(0, e.stageX, e.stageY);
		}
		private function openKbd2(e:MouseEvent):void
		{
			if (!container.contains(kbd)) {
				container.addChild(kbd);
			}
			kbd.setFocus(1, e.stageX, e.stageY);
		}
		private function openKbd3(e:MouseEvent):void
		{
			if (!container.contains(kbd)) {
				container.addChild(kbd);
			}
			kbd.setFocus(2, e.stageX, e.stageY);
		}
		private function openKbd4(e:MouseEvent):void
		{
			if (!container.contains(kbd)) {
				container.addChild(kbd);
			}
			kbd.setFocus(3, e.stageX, e.stageY);
		}
		private function closeKbd(e:MouseEvent = null):void
		{
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
		}
		
		
		public function hide():void
		{
			closeKbd();
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, startClicked);
			clip.btnCheck.removeEventListener(MouseEvent.MOUSE_DOWN, checkClicked);
			clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, showRulesClicked);			
		}
		
		
		/**
		 * called from ControllerMain.sweepsDone()
		 * @return
		 */
		public function getData():Array
		{			
			return new Array(clip.fname.text, clip.lname.text, clip.email.text, clip.phone.text, statesDropdown.getSelection());			
		}
		
		
		private function startClicked(e:MouseEvent):void
		{
			if (clip.fname.text == "" || clip.lname.text == "" || clip.email.text == "" || clip.phone.text == "") {
				dispatchEvent(new Event(REQUIRED));
			}else if (!Validator.isValidEmail(clip.email.text)) {
				dispatchEvent(new Event(EMAIL));
			}else if (!Validator.isValidPhoneNumber(clip.phone.text)) {
				dispatchEvent(new Event(PHONE));			
			}else if (statesDropdown.getSelection() == "" || statesDropdown.getSelection() == statesDropdown.getResetMessage()) {
				dispatchEvent(new Event(STATE));
			}else if (clip.check.currentFrame == 1) {
				dispatchEvent(new Event(RULES));
			}else{
				dispatchEvent(new Event(START));
			}
		}
		
		
		private function checkClicked(e:MouseEvent):void
		{
			if (clip.check.currentFrame == 1) {
				clip.check.gotoAndStop(2);
			}else {
				clip.check.gotoAndStop(1);
			}
		}
		
		
		private function showRulesClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(SHOW_RULES));
		}
		
	}
	
}