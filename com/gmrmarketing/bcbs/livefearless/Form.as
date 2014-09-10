package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.intel.girls20.ComboBox;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Form extends EventDispatcher
	{		
		public static const SHOWING:String = "formShowing";
		public static const SAVE:String = "doSave";
		public static const EMAIL:String = "badEmail";		
		public static const RULES:String = "noRulesChecked";
		public static const READ_RULES:String = "readRules";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var kbd:KeyBoard;
		private var combo:ComboBox;
		private var interestOptions:Array;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Form()
		{
			clip = new mcForm();
			
			kbd = new KeyBoard();			
			kbd.loadKeyFile("bcbs_photobooth.xml");
			
			
			combo = new ComboBox("Please select");			
			combo.populate(["Healthy Eating", "Healthy Lifestyle", "Healthcare", "Other"])
			clip.addChild(combo);
			combo.x = 977;
			combo.y = 358;
			combo.width = 480;			
			
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show($interestOptions:Array):void
		{
			interestOptions = $interestOptions;
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			kbd.x = 485;
			kbd.y = 700;
			if(!container.contains(kbd)){
				container.addChild(kbd);
			}
			kbd.addEventListener(KeyBoard.KBD, resetTimeout, false, 0, true);
			kbd.setFocusFields([clip.email]);
			
			container.addEventListener(KeyboardEvent.KEY_DOWN, hardKeyDown, false, 0, true);
			
			clip.email.text = "";			
			clip.email.maxChars = 35;
			
			clip.checkRules.gotoAndStop(1);//reset checks
			clip.checkPhoto.gotoAndStop(1);			
			clip.checkOptin.gotoAndStop(1);
			
			var items:Array = new Array();//need simple array of text values for comboBox
			for (var i:int = 0; i < interestOptions.length; i++) {
				items.push(interestOptions[i][0]);
			}
			combo.populate(items);
			combo.setSelection("");
			combo.reset();	
			
			clip.alpha = 0;
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, doSave, false, 0, true);
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, rulesClicked, false, 0, true);			
			clip.btnReadRules.addEventListener(MouseEvent.MOUSE_DOWN, readRulesClicked, false, 0, true);			
			//clip.btnReadRules2.addEventListener(MouseEvent.MOUSE_DOWN, readRulesClicked, false, 0, true);			
			clip.btnPhoto.addEventListener(MouseEvent.MOUSE_DOWN, photoClicked, false, 0, true);
			clip.btnOptin.addEventListener(MouseEvent.MOUSE_DOWN, optinClicked, false, 0, true);			
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
			kbd.removeEventListener(KeyBoard.KBD, resetTimeout);
			container.removeEventListener(KeyboardEvent.KEY_DOWN, hardKeyDown);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, rulesClicked);			
			clip.btnReadRules.removeEventListener(MouseEvent.MOUSE_DOWN, readRulesClicked);			
			//clip.btnReadRules2.removeEventListener(MouseEvent.MOUSE_DOWN, readRulesClicked);			
			clip.btnPhoto.removeEventListener(MouseEvent.MOUSE_DOWN, photoClicked);
			clip.btnOptin.removeEventListener(MouseEvent.MOUSE_DOWN, optinClicked);		
		}
		
		
		public function getData():Array
		{			
			var pho:String = clip.checkPhoto.currentFrame == 1 ? "false" : "true";
			var opt:String = clip.checkOptin.currentFrame == 1 ? "false" : "true";
			
			var selText:String = combo.getSelection();
			var cId:int;
			for (var i:int = 0; i < interestOptions.length; i++) {
				if (selText == interestOptions[i][0]) {
					cId = interestOptions[i][1];
					break;
				}
			}
			
			return new Array(clip.email.text, pho, opt, cId);			
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		/**
		 * called by clicking Save
		 * Validates form data
		 * @param	e
		 */
		private function doSave(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (!Validator.isValidEmail(clip.email.text)) {
				dispatchEvent(new Event(EMAIL));			
			}else if (clip.checkRules.currentFrame == 1) {
				dispatchEvent(new Event(RULES));			
			}else{
				dispatchEvent(new Event(SAVE));
			}
		}
		
		private function readRulesClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(READ_RULES));
		}
		
		private function rulesClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.checkRules.currentFrame == 1) {
				clip.checkRules.gotoAndStop(2);
			}else {
				clip.checkRules.gotoAndStop(1);
			}
		}
		
		private function photoClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.checkPhoto.currentFrame == 1) {
				clip.checkPhoto.gotoAndStop(2);
			}else {
				clip.checkPhoto.gotoAndStop(1);
			}
		}
		
		private function optinClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.checkOptin.currentFrame == 1) {
				clip.checkOptin.gotoAndStop(2);				
			}else {
				clip.checkOptin.gotoAndStop(1);				
			}
		}
		
		
		/**
		 * called whenever a keyboard key is pressed
		 * @param	e
		 */
		private function resetTimeout(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		/**
		 * called whenever a hardware keyboard key is pressed
		 * @param	e
		 */
		private function hardKeyDown(e:KeyboardEvent):void
		{
			timeoutHelper.buttonClicked();
		}
		
	}
	
}