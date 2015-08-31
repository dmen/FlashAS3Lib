package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.media.*;
	import flash.utils.Timer;
	
	public class Capture extends EventDispatcher
	{
		private var clip:MovieClip;
		private var myContainter:DisplayObjectContainer;
		private var receInterview:Interview2;
		
		private var vid:Video;
		private var vidConnection:NetConnection;
		private var vidStream:NetStream;		
		private var cam:Camera;
		private var mic:Microphone;		
		
		private var timeToRespond:Number; //time allowed for user response - set in nextQuestion()
		private var questionNumber:int;
		
		private var stitcher:Stitcher;
		
		
		
		public function Capture()
		{
			vid = new Video();//users video
			vid.width = 640
			vid.height = 360;
			
			stitcher = new Stitcher();
			
			clip = new mcCapture();
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainter = c;
		}
		
		
		public function show():void
		{
			if (!myContainter.contains(clip)) {
				myContainter.addChild(clip);
			}			
			
			cam = Camera.getCamera();
			cam.setQuality(750000, 0);//bandwidth, quality
			cam.setMode(640, 360, 30, false);//width, height, fps, favorArea
			mic = Microphone.getMicrophone();
			
			vidConnection = new NetConnection();
			vidConnection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);	
			vidConnection.connect("rtmp://localhost/reesesGameDay");	
			
			clip.waitForRece.alpha = 0;
			clip.waitForRece.scaleX = clip.waitForRece.scaleY = 0;
			
			receInterview = new Interview2();
			receInterview.container = clip.receVid;
			receInterview.show();
			receInterview.addEventListener(Interview2.INTRO_COMPLETE, startQuestions);
			receInterview.playIntro();
			
			clip.userVid.addChild(vid);
			vid.x = 20; 
			vid.y = 20;
			vid.attachCamera(cam);
		}
		
		//callback for vidConnection object
		private function statusHandler(e:NetStatusEvent):void
		{
			if (e.info.code == "NetConnection.Connect.Success")
			{		
				vidStream = new NetStream(vidConnection);
				vidStream.client = { onMetaData:metaDataHandler, onCuePoint:cuePointHandler };				
			}
		}
		
		/**
		 * called once intro is done playing - fades in wait for rece text
		 * and then plays the first question
		 * @param	e
		 */
		private function startQuestions(e:Event):void
		{
			questionNumber = 0;
			receInterview.removeEventListener(Interview2.INTRO_COMPLETE, startQuestions);			
			receInterview.addEventListener(Interview2.OUTRO_COMPLETE, interviewComplete, false, 0, true);			
			TweenMax.to(clip.waitForRece, 1, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:nextQuestion } );
		}
		
		/**
		 * Rece asks a question
		 */
		private function nextQuestion():void
		{
			questionNumber++;
			
			TweenMax.to(clip.receVid, .5, { y:256, ease:Back.easeOut } );
			TweenMax.to(clip.userVid, .5, { y:325, ease:Back.easeOut } );			
			
			TweenMax.to(clip.whiteArrow, .5, { scaleX:1, x:997 } );			
			
			TweenMax.to(clip.waitForRece, .5, { y:726, ease:Back.easeOut } );
			
			receInterview.addEventListener(Interview2.QUESTION_COMPLETE, recordUser);
			timeToRespond = receInterview.nextQuestion();
		}
		
		
		private function recordUser(e:Event):void
		{
			TweenMax.to(clip.receVid, .5, { y:325, ease:Back.easeOut } );
			TweenMax.to(clip.userVid, .5, { y:256, ease:Back.easeOut } );
			TweenMax.to(clip.whiteArrow, .5, { scaleX:-1, x:907 } );
			TweenMax.to(clip.waitForRece, .5, { y:795, ease:Back.easeOut } );
			
			mic.setSilenceLevel(0);			
			mic.rate = 44; //KHz
			
			vidStream.attachCamera(cam);
			vidStream.attachAudio(mic);						
			
			vidStream.publish("user" + questionNumber.toString(), "record"); //flv
			
			var tim:Timer = new Timer(1000 * timeToRespond, 1);
			tim.addEventListener(TimerEvent.TIMER, stopRecording, false, 0, true);
			tim.start();
		}
		
		
		private function stopRecording(e:TimerEvent):void
		{			
			//clip.vid.attachCamera(null);
			vidStream.attachCamera(null);
			vidStream.attachAudio(null);	
			vidStream.close();
			
			nextQuestion();
		}
		
		
		/**
		 * called once rece outro video is finished playing
		 * @param	e
		 */
		private function interviewComplete(e:Event):void
		{
			receInterview.removeEventListener(Interview2.OUTRO_COMPLETE, interviewComplete);			
			stitcher.questions = receInterview.questions;
			
			//close the connection to FMS - fixes problem with 10 connection max
			vidConnection.close();
		}
		
		
		private function metaDataHandler(infoObject:Object):void
		{}

		
		private function cuePointHandler(infoObject:Object):void
		{}
	}
	
}