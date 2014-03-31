package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import com.greensock.TweenMax;
	import com.greensock.TimelineMax;//for video game question
	import com.greensock.easing.*;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	

	public class Demo extends MovieClip
	{		
		private var questions:Array;		
		private var ques:MovieClip;
		private var homeTimer:Timer;
		private var curSegment:int = 1;
		
		private var segTimer:Timer; //for the loader on the divider screen
		private var divTimer:Timer;
		
		
		
		
		public function Demo()
		{
			segTimer = new Timer(80);
			segTimer.addEventListener(TimerEvent.TIMER, nextSeg, false, 0, true);
			
			divTimer = new Timer(7000, 1);
			divTimer.addEventListener(TimerEvent.TIMER, q4, false, 0, true);
			
			homeTimer = new Timer(3000, 1);
			homeTimer.addEventListener(TimerEvent.TIMER, fadeHome, false, 0, true);
			
			topPart.y = 33;
			
			questions = new Array();
			questions.push(["WOULD YOU RATHER SCORE TICKETS TO:", "Spin each segment until all of your selections match...", "Done"]);
			questions.push(["WHAT BEST DESCRIBES YOU AT PARTIES?", "Tilt your device to maneuver the arrow toward your selection...", "Start"]);
			questions.push(["TO YOU, THE BEST PART OF THE OUTDOORS IS:", "Swipe the scene to locate a selection...", "Start"]);
			questions.push(["YOUR FAVORITE BAND HAS A NEW ALBUM. DO YOU:", "Select from one of the objects in the studio...", "Start"]);
			questions.push(["WOULD YOU RATHER PLAY A VIDEO GAME THAT IS:", "Maneuver the ball into the selection that best fits you...", "Start"]);
			questions.push(["THE BIG GAME IS ON. WOULD YOU RATHER BE:", "Slide the pieces until you move your choice into the destination slot...", "Start"]);
			
			home();
		}
		
		
	
		private function home():void
		{
			ques = new homer(); //lib clip
			ques.x = 238;
			ques.y = 224;
			addChildAt(ques, 1);
			homeTimer.start();
		}		
		private function fadeHome(e:TimerEvent):void
		{
			homeTimer.removeEventListener(TimerEvent.TIMER, fadeHome);
			TweenMax.to(ques, 1, { alpha:0, onComplete:q1 } );
		}
		
		
		
		private function q1():void
		{
			removeChild(ques);
			ques.alpha = 1;
			
			menuBar.gotoAndStop(2);
			
			ques = new question1(); //lib clip
			ques.x = 238;
			ques.y = 401;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[0][0];
			topPart.subTitle.text = questions[0][1];
			topPart.buttonText.text = questions[0][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q1_2 } );
		}
		private function q1_2():void
		{
			TweenMax.to(cursor, 1, { x:360, y:600, delay:1.5 } );
			TweenMax.to(cursor, .5, { y:550, alpha:0, delay:2.7, onComplete:spin1 } );
		}
		private function spin1():void
		{
			TweenMax.to(ques.spin1, 0, { blurFilter: { blurY:20 }} );
			TweenMax.to(ques.spin1, 1.5, { y: -1133, blurFilter: { blurY:0 },  onComplete:q1_3} );
			
		}
		private function q1_3():void
		{
			cursor.x = 968;			
			TweenMax.to(cursor, 0, { alpha:1, delay:.5 } );
			TweenMax.to(cursor, .75, { y:580, alpha:0, delay:.6, onComplete:spin2 } );
		}
		private function spin2():void
		{
			TweenMax.to(ques.spin3, 0, { blurFilter: { blurY:20 }} );
			TweenMax.to(ques.spin3, 2, { y: -465, blurFilter: { blurY:0 }, onComplete:q1_4} );		
		}
		private function q1_4():void
		{
			TweenMax.to(cursor, 0, { alpha:1, delay:.5 } );
			TweenMax.to(cursor, 1, { x:980, y:370, delay:.5, onComplete:q2 } );
		}
		
		
		
		private function q2():void
		{
			menuBar.gotoAndStop(3);//show party
			cursor.alpha = 0;
			removeChild(ques);
			TweenMax.to(topPart, 1, { y:33, onComplete:q2_2 } );
		}
		private function q2_2():void
		{
			ques = new question2();
			ques.x = 238;
			ques.y = 274;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[1][0];
			topPart.subTitle.text = questions[1][1];
			topPart.buttonText.text = questions[1][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q2_3} );
		}
		private function q2_3():void
		{
			cursor.x = 975;
			cursor.y = 360;
			TweenMax.to(cursor, 1, {alpha:1, x:980, y:370, delay:2, onComplete:q2_4 } );
		}
		private function q2_4():void
		{
			cursor.alpha = 0;
			TweenMax.to(topPart, 1, { y:33 } );
			TweenMax.to(ques.q2, 1, { alpha:1 } );
			TweenMax.to(ques, 1, { y:223, onComplete:q2_5 } );
		}
		private function q2_5():void
		{
			TweenMax.to(ques.selector, 6, { bezierThrough:[ { x:392, y:237 }, { x:226, y:227 },{x:201, y:122},{x:272,y:120} ], orientToBezier:false, onComplete:chooseMexican } );			
		}
		private function chooseMexican():void
		{
			TweenMax.to(ques.fader, 1, { alpha:.65 } );
			TweenMax.to(ques.chooser, 1, { alpha:1 } );
			
			cursor.x = 644;
			cursor.y = 280;
			TweenMax.to(cursor, 1, { alpha:1,  y:300, delay:3.5, onComplete:q3 } );
		}
		
		
		
		
		
		
		private function q3():void
		{
			menuBar.gotoAndStop(4);//show outdoors
			cursor.alpha = 0;
			removeChild(ques);
			
			ques = new question3();
			ques.x = 238;
			ques.y = 224;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[2][0];
			topPart.subTitle.text = questions[2][1];
			topPart.buttonText.text = questions[2][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q3_3} );
		}
		private function q3_3():void
		{
			cursor.x = 980;
			cursor.y = 350;
			TweenMax.to(cursor, 1, { alpha:1, y:370, delay:2 } );
			TweenMax.to(cursor, 0, { alpha:0, delay:3.5, onComplete:q3_4 } );
		}
		private function q3_4():void
		{			
			TweenMax.to(topPart, 1, { y:33, onComplete:q3Scroll } );			
		}		
		private function q3Scroll():void
		{
			cursor.x = 300;
			cursor.y = 450;
			TweenMax.to(cursor, 2, { x:375, alpha:1 } );
			TweenMax.to(ques.q3, 5, { x:0, delay:.5, onComplete:q3Fader } );
			TweenMax.to(cursor, .25, { alpha:0, delay:2 } );
		}
		private function q3Fader():void
		{
			TweenMax.to(ques.q3.fader, 1, { alpha:.65, onComplete:q3sel } );
		}
		private function q3sel():void
		{
			TweenMax.to(ques.q3.selector, 1, { alpha:1 } );
			cursor.x = 636;
			cursor.y = 550;
			TweenMax.to(cursor, 1, { alpha:1, y:565, delay:2 } );
			TweenMax.to(cursor, 0, { alpha:0, delay:3.5, onComplete:divider1} );
		}
		
		
		private function divider1():void
		{
			removeChild(ques);
			ques = new dividerOne();
			ques.x = 238;
			ques.y = 224;
			addChildAt(ques, 1);
			
			segTimer.start();
			divTimer.start(); //three seconds before calling q4
		}
		

		private function nextSeg(e:TimerEvent):void
		{
			ques.loader["s" + curSegment].alpha = 1;
			TweenMax.to(ques.loader["s" + curSegment], 1, {alpha:0});
			curSegment++;
			if(curSegment > 12){
				curSegment = 1;
			}
			
		}
		
		
		private function q4(e:TimerEvent):void
		{
			segTimer.reset();
			TweenMax.killAll();
			
			menuBar.gotoAndStop(5);//show party
			cursor.alpha = 0;
			removeChild(ques);
			
			ques = new question4();
			ques.x = 238;
			ques.y = 224;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[3][0];
			topPart.subTitle.text = questions[3][1];
			topPart.buttonText.text = questions[3][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q4_2} );			
		}
		private function q4_2():void
		{
			cursor.x = 970;
			cursor.y = 350;
			TweenMax.to(cursor, 1, { alpha:1, x:980, y:370, delay:2 } );
			TweenMax.to(cursor, 0, { alpha:0, delay:3.5, onComplete:q4_3 } );
		}
		private function q4_3():void
		{
			TweenMax.to(topPart, 1, { y:33, onComplete:q4_4 } );
		}
		private function q4_4():void
		{
			cursor.x = 790;
			cursor.y = 420;
			TweenMax.to(cursor, .25, { alpha:1 } );
			TweenMax.to(cursor, 3, { bezierThrough:[ { x:556, y:460 }, { x:624, y:580 } ], onComplete:q4_5 } );
		}
		private function q4_5():void
		{
			cursor.alpha = 0;
			TweenMax.to(ques.fader, 1, { alpha:.65 } );
			TweenMax.to(ques.chooser, 1, { alpha:1 } );
			TweenMax.to(ques.cpu, 1.5, { alpha:1, onComplete:q4_6 } );
		}
		private function q4_6():void
		{
			TweenMax.to(cursor, 1, { x:611, y:528, alpha:1, delay:2.5, onComplete:q5 } );
		}
		
		
		
		
		private function q5():void
		{
			menuBar.gotoAndStop(6);//show video game
			cursor.alpha = 0;
			removeChild(ques);
			
			ques = new question5();
			ques.x = 238;
			ques.y = 401;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[4][0];
			topPart.subTitle.text = questions[4][1];
			topPart.buttonText.text = questions[4][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q5_2} );
		}
		private function q5_2():void
		{
			cursor.x = 970;
			cursor.y = 350;
			TweenMax.to(cursor, 1, { alpha:1, x:980, y:370, delay:3 } );
			TweenMax.to(cursor, 0, { alpha:0, delay:4.5, onComplete:q5_3 } );
		}
		private function q5_3():void
		{
			TweenMax.to(topPart, 1, { y:33} );
			TweenMax.to(ques, 1, { y:223, onComplete:q5_4 } );
		}
		private function q5_4():void
		{
			ques.addEventListener("q5end", q5_5);
			ques.gotoAndPlay(2);
		}
		private function q5_5(e:Event):void
		{
			ques.removeEventListener("q5end", q5_5);
			//ques.removeChild(ball);
			
			TweenMax.to(ques.fader, 1, { alpha:.65 } );
			TweenMax.to(ques.pic, 1, { alpha:1 } );
			TweenMax.to(ques.chooser, 1.2, { alpha:1, onComplete:q5_6 } );
		}
		private function q5_6():void
		{
			cursor.x = 580;
			cursor.y = 280;
			TweenMax.to(cursor, 1, { x:586, y:286, alpha:1, delay:3 } );
			TweenMax.to(cursor, .25, { alpha:0, delay:4.25, onComplete:q6 } );
		}
		
		
		
		private function q6():void
		{
			menuBar.gotoAndStop(7);//show big game
			cursor.alpha = 0;
			removeChild(ques);
			
			ques = new question6();
			ques.x = 238;
			ques.y = 224;
			addChildAt(ques, 1);
			
			topPart.theText.text = questions[5][0];
			topPart.subTitle.text = questions[5][1];
			topPart.buttonText.text = questions[5][2];
			
			TweenMax.to(topPart, 1, { y:223, onComplete:q6_2} );
		}
		private function q6_2():void
		{
			cursor.x = 970;
			cursor.y = 350;
			TweenMax.to(cursor, 1, { alpha:1, x:980, y:370, delay:3 } );
			TweenMax.to(cursor, 0, { alpha:0, delay:4.5, onComplete:q6_3 } );
		}
		private function q6_3():void
		{
			TweenMax.to(topPart, 1, { y:33 } );
			TweenMax.to(ques.t1, 1, { y:"-95", delay:1.5, onComplete:q6_4 } );
		}
		private function q6_4():void
		{			
			TweenMax.to(ques.t2, 1, { x:"95"} );
			TweenMax.to(ques.t7, 1, { y:"95", delay:1 } );
			TweenMax.to(ques.t4, 1, { x:"95", delay:2 } );
			TweenMax.to(ques.t5, 1, { x:"95", delay:3 } );
			TweenMax.to(ques.t6, 1, { y:"-95", delay:4 } );
			TweenMax.to(ques.t3, 1, { x:"-95", delay:5 } );
			TweenMax.to(ques.t7, 1, { x:"-95", delay:6 } );
			TweenMax.to(ques.t4, 1, { y:"95", delay:7 } );
			TweenMax.to(ques.t5, 1, { x:"95", delay:8 } );
			TweenMax.to(ques.t7, 1, { y:"-95", delay:9 } );
			TweenMax.to(ques.t4, 1, { x:"-95", delay:10 } );
			TweenMax.to(ques.t2, 1, { x:"-95", delay:11 } );
			TweenMax.to(ques.t1, 1, { y:"95", delay:12 } );
			TweenMax.to(ques.t5, 1, { x:"95", delay:13, onComplete:q6_5 } );
		}
		private function q6_5():void
		{
			TweenMax.to(ques.fader, 1, { alpha:.65 } );
			TweenMax.to(ques.choiceOne, 1, { alpha:1 } );
			TweenMax.to(ques.chooser, 1.25, { alpha:1, onComplete:q6_6 } );
		}
		private function q6_6():void
		{
			cursor.x = 615;
			cursor.y = 320;
			TweenMax.to(cursor, 1, { x:625, y:305, delay:4, alpha:1, onComplete:conclusion } );
		}
		
		
		private function conclusion():void
		{
			menuBar.gotoAndStop(8);//show conclusion
			cursor.alpha = 0;
			removeChild(ques);
			
			ques = new result();
			ques.x = 238;
			ques.y = 218;
			addChildAt(ques, 1);
			
			cursor.x = 1025;
			cursor.y = 670;
			
			TweenMax.to(cursor, 1.25, {x:1033, y:677, alpha:1, delay:3, onComplete:conc2 } );
		}
		private function conc2():void
		{
			cursor.alpha = 0;
			ques.gotoAndStop(2);
			
			cursor.x = 1025;
			cursor.y = 670;
			
			TweenMax.to(cursor, 1.25, {x:1033, y:677, alpha:1, delay:3, onComplete:conc3 } );
		}
		private function conc3():void
		{
			cursor.alpha = 0;
			ques.gotoAndStop(3);
		}
	}
	
}