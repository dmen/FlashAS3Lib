/**
 * Initial page after intro that contains
 * name fields and message field
 */

package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.SwearFilter;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.intel.girls20.ComboBox;
	
	
	public class TextEntry extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const NEXT:String = "nextPressed";
		public static const REQUIRED:String = "messageRequired";
		public static const PRIZE_REQUIRED:String = "prizeRequired";
		public static const PLEDGE_REQUIRED:String = "pledgeRequired";
		public static const NAME:String = "nameRequired";
		public static const SWEAR:String = "inappropriate";
		
		private const MAX_CHARS:int = 160;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var kbd:KeyBoard;		
		private var charCountTimer:Timer;
		private var pledgeCombo:ComboBox;//for pledge selection
		private var prizeCombo:ComboBox;//for prize selection
		private var timeoutHelper:TimeoutHelper;
		
		private var pledgeOptions:Array;
		private var prizeOptions:Array;
		
		
		public function TextEntry()
		{
			clip = new mcTextEntry();
			kbd = new KeyBoard();			 
			
			kbd.loadKeyFile("bcbs_photobooth.xml");
			
			clip.theText.text = "";
			clip.theCount.text = String(MAX_CHARS);
			
			charCountTimer = new Timer(200);
			charCountTimer.addEventListener(TimerEvent.TIMER, updateCharCount, false, 0, true);
			
			pledgeCombo = new ComboBox("Please select");			
			//pledgeCombo.populate();
			clip.addChild(pledgeCombo);
			pledgeCombo.x = 621;
			pledgeCombo.y = 615;	
			
			prizeCombo = new ComboBox("Please select");			
			//combo.populate();
			clip.addChild(prizeCombo);
			prizeCombo.x = 621;
			prizeCombo.y = 268;	
			
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * 
		 * @param	clearText
		 * @param	pledgeOptions Array of arrays - contains text and id in each item
		 */
		public function show(clearText:Boolean, $prizeOptions:Array, $pledgeOptions:Array):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			pledgeOptions = $pledgeOptions;
			prizeOptions = $prizeOptions;
			
			kbd.x = 525;
			kbd.y = 720;
			if(!clip.contains(kbd)){
				clip.addChildAt(kbd,1);
			}
			kbd.addEventListener(KeyBoard.KBD, resetTimeout, false, 0, true);
			kbd.setFocusFields([clip.fname, clip.lname, clip.theText]);
			
			container.addEventListener(KeyboardEvent.KEY_DOWN, hardKeyDown, false, 0, true);
			
			var items:Array = new Array();//need simple array of text values for comboBox
			for (var i:int = 0; i < pledgeOptions.length; i++) {
				items.push(pledgeOptions[i][0]);
			}
			
			if (clearText) {
				pledgeCombo.populate(items);
				pledgeCombo.setSelection("");
				pledgeCombo.reset();	
			}
			
			
			var prizes:Array = new Array();//need simple array of text values for comboBox
			for (i = 0; i < prizeOptions.length; i++) {				
				prizes.push(prizeOptions[i][0]);
			}
			
			if (clearText) {
				prizeCombo.populate(prizes);
				prizeCombo.setSelection("");
				prizeCombo.reset();	
			}			
			
			clip.fname.maxChars = 30;
			clip.lname.maxChars = 30;
			
			if (clearText) {
				clip.fname.text = "";
				clip.lname.text = "";
				clip.theText.text = "";
				clip.theCount.text = String(MAX_CHARS);			
			}else {
				clip.stage.focus = clip.theText;
			}
			
			clip.alpha = 0;
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
			
			charCountTimer.start();//call updateCharCount()
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		public function hide():void
		{
			charCountTimer.stop();
			kbd.removeEventListener(KeyBoard.KBD, resetTimeout);
			container.removeEventListener(KeyboardEvent.KEY_DOWN, hardKeyDown);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			if(clip.contains(kbd)){
				clip.removeChild(kbd);
			}
		}
		
		
		public function getMessage():String
		{
			return clip.theText.text;
		}
		
		
		public function getName():String
		{
			var fn:String = clip.fname.text;
			var ln:String = String(clip.lname.text).substr(0, 1);
			fn = fn.substr(0, 1).toUpperCase() + fn.substr(1);
			ln = ln.toUpperCase();
			return "- " + fn + " " + ln;
		}
		
		
		public function getData():Array
		{
			/*return new Array(clip.fname.text, clip.lname.text, combo.getSelection(), clip.theText.text);*/
			
			var pledgeSelectionText:String = pledgeCombo.getSelection();
			var cId:int;
			for (var i:int = 0; i < pledgeOptions.length; i++) {
				if (pledgeSelectionText == pledgeOptions[i][0]) {
					cId = pledgeOptions[i][1];
					break;
				}
			}
			
			var prizeSelectionText:String = prizeCombo.getSelection();
			var pId:int;
			for (i = 0; i < prizeOptions.length; i++) {
				if (prizeSelectionText == prizeOptions[i][0]) {
					pId = prizeOptions[i][1];
					break;
				}
			}
			
			return new Array(clip.fname.text, clip.lname.text, 0, clip.theText.text, pId.toString(), cId.toString());
		}
		
		
		/**
		 * Called when the Next button is pressed
		 * @param	e
		 */
		private function doNext(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			if (clip.fname.text == "" || clip.lname.text == "") {
				dispatchEvent(new Event(NAME));
			}else if (prizeCombo.getSelection() == prizeCombo.getResetMessage()) {
				dispatchEvent(new Event(PRIZE_REQUIRED));
			}else if (pledgeCombo.getSelection() == pledgeCombo.getResetMessage()) {
				dispatchEvent(new Event(PLEDGE_REQUIRED));
			}else if (clip.theText.length < 2) {
				dispatchEvent(new Event(REQUIRED));
			}else if (SwearFilter.isSwear(clip.theText.text)) {
				dispatchEvent(new Event(SWEAR));
			}else{
				dispatchEvent(new Event(NEXT));
			}
		}
		
		
		/**
		 * called whenever a software keyboard key is pressed
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
		
		
		private function updateCharCount(e:TimerEvent):void
		{
			var charsRemaining:int = MAX_CHARS - clip.theText.length;
			if (charsRemaining < 0) {
				charsRemaining = 0;
				clip.theText.text = String(clip.theText.text).substr(0, MAX_CHARS);
			}
			clip.theCount.text = String(charsRemaining);
		}
	}
	
}