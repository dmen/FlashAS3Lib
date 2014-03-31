package com.gmrmarketing.jimbeam.boldchoice
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.gmrmarketing.jimbeam.boldchoice.QuestionsData;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	
	public class QuestionsFB extends EventDispatcher
	{
		public static const QUESTIONS_ADDED:String = "questionsFadedIn";
		public static const QUESTIONS_COMPLETE:String = "allQuestionsAsked";
		
		private var questionType:String;
		private var container:DisplayObjectContainer;
		private var questionsData:QuestionsData;
		private var clip:MovieClip; //questions lib clip
		private var correctAnswer:String;
		private var chosenAnswer:String;
		private var answer:MovieClip;
		private var numQuestions:int;
		private var curQuestionNum:int;
		private var numAnswersCorrect:int;
		
		public function QuestionsFB()
		{			
			questionsData = new QuestionsData();
			
			clip = new the_questions(); //lib clips
			answer = new the_answer();
		}
		
		
		public function show($container:DisplayObjectContainer, theType:String = "sports", num:int = 3):void
		{
			container = $container;
			questionType = theType;
			numQuestions = num;
			curQuestionNum = 0;
			numAnswersCorrect = 0;
			
			clip.btnA.addEventListener(MouseEvent.MOUSE_DOWN, answerA, false, 0, true);
			clip.btnB.addEventListener(MouseEvent.MOUSE_DOWN, answerB, false, 0, true);
			clip.btnC.addEventListener(MouseEvent.MOUSE_DOWN, answerC, false, 0, true);
			clip.btnD.addEventListener(MouseEvent.MOUSE_DOWN, answerD, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, answerSubmitted, false, 0, true);
			clip.btnSkip.addEventListener(MouseEvent.MOUSE_DOWN, questionSkipped, false, 0, true);
			clip.btnSubmit.buttonMode = true;
			clip.btnSkip.buttonMode = true;
			clip.btnA.buttonMode = true;
			clip.btnB.buttonMode = true;
			clip.btnC.buttonMode = true;
			clip.btnD.buttonMode = true;
			
			askQuestion();//get the first question loaded so it fades in with the clip
			clip.alpha = 0;
			container.addChild(clip);
			TweenMax.to(clip, .5, { alpha:1, onComplete:clipAdded } );
		}
		
		
		public function hide():void
		{
			container.removeChild(clip);
			if (clip.contains(answer)) {
				clip.removeChild(answer);
			}
			unGlow();
			
			clip.btnA.removeEventListener(MouseEvent.MOUSE_DOWN, answerA);
			clip.btnB.removeEventListener(MouseEvent.MOUSE_DOWN, answerB);
			clip.btnC.removeEventListener(MouseEvent.MOUSE_DOWN, answerC);
			clip.btnD.removeEventListener(MouseEvent.MOUSE_DOWN, answerD);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, answerSubmitted);
			clip.btnSkip.removeEventListener(MouseEvent.MOUSE_DOWN, questionSkipped);
		}
		
		
		public function getNumCorrectAnswers():int
		{
			return numAnswersCorrect;
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(QUESTIONS_ADDED));
		}
		
		
		private function askQuestion():void
		{
			unGlow(); //turns off answer hiliter
			var ques:Array;
			switch(questionType) {
				case "music":
					ques = questionsData.getMusicQuestion();
					break;
				case "sports":
					ques = questionsData.getSportsQuestion();					
					break;
				case "both":
					ques = questionsData.getBothQuestion();
					break;
			}
			
			//question
			clip.theQuestion.text = ques[0];			
			clip.theQuestion.y = 242 + Math.round((112 - clip.theQuestion.textHeight) * .5);			
			
			//correct answer
			correctAnswer = ques[1];
			
			//answers
			clip.ansA.text = ques[2][0];			
			clip.ansB.text = ques[2][1];
			clip.ansC.text = ques[2][2];
			clip.ansD.text = ques[2][3];			
			
			clip.ansA.y = 358 + Math.round((65 - clip.ansA.textHeight) * .5) - 5;
			clip.ansB.y = 358 + Math.round((65 - clip.ansB.textHeight) * .5) - 5;
			clip.ansC.y = 433 + Math.round((65 - clip.ansC.textHeight) * .5) - 5;
			clip.ansD.y = 433 + Math.round((65 - clip.ansD.textHeight) * .5) - 5;
			
			curQuestionNum++;
			
			//New in FB online version - show question number at top left
			clip.quesNum.text = "Question " + curQuestionNum + " of " + numQuestions;
		}
		
		
		private function answerA(e:MouseEvent):void
		{
			chosenAnswer = clip.ansA.text;
			unGlow();
			TweenMax.to(clip.glowA, .5, { alpha:1 } );
		}
		
		
		private function answerB(e:MouseEvent):void
		{
			chosenAnswer = clip.ansB.text;
			unGlow();
			TweenMax.to(clip.glowB, .5, { alpha:1 } );
		}
		
		
		private function answerC(e:MouseEvent):void
		{
			chosenAnswer = clip.ansC.text;
			unGlow();
			TweenMax.to(clip.glowC, .5, { alpha:1 } );
		}
		
		
		private function answerD(e:MouseEvent):void
		{
			chosenAnswer = clip.ansD.text;
			unGlow();
			TweenMax.to(clip.glowD, .5, { alpha:1 } );
		}		
		
		private function unGlow():void
		{
			TweenMax.killAll();
			clip.glowA.alpha = 0;
			clip.glowB.alpha = 0;
			clip.glowC.alpha = 0;
			clip.glowD.alpha = 0;
		}
		
		
		private function questionSkipped(e:MouseEvent):void
		{
			nextQuestion();
		}
		
		
		private function answerSubmitted(e:MouseEvent):void
		{
			if (chosenAnswer == correctAnswer) {
				showAnswerScreen(true);
				numAnswersCorrect++;
			}else {
				showAnswerScreen(false, correctAnswer);
			}
		}
		
		
		private function showAnswerScreen(correct:Boolean, answerText:String = null):void
		{
			answer.alpha = 0;
			container.addChild(answer);			
			if (correct) {
				answer.sorry.alpha = 0;
				answer.correct.alpha = 0;
				TweenMax.to(answer.correct, .5, { alpha:1, delay:.5 } );				
				answer.theAnswer.alpha = 0;
			}else {
				answer.correct.alpha = 0;
				answer.sorry.alpha = 0;
				TweenMax.to(answer.sorry, .5, { alpha:1, delay:.5 } );
				
				//NEW in FB / online version show answer
				answer.theAnswer.alpha = 0;
				answer.theAnswer.theText.text = answerText;
				var tHeight:int = 30 + answer.theAnswer.theText.textHeight; //"the correct answer is" height + actual answer height
				var buffer:int = Math.round((94 - tHeight) * .5);
				answer.theAnswer.y = 118 + buffer;
				TweenMax.to(answer.theAnswer, .5, { alpha:1, delay:.75 } );				
			}
			TweenMax.to(answer, .5, { alpha:1 } );
			
			answer.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextQuestion, false, 0, true);
		}
		
		
		private function nextQuestion(e:MouseEvent = null):void
		{
			answer.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, nextQuestion);
			if(curQuestionNum < numQuestions){
				askQuestion();
				TweenMax.to(answer, .5, { alpha:0, onComplete:removeAnswer } );
			}else {
				dispatchEvent(new Event(QUESTIONS_COMPLETE));
			}
		}
		
		
		private function removeAnswer():void
		{
			if(container.contains(answer)){
				container.removeChild(answer);
			}
		}
		
	}
	
}