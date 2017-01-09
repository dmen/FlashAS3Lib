package com.gmrmarketing.goldenOne.cheerBooth2016
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.queue.*;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var bgContainer:Sprite;
		private var mainContainer:Sprite;
		private var logoContainer:Sprite;
		private var topContainer:Sprite;//for config dialog and cornerQuit/config
		
		private var liveBG:VideoBG;		
		private var logo:Logo;
		private var corner:Corner;
		
		private var intro:Intro;
		private var instructions:Instructions;
		private var review:Review;//review video
		private var reviewPhoto:ReviewPhoto;
		private var email:Email;
		private var thanks:Thanks;
		private var config:Config;
		private var whiteFlash:WhiteFlash;
		
		private var configCorner:CornerQuit;
		private var quitCorner:CornerQuit;
		
		private var tim:TimeoutHelper;
		
		private var recordingVideo:Boolean;//true if video, false if photo
		
		private var queue:Queue;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();
			
			bgContainer = new Sprite();
			mainContainer = new Sprite();
			logoContainer = new Sprite();
			topContainer = new Sprite();
			
			addChild(bgContainer);					
			addChild(mainContainer);
			addChild(logoContainer);
			addChild(topContainer);	
			
			liveBG = new VideoBG();
			liveBG.container = bgContainer;
			
			intro = new Intro();
			intro.container = mainContainer;
			
			instructions = new Instructions();
			instructions.container = mainContainer;
			
			review = new Review();
			review.container = mainContainer;
			
			reviewPhoto = new ReviewPhoto();
			reviewPhoto.container = mainContainer;
			
			email = new Email();
			email.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			config = new Config();
			config.container = topContainer;
			
			configCorner = new CornerQuit();
			configCorner.init(topContainer, "ul");
			configCorner.addEventListener(CornerQuit.CORNER_QUIT, openConfig, false, 0, true);
			
			quitCorner = new CornerQuit();
			quitCorner.init(topContainer, "ur");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, quitApp, false, 0, true);
			
			logo = new Logo();
			logo.container = logoContainer;
			
			corner = new Corner();
			corner.container = logoContainer;
			
			whiteFlash = new WhiteFlash();
			whiteFlash.container = logoContainer;
			
			queue = new Queue();
			queue.fileName = "golden1_cheerData";
			queue.service = new WebService();
			queue.start();
			
			recordingVideo = config.mode == "video" ? true : false;
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, reset, false, 0, true);
			tim.init(120000);			
			
			logo.show();//adds clip to container and begins a TweenMax loop - so don't killAll...
			corner.show();//just adds clip to container
			liveBG.show();
			
			reset();//kills all screens and then shows the intro
		}
		
		
		private function showInstructions(e:Event):void
		{
			tim.startMonitoring();
			
			corner.removeEventListener(Corner.SCREENTOUCHED, showInstructions);
			
			corner.addEventListener(Corner.CORNERCLICKED, showStartRecord, false, 0, true);
			corner.showInstructions(recordingVideo);
			
			intro.hide();
			//only allow config on the intro screen
			configCorner.removeEventListener(CornerQuit.CORNER_QUIT, openConfig);
			instructions.show();
		}
		
		
		/**
		 * shows the 5-4-3-2-1 countdown before recording or photo starts
		 * @param	e
		 */
		private function showStartRecord(e:Event):void
		{
			tim.buttonClicked();			
			corner.removeEventListener(Corner.CORNERCLICKED, showStartRecord);
			
			instructions.hide();
			
			TweenMax.delayedCall(.5, doCountdown);//wait for instructions to hide before begin count
			
			liveBG.removeGrid();			
		}
		
		
		private function doCountdown():void
		{
			corner.showStartRecord(recordingVideo);//changes corner text depending on video or photo: record or get ready
			corner.addEventListener(Corner.COUNTERELAPSED, startCountdownFinished, false, 0, true);
		}
		
		
		private function startCountdownFinished(e:Event):void
		{
			tim.buttonClicked();
			
			corner.removeEventListener(Corner.COUNTERELAPSED, startCountdownFinished);
			
			if (recordingVideo){
				
				corner.addEventListener(Corner.COUNTERELAPSED, stopit, false, 0, true);
				corner.addEventListener(Corner.CORNERCLICKED, stopit, false, 0, true);
				corner.showRecording();	//dispatches counterelapsed when complete			
				liveBG.beginRecording();//start publishing to fms
				
			}else{
				
				whiteFlash.show();//one sec fadeout
				liveBG.pause();
				liveBG.takeSnapshot();//takes the pic
				TweenMax.delayedCall(1, stopit);
				//liveBG.getSnapshot();//gets the taken pic
			}
		}
		
		
		/**
		 * called when recording the video is complete
		 * or when photo has been captured
		 * @param	e
		 */
		private function stopit(e:Event = null):void
		{		
			tim.buttonClicked();
			
			if (recordingVideo){
				liveBG.stopRecording();//encodes user.flv to an mp4
				corner.stopRecording();
				review.show();//displays user.flv
			}
			else{
				liveBG.unPause();
				reviewPhoto.show(liveBG.getSnapshot());
			}
			
			liveBG.showGrid();//puts back the grid and blur
			
			corner.removeEventListener(Corner.COUNTERELAPSED, stopit);
			corner.removeEventListener(Corner.CORNERCLICKED, stopit);
			
			corner.showSave(recordingVideo); //review screen - save & continue / retake
			corner.addEventListener(Corner.CORNERCLICKED, saveCapture, false, 0, true);
			corner.addEventListener(Corner.CANCELCLICKED, retakeCapture, false, 0, true);//TODO - fix for photo
		}
		
		
		/**
		 * save the photo or video
		 * shows the form screen
		 * @param	e
		 */
		private function saveCapture(e:Event):void
		{		
			tim.buttonClicked();
			
			corner.removeEventListener(Corner.CORNERCLICKED, saveCapture);
			corner.removeEventListener(Corner.CANCELCLICKED, retakeCapture);
			corner.showFinish(recordingVideo);
			
			if(recordingVideo){
				review.hide();
			}else{
				reviewPhoto.hide();
				TweenMax.delayedCall(2, liveBG.saveSnapshot);//saves the user snapshot to a guid named jpeg 
			}
			
			email.show();
			email.addEventListener(Email.COMPLETE, showThanks, false, 0, true);
			corner.addEventListener(Corner.CORNERCLICKED, submitEmail, false, 0, true);
			corner.addEventListener(Corner.CANCELCLICKED, reset, false, 0, true);
		}
		
		
		private function submitEmail(e:Event):void
		{
			tim.buttonClicked();
			email.submitPressed();
		}
		
		
		private function retakeCapture(e:Event):void
		{
			tim.buttonClicked();
			corner.removeEventListener(Corner.CANCELCLICKED, retakeCapture);
			
			if(recordingVideo){
				review.hide();
			}else{
				reviewPhoto.hide();
			}
			
			liveBG.removeGrid();
			corner.showStartRecord(recordingVideo);//changes corner text depending on video or photo: record or get ready
			corner.addEventListener(Corner.COUNTERELAPSED, startCountdownFinished, false, 0, true);
		}
		
		
		/**
		 * called once submit on form screen has happened - and form is valid
		 * @param	e
		 */
		private function showThanks(e:Event):void
		{
			tim.buttonClicked();
			
			var user:Object = email.data;
			user.file = liveBG.lastFileName;
			user.event = config.event;
			queue.add(user);
			
			corner.removeEventListener(Corner.CORNERCLICKED, submitEmail);
			email.removeEventListener(Email.COMPLETE, showThanks);
			corner.showThanks();//show finish button
			email.hide();
			thanks.show();
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete, false, 0, true);
			corner.addEventListener(Corner.CORNERCLICKED, thanksComplete, false, 0, true);			
		}
		
		
		private function thanksComplete(e:Event):void
		{
			tim.buttonClicked();
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);
			corner.removeEventListener(Corner.CORNERCLICKED, thanksComplete);
			thanks.hide();
			TweenMax.delayedCall(.5, reset);
		}
		
		
		/**
		 * called from constructor on first run
		 * called from timeoutHelper - tim - if the app times out
		 * @param	e
		 */
		private function reset(e:Event = null):void
		{			
			instructions.kill();			
			review.kill();
			reviewPhoto.kill();
			email.kill();
			thanks.kill();			
			corner.removeEventListener(Corner.CORNERCLICKED, showStartRecord);
			corner.removeEventListener(Corner.COUNTERELAPSED, startCountdownFinished);
			corner.removeEventListener(Corner.CORNERCLICKED, saveCapture);
			corner.removeEventListener(Corner.CANCELCLICKED, retakeCapture);
			corner.removeEventListener(Corner.CORNERCLICKED, submitEmail);			
			corner.removeEventListener(Corner.CANCELCLICKED, reset);
			corner.removeEventListener(Corner.COUNTERELAPSED, stopit);
			corner.removeEventListener(Corner.CORNERCLICKED, stopit);
			corner.removeEventListener(Corner.CORNERCLICKED, thanksComplete);
			email.removeEventListener(Email.COMPLETE, showThanks);
			thanks.removeEventListener(Thanks.COMPLETE, thanksComplete);
			
			TweenMax.delayedCall(1, addInstructionsListener);
			configCorner.addEventListener(CornerQuit.CORNER_QUIT, openConfig, false, 0, true);
			corner.showTouchToStart();	
			tim.stopMonitoring();	
			intro.show();
		}
		
		
		private function addInstructionsListener():void
		{
			corner.addEventListener(Corner.SCREENTOUCHED, showInstructions, false, 0, true);
		}
		
		
		/**
		 * called by cornerQuit event - four taps upper left
		 * @param	e
		 */
		private function openConfig(e:Event):void
		{
			config.addEventListener(Config.COMPLETE, updateMode, false, 0, true);
			config.show();
		}
		
		
		/**
		 * called whenever the config dialog closes
		 * @param	e
		 */
		private function updateMode(e:Event):void
		{
			config.removeEventListener(Config.COMPLETE, updateMode);
			recordingVideo = config.mode == "video" ? true : false;
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}