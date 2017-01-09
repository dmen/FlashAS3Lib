package com.gmrmarketing.nestle.dolcegusto2016.cafe
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.nestle.dolcegusto2016.*;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.geom.Point;
	import fl.transitions.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var sideBarContainer:Sprite;
		private var introTimeoutContainer:Sprite;//contains the big machine image that appears on inactivity - above all except cornerContainer
		private var introTimeoutImage:MovieClip;
		private var cornerContainer:Sprite;
		private var config:Config;
		private var sideBar:MovieClip;//raising the bar left side thing
		private var intro:Intro;
		private var email:Email;
		private var quiz:QuizDisplay;
		private var calcResults:CalculatingResults;
		private var results:Results;
		private var thanks:Thanks;
		
		//selection on the intro screen
		private var flavors:Flavors;
		private var videos:VideoPlayer;
		private var products:Products;
				
		private var netStuff:NetStuff;//for posting user data
		
		private var timeoutHelper:TimeoutHelper;
		
		private var cq:CornerQuit;
		
		private var privacyPolicy:PrivacyPolicy;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			netStuff = new NetStuff();
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			sideBarContainer = new Sprite();
			addChild(sideBarContainer);
			
			introTimeoutContainer = new Sprite();
			addChild(introTimeoutContainer);
			introTimeoutImage = new mcIntroTimeout();
			introTimeoutContainer.addChild(introTimeoutImage);
			introTimeoutImage.visible = false;
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			email = new Email();
			email.setContainer(mainContainer, introTimeoutContainer);
			
			privacyPolicy = new PrivacyPolicy();
			privacyPolicy.container = cornerContainer;
			
			quiz = new QuizDisplay();
			quiz.container = mainContainer;
			
			calcResults = new CalculatingResults();
			calcResults.container = mainContainer;
			
			results = new Results();
			results.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;					
			
			flavors = new Flavors();
			flavors.container = mainContainer;
			
			videos = new VideoPlayer();
			videos.container = mainContainer;
			
			products = new Products();
			products.container = mainContainer;
			
			sideBar = new mcSideBar();
			sideBarContainer.addChild(sideBar);
			sideBar.scaleX = sideBar.scaleY = .92;
			sideBar.y = 240;
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ll");
			cq.customLoc(1, new Point(0, 1674));
			cq.addEventListener(CornerQuit.CORNER_QUIT, doQuit);
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, restart, false, 0, true);
			timeoutHelper.init(120000);//2 minutes without an interaction			
			
			config = new Config();
			config.addEventListener(Config.COMPLETE, showIntro, false, 0, true);
		}		
		
		
		/**
		 * called once config is loaded - and from restart()
		 * @param	e
		 */
		private function showIntro(e:Event = null):void
		{		
			config.removeEventListener(Config.COMPLETE, showIntro);
			flavors.removeEventListener(Flavors.COMPLETE, showIntro);
			
			introTimeoutImage.visible = false;//large coffee maker
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.addEventListener(Intro.INTRO_TIMEOUT_SHOW, showIntroTimeoutImage, false, 0, true);
			intro.addEventListener(Intro.INTRO_TIMEOUT_HIDE, hideIntroTimeoutImage, false, 0, true);
			intro.addEventListener(Intro.FLAVORS, showFlavors, false, 0, true);
			intro.addEventListener(Intro.VIDEOS, showVideos, false, 0, true);
			intro.addEventListener(Intro.MACHINES, showProducts, false, 0, true);
			
			showSideBar();
			intro.show();	
			flavors.hide();
			videos.hide();
			products.hide();
		}
		
		private function showIntroTimeoutImage(e:Event):void
		{
			introTimeoutImage.visible = true;
			TransitionManager.start(introTimeoutImage, {type:PixelDissolve, direction:Transition.IN, duration:2, xSections:8, ySections:5});
			introTimeoutImage.addEventListener(MouseEvent.MOUSE_DOWN, hideIntroTimeoutImage, false, 0, true);
		}
		
		private function hideIntroTimeoutImage(e:Event):void
		{
			introTimeoutImage.removeEventListener(MouseEvent.MOUSE_DOWN, hideIntroTimeoutImage);
			TransitionManager.start(introTimeoutImage, {type:PixelDissolve, direction:Transition.OUT, duration:2, xSections:8, ySections:5});
		}
		
		
		private function hideIntro(e:Event):void
		{
			intro.removeEventListener(Intro.INTRO_TIMEOUT_SHOW, showIntroTimeoutImage);
			intro.removeEventListener(Intro.INTRO_TIMEOUT_HIDE, hideIntroTimeoutImage);
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.removeEventListener(Intro.FLAVORS, showFlavors);
			intro.removeEventListener(Intro.VIDEOS, showVideos);
			intro.removeEventListener(Intro.MACHINES, showProducts);
			intro.hide();
			
			timeoutHelper.startMonitoring();
			
			email.show();
			email.addEventListener(Email.COMPLETE, hideEmail, false, 0, true);
			email.addEventListener(Email.PRIVACY, showPrivacyPolicy, false, 0, true);
			email.addEventListener(Email.QUIT, restart, false, 0, true);
		}
		
		
		private function showFlavors(e:Event):void
		{
			intro.hide();//?????????
			hideSideBar();
			
			flavors.addEventListener(Flavors.COMPLETE, showIntro, false, 0, true);
			flavors.show();
		}
		private function showVideos(e:Event):void
		{
			intro.killClip();//?????????
			hideSideBar();
			
			videos.addEventListener(VideoPlayer.COMPLETE, showIntro, false, 0, true);
			videos.show();
		}
		private function showProducts(e:Event):void
		{
			intro.killClip();//?????????
			hideSideBar();
			
			products.addEventListener(Products.COMPLETE, showIntro, false, 0, true);
			products.show();
		}
		
		
		/**
		 * Called once COMPLETE from Email is received
		 * 
		 * @param	e
		 */
		private function hideEmail(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.QUIT, restart);
			email.removeEventListener(Email.PRIVACY, showPrivacyPolicy);
			email.hide();			
			
			if (email.userDidQuiz){
			
			
				//cafe - show user prefs
				calcResults.addEventListener(CalculatingResults.COMPLETE, hideCalc, false, 0, true);
				calcResults.show(email.userDidQuiz);				
				
			}else{
				
				quiz.addEventListener(QuizDisplay.COMPLETE, quizComplete, false, 0, true);
				quiz.addEventListener(QuizDisplay.QUIT, restart, false, 0, true);
				quiz.show();
			}			
		}
		
		
		private function showPrivacyPolicy(e:Event):void
		{
			privacyPolicy.show();
		}
		
		
		private function hidePrivacyPolicy(e:Event):void
		{
			privacyPolicy.hide();
		}
		
		
		private function quizComplete(e:Event):void
		{
			quiz.hide();
			quiz.removeEventListener(QuizDisplay.COMPLETE, quizComplete);
			
			calcResults.addEventListener(CalculatingResults.COMPLETE, hideCalc, false, 0, true);
			calcResults.show(email.userDidQuiz);//show Welcome Back if user has done the quiz previously
		}
		
		
		private function hideCalc(e:Event):void
		{
			calcResults.removeEventListener(CalculatingResults.COMPLETE, hideCalc);
			calcResults.hide();
			
			results.addEventListener(Results.COMPLETE, hideResults, false, 0, true);
			
			if (email.userDidQuiz){
				trace("userDidQuiz", email.result);
				//show results returned from server
				results.show(quiz.getResult(email.result));
				
			}else{
				
				//show results from quiz - and post
				results.show(quiz.getResult());					
				postUserData();			
			}
		
		}
		
		
		
		/**
		 * Called from hideCalc() - posts the user data to the db
		 */
		private function postUserData():void
		{
			//need to post user data - JSON stringified by netStuff.postResults			
			var ud:Object = email.userData;//Email, FName, OptIn
			ud.Result = quiz.getResult().value;
			
			//need to post full quiz responses
			var ans:Array = quiz.getAnswers();
			ud.Q1 = ans[0];
			ud.Q2 = ans[1];
			ud.Q3 = ans[2];
			ud.Q4 = ans[3];
			ud.Q5 = ans[4];
			ud.Q6 = ans[5];
			ud.Q7 = ans[6];
			ud.Q8 = ans[7];
			ud.Q9 = ans[8];
			
			ud.Timestamp = Utility.hubbleTimeStamp;
			
			//post new user and result to the DB
			netStuff.postResults(ud);		
		}
		
		
		private function hideResults(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, restart, false, 0, true);
			thanks.show(false);			
		}
		
		
		private function showSideBar():void
		{
			sideBar.visible = true;
			TweenMax.to(sideBar, .5, {alpha:1});			
		}
		
		
		private function hideSideBar():void
		{
			TweenMax.to(sideBar, .5, {alpha:0, onComplete:killSideBar});			
		}
		private function killSideBar():void
		{
			sideBar.visible = false;//so clicks go through it
		}
		
		
		/**
		 * Called from thanks by COMPLETE event
		 * @param	e
		 */
		private function restart(e:Event = null):void
		{
			
			timeoutHelper.stopMonitoring();//started in hideIntro()			
			
			thanks.removeEventListener(Thanks.COMPLETE, restart);	
			thanks.hide();
			
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.hide();
			
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.PRIVACY, showPrivacyPolicy);
			email.removeEventListener(Email.QUIT, restart);
			email.hide();
			
			quiz.removeEventListener(QuizDisplay.COMPLETE, quizComplete);
			quiz.removeEventListener(QuizDisplay.QUIT, restart);
			quiz.hide();
			
			showIntro();
		}
			
		
		private function doQuit(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	
	}
	
}