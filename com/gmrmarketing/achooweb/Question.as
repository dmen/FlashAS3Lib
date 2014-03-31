/**
 * In Game Questions
 * 
 * Kleenex Achoo Game
 * 
 * Engine adds Question and waits for event "questionAnswered"
 */

package com.gmrmarketing.achooweb
{ 	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.getDefinitionByName;
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*
	
		
	
	public class Question extends MovieClip
	{		
		private var answers:Array; //array of correct answers		
		private var theQuestion:uint;
		private var channel:SoundChannel;
		
		private var myRoom:String //used for prepending to sound class name in talk()
		/**
		 * CONSTRUCTOR
		 */
		public function Question(qNum:uint, theRoom:String):void
		{		
			theQuestion = qNum;
			myRoom = theRoom; //string - bathroom, bedroom, classroom
			channel = new SoundChannel();
			
			answers = new Array();			
			
			//zzz is item 0 so that answers and frame numbers correspond directly
			answers.push("zzz", "c", "b", "b", "c", "c", true, "a", "c", "c");			
			
			x = Engine.GAME_WIDTH / 2 - (width / 2) + 29;
			y = Engine.GAME_HEIGHT / 2 - (height / 2);
			
			scaleX = .4;
			scaleY = .4;			
			
			askQuestion();
		}		
		
		
		
		//------------------ PRIVATE -------------------
		
		/**
		 * Called from all Button Click listeners
		 */
		public function removeListeners():void
		{
			channel.stop();
			qa.removeEventListener(MouseEvent.CLICK, qaClick);
			qb.removeEventListener(MouseEvent.CLICK, qbClick);
			qc.removeEventListener(MouseEvent.CLICK, qcClick);
			qd.removeEventListener(MouseEvent.CLICK, qdClick);
		}
		
		
		/**
		 * Sets the frame based on the question number
		 * 
		 * @param	num
		 */
		public function askQuestion():void
		{	
			gotoAndStop(theQuestion);			
			answerHighlight.alpha = 0;
			
			if (answers[theQuestion] == true || answers[theQuestion] == false) {
				//only two answers - qa, qb (qa is true, qb is false)
				qa.addEventListener(MouseEvent.CLICK, clickTrue);
				qb.addEventListener(MouseEvent.CLICK, clickFalse);
			}else {
				//four answers qa, qb, qc, qd				
				qa.addEventListener(MouseEvent.CLICK, qaClick);
				qb.addEventListener(MouseEvent.CLICK, qbClick);
				qc.addEventListener(MouseEvent.CLICK, qcClick);
				qd.addEventListener(MouseEvent.CLICK, qdClick);
			}
			
			TweenLite.to(this, 1, { scaleX:1, scaleY:1, ease:Elastic.easeOut, onComplete:talk } );
			//talk();
		}
		
		
		
		/**
		 * Asks the question with voice once the dialog is showing
		 */
		private function talk()
		{
			if (Engine.USE_VOICE) {
				channel.stop();
				var classRef:Class = getDefinitionByName(myRoom + "Q" + theQuestion) as Class;
				var s:Sound = new classRef();
				channel = s.play();
			}
			
		}
		
		
		
		
		
		/**
		 * BUTTON CALLBACKS
		 */
		
		private function clickTrue(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qa.x - 9;
			answerHighlight.y = qa.y - 3;	
			if (answers[theQuestion] == true) {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function clickFalse(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qb.x - 9;
			answerHighlight.y = qb.y - 3;	
			if (answers[theQuestion] == false) {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qaClick(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qa.x - 9;
			answerHighlight.y = qa.y - 3;			
			if (answers[theQuestion] == "a") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qbClick(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qa.x - 9;
			answerHighlight.y = qb.y - 3;
			if (answers[theQuestion] == "b") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qcClick(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qa.x - 9;
			answerHighlight.y = qc.y - 3;
			if (answers[theQuestion] == "c") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qdClick(e:MouseEvent)
		{
			answerHighlight.alpha = 1;
			answerHighlight.x = qa.x - 9;
			answerHighlight.y = qd.y - 3;
			if (answers[theQuestion] == "d") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
	} 
}