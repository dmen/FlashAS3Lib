/**
 * Document class for User.fla
 */

package com.gmrmarketing.indian.daytona
{
	import flash.display.*;
	import com.gmrmarketing.indian.daytona.*;
	import flash.events.Event;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var lower:Sprite; //containers
		private var upper:Sprite;
		private var top:Sprite; //container for intro so it's above all things
		
		private var intro:Intro;
		private var email:EmailForm;
		private var form:MainForm;
		private var thanks:Thanks;
		private var rules:Rules;
		private var dialog:Dialog;		
		
		private var kbd:KeyBoard;
		private var timeoutHelper:TimeoutHelper;
		private var cq:CornerQuit;
		
		
		public function Main()
		{			
			lower = new Sprite();
			upper = new Sprite();
			top = new Sprite();
			
			addChild(lower);
			addChild(upper);
			addChild(top);
			
			dialog = new Dialog();
			form = new MainForm();
			form.setContainer(upper);
			
			email = new EmailForm();
			email.setContainer(lower);
			
			intro = new Intro();
			intro.setContainer(top);
			
			rules = new Rules();
			rules.setContainer(top);
			
			thanks = new Thanks();
			thanks.setContainer(upper);
			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			kbd = new KeyBoard();
			kbd.loadKeyFile("indianKeyboard.xml");
			
			cq = new CornerQuit();
			cq.init(top, "ul");			
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, restart, false, 0, true);
			timeoutHelper.init(120000);
			timeoutHelper.startMonitoring();

			init();
		}
		

		private function init():void
		{	
			intro.addEventListener(Intro.INTRO_CLICKED, removeIntro, false, 0, true);
			intro.show();
			cq.moveToTop();
		}
		
		
		/**
		 * called when the intro screen is touched
		 * shows the email entry form
		 * @param	e
		 */
		private function removeIntro(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			thanks.kill();
			
			intro.removeEventListener(Intro.INTRO_CLICKED, removeIntro);
			email.show();//puts email into lower
			intro.hide();//fades intro out in upper
			
			email.addEventListener(EmailForm.EMAIL_CANCEL, emailCanceled, false, 0, true);
			email.addEventListener(EmailForm.ERROR, errorOccured, false, 0, true);
			email.addEventListener(EmailForm.EMAIL_ENTERED, emailEntered, false, 0, true);			
			email.addEventListener(EmailForm.INVALID_EMAIL, invalidEmail, false, 0, true);
			email.addEventListener(EmailForm.PRIVACY, showPrivacyPolicy, false, 0, true);
			email.addEventListener(EmailForm.RULES, showRules, false, 0, true);
			
			kbd.x = 984;
			kbd.y = 670;
			lower.addChild(kbd);
			kbd.setFocusFields(email.getFields());
			//no weak reference so the listener won't be GC'd when the keyboard is not on the display list
			kbd.addEventListener(KeyBoard.KBD, resetTimeout);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, regKeyboard, false, 0, true);
		}
		
		
		private function regKeyboard(e:KeyboardEvent):void
		{			
			if (e.keyCode == 13) {
				//enter
				email.submitClicked();
			}
			timeoutHelper.buttonClicked();
		}
		
		
		
		private function emailCanceled(e:Event):void
		{			
			email.hide();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, regKeyboard);
			init();
		}
		
		
		private function errorOccured(e:Event):void
		{
			dialog.show("An error has occured please try again", top);
		}
		
		
		
		/**
		 * Called once the user enters a valid email
		 * @param	e
		 */
		private function emailEntered(e:Event):void
		{
			email.removeEventListener(EmailForm.EMAIL_CANCEL, emailCanceled);
			email.removeEventListener(EmailForm.ERROR, errorOccured);
			email.removeEventListener(EmailForm.EMAIL_ENTERED, emailEntered);		
			email.removeEventListener(EmailForm.INVALID_EMAIL, invalidEmail);
			email.removeEventListener(EmailForm.PRIVACY, showPrivacyPolicy);
			email.removeEventListener(EmailForm.RULES, showRules);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, regKeyboard);
			
			lower.removeChild(kbd);
			
			form.addEventListener(MainForm.FORM_CANCEL, formCanceled, false, 0, true);
			form.addEventListener(MainForm.ERROR, errorOccured, false, 0, true);
			form.addEventListener(MainForm.FORM_GOOD, goodForm, false, 0, true);
			form.addEventListener(MainForm.FORM_BAD, badForm, false, 0, true);
			form.addEventListener(MainForm.NAME_BAD, badName, false, 0, true);
			form.addEventListener(MainForm.PHONE_BAD, badPhone, false, 0, true);
			form.addEventListener(MainForm.ZIP_BAD, badZip, false, 0, true);			
			form.addEventListener(MainForm.RULES_BAD, badRules, false, 0, true);			
			form.addEventListener(MainForm.SHOW_RULES, showRules, false, 0, true);
			form.addEventListener(MainForm.PRIVACY, showPrivacyPolicy, false, 0, true);
			
			form.show(email.getEmail());
			
			upper.addChild(kbd);
			kbd.setFocusFields(form.getFields());
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, regKeyboardForm, false, 0, true);
		}		
		
		private function regKeyboardForm(e:KeyboardEvent):void
		{			
			if (e.keyCode == 13) {
				//enter
				form.submitClicked();
			}
			timeoutHelper.buttonClicked();
		}
		
		private function showRules(e:Event):void
		{
			timeoutHelper.buttonClicked();
			rules.show(2);
		}
		
		
		private function showPrivacyPolicy(e:Event):void
		{
			timeoutHelper.buttonClicked();
			rules.show(1);
		}
		
		
		private function formCanceled(e:Event):void
		{
			restart();
		}
		
		
		/**
		 * Called if user is already in the database
		 * goes to thanks after displaying the thanks for entering again dialog
		 * @param	e
		 */
		private function goodEmail(e:Event):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, regKeyboard);
			dialog.show("Thanks for entering again! You're entered into this hours giveaway.", top);
			dialog.addEventListener(Dialog.REMOVED, goodEmailThanks, false, 0, true);			
		}
		
		
		private function goodEmailThanks(e:Event):void
		{
			dialog.removeEventListener(Dialog.REMOVED, goodEmailThanks);
			showThanks();
		}
		
		
		private function goodForm(e:Event):void
		{
			showThanks();
		}
		
		
		private function badName(e:Event):void
		{
			dialog.show("Please enter a valid\nfirst and last name", top);
		}
		
		
		private function badPhone(e:Event):void
		{
			dialog.show("Please enter a valid phone number with area code", top);
		}
		
		
		private function badZip(e:Event):void
		{
			dialog.show("Please enter a valid five digit zip code", top);
		}
		
		
		private function badForm(e:Event):void
		{
			dialog.show("An error occured while posting the form data, please try again", top);
		}
		
		
		private function invalidEmail(e:Event):void
		{
			dialog.show("Please enter a valid email address", top);
		}
		
		
		private function badRules(e:Event):void
		{
			dialog.show("You must agree to the Official Rules before continuing", top);
		}
		
		
		private function showThanks():void
		{
			rules.hide();//takes care of special case when rules are showing and user hits enter to submit the form
			thanks.show();
			thanks.addEventListener(Thanks.DONE, restart, false, 0, true);
		}
		
		
		/**
		 * Callback when DONE is dispatched from Thanks
		 * Called when the timeoutHelper timeout period elapses
		 * @param	e
		 */
		private function restart(e:Event = null):void
		{
			email.hide();
			form.hide();
			rules.hide();
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, regKeyboardForm);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, regKeyboard);
			
			email.removeEventListener(EmailForm.EMAIL_CANCEL, emailCanceled);
			email.removeEventListener(EmailForm.ERROR, errorOccured);
			email.removeEventListener(EmailForm.EMAIL_ENTERED, emailEntered);			
			email.removeEventListener(EmailForm.INVALID_EMAIL, invalidEmail);
			email.removeEventListener(EmailForm.PRIVACY, showPrivacyPolicy);
			
			form.removeEventListener(MainForm.FORM_CANCEL, formCanceled);
			form.removeEventListener(MainForm.ERROR, errorOccured);
			form.removeEventListener(MainForm.FORM_GOOD, goodForm);
			form.removeEventListener(MainForm.FORM_BAD, badForm);
			form.removeEventListener(MainForm.NAME_BAD, badName);
			form.removeEventListener(MainForm.PHONE_BAD, badPhone);
			form.removeEventListener(MainForm.ZIP_BAD, badZip);			
			form.removeEventListener(MainForm.RULES_BAD, badRules);			
			form.removeEventListener(MainForm.SHOW_RULES, showRules);
			form.removeEventListener(MainForm.PRIVACY, showPrivacyPolicy);
			
			thanks.removeEventListener(Thanks.DONE, restart);
			init();
		}
		
		
		/**
		 * Called whenever a key on the virtual keyboard is pressed
		 * @param	e
		 */
		private function resetTimeout(e:Event):void
		{
			timeoutHelper.buttonClicked();
		}
		
		
		private function quit(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}