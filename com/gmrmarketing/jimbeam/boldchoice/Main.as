package com.gmrmarketing.jimbeam.boldchoice
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import com.gmrmarketing.jimbeam.boldchoice.AgeGate;
	import com.gmrmarketing.jimbeam.boldchoice.Questions;
	import com.gmrmarketing.jimbeam.boldchoice.Facebook;
	import com.gmrmarketing.jimbeam.boldchoice.Dialog;
	import com.gmrmarketing.jimbeam.boldchoice.Admin;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.media.StageWebView;
	import flash.geom.Rectangle;
	
	
	
	public class Main extends MovieClip
	{
		private var ageGate:AgeGate;
		private var choices:Choices;
		private var questions:Questions;
		private var thanks:Thanks;
		private var dialog:Dialog;
		private var admin:Admin;
		
		private var adminCorner:CornerQuit;
		
		private var fb:Facebook;
		private var fbCancel:MovieClip;
		
		private var swv:StageWebView;
		
		
		
		public function Main()
		{			
			ageGate = new AgeGate();			
			choices = new Choices();			
			questions = new Questions();
			thanks = new Thanks();
			dialog = new Dialog();
			admin = new Admin();
			fb = new Facebook();
			
			adminCorner = new CornerQuit(false);
			adminCorner.init(this, "ul");
			adminCorner.customLoc(1, new Point(0,0));
			adminCorner.addEventListener(CornerQuit.CORNER_QUIT, showAdmin, false, 0, true);
			
			init();
		}
		
		
		private function init():void
		{
			ageGate.addEventListener(AgeGate.PASSED, ageVerified, false, 0, true);
			ageGate.addEventListener(AgeGate.FAILED, ageFailed, false, 0, true);
			ageGate.addEventListener(AgeGate.AGEGATE_ADDED, removeThanks, false, 0, true);
			ageGate.show(this);
			adminCorner.moveToTop();
		}
		
		
		private function removeThanks(e:Event):void
		{
			ageGate.removeEventListener(AgeGate.AGEGATE_ADDED, removeThanks);
			thanks.hide();
		}
		
		
		private function ageVerified(e:Event):void
		{
			ageGate.removeEventListener(AgeGate.PASSED, ageVerified);
			ageGate.removeEventListener(AgeGate.FAILED, ageFailed);
			
			choices.addEventListener(Choices.CHOICES_ADDED, removeAgeGate, false, 0, true);
			choices.addEventListener(Choices.CHOICE_MADE, addQuestions, false, 0, true);
			choices.show(this);
			adminCorner.moveToTop();
		}
		
		
		private function ageFailed(e:Event):void
		{
			dialog.addEventListener(Dialog.DIALOG_REMOVED, restart, false, 0, true);
			dialog.show(this, "SORRY, YOU MUST BE 21 TO TAKE THE CHALLENGE");
		}
		
		
		private function restart(e:Event):void
		{
			dialog.removeEventListener(Dialog.DIALOG_REMOVED, restart);
			init();
		}
		
		
		private function removeAgeGate(e:Event):void
		{
			ageGate.hide();
		}
		
		
		private function addQuestions(e:Event):void
		{
			choices.removeEventListener(Choices.CHOICES_ADDED, removeAgeGate);
			choices.removeEventListener(Choices.CHOICE_MADE, addQuestions);
			
			questions.addEventListener(Questions.QUESTIONS_ADDED, removeChoices, false, 0, true);
			questions.addEventListener(Questions.QUESTIONS_COMPLETE, questionsComplete, false, 0, true);
			questions.show(this, choices.getChoice(), admin.getNumQuestions());
			adminCorner.moveToTop();
		}
		
		
		private function removeChoices(e:Event):void
		{
			questions.removeEventListener(Questions.QUESTIONS_ADDED, removeChoices);			
			choices.hide();
		}
		
		
		private function questionsComplete(e:Event):void
		{
			questions.removeEventListener(Questions.QUESTIONS_COMPLETE, questionsComplete);

			thanks.addEventListener(Thanks.THANKS_ADDED, removeQuestions, false, 0, true);
			thanks.addEventListener(Thanks.DATA_SUBMITTED, thanksSubmit, false, 0, true);
			thanks.addEventListener(Thanks.BAD_EMAIL, badEmail, false, 0, true);
			thanks.addEventListener(Thanks.NO_OPT, badOptin, false, 0, true);
			thanks.addEventListener(Thanks.DATA_POSTING, dataPosting, false, 0, true);
			thanks.addEventListener(Thanks.FB_PRESSED, postToFB, false, 0, true);
			
			thanks.show(this, questions.getNumCorrectAnswers(), admin.getNumQuestions(), admin.getVenue());			
			
			adminCorner.moveToTop();
		}
		
		
		private function removeQuestions(e:Event):void
		{
			thanks.removeEventListener(Thanks.THANKS_ADDED, removeQuestions);
			questions.hide();
		}
		
		
		/**
		 * Called by pressing Facebook button on thanks page
		 * @param	e
		 */
		private function postToFB(e:Event):void
		{	
			swv = new StageWebView();
			swv.stage = stage;
			swv.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight - 236);
			
			fb.init(this, swv, questions.getNumCorrectAnswers(), admin.getNumQuestions());
			fb.addEventListener(Facebook.PHOTO_POSTED, clearFB, false, 0, true);
			
			//show cancel button
			fbCancel = new cancel_FB();//lib clip
			fbCancel.x = 265;
			fbCancel.y = 801;
			addChild(fbCancel);
			fbCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelFB, false, 0, true);
		}
		
		
		/**
		 * Called by clicking the cancel facebook button
		 * kills the stage web view object and removes the cancel button
		 * @param	e
		 */
		private function cancelFB(e:MouseEvent = null):void
		{
			fbCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelFB);
			fb.removeEventListener(Facebook.PHOTO_POSTED, clearFB);
			if (fbCancel) {
				if (contains(fbCancel)) {
					removeChild(fbCancel);
				}
			}			
			
			try{
				swv.dispose();
			}catch (e:Error) {
				
			}
		}
		
		private function clearFB(e:Event):void
		{
			dialog.show(this, "THANKS FOR SHARING");
			cancelFB();
		}
		
		
		private function badEmail(e:Event):void
		{
			dialog.show(this, "THE EMAIL ADDRESS ENTERED IS NOT VALID");
		}
		
		private function dataPosting(e:Event):void
		{
			dialog.show(this, "PLEASE WAIT A MOMENT...");
		}
		
		
		private function badOptin(e:Event):void
		{
			dialog.show(this, "YOU MUST PROVIDE AN EMAIL ADDRESS IN ORDER TO OPT IN");
		}
		
		
		private function thanksSubmit(e:Event):void
		{
			thanks.removeEventListener(Thanks.DATA_SUBMITTED, thanksSubmit);
			thanks.removeEventListener(Thanks.BAD_EMAIL, badEmail);
			thanks.removeEventListener(Thanks.NO_OPT, badOptin);
			thanks.removeEventListener(Thanks.DATA_POSTING, dataPosting);
			thanks.removeEventListener(Thanks.FB_PRESSED, postToFB);
			
			dialog.addEventListener(Dialog.DIALOG_REMOVED, restart, false, 0, true);
			dialog.show(this, "COMPLETE. THANK YOU FOR PARTICIPATING");
		}
		
		
		private function showAdmin(e:Event):void
		{
			admin.addEventListener(Admin.ADMIN_CLOSED, closeAdmin, false, 0, true);
			admin.show(this);
		}
		
		
		private function closeAdmin(e:Event):void
		{
			admin.removeEventListener(Admin.ADMIN_CLOSED, closeAdmin);
			admin.hide();
			//need to reinit so app uses new data
			while (numChildren) {
				removeChildAt(0);
			}
			init();
		}
	}
	
}