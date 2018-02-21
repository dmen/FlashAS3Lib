package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var config:Config;
		private var intro:Intro;
		private var email:Email;
		private var quiz:QuizDisplay;
		private var calcResults:CalculatingResults;
		private var results:Results;
		private var thanks:Thanks;
		
		private var netStuff:NetStuff;//for posting user data
		private var moodControl:MoodControl;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			netStuff = new NetStuff();
			
			moodControl = new MoodControl();
			
			mainContainer = new Sprite();
			addChild(mainContainer);
			
			config = new Config();
			config.addEventListener(Config.COMPLETE, showIntro, false, 0, true);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			quiz = new QuizDisplay();
			quiz.container = mainContainer;
			
			calcResults = new CalculatingResults();
			calcResults.container = mainContainer;
			
			results = new Results();
			results.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
		}
		
		
		private function showIntro(e:Event):void
		{
			config.removeEventListener(Config.COMPLETE, showIntro);			
			moodControl.bridgeInit(config.bridgeIP, config.bridgeUser);
			
			intro.show(config.isPhotoBooth);			
			
			//value,title,exp,image
			//var t:Object = {"value":"a", "title":"Coffee Is My Not-So-Secret Lover!", "exp":"Nothing compares to the way you feel when you have a cup of coffee in your hands. It adds warmth and sweetness to any situation and makes you feel like everything is right in the world. You love the way coffee tastes, the way it smells, the way it makes you feel — you love everything about it!", "image":"Result_FriendsWithBenefits.png"};
			//results.show(t);
		}
		
		
		private function hideIntro(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.hide();
			
			email.show(config.isPhotoBooth);
			email.addEventListener(Email.COMPLETE, hideEmail, false, 0, true);
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
			email.hide();
			
			if (email.userDidQuiz){
				
				calcResults.addEventListener(CalculatingResults.COMPLETE, hideCalc, false, 0, true);
				calcResults.show(email.userDidQuiz, config.isPhotoBooth);
				
			}else{
				
				quiz.addEventListener(QuizDisplay.COMPLETE, quizComplete, false, 0, true);
				quiz.show();
			}			
		}		
		
		
		private function quizComplete(e:Event):void
		{
			quiz.hide();
			quiz.removeEventListener(QuizDisplay.COMPLETE, quizComplete);
			
			calcResults.addEventListener(CalculatingResults.COMPLETE, hideCalc, false, 0, true);
			calcResults.show(email.userDidQuiz, config.isPhotoBooth);//show Welcome Back if user has done the quiz previously
		}
		
		
		private function hideCalc(e:Event):void
		{
			calcResults.removeEventListener(CalculatingResults.COMPLETE, hideCalc);
			calcResults.hide();
			
			if(!config.isPhotoBooth){
			
				results.addEventListener(Results.COMPLETE, hideResults, false, 0, true);
				
				if (email.userDidQuiz){
					
					//show results returned from server
					results.show(quiz.getResult(email.result));
					
				}else{
					
					results.show(quiz.getResult());
					
					//need to post user data
					var ud:Object = email.userData;//Email, FName, OptIn
					ud.Result = quiz.getResult().value;
					
					//post new user and result to the DB
					netStuff.postResults(ud);					
				}
				
			}else{
				
				//photobooth
				
				//get the mood string from the result key object
				//mountains, beach, or woods
				var moo:String;
				if (email.userDidQuiz){
					moo = quiz.getResult(email.result).mood;
				}else{
					moo = quiz.getResult().mood;
				}
				
				moodControl.moodColor = config.getColor(moo);
				
				
				
			}
		}
		
		
		private function hideResults(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.hide();
			
			thanks.addEventListener(Thanks.COMPLETE, restart, false, 0, true);
			thanks.show();			
		}
		
		
		private function restart(e:Event):void
		{
			email.removeEventListener(Email.COMPLETE, hideEmail);
			email.removeEventListener(Email.QUIT, restart);
			email.hide();
			
			thanks.removeEventListener(Thanks.COMPLETE, restart);			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			//changes call to action text based on pb or just cafe
			intro.show(config.isPhotoBooth);
		}
				
	
	}
	
}