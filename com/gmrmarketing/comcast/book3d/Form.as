package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;	
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Validator;
	
	
	public class Form extends EventDispatcher
	{
		public static const COMPLETE:String = "formComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var kbd:KeyBoard;
		
		public function Form()
		{
			clip = new mcForm();
			
			kbd = new KeyBoard();			
			kbd.loadKeyFile("keyboard.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get userData():Object
		{
			var u:Object = { };
			
			u.firstName = clip.fname.text;
			u.lastName = clip.lname.text;
			u.Email = clip.email.text;
			u.PhoneNumber = clip.phone.text;
			u.Agree = true;
			u.OptIn = clip.checkAdditional.currentFrame == 2 ? true : false;
			
			return u;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.fname.text = "";
			clip.lname.text = "";
			clip.email.text = "";
			clip.phone.text = "";
			
			clip.phone.restrict = "-0-9";
			
			clip.checkRules.gotoAndStop(1);
			clip.checkAdditional.gotoAndStop(1);
			
			kbd.x = 70;
			kbd.y = 435;
			if(!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
			}
			
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, formSubmit, false, 0, true);
			clip.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, toggleRulesCheck, false, 0, true);
			clip.btnAdditional.addEventListener(MouseEvent.MOUSE_DOWN, toggleAdditionalCheck, false, 0, true);
			
			//kbd.addEventListener(KeyBoard.KBD, resetTimeout, false, 0, true);
			kbd.setFocusFields([[clip.fname, 20], [clip.lname, 20], [clip.email, 20], [clip.phone, 12]]);
			
			clip.w1.scaleX = 0;
			clip.w2.scaleX = 0;
			clip.w3.scaleX = 0;
			clip.w4.scaleX = 0;
			clip.fieldTitles.alpha = 0;
			clip.btnSubmit.scaleX = 0;
			clip.title.alpha = 0;
			clip.title.y += 50;
			clip.checkRules.alpha = 0;
			clip.checkAdditional.alpha = 0;
			clip.checkText.alpha = 0;
			kbd.alpha = 0;
			kbd.y += 50;
			clip.kbdBG.alpha = 0;
			
			TweenMax.to(clip.w1, .5, { scaleX:1, ease:Back.easeOut } );
			TweenMax.to(clip.w2, .5, { scaleX:1, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.w3, .5, { scaleX:1, delay:.2, ease:Back.easeOut } );
			TweenMax.to(clip.w4, .5, { scaleX:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.fieldTitles, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.checkRules, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.checkAdditional, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.checkText, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.btnSubmit, .5, { scaleX:1, delay:.5, ease:Back.easeOut } );
			TweenMax.to(clip.title, .5, { y:"-50", alpha:1, delay:.8 } );
			TweenMax.to(kbd, 1, { alpha:1, y:"-50", delay:1.2 } );
			TweenMax.to(clip.kbdBG, 1, { alpha:1, delay:1.2 } );
		}
		
		
		private function formSubmit(e:MouseEvent):void
		{		
			//validation
			if (clip.fname.text != "" && clip.lname.text != "" && clip.email.text != "" && clip.phone.text != "") {
				if (Validator.isValidEmail(clip.email.text)) {
					if (Validator.isValidPhoneNumber(clip.phone.text)) {
						if (clip.checkRules.currentFrame == 2) {
							clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, formSubmit);
							clip.btnRules.removeEventListener(MouseEvent.MOUSE_DOWN, toggleRulesCheck);
							clip.btnAdditional.removeEventListener(MouseEvent.MOUSE_DOWN, toggleAdditionalCheck);
							dispatchEvent(new Event(COMPLETE));
						}else {
							message("You Must Accept the Official Rules");
						}
					}else {
						message("Please Enter a Valid Phone Number");
					}
				}else {
					message("Please Enter a Valid Email");
				}
			}else {
				message("All Fields Are Required");
			}
		}
		
		
		public function hide():void		
		{
			if(myContainer.contains(kbd)){
				myContainer.removeChild(kbd);
			}
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function toggleRulesCheck(e:MouseEvent):void
		{
			if (clip.checkRules.currentFrame == 1) {
				clip.checkRules.gotoAndStop(2);
			}else {
				clip.checkRules.gotoAndStop(1);
			}
		}
		
		private function toggleAdditionalCheck(e:MouseEvent):void
		{
			if (clip.checkAdditional.currentFrame == 1) {
				clip.checkAdditional.gotoAndStop(2);
			}else {
				clip.checkAdditional.gotoAndStop(1);
			}
		}
		
		
		private function message(s:String):void
		{
			clip.title.theTitle.text = s;
			clip.title.alpha = 1;
			TweenMax.killTweensOf(clip.title);
			TweenMax.to(clip.title, 2, { alpha:0, delay:2, onComplete:resetTitle } );
		}
		
		
		private function resetTitle():void
		{
			clip.title.theTitle.text = "A Few Questions to Test You";
			TweenMax.to(clip.title, .5, { alpha:1 } );
		}
	}
	
}