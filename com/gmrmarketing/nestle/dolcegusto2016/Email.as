package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Email extends EventDispatcher
	{
		public static const COMPLETE:String = "emailComplete";
		public static const QUIT:String = "emailQuit";
		public static const PRIVACY:String = "privacyPressed";
		
		private var jsonAccept:URLRequestHeader;		
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var kbdContainer:DisplayObjectContainer;
		
		private var kbd:KeyBoard;		
		
		private var alreadyDidQuiz:Boolean;
		private var quizResult:String;
		
		private var timeoutHelper:TimeoutHelper;		
		
		
		public function Email()
		{
			clip = new mcEmail();
			kbd = new KeyBoard();
			timeoutHelper = TimeoutHelper.getInstance();
			jsonAccept = new URLRequestHeader("Accept", "application/json");
			kbd.loadKeyFile("nestleKBD.xml"); 
		}
		
		
		public function setContainer(c:DisplayObjectContainer, d:DisplayObjectContainer):void
		{
			myContainer = c;
			kbdContainer = d;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}			
			
			clip.theTitle.text = "LET'S GET STARTED";
			
			clip.theTitle.alpha = 1;
			clip.enterEmail.alpha = 1;
			clip.theEmail.alpha = 1;
			clip.grayBox.alpha = 1;
			clip.optCheck.alpha = 1;
			clip.optText.alpha = 1;
				
			clip.titleFname.alpha = 1;
			clip.theFname.alpha = 1;
			clip.grayBox1.alpha = 1;			
			
			//hide everything off screen right
			clip.theTitle.x = 2860;			
			clip.enterEmail.x = 2860;
			clip.theEmail.x = 2860;
			clip.theEmail.text = "";
			clip.grayBox.x = 2860;
			
			//name screen
			clip.titleFname.x = 2860;
			clip.theFname.x = 2860;
			clip.theFname.text = "";			
			clip.grayBox1.x = 2860;
			
			clip.optCheck.x = 2860;
			clip.optCheck.gotoAndStop(1);
			clip.optText.x = 2860;
			clip.btnPrivacy.x = 3824;
			
			clip.btnClose.alpha = 0;
			
			alreadyDidQuiz = false;			
			
			TweenMax.to(clip.theTitle, .4, {x:1130, ease:Back.easeOut});			
			TweenMax.to(clip.enterEmail, .4, {x:1130, ease:Back.easeOut, delay:.2});
			TweenMax.to(clip.grayBox, .4, {x:1130, ease:Back.easeOut, delay:.3});
			TweenMax.to(clip.theEmail, .4, {x:1164, ease:Back.easeOut, delay:.4});
			TweenMax.to(clip.optCheck, .4, {x:1130, ease:Back.easeOut, delay:.5});
			TweenMax.to(clip.optText, .4, {x:1242, ease:Back.easeOut, delay:.6});
			TweenMax.to(clip.btnPrivacy, .4, {x:2116, ease:Back.easeOut, delay:.6});
			TweenMax.to(clip.btnClose, .5, {alpha:1, delay:1});
			
			if(!kbdContainer.contains(kbd)){
				kbdContainer.addChild(kbd);
			}
			
			kbd.scaleX = kbd.scaleY = 1.45;
			kbd.x = 550;
			kbd.y = 1750;// 975;
			kbd.alpha = 0;
			//kbd.setFocusFields([[clip.theEmail, 0], [clip.theFname, 16], [clip.theLname, 16]]);
			kbd.setFocusFields([[clip.theEmail, 0], [clip.theFname, 16]]);
			kbd.enableKeyboard();
			
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.SUBMIT, validateEmail, false, 0, true);
			
			clip.optCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleOpt, false, 0, true);
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, quitPressed, false, 0, true);
			clip.btnPrivacy.addEventListener(MouseEvent.MOUSE_DOWN, privacyPressed, false, 0, true);
			
			TweenMax.to(kbd, .3, {alpha:1, y:1200, delay:.75, ease:Back.easeOut});
		}
		
		
		public function hide():void
		{			
			kbd.removeEventListener(KeyBoard.SUBMIT, validateEmail);
			kbd.removeEventListener(KeyBoard.SUBMIT, validateName);
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			clip.optCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleOpt);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, quitPressed);
			clip.btnPrivacy.removeEventListener(MouseEvent.MOUSE_DOWN, privacyPressed);
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			
			if (kbdContainer.contains(kbd)){
				kbdContainer.removeChild(kbd);
			}
		}
		
		
		private function doComplete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		private function privacyPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(PRIVACY));
		}
		
		/**
		 * called from emailChecked or validateName instead of dispatching COMPLETE
		 */
		private function animateHide():void
		{
			//kbd & title are always there
			TweenMax.to(kbd, .4, {alpha:0, y:"200", ease:Back.easeIn});
			TweenMax.to(clip.theTitle, .4, {alpha:0, y:"-100", ease:Back.easeIn, delay:.75, onComplete:doComplete});
			
			if (userDidQuiz){
				//email is showing				
				TweenMax.to(clip.enterEmail, .4, {alpha:0, delay:.2});
				TweenMax.to(clip.theEmail, .4, {alpha:0, delay:.3});
				TweenMax.to(clip.grayBox, .4, {alpha:0, delay:.3});
				TweenMax.to(clip.optCheck, .4, {alpha:0, delay:.4});
				TweenMax.to(clip.btnPrivacy, .4, {alpha:0, delay:.4});
				TweenMax.to(clip.optText, .4, {alpha:0, delay:.4});
				
			}else{
				//fname showing				
				TweenMax.to(clip.titleFname, .4, {alpha:0, delay:.2});
				TweenMax.to(clip.theFname, .4, {alpha:0, delay:.3});
				TweenMax.to(clip.grayBox1, .4, {alpha:0, delay:.3});				
			}
		}
		
		
		/**
		 * Returns true if the entered email was in the DB with a quiz result
		 */
		public function get userDidQuiz():Boolean
		{
			return alreadyDidQuiz;
		}
		
		
		/**
		 * Returns the user data object containing Email, FName, OptIn properties
		 * Sent to server once quiz has been completed
		 */
		public function get userData():Object
		{
			var opt:int = clip.optCheck.currentFrame == 1 ? 0 : 1;
			
			return {"Email":clip.theEmail.text, "FName":clip.theFname.text, "OptIn":opt};//"lname":clip.theLname.text, "optin":opt};
		}
		
		
		/**
		 * resets the timeout handler whenever a key is pressed
		 * @param	e
		 */
		private function keyPressed(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		/**
		 * called by pressingsubmit button on the keyboard - when email field is showing
		 * @param	e
		 */
		private function validateEmail(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			if (Validator.isValidEmail(clip.theEmail.text)){
				
				//check email against service
				checkEmail();
				//emailChecked();
				
			}else{
				clip.enterEmail.text = "Please enter a valid email address";
				TweenMax.to(clip.enterEmail, 1, {alpha:0, delay:1, onComplete:resetEnterText});				
			}
		}
		
		
		private function resetEnterText():void
		{
			clip.enterEmail.text = "Enter your email to get started";
			clip.enterEmail.alpha = 1;
		}
		
		
		/**
		 * called from validateEmail
		 */
		private function checkEmail():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, validateEmail);
			kbd.disableKeyboard();
			
			var request:URLRequest = new URLRequest("https://nescafedolcegusto.thesocialtab.net/home/isregistered");
				
			var vars:URLVariables = new URLVariables();
			vars.email = clip.theEmail.text;
			
			//show please wait a moment
			clip.theTitle.text = "PLEASE WAIT A MOMENT...";
			clip.theTitle.alpha = 0;
			TweenMax.to(clip.theTitle, .5, {alpha:1});
					
			request.data = vars;			
			request.method = URLRequestMethod.GET;
			request.requestHeaders.push(jsonAccept);
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, emailChecked, false, 0, true);
			lo.load(request);
		}
		
		
		/**
		 * IO error occured checking the email address
		 * go on like they haven't done the quiz...
		 * 
		 * @param	e
		 */
		private function dataError(e:IOErrorEvent):void
		{
			alreadyDidQuiz = false;
			quizResult = "";
			getName();
		}

		
		private function emailChecked(e:Event):void
		{			
			var j:Object = JSON.parse(e.currentTarget.data);
			
			if (j.Data.Result){//true
				
				//they've already taken the quiz before
				alreadyDidQuiz = true;
				quizResult = j.Data.Result;//uppercase A-F
				
				animateHide();//calls doComplete at end			
				
			}else{
			
				//Result was null - first timer
				alreadyDidQuiz = false;
				quizResult = "";
				getName();
			}
		}
		
		
		/**
		 * returns the quizResult A - F
		 */
		public function get result():String
		{
			return quizResult;
		}
		
		
		private function getName():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, validateEmail);
			kbd.addEventListener(KeyBoard.SUBMIT, validateName, false, 0, true);
			
			//user hasn't completed the quiz				
			clip.theTitle.text = "WELCOME!";
			
			//move email off screen left
			TweenMax.to(clip.enterEmail, .5, {x: -2538});
			TweenMax.to(clip.theEmail, .5, {x: -2538});
			TweenMax.to(clip.grayBox, .5, {x: -2538});
			TweenMax.to(clip.optCheck, .3, {x:-2538});
			TweenMax.to(clip.btnPrivacy, .3, {x:-2538});
			TweenMax.to(clip.optText, .3, {x:-2538});			
			
			//fname on screen
			TweenMax.to(clip.titleFname, .3, {x:1130, ease:Back.easeOut});
			TweenMax.to(clip.theFname, .3, {x:1164, ease:Back.easeOut});
			TweenMax.to(clip.grayBox1, .3, {x:1130, ease:Back.easeOut});			
			
			kbd.setFocus(1);//set focus to the first name field
			kbd.enableKeyboard();
		}
		
		
		
		private function toggleOpt(e:MouseEvent):void
		{
			if (clip.optCheck.currentFrame == 1){
				clip.optCheck.gotoAndStop(2);
			}else{
				clip.optCheck.gotoAndStop(1);
			}
		}
		
		
		/**
		 * called by pressing Submit when fname field is displayed
		 * @param	e
		 */
		private function validateName(e:Event):void
		{
			if (clip.theFname.text == ""){				
				clip.titleFname.text = "Please enter your First Name";
				TweenMax.to(clip.titleFname, 1, {alpha:0, delay:1, onComplete:resetFnameText});	
			}else{
				//populated				
				animateHide();
			}
		}		
		
		
		private function resetFnameText():void
		{
			clip.titleFname.text = "First Name";
			clip.titleFname.alpha = 1;
		}
		
		
		private function resetLnameText():void
		{
			clip.titleLname.text = "Last Name";
			clip.titleLname.alpha = 1;
		}
		
		
		private function quitPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(QUIT));
		}
		
	}
	
}