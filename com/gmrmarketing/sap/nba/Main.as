package com.gmrmarketing.sap.nba
{	
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;		
	import flash.utils.Timer;	
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.website.VPlayer;
	
	
	public class Main extends MovieClip
	{		
		private var questionClip:McQuestion;	
		private var star:Star;		
		private var rankTimer:Timer;
		
		private var fourCornerContainer:Sprite;
		private var cq:CornerQuit;
		private var player:VPlayer;
		
		
		public function Main() 
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN;	
			stage.scaleMode = StageScaleMode.EXACT_FIT;			
			Mouse.hide();
			
			fourCornerContainer = new Sprite();
			addChild(fourCornerContainer);
			
			cq = new CornerQuit();
			cq.init(fourCornerContainer, "ulur");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			//n seconds at end to read final screen - also used for timeout on instructions screen
			rankTimer = new Timer(30000);
			
			hideAllMovieClips();
			
			star = new Star(results_mc.starContainer_mc);
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setVidSize( { width:1920, height:1080 } );
			player.setSmoothing();
			//player.addEventListener(VPlayer.STATUS_RECEIVED, statusChanged, false, 0, true);
			player.addEventListener(VPlayer.CUE_RECEIVED, checkCue, false, 0, true);
			
			// Loading questions --question_mc is on stage...
			questionClip = new McQuestion(question_mc);
			questionClip.addEventListener(McQuestion.POPULATED, donePopulating, false, 0, true);
			questionClip.addEventListener(McQuestion.QUESTIONS_DONE, showResults, false, 0, true);
			questionClip.PopulateQuestions("questions.xml");
		}
		
		
		public function donePopulating(e:Event):void
		{
			initSplash();			
		}
		
		
		/**
		 * hide all clips but the topmost - which is fourCornerContainer
		 */
		private function hideAllMovieClips():void
		{
			for(var i:int = 0; i < numChildren - 1; i++){
				getChildAt(i).visible = false;
			}
		}
		
		
		private function initSplash(e:TimerEvent = null):void
		{	
			hideAllMovieClips();
			
			rankTimer.reset();		
			rankTimer.removeEventListener(TimerEvent.TIMER, initSplash);
			
			player.showVideo(splash_mc);
			player.playVideo("videos/intro.f4v");
			
			splash_mc.visible = true;
			splash_mc.addEventListener(MouseEvent.MOUSE_DOWN, initIntro, false, 0, true);
		}
		
		
		//shows instructions screen
		private function initIntro(e:MouseEvent = null):void 
		{
			splash_mc.removeEventListener(MouseEvent.MOUSE_DOWN, initIntro);
			player.stop();
			
			rankTimer.reset();		
			rankTimer.addEventListener(TimerEvent.TIMER, initSplash, false, 0, true);
			rankTimer.start();//call initSplash in 30 seconds
			
			results_mc.visible = false;
			splash_mc.visible = false;
			intro_mc.visible = true;
			intro_mc.btnStart.addEventListener(MouseEvent.MOUSE_DOWN, beginTrivia, false, 0, true);
		}		
		

		private function beginTrivia(e:MouseEvent):void 
		{
			rankTimer.reset();		
			rankTimer.removeEventListener(TimerEvent.TIMER, initSplash);
			intro_mc.btnStart.removeEventListener(MouseEvent.MOUSE_DOWN, beginTrivia);
			intro_mc.visible = false;			
			questionClip.Begin();
		}		
		
		/**
		 * 
		 * @param	e McQuestion.QUESTIONS_DONE
		 */
		private function showResults(e:Event):void
		{
			var starNumber:int;
			question_mc.visible = false;
			
			if (questionClip.GetTotalScore() >= 3000){
				starNumber = 4;
			}else if (questionClip.GetTotalScore() >= 2000){
				starNumber = 3;
			}else if (questionClip.GetTotalScore() >= 1000){
				starNumber = 2;
			}else{
				starNumber = 1;
			}
			
			star.setStar(starNumber);			
					
			results_mc.rank.gotoAndStop(starNumber); //rookie,starter,all-star,mvp
			results_mc.rankText.gotoAndStop(starNumber);//not bad, etc. text			
			results_mc.score.text = questionClip.GetTotalScore() + " PTS";
			
			//results_mc.rank.alpha = 0;
			//results_mc.rankText.alpha = 0;
			TweenMax.from(results_mc.rank, .5, { x:"-100", alpha:0 } );
			TweenMax.from(results_mc.rankText, .5, { x:"100", alpha:0 } );
			
			results_mc.visible = true;
			
			results_mc.btnAgain.addEventListener(MouseEvent.MOUSE_DOWN, startOver, false, 0, true);
			
			rankTimer.addEventListener(TimerEvent.TIMER, startOver, false, 0, true);
			rankTimer.reset();
			rankTimer.start();
		}
		
		
		private function startOver(e:Event):void
		{
			rankTimer.removeEventListener(TimerEvent.TIMER, startOver);
			results_mc.btnAgain.removeEventListener(MouseEvent.MOUSE_DOWN, startOver);
			rankTimer.reset();
			results_mc.visible = false;			
			intro_mc.visible = false;
			initSplash();			
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function statusChanged(e:Event) 
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				player.playVideo("videos/intro.f4v");
			}			
		}
		private function checkCue(e:Event):void
		{			
			player.replay();	
		}
		
	}
	
}
