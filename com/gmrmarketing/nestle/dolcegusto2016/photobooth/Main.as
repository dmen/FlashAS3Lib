package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import fl.transitions.*;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.Utility;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.geom.Point;
	import com.gmrmarketing.nestle.dolcegusto2016.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Logger;
	import com.gmrmarketing.utilities.LoggerAIR;
	
	
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
		private var thanks:Thanks;
		
		private var takePhoto:TakePhoto;
		
		private var netStuff:NetStuff;//for posting user data
		private var moodControl:MoodControl;
		
		private var timeoutHelper:TimeoutHelper;
		
		private var cq:CornerQuit;
		private var quitDialog:QuitDialog;
		
		private var privacyPolicy:PrivacyPolicy;		
		
		private var log:Logger;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			netStuff = new NetStuff();
			
			moodControl = new MoodControl();
			moodControl.addEventListener(MoodControl.LOG_READY, writeToLog, false, 0, true);
			
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
			
			thanks = new Thanks();
			thanks.container = mainContainer;			
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			sideBar = new mcSideBar();
			sideBarContainer.addChild(sideBar);
			sideBar.scaleX = sideBar.scaleY = .92;
			sideBar.y = 240;
			
			cq = new CornerQuit();
			cq.init(cornerContainer, "ll");
			cq.customLoc(1, new Point(0, 1674));
			cq.addEventListener(CornerQuit.CORNER_QUIT, showQuitDialog);
			
			quitDialog = new QuitDialog();
			quitDialog.container = cornerContainer;
			
			timeoutHelper = TimeoutHelper.getInstance();
			timeoutHelper.addEventListener(TimeoutHelper.TIMED_OUT, restart, false, 0, true);
			timeoutHelper.init(120000);//2 minutes without an interaction
			
			var d:Date = new Date();
			var ts:String = (d.getMonth() + 1) + "/" + d.getDate() + "
			log = Logger.getInstance();
			log.logger = new LoggerAIR();
			log.log("APP BEGIN " + (d.getMonth() + 1
			config = new Config();
			config.addEventListener(Config.COMPLETE, init, false, 0, true);
		}
		
		
		private function writeToLog(e:Event):void
		{
			log.log(moodControl.log);
		}
		
		/**
		 * called once config.json is loaded and parsed
		 * @param	e
		 */
		private function init(e:Event):void
		{
			config.removeEventListener(Config.COMPLETE, init);
			
			//need to find bridge IP from the ID in the config file
			netStuff.addEventListener(NetStuff.GOTIP, showIntro, false, 0, true);
			netStuff.getBridgeIP(config.bridgeID);
		}
		
		
		private function showIntro(e:Event):void
		{			
			netStuff.removeEventListener(NetStuff.GOTIP, showIntro);
			
			//builds baseURL for bridge commands
			moodControl.init(netStuff.IP, config.bridgeUser, config.serproxyPort);
			//moodControl.moodColor = config.getColor("woods");			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.addEventListener(Intro.INTRO_TIMEOUT_SHOW, showIntroTimeoutImage, false, 0, true);
			intro.addEventListener(Intro.INTRO_TIMEOUT_HIDE, hideIntroTimeoutImage, false, 0, true);
			intro.show();	
			
			showQuitDialog();//show at app start for setting bg to paris
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
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.hide();
			
			timeoutHelper.startMonitoring();
			
			email.show();
			email.addEventListener(Email.COMPLETE, hideEmail, false, 0, true);
			email.addEventListener(Email.PRIVACY, showPrivacyPolicy, false, 0, true);
			email.addEventListener(Email.QUIT, restart, false, 0, true);
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
			
				//show user prefs
				calcResults.addEventListener(CalculatingResults.COMPLETE, hideCalc, false, 0, true);
				calcResults.show();			
				
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
			calcResults.show();
		}
		
		
		private function hideCalc(e:Event):void
		{
			calcResults.removeEventListener(CalculatingResults.COMPLETE, hideCalc);
			calcResults.hide();	
			
			//get the mood string from the result key object
			//paris, beach, or woods
			var key:Object;
			if (email.userDidQuiz){
				key = quiz.getResult(email.result);
			}else{
				key = quiz.getResult();
				postUserData();
			}
			
			moodControl.mood = key.mood;//string mood name
			moodControl.moodColor = config.getColor(key.mood);//xy values for light colors
			moodControl.playMoodSound();//based on mood set previously
			moodControl.advanceBG();
			
			hideSideBar();
			
			takePhoto.addEventListener(TakePhoto.COMPLETE, hidePhoto, false, 0, true);
			takePhoto.addEventListener(TakePhoto.MOVE_BG, advanceBackground, false, 0, true);
			takePhoto.show(key.mood);
			
		}
		
		
		private function hidePhoto(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.COMPLETE, hidePhoto);
			takePhoto.removeEventListener(TakePhoto.MOVE_BG, advanceBackground);
			takePhoto.hide();			
			
			showSideBar();
			
			thanks.addEventListener(Thanks.COMPLETE, postPhoto, false, 0, true);
			//send the bitmapdata from takePhoto to show - turns to B64 string while thank you message is displayed
			thanks.show(true, takePhoto.photo);			
		}
		
		
		/**
		 * called by listener if the user presses the advance background button in takePhoto
		 * @param	e
		 */
		private function advanceBackground(e:Event):void
		{
			var newMood:String;
			
			//paris - beach - woods
			switch(moodControl.mood){
				case "paris":
					newMood = "beach";
					break;
				case "beach":
					newMood = "woods";
					break;
				case "woods":
					newMood = "paris";
					break;
			}
			
			moodControl.mood = newMood;
			moodControl.moodColor = config.getColor(newMood);//xy values for light colors
			moodControl.playMoodSound();//based on mood set previously
			moodControl.advanceBG();
			takePhoto.setOverlay(newMood);
		}
		
		
		
		/**
		 * called when thanks is complete when the photobooth is running
		 * when thanks is done the b64 string is ready from thanks
		 * @param	e
		 */
		private function postPhoto(e:Event):void
		{
			thanks.removeEventListener(Thanks.COMPLETE, postPhoto);
			
			var ud:Object = new Object();
			ud.Email = email.userData.Email;
			ud.Image = thanks.imageString;
			ud.Timestamp = Utility.hubbleTimeStamp;
			
			netStuff.postPhoto(ud);		
			
			restart();
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
		
		
		/**
		 * Called from thanks by COMPLETE event
		 * @param	e
		 */
		private function restart(e:Event = null):void
		{			
			moodControl.turnOffLights();
			moodControl.turnOffSound();
			
			timeoutHelper.stopMonitoring();//started in hideIntro()
			
			thanks.removeEventListener(Thanks.COMPLETE, postPhoto);
			thanks.removeEventListener(Thanks.COMPLETE, restart);	
			thanks.hide();
			
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.QUIT, restart);
			email.removeEventListener(Email.PRIVACY, showPrivacyPolicy);
			email.hide();
						
			quiz.removeEventListener(QuizDisplay.COMPLETE, quizComplete);
			quiz.removeEventListener(QuizDisplay.QUIT, restart);
			quiz.hide();
			
			takePhoto.removeEventListener(TakePhoto.COMPLETE, hidePhoto);
			takePhoto.removeEventListener(TakePhoto.MOVE_BG, advanceBackground);
			takePhoto.hide();			
			
			privacyPolicy.hide();			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			//changes call to action text based on pb or just cafe
			intro.show();
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
		 * called at app start, or by four taps lower left
		 * @param	e
		 */
		private function showQuitDialog(e:Event = null):void
		{
			quitDialog.show();
			quitDialog.addEventListener(QuitDialog.ADVANCE_BG, advanceBG, false, 0, true);
			quitDialog.addEventListener(QuitDialog.QUIT, doQuit, false, 0, true);
		}
		
		
		private function advanceBG(e:Event):void
		{
			moodControl.doAdvance();
		}
		
		
		private function doQuit(e:Event):void
		{
			moodControl.turnOffLights();
			moodControl.disconnect();//closes socket to serproxy
			NativeApplication.nativeApplication.exit();
		}
		
	
	}
	
}