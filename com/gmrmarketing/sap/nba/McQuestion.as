package com.gmrmarketing.sap.nba
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.*;	
	import com.greensock.easing.*;	
	import flash.filesystem.*;
	import flash.net.*;	
	import flash.text.TextFormat;
	import flash.utils.*;
	import flash.media.Video;	
	import com.gmrmarketing.website.VPlayer;	
	
	
	public class McQuestion extends EventDispatcher 
	{
		public static const POPULATED:String = "Questions populated";
		public static const QUESTIONS_DONE:String = "Questions done";
		
		// Constants
		private const QUESTION_DELAY:int = 3000; // Three seconds to read the question
		private const ANSWER_DELAY:int = 100; // Updated in one tenth second intervals
		private const ANSWER_REPEAT:int = 100; // Repeat 10 time - total of 10 seconds
		private const NUMBER_OF_QUESTIONS:int = 5; // Number of questions per round
		private const DELAY_AFTER_ANSWER:int = 3; // seconds to show correct answer before going to next answer		
		
		private var Clip:MovieClip;
		private var TotalQuestions:int = 0; // Total number of questions provided by the xml
		private var CurrentQuestionIndex:int = 0; // Current index of array in whole question array
		private var QuestionsArray:Array; // Stores all question objects
		private var QuestionCount:int; // The question number the user is on
		
		private var QuestionTimer:Timer = new Timer(QUESTION_DELAY); // Timer the user gets to read the question
		private var AnswerTimer:Timer = new Timer(ANSWER_DELAY, ANSWER_REPEAT); // Timer the user gets to answer a question
		private var AnswerCountDown:int;
		private var fileStream:FileStream;		
		
		public var TotalScore:int;		
		private var b:Bitmap;		
		private var player:VPlayer;
		
		private var whiteFormat:TextFormat;
		private var grayFormat:TextFormat;
		private var sapLogo:Bitmap; //fades over end of each video
		private var bigBlack:MovieClip; //placed behind sap logo so logo can fade to black
		
		public function McQuestion(clipRef:MovieClip) 
		{	
			Clip = clipRef;			
			
			whiteFormat = new TextFormat();
			whiteFormat.color = 0xFFFFFF;
			grayFormat = new TextFormat();
			grayFormat.color = 0xDDDDDD;
			
			sapLogo = new Bitmap(new bigSAP());//library image
			bigBlack = new mcBigBlack();//lib clip
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setVidSize( { width:1920, height:1080 } );
			player.addEventListener(VPlayer.STATUS_RECEIVED, statusChanged, false, 0, true);
			
			initCount();
		}
		
		
		//sets count indicator at upper right
		private function initCount():void
		{
			for(var i = 1; i <= Clip.questionCount_mc.numChildren; i++)
			{				
				Clip.questionCount_mc["questionItem" + i].questionNumber_mc.text = i;
				Clip.questionCount_mc["questionItem" + i].questionNumber_mc.setTextFormat(whiteFormat);
				Clip.questionCount_mc["questionItem" + i].gotoAndStop(1);
			}
		}
		
		
		public function setCount(questionCountNumber:int):void
		{
			initCount();
			if (questionCountNumber > Clip.questionCount_mc.numChildren){
				questionCountNumber = Clip.questionCount_mc.numChildren;
			}
			
			for(var i:int = 1; i <= questionCountNumber; i++)
			{			
				Clip.questionCount_mc["questionItem" + i].questionNumber_mc.setTextFormat(grayFormat);
				Clip.questionCount_mc["questionItem" + i].gotoAndStop(2);
			}
		}
		
		
		public function GetTotalScore():int
		{
			return TotalScore;
		}
		
		
		public function Begin():void
		{
			Clip.visible = false;
			QuestionCount = 0;
			TotalScore = 0;
			showNextQuestion();			
		}
		
		
		private function showNextQuestion():void 
		{			
			while (Clip.questionImage_mc.numChildren > 0){ 
				Clip.questionImage_mc.removeChildAt(0); 
			}
			
			QuestionCount++;
			
			// Checking if user is done with questions
			if (QuestionCount > NUMBER_OF_QUESTIONS){				
				QuestionTimer.stop();
				AnswerTimer.stop();
				dispatchEvent(new Event(QUESTIONS_DONE));
			}else{
				// Incrementing current question index
				CurrentQuestionIndex = (CurrentQuestionIndex + 1) % TotalQuestions;
				setCount(QuestionCount);
				var nextQuestion:QuestionItem = QuestionsArray[CurrentQuestionIndex];
				nextQuestion.setVisible();
				setImage(nextQuestion.ImageFilename);
			}
		}
		
		
		private function setImage(filename:String):void
		{			
			while (Clip.questionImage_mc.numChildren > 0){ 
				Clip.questionImage_mc.removeChildAt(0); 
			}
			
			var questionPicture:Class = flash.utils.getDefinitionByName(filename) as Class;
			b = new Bitmap(new questionPicture() as BitmapData);
			Clip.questionImage_mc.addChild(b);

			hideAnswers();
			resetScore();
			
			// Displaying next question
			var nextQuestion = QuestionsArray[CurrentQuestionIndex];
			Clip.question_tx.text = nextQuestion.Question; 
			Clip.question_tx.alpha = 1;
			Clip.questionBack.alpha = .6;
			TweenMax.to(Clip.questionCount_mc, .75, { alpha:1 } );
			TweenMax.to(Clip.logo, .75, { alpha:1 } );
			Clip.answerA_mc.answer_tx.text = nextQuestion.Answers[0].Answer;
			Clip.answerB_mc.answer_tx.text = nextQuestion.Answers[1].Answer;
			Clip.answerC_mc.answer_tx.text = nextQuestion.Answers[2].Answer;
			Clip.answerD_mc.answer_tx.text = nextQuestion.Answers[3].Answer;
			
			Clip.answerA_mc.gotoAndStop(0);
			Clip.answerB_mc.gotoAndStop(0);
			Clip.answerC_mc.gotoAndStop(0);
			Clip.answerD_mc.gotoAndStop(0);
			
			// Attaching right and wrong events to answers
			assignAnswerClickEvent(nextQuestion.Answers[0], Clip.answerA_mc);
			assignAnswerClickEvent(nextQuestion.Answers[1], Clip.answerB_mc);
			assignAnswerClickEvent(nextQuestion.Answers[2], Clip.answerC_mc);
			assignAnswerClickEvent(nextQuestion.Answers[3], Clip.answerD_mc);			
			
			TweenMax.to(Clip.questionImage_mc, 0, {blurFilter: { blurX:120, blurY:120 }, colorMatrixFilter: { saturation:0 }} );			
		
			QuestionTimer.reset();
			QuestionTimer.start();
			QuestionTimer.addEventListener(TimerEvent.TIMER, questionTimerCompleteHandler, false, 0, true);
			Clip.visible = true;
		}
		
		private function hideAnswers():void
		{
			Clip.answerA_mc.visible = false;
			Clip.answerB_mc.visible = false;
			Clip.answerC_mc.visible = false;
			Clip.answerD_mc.visible = false;
		}
		
		private function showAnswers():void
		{
			Clip.answerA_mc.visible = true;
			Clip.answerB_mc.visible = true;
			Clip.answerC_mc.visible = true;
			Clip.answerD_mc.visible = true;
		}
		
		private function resetScore():void
		{
			Clip.time_mc.text = "10";
			Clip.points_mc.text = "1000 PTS"; 
		}
		
		private function answerTimerHandler(e:TimerEvent):void
		{
			AnswerCountDown--;
			var timeCount = Math.floor(AnswerCountDown / 10) + 1;
			// Maxing the count at 10 to prevent number flicker on first;
			Clip.time_mc.text = timeCount > 10 ? 10 : timeCount;
			Clip.points_mc.text = (AnswerCountDown * 10) + " PTS";
			if (AnswerCountDown == 60 || AnswerCountDown == 30 || AnswerCountDown == 10)
			{
				hideWrongAnswer();
			}
		}
		
		private function hideWrongAnswer():void
		{
			var pos:int = Math.floor(Math.random() * 4);
			var found:Boolean = false;
			
			while(!found)
			{
				if (!QuestionsArray[CurrentQuestionIndex].Answers[pos].IsCorrect && !QuestionsArray[CurrentQuestionIndex].Answers[pos].IsHidden)
				{
					QuestionsArray[CurrentQuestionIndex].Answers[pos].IsHidden = true;
					var hidingAnswer:MovieClip = null;
					
					switch(pos)
					{
						case 0:
						hidingAnswer = Clip.answerA_mc;
						break;
						case 1:
						hidingAnswer = Clip.answerB_mc;
						break;
						case 2:
						hidingAnswer = Clip.answerC_mc;
						break;
						case 3:
						hidingAnswer = Clip.answerD_mc;
						break;
						default:
						break;
					}
					
					if (hidingAnswer != null)
					{
						hidingAnswer.visible = false;
					}
					found = true;
				}
				else
				{
					pos = (pos + 1) % 4;
				}
			}
			
		}
		
		private function answerTimerCompleteHandler(e:TimerEvent):void 
		{
			Clip.time_mc.text = 0;
			AnswerTimer.stop();

			var rightAnswer:MovieClip;
			var nextQuestion = QuestionsArray[CurrentQuestionIndex];
			
			if (nextQuestion.Answers[0].IsCorrect)
			{
				rightAnswer = Clip.answerA_mc;
			}
			
			if (nextQuestion.Answers[1].IsCorrect)
			{
				rightAnswer = Clip.answerB_mc;
			}
			
			if (nextQuestion.Answers[2].IsCorrect)
			{
				rightAnswer = Clip.answerC_mc;
			}
			
			if (nextQuestion.Answers[3].IsCorrect)
			{
				rightAnswer = Clip.answerD_mc;
			}
			
			// Highlight right answer - got user timed out
			rightAnswer.gotoAndStop(3);
			
			finishQuestion();
		}
		
		/**
		 * called when the initial read is done and the question is ready to answer
		 * @param	e
		 */		
		private function questionTimerCompleteHandler(e:Event):void
		{
			QuestionTimer.stop();
			showAnswers();			
			
			TweenMax.to(Clip.questionImage_mc, 20, {blurFilter: { blurX:0, blurY:0 }, colorMatrixFilter: { saturation:1 }} );
			
			// Starting answer clock
			AnswerCountDown = ANSWER_REPEAT;
			AnswerTimer.reset();
			AnswerTimer.start();
			AnswerTimer.addEventListener(TimerEvent.TIMER, answerTimerHandler, false, 0, true);
            AnswerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, answerTimerCompleteHandler, false, 0, true);
		}
		
		private function assignAnswerClickEvent(answer:AnswerItem, answer_mc:MovieClip):void
		{
			if (answer.IsCorrect){
				answer_mc.addEventListener(MouseEvent.MOUSE_DOWN, correctAnswer, false, 0, true); 
			}else{
				answer_mc.addEventListener(MouseEvent.MOUSE_DOWN, wrongAnswer, false, 0, true);
			}
		}
		
		private function removeAnswerClickEvents(movie:MovieClip):void
		{
			movie.removeEventListener(MouseEvent.MOUSE_DOWN, correctAnswer);
			movie.removeEventListener(MouseEvent.MOUSE_DOWN, wrongAnswer);
		}
		
		private function correctAnswer(e:MouseEvent):void
		{
			AnswerTimer.stop();
			
			TotalScore += AnswerCountDown * 10;			
			
			if (Clip.answerA_mc.name != e.currentTarget.name){
				Clip.answerA_mc.visible = false;
			}
			
			if (Clip.answerB_mc.name != e.currentTarget.name){
				Clip.answerB_mc.visible = false;
			}
			
			if (Clip.answerC_mc.name != e.currentTarget.name){
				Clip.answerC_mc.visible = false;
			}
			
			if (Clip.answerD_mc.name != e.currentTarget.name){
				Clip.answerD_mc.visible = false;
			}
			
			e.currentTarget.gotoAndStop(3);
			
			finishQuestion();
		}
		
		private function wrongAnswer(e:MouseEvent):void
		{
			AnswerTimer.stop();
			Clip.points_mc.text = "0 PTS";
						
			var rightAnswer:MovieClip;
			var nextQuestion = QuestionsArray[CurrentQuestionIndex];
			
			if (nextQuestion.Answers[0].IsCorrect){
				rightAnswer = Clip.answerA_mc;
			}
			
			if (nextQuestion.Answers[1].IsCorrect){
				rightAnswer = Clip.answerB_mc;
			}
			
			if (nextQuestion.Answers[2].IsCorrect){
				rightAnswer = Clip.answerC_mc;
			}
			
			if (nextQuestion.Answers[3].IsCorrect){
				rightAnswer = Clip.answerD_mc;
			}
			
			if (Clip.answerA_mc.name != e.currentTarget.name && rightAnswer.name != "answerA_mc"){
				Clip.answerA_mc.visible = false;
			}
			
			if (Clip.answerB_mc.name != e.currentTarget.name && rightAnswer.name != "answerB_mc"){
				Clip.answerB_mc.visible = false;
			}
			
			if (Clip.answerC_mc.name != e.currentTarget.name && rightAnswer.name != "answerC_mc"){
				Clip.answerC_mc.visible = false;
			}
			
			if (Clip.answerD_mc.name != e.currentTarget.name && rightAnswer.name != "answerD_mc"){
				Clip.answerD_mc.visible = false;
			}
			
			e.currentTarget.gotoAndStop(4);
			rightAnswer.gotoAndStop(3);			
			finishQuestion();
		}
		
		private function finishQuestion():void
		{
			TweenMax.killTweensOf(Clip.questionImage_mc);
			TweenMax.to(Clip.questionImage_mc, .25, { blurFilter: { blurX:0, blurY:0 }, colorMatrixFilter: { saturation:1 }} );
			
			// Removing previous click events
			removeAnswerClickEvents(Clip.answerA_mc);
			removeAnswerClickEvents(Clip.answerB_mc);
			removeAnswerClickEvents(Clip.answerC_mc);
			removeAnswerClickEvents(Clip.answerD_mc);
			
			var nextQuestion = QuestionsArray[CurrentQuestionIndex];
			//if (nextQuestion.VideoFile == ""){				
				//TweenMax.delayedCall(DELAY_AFTER_ANSWER, showNextQuestion);
			//}else {	
				//moved to showNextQuestion() to prevent flicker of bg image removal
				//before the video starts playing
				/*
				while (Clip.questionImage_mc.numChildren > 0){ 
					Clip.questionImage_mc.removeChildAt(0); 
				}	
				*/
				player.showVideo(Clip.questionImage_mc);
				player.playVideo("videos/" + nextQuestion.VideoFile);
				
				//hide question and backer when playing video
				TweenMax.to(Clip.question_tx, .75, { alpha:0 } );
				TweenMax.to(Clip.questionBack, .75, { alpha:0 } );
				//hide logo and question count
				TweenMax.to(Clip.questionCount_mc, .75, { alpha:0 } );
				TweenMax.to(Clip.logo, .75, { alpha:0 } );
			//}
		}
		
		//private function statusChanged(stats:NetStatusEvent) {
		private function statusChanged(e:Event) 
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				//Clip.questionImage_mc.addChild(sapLogo);
				//sapLogo.alpha = 0;
				//TweenMax.to(sapLogo, .5, { alpha:1, onComplete:removeLogo } );				
				showNextQuestion();
			}			
		}
		private function removeLogo():void
		{		
			Clip.questionImage_mc.addChildAt(bigBlack, Clip.questionImage_mc.numChildren - 1);
			bigBlack.alpha = 1;
			TweenMax.to(sapLogo, 1, { alpha:0, delay:1, onComplete:showNextQuestion } );
		}
		
		public function PopulateQuestions(questionFile:String):void
		{
			var file = File.applicationDirectory.resolvePath(questionFile);
			fileStream = new FileStream();
			fileStream.addEventListener(Event.COMPLETE, processQuestions, false, 0, true);
			fileStream.openAsync(file, FileMode.READ);
		}
		
		
		private function processQuestions(e:Event):void
		{
			var i:int;
			QuestionsArray = new Array();
			
			var xml:XML = new XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
			
			for (i = 0; i < xml.question.length(); i++){
				var question:QuestionItem = new QuestionItem();
				question.Question = xml.question[i].text;
				question.Type = xml.question[i].@type;				
				question.VideoFile = xml.question[i].@video;
				question.ImageFilename = xml.question[i].@image;				
				
				for (var j:int = 0; j < xml.question[i].answers[0].*.length(); j++){
					var answer:AnswerItem = new AnswerItem();
					answer.Answer = xml.question[i].answers[0].answer[j];
					answer.IsCorrect = xml.question[i].answers[0].answer[j].@correct == "true" ? true : false;
					answer.IsHidden = false;
					question.Answers.push(answer);
				}
				
				shuffleArray(question.Answers);				
				QuestionsArray.push(question);
			}
			
			shuffleArray(QuestionsArray);
			TotalQuestions = QuestionsArray.length;
			
			//traceQuestions();
			dispatchEvent(new Event(POPULATED));
		}
		
		
		// Used for question debugging
		public function traceQuestions():void
		{
			for (var i:int = 0; i < QuestionsArray.length; i++){
				trace("Question " + i + " : " + QuestionsArray[i].Question + "\ntype: " + QuestionsArray[i].Type);
				trace("video " + i + " : " + QuestionsArray[i].VideoFile + "\nImage: " + QuestionsArray[i].ImageFilename);
				
				for (var j:int = 0; j < QuestionsArray[i].Answers.length; j++){
					trace("  Answer: " + QuestionsArray[i].Answers[j].Answer + "  " + QuestionsArray[i].Answers[j].IsCorrect); 
				}
			}
		}
		
		// Used to shuffles question and answers
		private function shuffleArray(arr:Array):void
		{
			var arraySize:int = arr.length;
			for (var i:int = 0; i < arraySize; i++){
				var randomNum_num:int = Math.floor(Math.random() * arraySize);
				var temp = arr[i];
				arr[i] = arr[randomNum_num];
				arr[randomNum_num] = temp;
			}
		}

	}
	
}
