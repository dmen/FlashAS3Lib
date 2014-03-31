package com.gmrmarketing.pm.ipadquiz
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.filters.DropShadowFilter;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	
	
	public class Main extends MovieClip 
	{
		private var questions:XML;
		private var currentQuestionIndex:int;
		
		private var ds:DropShadowFilter;
		//private var dsDialog:DropShadowFilter;
		private var currentQuestion:XML;
		
		private var answers:Array;
		
		private var im1:MovieClip;
		private var im2:MovieClip;
		private var im3:MovieClip;
		private var im4:MovieClip;
		
		//lib clips
		private var opening:MovieClip;
		private var finalScreen:MovieClip;
		private var prizes:MovieClip;
		
		private var initTimer:Timer;
		
		
		
		public function Main()
		{			
			//dsDialog = new DropShadowFilter(0, 0, 0, .6, 12, 12, 1, 2, false, false, false)
			ds = new DropShadowFilter(0, 0, 0, .6, 8, 8, 1, 2, false, false, false);
			
			answers = new Array();
			
			opening = new openingPage(); //lib clip
			finalScreen = new youare(); //lib clip - challenge seeker page
			prizes = new prizeScreen();
			
			ha.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
			hb.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
			hc.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
			hd.addEventListener(MouseEvent.MOUSE_DOWN, checkClicked, false, 0, true);
			
			btnNext.addEventListener(MouseEvent.MOUSE_DOWN, nextQuestion, false, 0, true);
			
			im1 = new MovieClip();
			im2 = new MovieClip();
			im3 = new MovieClip();
			im4 = new MovieClip();
			
					
			
			initTimer = new Timer(350, 1);
			initTimer.addEventListener(TimerEvent.TIMER, init, false, 0, true);
			initTimer.start();
		}
		
		
		
		private function init(e:TimerEvent = null):void
		{
			initTimer.removeEventListener(TimerEvent.TIMER, init);
			
			if(contains(cover)){
				removeChild(cover);
			}
			
			opening.im1.alpha = 0;
			opening.im2.alpha = 0;
			opening.im3.alpha = 0;			
			opening.btnNext.alpha = 0;	
			
			addChild(opening);
			TweenLite.to(opening.im1, 1.5, { alpha:1 } );
			TweenLite.to(opening.im2, 1.5, { alpha:1, delay:.5 } );
			TweenLite.to(opening.im3, 1.5, { alpha:1, delay:1, onComplete:introListen } );				
		}
		
		
		
		private function introListen():void
		{
			TweenLite.to(opening.btnNext, 1, { alpha:1 } );
			opening.btnNext.addEventListener(MouseEvent.CLICK, begin, false, 0, true);
		}
		
		
		
		private function begin(e:MouseEvent):void
		{
			removeChild(opening);
			
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);	
			xmlLoader.load(new URLRequest("questions.xml"));
		}
		
		
		
		private function xmlLoaded(e:Event):void
		{
			questions = new XML(e.target.data);			
			currentQuestionIndex = 0;
			askQuestion();
		}
		
		
		
		private function askQuestion():void
		{		
			currentQuestion = questions.question[currentQuestionIndex];
			theQuestion.htmlText = currentQuestion.title;
			qa.text = currentQuestion.choices.choice[0];
			qb.text = currentQuestion.choices.choice[1];
			qc.text = currentQuestion.choices.choice[2];
			qd.text = currentQuestion.choices.choice[3];
			
			theQuestion.y -= 20;
			TweenLite.to(theQuestion, .4, { y:"20", alpha:1 } );
			
			TweenLite.to(qa, .4, { alpha:1, delay:.1 } );
			TweenLite.to(checka, .4, { alpha:1, delay:.1 } );
			TweenLite.to(qb, .4, { alpha:1, delay:.1 } );
			TweenLite.to(checkb, .4, { alpha:1, delay:.1 } );
			TweenLite.to(qc, .4, { alpha:1, delay:.2 } );
			TweenLite.to(checkc, .4, { alpha:1, delay:.2 } );
			TweenLite.to(qd, .4, { alpha:1, delay:.2 } );
			TweenLite.to(checkd, .4, { alpha:1, delay:.2, onComplete:showImages } );
		}
		
		
		private function showImages():void
		{
			var asset:Class;
			asset = Class(getDefinitionByName("q" + String(currentQuestionIndex + 1) + "a"));
			
			if (im1.numChildren) {
				im1.removeChildAt(0);
			}
			if (im2.numChildren) {
				im2.removeChildAt(0);
			}
			if (im3.numChildren) {
				im3.removeChildAt(0);
			}
			if (im4.numChildren) {
				im4.removeChildAt(0);
			}
			
			var bmpda:BitmapData = new asset(250, 185);
			var bmpa:Bitmap = new Bitmap(bmpda);
			bmpa.smoothing = true;
			im1.addChild(bmpa);			
			addChildAt(im1,6);
			im1.alpha = 0;
			im1.x = 247;
			im1.y = 280;
			im1.rotation = -5;
			
			asset = Class(getDefinitionByName("q" + String(currentQuestionIndex + 1) + "b"));
			var bmpdb:BitmapData = new asset(250, 185);
			var bmpb:Bitmap = new Bitmap(bmpdb);
			bmpb.smoothing = true;
			im2.addChild(bmpb);
			addChildAt(im2,6);
			im2.alpha = 0;
			im2.x = 596;
			im2.y = 273;
			im2.rotation = 3;
			
			asset = Class(getDefinitionByName("q" + String(currentQuestionIndex + 1) + "c"));
			var bmpdc:BitmapData = new asset(250, 185);
			var bmpc:Bitmap = new Bitmap(bmpdc);
			bmpc.smoothing = true;
			im3.addChild(bmpc);
			addChildAt(im3,6);
			im3.alpha = 0;
			im3.x = 238;
			im3.y = 510;
			im3.rotation = 2;
			
			asset = Class(getDefinitionByName("q" + String(currentQuestionIndex + 1) + "d"));
			var bmpdd:BitmapData = new asset(250, 185);
			var bmpd:Bitmap = new Bitmap(bmpdd);
			bmpd.smoothing = true;
			im4.addChild(bmpd);			
			addChildAt(im4,6);
			im4.alpha = 0;
			im4.x = 595;
			im4.y = 518;
			im4.rotation = -3;
			
			TweenLite.to(im1, 1, { alpha:1 } );
			TweenLite.to(im2, 1, { alpha:1, delay:.25 } );
			TweenLite.to(im3, 1, { alpha:1, delay:.5 } );
			TweenLite.to(im4, 1, { alpha:1, delay:.75 } );
		}
		
		
		
		private function nextQuestion(e:MouseEvent = null):void
		{
			if (answers[currentQuestionIndex] != undefined) {				
				oldChecksOff();				
				currentQuestionIndex++;
				
				if (currentQuestionIndex >= questions.question.length()) {
					//finished
					showFinalScreen();
				}else {
					removeQuestion();
				}				
				
			}else {
				
			}
		}
		
		
		
		private function removeQuestion():void
		{
			im1.alpha = 0;
			im2.alpha = 0;
			im3.alpha = 0
			im4.alpha = 0;
			
			TweenLite.to(theQuestion, .5, { alpha:0 } );
			TweenLite.to(qa, .4, { alpha:0, delay:.1 } );
			TweenLite.to(checka, .4, { alpha:0, delay:.1 } );
			TweenLite.to(qb, .4, { alpha:0, delay:.1 } );
			TweenLite.to(checkb, .4, { alpha:0, delay:.1 } );
			TweenLite.to(qc, .4, { alpha:0, delay:.2 } );
			TweenLite.to(checkc, .4, { alpha:0, delay:.2 } );
			TweenLite.to(qd, .4, { alpha:0, delay:.2 } );
			TweenLite.to(checkd, .4, { alpha:0, delay:.2, onComplete:removeComplete } );
		}
		
		
		
		private function removeComplete():void
		{
			askQuestion();
		}
		
		
		
		private function checkClicked(e:MouseEvent):void
		{
			oldChecksOff();			
			var charIndex:String = String(e.currentTarget.name).substr(1, 1);
			
			this["check" + charIndex].gotoAndStop(2);			
			answers[currentQuestionIndex] = charIndex;
		}
		
		
		
		private function oldChecksOff():void
		{				
			checka.gotoAndStop(1);
			checkb.gotoAndStop(1);
			checkc.gotoAndStop(1);
			checkd.gotoAndStop(1);
		}
		
		
		private function showFinalScreen():void
		{
			if (im1.numChildren) {
				im1.removeChildAt(0);
			}
			if (im2.numChildren) {
				im2.removeChildAt(0);
			}
			if (im3.numChildren) {
				im4.removeChildAt(0);
			}
			if (im4.numChildren) {
				im4.removeChildAt(0);
			}
			removeChild(im1);
			removeChild(im2);
			removeChild(im3);
			removeChild(im4);
			
			finalScreen.pic.alpha = 0;
			finalScreen.btnNext.alpha = 0;
			addChild(finalScreen);
			TweenLite.to(finalScreen.pic, 1.5, { alpha:1, onComplete:waitFinal } );
		}
		
		
		
		private function waitFinal():void
		{
			TweenLite.to(finalScreen.btnNext, 1, { alpha:1 } );
			finalScreen.btnNext.addEventListener(MouseEvent.CLICK, showPrizeScreen, false, 0, true);
		}
		
		
		
		private function showPrizeScreen(e:MouseEvent):void
		{
			prizes.im1.alpha = 0;
			prizes.im2.alpha = 0;
			prizes.im3.alpha = 0;
			prizes.btnNext.alpha = 0;
			removeChild(finalScreen);
			addChild(prizes);
			
			TweenLite.to(prizes.im1, 1.5, { alpha:1 } );
			TweenLite.to(prizes.im2, 1.5, { alpha:1, delay:.5 } );
			TweenLite.to(prizes.im3, 1.5, { alpha:1, delay:1, onComplete:waitPrizes } );
		}
		
		private function waitPrizes():void
		{
			TweenLite.to(prizes.btnNext, 1, { alpha:1 } );
			prizes.btnNext.addEventListener(MouseEvent.CLICK, playAgain, false, 0, true);
		}
		
		
		
		private function playAgain(e:MouseEvent):void
		{			
			removeChild(prizes);
			prizes.btnNext.removeEventListener(MouseEvent.CLICK, playAgain);
			
			answers = new Array();
			currentQuestionIndex = 0;
			init();
		}
	}
}