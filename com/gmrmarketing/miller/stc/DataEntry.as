package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import flash.text.TextField;
	import com.gmrmarketing.utilities.AutoTab;
	
	
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
			kbd.loadKeyFile("kbd3.xml");			
			kbd.x = 320;
			kbd.y = 500;
			kbd.setFocusFields([[clip.bDay.theMonth,2], [clip.bDay.theDay,2], [clip.bDay.theYear,4], [clip.phone.p1,3], [clip.phone.p2,3], [clip.phone.p3,4], [clip.fname.theName,0]]);
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
			clip.kbdBG.alpha = 0;
			
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
			clip.fname.scaleX = 0;
			//clip.whiteLines.scaleY = 0;
			//clip.whiteLines.alpha = 1;
			
			clip.bDay.theMonth.text = "";
			clip.bDay.theDay.text = "";
			clip.bDay.theYear.text = "";
			
			clip.phone.p1.text = "";
			clip.phone.p2.text = "";
			clip.phone.p3.text = "";
			
			clip.fname.theName.text = "";
			
			clip.gender.male.gotoAndStop(1);
			clip.gender.female.gotoAndStop(1);
			
			TweenMax.to(clip.l1, .3, { x:607, ease:Back.easeOut } );
			TweenMax.to(clip.l2, .3, { x:430, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.l3, .3, { x:288, delay:.2, ease:Back.easeOut } );
			
			TweenMax.to(clip.r1, .3, { x:1384, ease:Back.easeOut } );
			TweenMax.to(clip.r2, .3, { x:1582, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.r3, .3, { x:1759, delay:.2, ease:Back.easeOut } );
			
			TweenMax.to(clip.bars, .3, { scaleX:1, scaleY:.2, ease:Back.easeOut } );
			TweenMax.to(clip.bars, .5, { scaleY:1, ease:Back.easeInOut, delay:.3 } );
			
			TweenMax.to(clip.getYour, .5, { scaleY:1, ease:Back.easeOut, delay:.8 } );
			TweenMax.to(clip.winOriginal, .5, { scaleX:1, ease:Back.easeOut, delay:.9 } );
			
			TweenMax.to(clip.bDay, .25, { scaleX:1, delay:1.4, ease:Back.easeOut } );
			TweenMax.to(clip.phone, .25, { scaleX:1, delay:1.5, ease:Back.easeOut } );
			TweenMax.to(clip.fname, .25, { scaleX:1, delay:1.6, ease:Back.easeOut } );
			TweenMax.to(clip.gender, .25, { scaleX:1, delay:1.7, ease:Back.easeOut } );
			TweenMax.to(clip.submit, .3, { scaleX:1, scaleY:1, delay:1.8, ease:Bounce.easeOut } );
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, showKBD);
		}
		
		
		public function hide():void
		{			
			clip.submit.addEventListener(MouseEvent.MOUSE_DOWN, checkForm);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			if(myContainer.contains(kbd)){
				myContainer.removeChild(kbd);				
			}
		}
		
		
		private function showKBD(e:MouseEvent = null):void
		{
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, showKBD);
			
			//TweenMax.to(clip.whiteLines, .75, { scaleY:1.3, alpha:0, ease:Back.easeOut } );
			if(!myContainer.contains(kbd)){
				myContainer.addChild(kbd);				
			}
			kbd.alpha = 0;
			kbd.setFocus(0);//set focus to first field in the list
			TweenMax.to(kbd, .3, { alpha:1, scaleY:1, ease:Back.easeOut} );
			TweenMax.to(clip.kbdBG, 1, { alpha:.9, delay:.2} );			
			
			clip.genderM.addEventListener(MouseEvent.MOUSE_DOWN, doMale);
			clip.genderF.addEventListener(MouseEvent.MOUSE_DOWN, doFemale);
			clip.submit.addEventListener(MouseEvent.MOUSE_DOWN, checkForm);
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
				sex = "M";
			}else if (clip.gender.female.currentFrame == 2) {
				sex = "F";
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
			}else if (clip.fname.theName.text == "") {
				clip.theError.text = "Please enter\na first name.";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, 1, { alpha:0, delay:2 } );
			}else {
				clip.theError.text = "Thanks!";
				clip.theError.alpha = 1;
				TweenMax.to(clip.theError, .5, { alpha:0, delay:.5, onComplete:dispatchComplete } );
			}			
		}
		
		public function get entryData():Object
		{
			var o:Object = { DOB:clip.bDay.theYear.text + "-" + clip.bDay.theMonth.text + "-" + clip.bDay.theDay.text };
			if (clip.gender.male.currentFrame == 2) {
				o.Gender = "M";
			}else {
				o.Gender = "F";
			}
			o.MobilePhone = clip.phone.p1.text + clip.phone.p2.text + clip.phone.p3.text;
			o.FirstName = clip.fname.theName.text;
			return o;
		}
		
		private function dispatchComplete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}