package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import flash.text.TextField;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Email extends EventDispatcher
	{
		public static const COMPLETE:String = "emailComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbd:KeyBoard;		
		private var tim:TimeoutHelper;
		
		public function Email()
		{
			clip = new mcEmail();
			kbd = new KeyBoard();
			kbd.loadKeyFile("keyboard.xml");
			kbd.x = 50;
			kbd.y = 1090;// 600;
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns an object with these properties:
		 * fname,lname,email,member,opt1
		 * property values are all strings
		 */
		public function get data():Object
		{
			var p:Object = {};
			p.fname = clip.fname.theText.text;
			p.lname = clip.lname.theText.text;
			p.email = clip.email.theText.text;
			p.member = clip.g1Member.checkYes.currentFrame == 2 ? "yes" : "no";
			p.opt1 = clip.opt1.check.currentFrame == 2 ? "yes" : "no";
			return p;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			if (!myContainer.contains(kbd)){
				myContainer.addChild(kbd);
			}
			clip.title.x = 1920;
			clip.subTitle.alpha = 1;
			clip.subTitle.x = 1920;
			clip.fname.x = 1920;
			clip.lname.x = 1920;
			clip.email.x = 1920;
			clip.g1Member.x = 1920;
			clip.error.alpha = 0;
			clip.g1Member.checkYes.gotoAndStop(1);
			clip.g1Member.checkNo.gotoAndStop(1);
			clip.opt1.x = 1920;
			clip.opt1.check.gotoAndStop(1);
			
			clip.fname.theLabel.text = "FIRST NAME";			
			clip.lname.theLabel.text = "LAST NAME";
			clip.email.theLabel.text = "EMAIL";
			
			clip.fname.theText.text = "";			
			clip.lname.theText.text = "";
			clip.email.theText.text = "";
			
			kbd.setFocusFields([[clip.fname.theText, 0], [clip.lname.theText, 0], [clip.email.theText, 0]]);				
			
			
			TweenMax.to(clip.title, .5, {x:146, ease:Expo.easeOut, delay:.4});//wait for previous screen to hide
			TweenMax.to(clip.subTitle, .5, {x:150, ease:Expo.easeOut, delay:.5});	
			TweenMax.to(clip.fname, .5, {x:154, ease:Expo.easeOut, delay:.6});
			TweenMax.to(clip.lname, .5, {x:932, ease:Expo.easeOut, delay:.6});
			TweenMax.to(clip.email, .5, {x:154, ease:Expo.easeOut, delay:.7});
			TweenMax.to(clip.g1Member, .5, {x:936, ease:Expo.easeOut, delay:.7});
			TweenMax.to(clip.opt1, .5, {x:154, ease:Expo.easeOut, delay:.8, onComplete:showKeyboard});
		}
		
		
		public function hide():void
		{
			clip.removeEventListener(Event.ENTER_FRAME, focusCheck);
			
			TweenMax.to(clip.title, .5, {x: -1500, ease:Expo.easeIn});
			TweenMax.to(clip.subTitle, .5, {x:-1500, ease:Expo.easeIn});	
			TweenMax.to(clip.fname, .5, {x:-1500, ease:Expo.easeIn, delay:.1});
			TweenMax.to(clip.lname, .5, {x:-1500, ease:Expo.easeIn, delay:.1});
			TweenMax.to(clip.email, .5, {x:-1500, ease:Expo.easeIn, delay:.2});
			TweenMax.to(clip.g1Member, .5, {x:-1500, ease:Expo.easeIn, delay:.2});
			TweenMax.to(clip.opt1, .5, {x:-1500, ease:Expo.easeIn, delay:.3});
			TweenMax.to(kbd, .5, {y:1080, ease:Expo.easeIn, delay:.3, onComplete:kill});
			
		}
		
		
		public function kill():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(kbd)){
				myContainer.removeChild(kbd);
			}
			clip.removeEventListener(Event.ENTER_FRAME, focusCheck);
			kbd.disableKeyboard();
		}
		
		
		private function showKeyboard():void
		{
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			kbd.enableKeyboard();
			kbd.setFocus( -1);
			TweenMax.to(kbd, .5, {y:600, ease:Expo.easeOut});
			clip.addEventListener(Event.ENTER_FRAME, focusCheck, false, 0, true);
			clip.opt1.addEventListener(MouseEvent.MOUSE_DOWN, opt1Toggle, false, 0, true);
			clip.g1Member.clickYes.addEventListener(MouseEvent.MOUSE_DOWN, memberYes, false, 0, true);
			clip.g1Member.clickNo.addEventListener(MouseEvent.MOUSE_DOWN, memberNo, false, 0, true);			
		}
		
		
		private function opt1Toggle(e:MouseEvent):void
		{
			if (clip.opt1.check.currentFrame == 1){
				clip.opt1.check.gotoAndStop(2);
			}else{
				clip.opt1.check.gotoAndStop(1);
			}
		}
		private function memberYes(e:MouseEvent):void
		{
			clip.g1Member.checkYes.gotoAndStop(2);
			clip.g1Member.checkNo.gotoAndStop(1);
		}
		private function memberNo(e:MouseEvent):void
		{
			clip.g1Member.checkYes.gotoAndStop(1);
			clip.g1Member.checkNo.gotoAndStop(2);
		}
		
		
		/**
		 * resets the timeout handler whenever a key is pressed
		 * @param	e
		 */
		private function keyPressed(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		public function submitPressed(e:Event = null):void
		{
			if (Validator.isValidEmail(clip.email.theText.text)){
				dispatchEvent(new Event(COMPLETE));
			}else{
				TweenMax.killTweensOf(clip.error);
				TweenMax.killTweensOf(clip.subTitle);
				clip.subTitle.alpha = 0;
				clip.error.alpha = 1;
				clip.error.theText.text = "Please enter a valid email address!";
				TweenMax.to(clip.error, 1, {alpha:0, delay:2, onComplete:resetError});
			}
		}
		
		private function resetError():void
		{
			TweenMax.to(clip.subTitle, .5, {alpha:1});
			clip.error.alpha = 0;
		}
		
		
		private function focusCheck(e:Event):void
		{
			if (clip.stage.focus == clip.fname.theText){
				clip.fname.theLabel.text = "";				
			}
			if (clip.stage.focus != clip.fname.theText){
				if (clip.fname.theText.text == ""){
					clip.fname.theLabel.text = "FIRST NAME";
				}
			}
			if (clip.stage.focus == clip.lname.theText){
				clip.lname.theLabel.text = "";				
			}
			if (clip.stage.focus != clip.lname.theText){
				if (clip.lname.theText.text == ""){
					clip.lname.theLabel.text = "LAST NAME";
				}
			}
			if (clip.stage.focus == clip.email.theText){
				clip.email.theLabel.text = "";		
			}
			if (clip.stage.focus != clip.email.theText){
				if (clip.email.theText.text == ""){
					clip.email.theLabel.text = "EMAIL";
				}
			}
		}
		

	}
	
}