/**
 * In Game Questions
 * 
 * Kleenex Achoo Game
 * 
 * Engine adds Question and waits for event "questionAnswered"
 */

package com.gmrmarketing.morris
{ 	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	
	import flash.display.Sprite;
	import gs.TweenLite;
	import gs.easing.*
	
	
	public class Question extends MovieClip
	{
		
		private var answers:Array; //array of correct answers				
		private var theGame:Sprite;
		private var qOrder:Array;
		private var theQuestion:int;
		
		/**
		 * CONSTRUCTOR
		 */
		public function Question(gameRef:Sprite):void
		{		
			trace("Question constructor");
			theGame = gameRef;			
			answers = new Array();
			
			//zzz is item 0 so that answers and frame numbers correspond directly
			answers.push("zzz", "b", "c", "a", "b", "c", "c", "a", "c", "c", "c", true, true, true, true, true, true, true, "a", "b", "a");
			randomizeQuestions();		
		}		
		
		
		public function askQuestion(atX:int, atY:int):void
		{			
			if (qOrder.length == 0) {
				randomizeQuestions();
			}
			//if (qOrder.length > 0) {
				alpha = 0;
				theGame.addChild(this);
				x = atX + 30;
				y = atY - 15;
				scaleX = scaleY = .3;
				theQuestion = qOrder.splice(0, 1)[0];
				gotoAndStop(theQuestion);
				TweenLite.to(this, 1, { alpha:1, scaleX:1, scaleY:1, ease:Bounce.easeOut, onComplete:addListeners } );
			//}
		}
		
		
		//------------------ PRIVATE -------------------
		private function randomizeQuestions():void
		{
			qOrder = new Array();
			var qs:Array = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20);
			while (qs.length > 0) {
				var qind:int = Math.floor(Math.random() * qs.length);
				var q = qs.splice(qind, 1)[0];
				qOrder.push(q);
			}	
		}
		/**
		 * Called from TweenLite complete
		 * adds button listeners
		 */
		private function addListeners():void
		{
			if (answers[theQuestion] == true || answers[theQuestion] == false) {
					qa.addEventListener(MouseEvent.CLICK, trueClick);
					qb.addEventListener(MouseEvent.CLICK, falseClick);
				}else {					
					qa.addEventListener(MouseEvent.CLICK, qaClick);
					qb.addEventListener(MouseEvent.CLICK, qbClick);
					qc.addEventListener(MouseEvent.CLICK, qcClick);	
				}
		}
		
		
		public function removeListeners2():void
		{			
			qa.removeEventListener(MouseEvent.CLICK, trueClick);
			qb.removeEventListener(MouseEvent.CLICK, falseClick);		
		}
		
		public function removeListeners():void
		{			
			qa.removeEventListener(MouseEvent.CLICK, qaClick);
			qb.removeEventListener(MouseEvent.CLICK, qbClick);			
			qc.removeEventListener(MouseEvent.CLICK, qcClick);
		}
		
		public function removeSelf():void 
		{
			trace("Question removeSelf");
			if (theGame.contains(this)) {
				theGame.removeChild(this);
			}
		}
		
		
		/**
		 * BUTTON CALLBACKS
		 */	
		private function trueClick(e:MouseEvent)
		{			
			if (answers[theQuestion] == true) {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners2();
		}
		private function falseClick(e:MouseEvent)
		{			
			if (answers[theQuestion] == false) {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners2();
		}
		private function qaClick(e:MouseEvent)
		{			
			if (answers[theQuestion] == "a") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qbClick(e:MouseEvent)
		{			
			if (answers[theQuestion] == "b") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
		
		
		private function qcClick(e:MouseEvent)
		{			
			if (answers[theQuestion] == "c") {
				dispatchEvent(new Event("questionAnsweredCorrect"));
			}else {
				dispatchEvent(new Event("questionAnsweredWrong"));
			}
			removeListeners();
		}
	
	} 
}