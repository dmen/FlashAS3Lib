package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	
	public class Quiz extends EventDispatcher
	{
		public static const QUIZ_LOADED:String = "quizDataLoaded";
		
		private var loader:URLLoader;
		private var theQuiz:Object;
		
		private var questionIndexes:Array;
		private var currentQuestionIndex:int;
		private var currentQuestion:Object;
		
		private var numQuestions:int;
		
		
		public function Quiz(){}		
		
		
		/**
		 * Called from QuizDisplay constructor
		 */
		public function loadQuiz()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseJSON);
			loader.load(new URLRequest("quiz.json"));
		}
		
		
		private function parseJSON(e:Event):void
		{
			theQuiz = JSON.parse(loader.data);
			numQuestions = theQuiz.quiz.questions.length;
			
			reset();
			
			loader.removeEventListener(Event.COMPLETE, parseJSON);
			loader = null;
			
			dispatchEvent(new Event(QUIZ_LOADED));
		}
		
		
		/**
		 * resets the quiz to question 1
		 */
		public function reset():void
		{
			//build index list = [0,1,2,3,4... n-1 questions]
			questionIndexes = [];
			for (var i:int = 0; i < numQuestions; i++){
				questionIndexes.push(i);
			}
			
			currentQuestionIndex = -1;
		}
		
		
		/**
		 * Increments the question counter and returns the next question
		 * 
		 * @return String question or xxx if no more questions in the quiz
		 */
		public function getNextQuestion():String
		{
			
			currentQuestionIndex++;
			if (currentQuestionIndex >= numQuestions){
				return "xxx";
			}
			
			//Object with question and answers properties. Questions is a string. Answers is an array
			currentQuestion = theQuiz.quiz.questions[questionIndexes[currentQuestionIndex]];
			
			return currentQuestion.question;
		}
		
		
		/**
		 * Decrements the question counter and returns the question
		 * 
		 * @return String question or xxx if no more questions in the quiz
		 */
		public function getPreviousQuestion():String
		{
			
			currentQuestionIndex--;
			if (currentQuestionIndex < 0){
				return "xxx";
			}
			
			//Object with question and answers properties. Questions is a string. Answers is an array
			currentQuestion = theQuiz.quiz.questions[questionIndexes[currentQuestionIndex]];
			
			return currentQuestion.question;
		}
		
		
		/**
		 * Must call getNextQuestion() first
		 * so that currentQuestionIndex is the same for both question & answer
		 * @return Array of strings ordered a,b,c,d,e,f - which matches the key data
		 */
		public function getNextAnswers():Array
		{			
			return currentQuestion.answers;
		}
		
		
		/**
		 * Must call getNextQuestion() first
		 * so that currentQuestionIndex is the same for both question & answer
		 * @return Array of strings ordered a,b,c,d,e,f - which matches the key data
		 */
		public function getNextImages():Array
		{
			return currentQuestion.images;
		}
		
		
		/**
		 * Returns the current question number 0 to (num questions - 1)
		 * returns -1 before getNextQuestion() has been called
		 */
		public function get questionNumber():int
		{
			return currentQuestionIndex;
		}
		
		
		/**
		 * Returns the total number of questions in the parsed json
		 */
		public function get totalQuestions():int
		{
			return numQuestions;
		}
		
		
		/**
		 * returns an array of objects with value,title,exp,image,coffee,mood properties
		 */
		public function getKey():Array
		{
			return theQuiz.key;
		}
		
	}
	
}