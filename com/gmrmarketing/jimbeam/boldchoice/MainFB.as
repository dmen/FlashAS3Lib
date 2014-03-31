package com.gmrmarketing.jimbeam.boldchoice
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import com.gmrmarketing.jimbeam.boldchoice.AgeGateFB;
	import com.gmrmarketing.jimbeam.boldchoice.QuestionsFB;	
	import com.gmrmarketing.jimbeam.boldchoice.DialogFB;
	import com.gmrmarketing.jimbeam.boldchoice.Admin;
	import com.gmrmarketing.jimbeam.boldchoice.ThanksFB;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;	
	import flash.geom.Rectangle;
	import flash.external.ExternalInterface;
	
	
	public class MainFB extends MovieClip
	{
		private const NUM_QUESTIONS:int = 5;
		
		private var ageGate:AgeGateFB;
		private var choices:Choices;
		private var questions:QuestionsFB;
		private var thanks:ThanksFB;
		private var dialog:DialogFB;		
		
		public function MainFB()
		{			
			ageGate = new AgeGateFB();			
			choices = new Choices();			
			questions = new QuestionsFB();
			thanks = new ThanksFB();
			dialog = new DialogFB();
			
			ExternalInterface.addCallback("FBPostSucceeded", FBPostGood);
			ExternalInterface.addCallback("FBPostFailed", FBPostFail);
			
			init();
		}
		
		
		private function init():void
		{
			ageGate.addEventListener(AgeGateFB.PASSED, ageVerified, false, 0, true);
			ageGate.addEventListener(AgeGateFB.FAILED, ageFailed, false, 0, true);
			ageGate.addEventListener(AgeGateFB.AGEGATE_ADDED, removeThanks, false, 0, true);
			ageGate.show(this);			
		}
		
		
		private function removeThanks(e:Event):void
		{
			ageGate.removeEventListener(AgeGateFB.AGEGATE_ADDED, removeThanks);
			thanks.hide();
		}
		
		
		private function ageVerified(e:Event):void
		{
			ageGate.removeEventListener(AgeGateFB.PASSED, ageVerified);
			ageGate.removeEventListener(AgeGateFB.FAILED, ageFailed);
			
			choices.addEventListener(Choices.CHOICES_ADDED, removeAgeGate, false, 0, true);
			choices.addEventListener(Choices.CHOICE_MADE, addQuestions, false, 0, true);
			choices.show(this);			
		}
		
		
		private function ageFailed(e:Event):void
		{
			dialog.addEventListener(DialogFB.DIALOG_REMOVED, restart, false, 0, true);
			dialog.show(this, "SORRY, YOU MUST BE 21 TO TAKE THE CHALLENGE");
		}
		
		private function FBPostGood():void
		{
			dialog.show(this, "THANK YOU FOR SHARING!");
		}
		
		private function FBPostFail():void
		{
			dialog.show(this, "SORRY, THERE WAS AN ERROR SHARING, PLEASE TRY AGAIN");
		}
		
		
		private function restart(e:Event):void
		{
			dialog.removeEventListener(DialogFB.DIALOG_REMOVED, restart);
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
			
			questions.addEventListener(QuestionsFB.QUESTIONS_ADDED, removeChoices, false, 0, true);
			questions.addEventListener(QuestionsFB.QUESTIONS_COMPLETE, questionsComplete, false, 0, true);
			questions.show(this, choices.getChoice(), NUM_QUESTIONS);			
		}
		
		
		private function removeChoices(e:Event):void
		{
			questions.removeEventListener(QuestionsFB.QUESTIONS_ADDED, removeChoices);			
			choices.hide();
		}
		
		
		private function questionsComplete(e:Event):void
		{
			questions.removeEventListener(QuestionsFB.QUESTIONS_COMPLETE, questionsComplete);

			thanks.addEventListener(ThanksFB.THANKS_ADDED, removeQuestions, false, 0, true);
			thanks.addEventListener(ThanksFB.DATA_SUBMITTED, thanksSubmit, false, 0, true);
			thanks.addEventListener(ThanksFB.BAD_EMAIL, badEmail, false, 0, true);
			thanks.addEventListener(Thanks.NO_OPT, badOptin, false, 0, true);
			thanks.addEventListener(ThanksFB.DATA_POSTING, dataPosting, false, 0, true);			
			
			thanks.show(this, questions.getNumCorrectAnswers(), NUM_QUESTIONS, "FB");
		}
		
		
		private function removeQuestions(e:Event):void
		{
			thanks.removeEventListener(ThanksFB.THANKS_ADDED, removeQuestions);
			questions.hide();
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
			thanks.removeEventListener(ThanksFB.DATA_SUBMITTED, thanksSubmit);
			thanks.removeEventListener(ThanksFB.BAD_EMAIL, badEmail);
			thanks.removeEventListener(ThanksFB.NO_OPT, badOptin);
			thanks.removeEventListener(ThanksFB.DATA_POSTING, dataPosting);			
			
			dialog.addEventListener(DialogFB.DIALOG_REMOVED, restart, false, 0, true);
			dialog.show(this, "COMPLETE. THANK YOU FOR PARTICIPATING");
		}
	}
	
}