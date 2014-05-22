package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var textEntry:TextEntry;
		private var takePhoto:TakePhoto;
		private var countdown:Countdown;
		private var flash:WhiteFlash;
		private var form:Form;
		private var thanks:Thanks;
		private var dialog:Dialog;
		private var queue:Queue;
		private var admin:Admin;
		
		private var rules:MovieClip;//lib clip - lower left button rules/terms
		private var rulesClip:MovieClip; //actual clip containing the rules
		private var termsClip:MovieClip; //actual clip containing the terms
		
		private var mainContainer:Sprite;
		private var topContainer:Sprite;
		
		private var timeoutHelper:TimeoutHelper;
		private var cq:CornerQuit; //quit - upper right
		private var cb:CornerQuit; //back to intro - upper left
		private var ca:CornerQuit; //show admin screen - lower left
		
		private var editingText:Boolean;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			mainContainer = new Sprite();
			topContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(topContainer);
			
			textEntry = new TextEntry();
			textEntry.setContainer(mainContainer);
			
			takePhoto = new TakePhoto();
			takePhoto.setContainer(mainContainer);
			
			countdown = new Countdown();
			countdown.setContainer(mainContainer);
			
			flash = new WhiteFlash();
			flash.setContainer(mainContainer);
			
			form = new Form();
			form.setContainer(mainContainer);
			
			thanks = new Thanks();
			thanks.setContainer(mainContainer);
			
			dialog = new Dialog();
			dialog.setContainer(topContainer);
			
			rules = new mcTermsRules();
			topContainer.addChild(rules);
			rules.y = 1014;
			rules.btnTerms.addEventListener(MouseEvent.MOUSE_DOWN, showTerms, false, 0, true);
			rules.btnRules.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
			
			termsClip = new mcTerms();
			rulesClip = new mcRules();
			
			cq = new CornerQuit();
			cq.init(topContainer, "ur");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			cb = new CornerQuit();
			cb.init(topContainer, "ul");
			cb.addEventListener(CornerQuit.CORNER_QUIT, doReset, false, 0, true);
			
			ca = new CornerQuit();
			ca.init(topContainer, "lr");
			ca.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, doReset, false, 0, true);
			timeoutHelper.init(120000);//2 min		
			
			admin = new Admin();
			admin.setContainer(topContainer);
			
			queue = new Queue();
			queue.addEventListener(Queue.DEBUG_MESSAGE, queueDebug, false, 0, true);
			
			intro = new Intro();
			intro.setContainer(mainContainer);
			intro.addEventListener(Intro.BEGIN, showTextEntry, false, 0, true);
			intro.show();
		}
		
		
		private function showTerms(e:Event):void
		{
			termsClip.alpha = 0;
			if(!topContainer.contains(termsClip)){
				topContainer.addChild(termsClip);
			}
			termsClip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeTerms, false, 0, true);
			TweenMax.to(termsClip, 1, { alpha:1 } );
		}
		
		
		private function showRules(e:Event = null):void
		{	
			if(!topContainer.contains(rulesClip)){
				topContainer.addChild(rulesClip);			
			}
			if (rulesClip.currentFrame == 2){
				rulesClip.gotoAndStop(1);				
			}else {
				rulesClip.alpha = 0;
				TweenMax.to(rulesClip, 1, { alpha:1} );
			}
			rulesClip.btnPage2.addEventListener(MouseEvent.MOUSE_DOWN, showRulesPage2, false, 0, true);
			rulesClip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeRules, false, 0, true);			
		}
		
		
		private function showRulesPage2(e:MouseEvent):void
		{
			rulesClip.btnPage2.removeEventListener(MouseEvent.MOUSE_DOWN, showRulesPage2);
			rulesClip.gotoAndStop(2);
			rulesClip.btnPage1.addEventListener(MouseEvent.MOUSE_DOWN, showRules, false, 0, true);
		}
		
		
		private function closeTerms(e:Event = null):void
		{
			termsClip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeTerms);
			if(topContainer.contains(termsClip)){
				topContainer.removeChild(termsClip);
			}
		}
		
		
		private function closeRules(e:Event = null):void
		{
			rulesClip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeRules);
			if (rulesClip.currentFrame == 2) {				
				rulesClip.btnPage1.removeEventListener(MouseEvent.MOUSE_DOWN, showRules);				
			}
			rulesClip.gotoAndStop(1);
			if(topContainer.contains(rulesClip)){
				topContainer.removeChild(rulesClip);
			}
		}
		
		
		private function showTextEntry(e:Event):void
		{
			timeoutHelper.startMonitoring();
			
			textEntry.addEventListener(TextEntry.SHOWING, removeIntro, false, 0, true);
			textEntry.addEventListener(TextEntry.NAME, nameRequired, false, 0, true);
			textEntry.addEventListener(TextEntry.REQUIRED, messageRequired, false, 0, true);
			textEntry.addEventListener(TextEntry.SWEAR, inappropriateMessage, false, 0, true);
			textEntry.addEventListener(TextEntry.NEXT, showTakePhoto, false, 0, true);
			editingText = false;
			textEntry.show(true);//clear any old text
		}
		
		
		/**
		 * Hides intro screen once textEntry screen is showing
		 * @param	e
		 */
		private function removeIntro(e:Event):void
		{
			textEntry.removeEventListener(TextEntry.SHOWING, removeIntro);
			intro.hide();
		}
		
		private function nameRequired(e:Event):void
		{
			dialog.show("Please enter your first and last name");
		}
		
		private function messageRequired(e:Event):void
		{
			dialog.show("Please enter your Live Fearless story");
		}
		
		private function inappropriateMessage(e:Event):void
		{
			dialog.show("Inappropriate language is not allowed");
		}
		
		
		private function showTakePhoto(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			textEntry.removeEventListener(TextEntry.NAME, nameRequired);
			textEntry.removeEventListener(TextEntry.REQUIRED, messageRequired);
			textEntry.removeEventListener(TextEntry.SWEAR, inappropriateMessage);
			textEntry.removeEventListener(TextEntry.NEXT, showTakePhoto);			
			
			takePhoto.addEventListener(TakePhoto.SHOWING, removeTextEntry, false, 0, true);
			takePhoto.addEventListener(TakePhoto.EDIT, editText, false, 0, true);
			takePhoto.addEventListener(TakePhoto.TAKE_PHOTO, beginCount, false, 0, true);
			takePhoto.addEventListener(TakePhoto.FINISHED, showForm, false, 0, true);
			
			takePhoto.show(textEntry.getMessage(), textEntry.getName(), editingText);
		}
		
		
		/**
		 * called once the takePhoto screen is showing
		 * removes the textEntry screen now behind it
		 * @param	e
		 */
		private function removeTextEntry(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeTextEntry);
			textEntry.hide();
		}
		
		
		/**
		 * user pressed the edit text button on the take photo screen
		 * @param	e
		 */
		private function editText(e:Event):void
		{
			timeoutHelper.buttonClicked();
			editingText = true;
			textEntry.addEventListener(TextEntry.NEXT, showTakePhoto, false, 0, true);
			textEntry.addEventListener(TextEntry.SHOWING, removePhoto, false, 0, true);
			textEntry.addEventListener(TextEntry.NAME, nameRequired, false, 0, true);
			textEntry.addEventListener(TextEntry.REQUIRED, messageRequired, false, 0, true);
			textEntry.addEventListener(TextEntry.SWEAR, inappropriateMessage, false, 0, true);
			
			textEntry.show(false);//don't clear old text
		}		
		
		
		private function beginCount(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			
			countdown.addEventListener(Countdown.COUNT_COMPLETE, showFlash, false, 0, true);
			countdown.show();
		}
		
		
		private function showFlash(e:Event):void
		{
			countdown.removeEventListener(Countdown.COUNT_COMPLETE, showFlash);
			countdown.hide();
			flash.addEventListener(WhiteFlash.FLASH_COMPLETE, getPic, false, 0, true);
			flash.show();
		}
		
		
		private function getPic(e:Event):void
		{
			flash.removeEventListener(WhiteFlash.FLASH_COMPLETE, getPic);			
			takePhoto.showPhoto();
		}
		
		
		/**
		 * User clicked the continue button on the takePhoto screen
		 * @param	e
		 */
		private function showForm(e:Event):void
		{			
			timeoutHelper.buttonClicked();
			
			takePhoto.removeEventListener(TakePhoto.FINISHED, showForm);
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeTextEntry);
			takePhoto.removeEventListener(TakePhoto.EDIT, editText);
			takePhoto.removeEventListener(TakePhoto.TAKE_PHOTO, beginCount);			
			
			form.addEventListener(Form.SHOWING, removePhoto, false, 0, true);						
			form.addEventListener(Form.EMAIL, badEmail, false, 0, true);
			form.addEventListener(Form.RULES, noRules, false, 0, true);			
			form.addEventListener(Form.SAVE, formComplete, false, 0, true);			
			form.addEventListener(Form.READ_RULES, showRules, false, 0, true);			
			form.show();			
		}
		
			
		private function removePhoto(e:Event):void
		{
			form.removeEventListener(Form.SHOWING, removePhoto);
			takePhoto.hide();
		}		
		
		
		private function fieldsRequired(e:Event):void
		{
			dialog.show("Please enter your first and last name");
		}
		
		
		private function badEmail(e:Event):void
		{
			dialog.show("Please enter a valid email");
		}
		
		
		private function noRules(e:Event):void
		{
			dialog.show("You must agree to the rules");
		}		
		
		
		
		/**
		 * Called when form has been completed and validated
		 * @param	e
		 */
		private function formComplete(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			form.removeEventListener(Form.SAVE, formComplete);
			form.removeEventListener(Form.EMAIL, badEmail);
			form.removeEventListener(Form.RULES, noRules);
			form.removeEventListener(Form.READ_RULES, showRules);
			
			thanks.addEventListener(Thanks.DONE, restart, false, 0, true );
			thanks.addEventListener(Thanks.SHOWING, removeForm, false, 0, true);
			thanks.show();
		}	
		
		
		private function removeForm(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, removeForm);
			form.hide();
			var formData:Array = form.getData();//email,pho,opt
			var textData:Array = textEntry.getData(); //fname,lname,message
			var im:String = takePhoto.getPhotoString();
			//removed combo
			var ob:Object = { fname:textData[0], lname:textData[1], email:formData[0], sharephoto:formData[1], emailoptin:formData[2], message:textData[2], image:im };
			queue.add(ob);
		}
		
		
		/**
		 * called when user clicks done on the final thanks page
		 * @param	e
		 */
		private function restart(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			thanks.removeEventListener(Thanks.DONE, restart);
			thanks.hide();
			
			intro.addEventListener(Intro.BEGIN, showTextEntry, false, 0, true);
			intro.show();
		}
		
		
		/**
		 * called by timeoutHelper if the app times out
		 * @param	e
		 */
		private function doReset(e:Event):void
		{
			closeRules();
			
			textEntry.removeEventListener(TextEntry.NAME, nameRequired);
			textEntry.removeEventListener(TextEntry.REQUIRED, messageRequired);
			textEntry.removeEventListener(TextEntry.SWEAR, inappropriateMessage);
			textEntry.removeEventListener(TextEntry.NEXT, showTakePhoto);		
			textEntry.hide();
			
			takePhoto.removeEventListener(TakePhoto.FINISHED, showForm);
			takePhoto.removeEventListener(TakePhoto.SHOWING, removeTextEntry);
			takePhoto.removeEventListener(TakePhoto.EDIT, editText);
			takePhoto.removeEventListener(TakePhoto.TAKE_PHOTO, beginCount);
			takePhoto.hide();
			
			form.removeEventListener(Form.SAVE, formComplete);
			form.removeEventListener(Form.EMAIL, badEmail);
			form.removeEventListener(Form.RULES, noRules);
			form.hide();
			
			thanks.removeEventListener(Thanks.SHOWING, removeForm);
			thanks.removeEventListener(Thanks.DONE, restart);
			thanks.hide();
			
			timeoutHelper.stopMonitoring(); //don't monitor the intro screen
			intro.addEventListener(Intro.BEGIN, showTextEntry, false, 0, true);
			intro.show();
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function queueDebug(e:Event):void
		{
			admin.displayDebug(queue.getDebug());		
		}
		
		
		/**
		 * Called by pressing four times at lower left
		 * @param	e
		 */
		private function showAdmin(e:Event):void
		{
			admin.show();
		}
	}	
}