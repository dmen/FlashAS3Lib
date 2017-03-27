package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.queue.Queue;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;//for quiz
		private var progContainer:Sprite;//for progress bar
		
		private var intro:Intro;
		private var q1:Q1;
		private var q2:Q2;
		private var q2b:Q2B;
		private var q3:Q3;
		private var q4:Q4;
		private var q5:Q5;
		private var q6:Q6;
		private var progress:QuizProgress;//progress bar for quiz
		private var results:Results;
		private var takePhoto:TakePhoto;
		private var flash:WhiteFlash;
		private var form:Form;
		private var fin:Final;
		
		private var queue:Queue;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			mainContainer = new Sprite();
			progContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(progContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			q1 = new Q1();
			q1.container = mainContainer;
			
			q2 = new Q2();
			q2.container = mainContainer;
			
			q2b = new Q2B();
			q2b.container = mainContainer;
			
			q3 = new Q3();
			q3.container = mainContainer;
			
			q4 = new Q4();
			q4.container = mainContainer;
			
			q5 = new Q5();
			q5.container = mainContainer;
			
			q6 = new Q6();
			q6.container = mainContainer;
			
			progress = new QuizProgress();
			progress.container = progContainer;
			
			results = new Results();
			results.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			flash = new WhiteFlash();
			flash.container = mainContainer;
			
			form = new Form();
			form.container = mainContainer;
			
			fin = new Final();
			fin.container = mainContainer;
			
			queue = new Queue();
			queue.fileName = "metrx_booth";			
			queue.service = new HubbleServiceExtender();
			queue.start();
			
			//intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			//intro.show();
			test();
		}
		
		
		private function hideIntro(e:Event):void
		{			
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.addEventListener(Intro.HIDDEN, beginQuiz, false, 0, true);
			intro.hide();
		}
		
		
		private function beginQuiz(e:Event):void
		{		
			intro.removeEventListener(Intro.HIDDEN, beginQuiz);
			
			q1.addEventListener(Q1.COMPLETE, hideQ1, false, 0, true);
			q1.show();
			
			progress.show();
			progress.question = 1;
		}
		
		
		private function hideQ1(e:Event):void
		{
			q1.removeEventListener(Q1.COMPLETE, hideQ1);
			q1.addEventListener(Q1.HIDDEN, showQ2, false, 0, true);
			q1.hide();
		}
		
		
		private function showQ2(e:Event):void
		{
			q1.removeEventListener(Q1.HIDDEN, showQ2);
			
			q2.addEventListener(Q2.COMPLETE, hideQ2, false, 0, true);
			q2.show();
			
			progress.question = 2;
		}
		
		
		private function hideQ2(e:Event):void
		{
			q2.removeEventListener(Q2.COMPLETE, hideQ2);
			q2.addEventListener(Q2.HIDDEN, showQ2B, false, 0, true);
			q2.hide();
		}
		
		
		private function showQ2B(e:Event):void
		{
			q2.removeEventListener(Q2.HIDDEN, showQ2B);
			
			q2b.addEventListener(Q2B.COMPLETE, hideQ2B, false, 0, true);
			q2b.show();
			
			progress.question = 3;
		}
		
		
		private function hideQ2B(e:Event):void
		{
			q2b.removeEventListener(Q2B.COMPLETE, hideQ2B);
			
			q2b.addEventListener(Q2B.HIDDEN, showQ3, false, 0, true);
			q2b.hide();
		}
		
		
		private function showQ3(e:Event):void
		{
			q2b.removeEventListener(Q2B.HIDDEN, showQ3);
			
			q3.addEventListener(Q3.COMPLETE, hideQ3, false, 0, true);
			q3.show();
			
			progress.question = 4;
		}
		
		
		private function hideQ3(e:Event):void
		{
			q3.removeEventListener(Q3.COMPLETE, hideQ3);
			
			q3.addEventListener(Q3.HIDDEN, showQ4, false, 0, true);
			q3.hide();
		}
		
		
		private function showQ4(e:Event):void
		{
			q3.removeEventListener(Q3.HIDDEN, showQ4);
			
			q4.addEventListener(Q4.COMPLETE, hideQ4, false, 0, true);
			q4.show();
			
			progress.question = 5;
		}
		
		
		private function hideQ4(e:Event):void
		{
			q4.removeEventListener(Q4.COMPLETE, hideQ4);
			
			q4.addEventListener(Q4.HIDDEN, showQ5, false, 0, true);
			q4.hide();
		}
		
		
		private function showQ5(e:Event):void
		{
			q4.removeEventListener(Q4.HIDDEN, showQ5);			
			
			q5.addEventListener(Q5.COMPLETE, hideQ5, false, 0, true);
			q5.show();
			
			progress.question = 6;
		}
		
		
		private function hideQ5(e:Event):void
		{
			q5.removeEventListener(Q5.COMPLETE, hideQ5);
			
			q5.addEventListener(Q5.HIDDEN, showQ6, false, 0, true);
			q5.hide();
		}
		
		
		private function showQ6(e:Event):void
		{
			q5.removeEventListener(Q5.HIDDEN, showQ6);
			
			q6.addEventListener(Q6.COMPLETE, hideQ6, false, 0, true);
			q6.show();
			
			progress.question = 7;
		}
		
		
		private function hideQ6(e:Event):void
		{
			q6.removeEventListener(Q6.COMPLETE, hideQ6);
			
			q6.addEventListener(Q6.HIDDEN, showResults, false, 0, true);
			q6.hide();
		}
		
		
		private function showResults(e:Event):void
		{
			q6.removeEventListener(Q6.HIDDEN, showResults);
			progress.hide();
			
			results.addEventListener(Results.COMPLETE, hideResults, false, 0, true);
			results.show(q1.points + q2.points + q2b.points + q3.points + q4.points);
		}
		
		
		private function hideResults(e:Event):void
		{
			results.removeEventListener(Results.COMPLETE, hideResults);
			results.addEventListener(Results.HIDDEN, showPhoto, false, 0, true);
			results.hide();
		}
		
		
		private function showPhoto(e:Event):void
		{
			results.removeEventListener(Results.HIDDEN, showPhoto);
			
			takePhoto.addEventListener(TakePhoto.SHOW_WHITE, showFlash, false, 0, true);
			takePhoto.addEventListener(TakePhoto.COMPLETE, hidePhoto, false, 0, true);
			takePhoto.show(results.ranking);
		}
		
		
		private function showFlash(e:Event):void
		{
			//takePhoto.removeEventListener(TakePhoto.SHOW_WHITE, showFlash);
			flash.show();
			
			takePhoto.takePic();
			takePhoto.reviewPic();
		}
		
		
		private function hidePhoto(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOW_WHITE, showFlash);
			takePhoto.removeEventListener(TakePhoto.COMPLETE, hidePhoto);
			
			takePhoto.addEventListener(TakePhoto.HIDDEN, showForm, false, 0, true);
			takePhoto.hide();
		}
		
		
		
		private function showForm(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.HIDDEN, showForm);
			
			form.addEventListener(Form.COMPLETE, hideForm, false, 0, true);
			form.show();
		}		
		
		
		private function hideForm(e:Event):void
		{
			form.removeEventListener(Form.COMPLETE, hideForm);
			form.addEventListener(Form.HIDDEN, showFinal, false, 0, true);
			form.hide();			
		}
		
		
		private function showFinal(e:Event):void
		{			
			fin.addEventListener(Final.SHOWING, encodePic, false, 0, true);
			fin.show();
		}
		
		/**
		 * once final is showing do the encode as this will interrupt animation
		 * @param	e
		 */
		private function encodePic(e:Event):void
		{
			fin.removeEventListener(Final.SHOWING, encodePic);
			
			var encodeTimer:Timer = new Timer(10000, 1);
			encodeTimer.addEventListener(TimerEvent.TIMER, encodeComplete, false, 0, true);
			encodeTimer.start();
			
			takePhoto.encode();
		}
		
		
		private function encodeComplete(e:TimerEvent):void
		{
			var userData:Object = form.data; //object with fname,lname,email,optin properties - optin's value is "yes" or "no"
			userData.image = takePhoto.pic;
			userData.q1 = q1.choice; // 1 - 5
			userData.q2 = q2.choice; //array with two ints 1-4 and 5-8
			userData.q2b = q2b.choice; //array with two ints 1-4 and 5-8
			userData.q3 = q3.choice;//array with 4 elements - 1 is selected, 0 is not
			userData.q4 = q4.choice;//array with 4 elements - 1 is selected, 0 is not
			userData.q5 = q5.choice;//array with 6 elements - 1 is selected, 0 is not
			userData.q6 = q6.choice;//array with 4 elements - 1 is selected, 0 is not
			
			queue.add(userData);
			
			fin.addEventListener(Final.COMPLETE, restart, false, 0, true);
			fin.hide();
		}
		
		
		private function restart(e:Event = null):void
		{
			q1.reset();
			q2.reset();
			q2b.reset();
			q3.reset();
			q4.reset();
			q5.reset();
			q6.reset();
			progress.kill();
			takePhoto.kill();
			form.reset();
			
			fin.removeEventListener(Final.COMPLETE, restart);			
			
			intro.addEventListener(Intro.COMPLETE, hideIntro, false, 0, true);
			intro.show();
		}
		
		
		private function test():void
		{
			//form.addEventListener(Form.COMPLETE, hideForm, false, 0, true);
			//form.show();
			
			results.show(0);
			/*
			takePhoto.addEventListener(TakePhoto.SHOW_WHITE, showFlash, false, 0, true);
			takePhoto.addEventListener(TakePhoto.COMPLETE, hidePhoto, false, 0, true);
			takePhoto.show("legend");*/
		}
	}
	
}