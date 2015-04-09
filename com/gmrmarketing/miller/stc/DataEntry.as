package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.text.TextField;
	
	
	public class DataEntry extends EventDispatcher
	{
		public static const COMPLETE:String = "dataComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;
		
		
		public function DataEntry()
		{
			clip = new mcData();
			kbd = new KeyBoard();			
			kbd.loadKeyFile("numbers.xml");
			kbd.x = 420;
			kbd.y = 920;
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
			
			//kbd.addEventListener(KeyBoard.KBD, resetTimeout, false, 0, true);
			
			kbd.alpha = 0;
			kbd.scaleY = 0;
			
			clip.l3.x = -200;
			clip.l2.x = -200;
			clip.l1.x = -200;
			
			clip.r3.x = 2200;
			clip.r2.x = 2200;
			clip.r1.x = 2200;
			
			clip.theError.alpha = 0;
			
			clip.bars.scaleX = clip.bars.scaleY = 0;
			clip.getYour.scaleY = 0;//text between the bars
			clip.winOriginal.scaleX = 0;
			
			clip.bDay.scaleX = 0;
			clip.phone.scaleX = 0;
			clip.gender.scaleX = 0;
			clip.submit.scaleX = clip.submit.scaleY = 0;
			clip.whiteLines.scaleY = 0;
			clip.whiteLines.alpha = 1;
			
			clip.bDay.theMonth.text = "MM";
			clip.bDay.theDay.text = "DD";
			clip.bDay.theYear.text = "YYYY";
			clip.phone.p1.text = "";
			clip.phone.p2.text = "";
			clip.phone.p3.text = "";
			
			clip.gender.male.gotoAndStop(1);
			clip.gender.female.gotoAndStop(1);
			
			TweenMax.to(clip.l1, .3, { x:599, ease:Back.easeOut } );
			TweenMax.to(clip.l2, .3, { x:424, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.l3, .3, { x:290, delay:.2, ease:Back.easeOut } );
			
			TweenMax.to(clip.r1, .3, { x:1362, ease:Back.easeOut } );
			TweenMax.to(clip.r2, .3, { x:1560, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.r3, .3, { x:1736, delay:.2, ease:Back.easeOut } );
			
			TweenMax.to(clip.bars, .3, { scaleX:1, scaleY:.2, ease:Back.easeOut } );
			TweenMax.to(clip.bars, .5, { scaleY:1, ease:Back.easeInOut, delay:.3 } );
			
			TweenMax.to(clip.getYour, .5, { scaleY:1, ease:Back.easeOut, delay:.8 } );
			TweenMax.to(clip.winOriginal, .5, { scaleX:1, ease:Back.easeOut, delay:.9 } );
			
			TweenMax.to(clip.bDay, .25, { scaleX:1, delay:1.4, ease:Back.easeOut } );
			TweenMax.to(clip.phone, .25, { scaleX:1, delay:1.5, ease:Back.easeOut } );
			TweenMax.to(clip.gender, .25, { scaleX:1, delay:1.6, ease:Back.easeOut } );
			TweenMax.to(clip.submit, .3, { scaleX:1, scaleY:1, delay:1.7, ease:Bounce.easeOut, onComplete:showKBD } );
		}
		
		
		public function hide():void
		{
			myContainer.removeEventListener(Event.ENTER_FRAME, autoTab);
			clip.submit.addEventListener(MouseEvent.MOUSE_DOWN, checkForm);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if(myContainer.contains(kbd)){
				myContainer.removeChild(kbd);				
			}
			kbd.removeEventListener(KeyBoard.FOCUS_CHANGE, stopAutoTab);
		}
		
		
		private function showKBD():void
		{
			TweenMax.to(clip.whiteLines, .75, { scaleY:1.3, alpha:0, ease:Back.easeOut } );
			if(!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
				
			}
			kbd.alpha = 0;
			TweenMax.to(kbd, .3, { alpha:1, scaleY:1, ease:Back.easeOut, delay:.4 } );
			
			kbd.setFocusFields([clip.bDay.theMonth, clip.bDay.theDay, clip.bDay.theYear, clip.phone.p1, clip.phone.p2, clip.phone.p3], false);
			kbd.addEventListener(KeyBoard.FOCUS_CHANGE, checkFocus, false, 0, true);
			myContainer.addEventListener(Event.ENTER_FRAME, autoTab);
			
			clip.genderM.addEventListener(MouseEvent.MOUSE_DOWN, doMale);
			clip.genderF.addEventListener(MouseEvent.MOUSE_DOWN, doFemale);
			clip.submit.addEventListener(MouseEvent.MOUSE_DOWN, checkForm);
		}
		
		
		/**
		 * Called whenever the focus changes on one of the fields given to keyboard.setFocusFields
		 * Erases the default text in the birthday fields if one of those fields is pressed
		 * @param	e
		 */
		private function checkFocus(e:Event):void
		{	
			e.stopImmediatePropagation();
			var n:String = kbd.getFocus().name;
			
			if (n == "theMonth" || n == "theDay" || n == "theYear") {
				kbd.removeEventListener(KeyBoard.FOCUS_CHANGE, checkFocus);
				clip.bDay.theMonth.text = "";
				clip.bDay.theDay.text = "";
				clip.bDay.theYear.text = "";
				
				kbd.addEventListener(KeyBoard.FOCUS_CHANGE, stopAutoTab, false, 0, true);
			}
		}
		
		
		private function stopAutoTab(e:Event):void
		{			
			myContainer.removeEventListener(Event.ENTER_FRAME, autoTab);
		}
		
		
		/**
		 * Called on Enter_Frame
		 * @param	e
		 */
		private function autoTab(e:Event):void
		{
			var f:TextField = kbd.getFocus();
			
			if (f.name == "theMonth") {
				if (f.text.length == 2) {
					kbd.tabToNextField();
				}
			}
			if (f.name == "theDay") {
				if (f.text.length == 2) {
					kbd.tabToNextField();
				}
			}
			if (f.name == "theYear") {
				if (f.text.length == 4) {
					kbd.tabToNextField();
				}
			}
			if (f.name == "p1") {
				if (f.text.length == 3) {
					kbd.tabToNextField();
				}
			}
			if (f.name == "p2") {
				if (f.text.length == 3) {
					kbd.tabToNextField();
				}
			}
		}
		
		
		private function doMale(e:MouseEvent):void
		{
			clip.gender.male.gotoAndStop(2);
			clip.gender.female.gotoAndStop(1);
		}
		
		
		private function doFemale(e:MouseEvent):void
		{
			clip.gender.male.gotoAndStop(1);
			clip.gender.female.gotoAndStop(2);
		}
		
		
		private function checkForm(e:MouseEvent):void
		{			
			TweenMax.to(clip.submit, 0, {colorTransform:{tint:0xffffff, tintAmount:.9}});
			TweenMax.to(clip.submit, .75, {colorTransform:{tint:0xffffff, tintAmount:0}, delay:.2});
			
			var m:int = parseInt(clip.bDay.theMonth.text);
			var d:int = parseInt(clip.bDay.theDay.text);
			var y:int = parseInt(clip.bDay.theYear.text);
			
			var p1:String = clip.phone.p1.text;
			var p2:String = clip.phone.p2.text;
			var p3:String = clip.phone.p3.text;
			
			var sex:String = "";
			if (clip.gender.male.currentFrame == 2) {
				sex = "male";
			}else if (clip.gender.female.currentFrame == 2) {
				sex = "female";
			}
			
			var bday:Date = new Date(y, m-1, d);
			var now:Date = new Date();
			var age:int = now.fullYear - bday.fullYear;
			if(now.month < bday.month){
				age--;
			}
			if(now.month == bday.month){
				if(now.date < bday.date){
					age--;
				}
			}
			
			if (m < 1 || m > 12 || d < 1 || d > 31 || y < 1915 || y > 2015) {
				clip.theError.text = "Please enter a\nvalid birthday.";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
			}else if (p1.length != 3 || p2.length != 3 || p3.length != 4) {
				clip.theError.text = "Please enter a\nvalid phone number.";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
			}else if (sex == "") {
				clip.theError.text = "Please select\nyour gender.";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
			}else if (age < 21) {
				clip.theError.text = "You must be at least\n21 to participate.";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
			}else {
				clip.theError.text = "Thanks!";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, .5, { alpha:0, delay:.5, onComplete:dispatchComplete } );
			}			
		}
		
		
		private function dispatchComplete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}