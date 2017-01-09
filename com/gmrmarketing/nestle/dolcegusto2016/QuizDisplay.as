package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class QuizDisplay extends EventDispatcher 
	{
		public static const COMPLETE:String = "QUIZ_COMPLETE";
		public static const READY:String = "QUIZ_READY";
		public static const QUIT:String = "QUIZ_QUIT";
		
		private var quiz:Quiz;//quiz data from json
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;		
		
		private var images:Array; //text images from the json
		private var imageIndex:int;//index of loading images - associates images # to answer a - f
		
		private var userAnswers:Array;
		
		private var timeoutHelper:TimeoutHelper;
		
		
		public function QuizDisplay()
		{
			clip = new mcQuiz();
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			quiz = new Quiz();
			quiz.addEventListener(Quiz.QUIZ_LOADED, quizReady, false, 0, true);
			quiz.loadQuiz();//loads quiz.json
		}
		
		
		private function quizReady(e:Event):void
		{	
			dispatchEvent(new Event(READY));
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			userAnswers = [];
			quiz.reset();//reset to q1			
			
			//hide prev question
			clip.btnPrevQuestion.width = clip.btnPrevQuestion.height = 0;			
			
			clip.btnQuit.addEventListener(MouseEvent.MOUSE_DOWN, quitPressed, false, 0, true);
			
			nextQuestion(1);//populate the quiz			
		}
		
		
		public function hide()
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}			
			
			clip.ansA.removeEventListener(MouseEvent.MOUSE_DOWN, choiceA);
			clip.ansB.removeEventListener(MouseEvent.MOUSE_DOWN, choiceB);
			clip.ansC.removeEventListener(MouseEvent.MOUSE_DOWN, choiceC);
			clip.ansD.removeEventListener(MouseEvent.MOUSE_DOWN, choiceD);
			clip.ansE.removeEventListener(MouseEvent.MOUSE_DOWN, choiceE);
			clip.ansF.removeEventListener(MouseEvent.MOUSE_DOWN, choiceF);
			
			removeImages();
		}
		
		
		/**
		 * returns array of nine items - letters A - F
		 * @return
		 */
		public function getAnswers():Array
		{
			return userAnswers;
		}
		
		
		/**
		 * Resturns an object from the key
		 * @param res String A - F user quiz result from server
		 * @return object Single key object with value,title,exp,image properties
		 * 
		 */
		public function getResult(res:String = ""):Object
		{
			var key:Array = quiz.getKey();//array of key objects
			
			if(res == ""){
				
				var totals:Array = [0, 0, 0, 0, 0, 0];//A,B,C,D,E,F
				
				for (var i:int = 0; i < userAnswers.length; i++){
					
					switch(userAnswers[i]){
						case "A":
							totals[0] += 1;
							break;
						case "B":
							totals[1] += 1;
							break;
						case "C":
							totals[2] += 1;
							break;
						case "D":
							totals[3] += 1;
							break;
						case "E":
							totals[4] += 1;
							break;
						case "F":
							totals[5] += 1;
							break;
					}				
				}
				
				var maxTotal:int = 0;
				var maxIndex:int;
				for (var j:int = 0; j < totals.length; j++){
					if (totals[j] >= maxTotal){
						maxTotal = totals[j];
						maxIndex = j;
					}
				}
				
				var ret:Object = key[maxIndex];
				return ret;
				
			}else{
				
				var o:Object;
				
				for (var k:int = 0; k < key.length; k++){
					if (key[k].value == res){
						o = key[k];
						break;
					}
				}
				
				return o;
			}
		}
		
		
		
		/**
		 * populates quiz with next question data
		 */
		private function nextQuestion(direction:int):void
		{
			timeoutHelper.buttonClicked();
			
			var q:String;
			if (direction == 1){
				q = quiz.getNextQuestion();//increments question #
			}else{
				q = quiz.getPreviousQuestion();//decrements question #
			}
			
			if (quiz.questionNumber < quiz.totalQuestions){	
				
				clip.theQuestion.alpha = 0;
				clip.theQuestion.y = 250;
				TweenMax.to(clip.theQuestion, .4, {y:340, alpha:1, delay:.1, ease:Back.easeOut});
				
				clip.theQuestion.text = q.toUpperCase();
				
				var ans:Array = quiz.getNextAnswers();
				clip.ansA.theAnswer.text = "";//ans[0];
				clip.ansB.theAnswer.text = "";//ans[1];
				clip.ansC.theAnswer.text = "";//ans[2];
				clip.ansD.theAnswer.text = "";//ans[3];
				clip.ansE.theAnswer.text = "";//ans[4];
				clip.ansF.theAnswer.text = "";//ans[5];
				
				clip.ansA.alpha = 0;
				clip.ansB.alpha = 0;
				clip.ansC.alpha = 0;
				clip.ansD.alpha = 0;
				clip.ansE.alpha = 0;
				clip.ansF.alpha = 0;
				//clip.ansA.scaleY = .5;
				//clip.ansB.scaleY = .5;
				//clip.ansC.scaleY = .5;
				//clip.ansD.scaleY = .5;
				//clip.ansE.scaleY = .5;
				//clip.ansF.scaleY = .5;
				
				images = quiz.getNextImages();				
				imageIndex = 0;
				loadNextImage();
				
				if (quiz.questionNumber > 0){
					TweenMax.to(clip.btnPrevQuestion, .5, {width:110, height:91, ease:Back.easeOut});
					clip.btnPrevQuestion.addEventListener(MouseEvent.MOUSE_DOWN, prevQuesPressed, false, 0, true);
				}else{
					TweenMax.to(clip.btnPrevQuestion, .5, {width:0, height:0, ease:Back.easeIn});
					clip.btnPrevQuestion.removeEventListener(MouseEvent.MOUSE_DOWN, prevQuesPressed);
				}
				
				clip.indicator.text = "QUESTION " + String(quiz.questionNumber + 1) + " OF " + quiz.totalQuestions;
				
			}else{
				//end of quiz
				dispatchEvent(new Event(COMPLETE));				
			}
		}
		
		/**
		 * called by pressing the previous question button (back arrow at top left)
		 * @param	e
		 */
		private function prevQuesPressed(e:MouseEvent):void
		{
			//remove previous answer
			userAnswers.pop();
			
			//remove the images from the answer buttons
			removeImages();
			
			//turns the borders to alpha=0
			deselectAnswers();
			
			nextQuestion(0);//moves backward
		}
		
		
		private function quitPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			clip.btnQuit.removeEventListener(MouseEvent.MOUSE_DOWN, quitPressed);
			dispatchEvent(new Event(QUIT));
		}
		
		
		/**
		 * called from choiceA() - choiceF()
		 */
		private function autoNext():void
		{
			//remove the images from the answer buttons
			removeImages();
			
			//turns the borders to alpha=0
			deselectAnswers();
			
			nextQuestion(1);//forward
		}
		
		
		private function removeImages():void
		{
			while(clip.ansA.numChildren > 3){
				clip.ansA.removeChildAt(0);
			}
			while(clip.ansB.numChildren > 3){
				clip.ansB.removeChildAt(0);
			}
			while(clip.ansC.numChildren > 3){
				clip.ansC.removeChildAt(0);
			}
			while(clip.ansD.numChildren > 3){
				clip.ansD.removeChildAt(0);
			}
			while(clip.ansE.numChildren > 3){
				clip.ansE.removeChildAt(0);
			}
			while(clip.ansF.numChildren > 3){
				clip.ansF.removeChildAt(0);
			}
		}
		
		
		private function loadNextImage():void
		{
			if(imageIndex < 6){
				var im:String = "assets/" + images[imageIndex];// images.shift();
				var l:Loader = new Loader();
				l.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
				l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError, false, 0, true);
				l.load(new URLRequest(im));
			}else {
				//all images are loaded - add listeners to answer buttons
				clip.ansA.addEventListener(MouseEvent.MOUSE_DOWN, choiceA, false, 0, true);
				clip.ansB.addEventListener(MouseEvent.MOUSE_DOWN, choiceB, false, 0, true);
				clip.ansC.addEventListener(MouseEvent.MOUSE_DOWN, choiceC, false, 0, true);
				clip.ansD.addEventListener(MouseEvent.MOUSE_DOWN, choiceD, false, 0, true);
				clip.ansE.addEventListener(MouseEvent.MOUSE_DOWN, choiceE, false, 0, true);
				clip.ansF.addEventListener(MouseEvent.MOUSE_DOWN, choiceF, false, 0, true);
				
				TweenMax.to(clip.ansA, .3, {alpha:1, delay:.2});
				TweenMax.to(clip.ansB, .3, {alpha:1, delay:.3});
				TweenMax.to(clip.ansC, .3, {alpha:1, delay:.4});
				TweenMax.to(clip.ansD, .3, {alpha:1, delay:.5});
				TweenMax.to(clip.ansE, .3, {alpha:1, delay:.6});
				TweenMax.to(clip.ansF, .3, {alpha:1, delay:.7});
			}
		}
		
		
		private function imageLoaded(e:Event):void
		{
			imageIndex++;
			
			var b:Bitmap = new Bitmap(e.target.content.bitmapData);
			b.smoothing = true;
			b.width = 445;
			b.height = 445;
			
			switch(imageIndex){
				case 1:
					clip.ansA.addChildAt(b, 0);
					break;
				case 2:
					clip.ansB.addChildAt(b, 0);
					break;
				case 3:
					clip.ansC.addChildAt(b, 0);
					break;
				case 4:
					clip.ansD.addChildAt(b, 0);
					break;
				case 5:
					clip.ansE.addChildAt(b, 0);
					break;
				case 6:
					clip.ansF.addChildAt(b, 0);
					break;
			}
			
			loadNextImage();
		}
		
		
		private function imageError(e:IOErrorEvent):void
		{
			trace("image error",e.toString());
		}
		
		
		private function choiceA(e:MouseEvent):void
		{
			userAnswers[quiz.questionNumber] = "A";
			deselectAnswers();
			clip.ansA.border.scaleX = clip.ansA.border.scaleY = .8;
			TweenMax.to(clip.ansA.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansA.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		private function choiceB(e:MouseEvent):void
		{
			userAnswers[quiz.questionNumber] = "B";
			deselectAnswers();
			clip.ansB.border.scaleX = clip.ansB.border.scaleY = .8;
			TweenMax.to(clip.ansB.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansB.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		private function choiceC(e:MouseEvent):void
		{
			userAnswers[quiz.questionNumber] = "C";
			deselectAnswers();
			clip.ansC.border.scaleX = clip.ansC.border.scaleY = .8;
			TweenMax.to(clip.ansC.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansC.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		private function choiceD(e:MouseEvent):void
		{
			userAnswers[quiz.questionNumber] = "D";
			deselectAnswers();
			clip.ansD.border.scaleX = clip.ansD.border.scaleY = .8;
			TweenMax.to(clip.ansD.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansD.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		private function choiceE(e:MouseEvent):void
		{
			userAnswers[quiz.questionNumber] = "E";
			deselectAnswers();
			clip.ansE.border.scaleX = clip.ansE.border.scaleY = .8;
			TweenMax.to(clip.ansE.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansE.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		private function choiceF(e:MouseEvent):void
		{			
			userAnswers[quiz.questionNumber] = "F";
			deselectAnswers();
			clip.ansF.border.scaleX = clip.ansF.border.scaleY = .8;
			TweenMax.to(clip.ansF.getChildAt(0), .4, {alpha:.7});
			TweenMax.to(clip.ansF.border, .4, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:autoNext});
		}
		
		
		/**
		 * changes all the border alphas to 0 to hide them
		 */
		private function deselectAnswers()
		{
			clip.ansA.border.alpha = 0;
			clip.ansB.border.alpha = 0;
			clip.ansC.border.alpha = 0;
			clip.ansD.border.alpha = 0;
			clip.ansE.border.alpha = 0;
			clip.ansF.border.alpha = 0;
		}
		
		
	}
	
}