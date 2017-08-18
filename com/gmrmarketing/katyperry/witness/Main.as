package com.gmrmarketing.katyperry.witness
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.geom.*;
	import brfv4.BRFManager;//in the ANE
	import com.gmrmarketing.utilities.CornerQuit;
	import com.gmrmarketing.utilities.queue.Queue;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPEGEncoder;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var intro:Intro;
		private var current:CurrentCustomer;
		private var introVideo:IntroVideo;
		private var selector:Selector;
		private var solo:SoloFace;
		private var result:Result;
		private var thanks:Thanks;
		
		private const _width:Number = 1280;//Camera
		private const _height:Number = 720;
		private var brfManager:BRFManager;
		
		private var cityDialog:CityDialog;
		private var cityCorner:CornerQuit;
		private var quitCorner:CornerQuit;
		
		private var queue:Queue;
		
		private var tim:TimeoutHelper;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();
			
			queue = new Queue();
			queue.fileName = "katyPerryQ";
			queue.service = new HubbleServiceExtender();

			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			current = new CurrentCustomer();
			current.container = mainContainer;
			
			introVideo = new IntroVideo();
			introVideo.container = mainContainer;
			
			selector = new Selector();
			selector.container = mainContainer;
			
			solo = new SoloFace();
			solo.container = mainContainer;		
			
			result = new Result();
			result.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			brfManager = new BRFManager();
			
			brfManager.init(new Rectangle(0, 0, _width, _height), new Rectangle(0, 0, _width, _height), "com.gmrmarketing.brftest");			
	
			//set params as percentages of screen size
			brfManager.setFaceDetectionParams(_height * 0.20, _height, 12, 8);
			brfManager.setFaceTrackingStartParams(_height * 0.20, _height, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(_height * 0.15, _height, 40, 55, 32);	
			
			cityDialog = new CityDialog();
			cityDialog.container = mainContainer;
			
			cityCorner = new CornerQuit();
			quitCorner = new CornerQuit();
			cityCorner.init(cornerContainer, "ll");
			quitCorner.init(cornerContainer, "ur");
			quitCorner.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			tim = TimeoutHelper.getInstance();
			tim.addEventListener(TimeoutHelper.TIMED_OUT, timReset);
			tim.init(45000);
			
			init();
			//result.show(new BitmapData(1080, 1080, false, 0xff0000));
		}
		
		
		private function init():void
		{	
			tim.stopMonitoring();
			
			cityCorner.addEventListener(CornerQuit.CORNER_QUIT, showCityDialog, false, 0, true);			
			cityCorner.show();
			
			intro.addEventListener(Intro.COMPLETE, showCurrent, false, 0, true);
			intro.show();
		}
		
		
		private function showCurrent(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, showCurrent);
			
			tim.startMonitoring();
			
			//only listen for city dialog on intro screen
			cityCorner.removeEventListener(CornerQuit.CORNER_QUIT, showCityDialog);
			cityCorner.hide();//remove the corner click areas
			
			intro.hide();
			
			current.addEventListener(CurrentCustomer.COMPLETE, showIntroVideo, false, 0, true);
			current.show();
			
			
		}
		
		/**
		 * callack from CurrentCustomer - once yes/no is selected
		 * @param	e
		 */
		private function showIntroVideo(e:Event):void
		{
			current.removeEventListener(CurrentCustomer.COMPLETE, showIntroVideo);
			current.hide();			
			
			tim.stopMonitoring();
			
			introVideo.addEventListener(IntroVideo.COMPLETE, showSelector, false, 0, true);
			introVideo.show("intro");
		}
		
		private function showSelector(e:Event):void
		{
			introVideo.removeEventListener(IntroVideo.COMPLETE, showSelector);
			introVideo.hide();
			
			tim.startMonitoring();
			
			selector.addEventListener(Selector.COMPLETE, showSelection, false, 0, true);
			selector.show();
		}
		
		
		private function backFromPhoto(e:Event):void
		{
			solo.removeEventListener(SoloFace.COMPLETE, showResults);
			solo.removeEventListener(SoloFace.BACK, showSelector);
			solo.hide();
			
			selector.addEventListener(Selector.COMPLETE, showSelection, false, 0, true);
			selector.show();
		}
		
		
		/**
		 * callback from selector - once user presses solo or group
		 * @param	e
		 */
		private function showSelection(e:Event = null):void
		{
			tim.buttonClicked();
			
			selector.removeEventListener(Selector.COMPLETE, showSelection);
			selector.hide();
			
			var sel:String = selector.selection;//solo or group			
			if (sel == "solo"){
				
				brfManager.setNumFacesToTrack(1);
				solo.addEventListener(SoloFace.COMPLETE, showResults, false, 0, true);
				solo.addEventListener(SoloFace.BACK, backFromPhoto, false, 0, true);
				solo.show(brfManager, false, cityDialog.getColorValues(), cityDialog.cityImages);
				
			}else{
				
				brfManager.setNumFacesToTrack(4);
				solo.addEventListener(SoloFace.COMPLETE, showResults, false, 0, true);
				solo.addEventListener(SoloFace.BACK, backFromPhoto, false, 0, true);
				solo.show(brfManager, true, cityDialog.getColorValues(), cityDialog.cityImages);
				
			}
		}
		
		
		private function showResults(e:Event):void
		{
			solo.removeEventListener(SoloFace.COMPLETE, showResults);
			solo.removeEventListener(SoloFace.BACK, showSelector);
			solo.hide();
			
			result.addEventListener(Result.COMPLETE, showExitVideo, false, 0, true);
			result.addEventListener(Result.RETAKE, retakeFromResults, false, 0, true);
			result.show(solo.userPhoto);
		}
		
		
		private function showExitVideo(e:Event):void
		{
			result.removeEventListener(Result.COMPLETE, showExitVideo);
			result.removeEventListener(Result.RETAKE, retakeFromResults);
			result.hide();
			
			tim.stopMonitoring();
			
			introVideo.addEventListener(IntroVideo.COMPLETE, showThanks, false, 0, true);
			introVideo.show("exit");
		}
		
		
		private function showThanks(e:Event):void
		{
			introVideo.removeEventListener(IntroVideo.COMPLETE, showThanks);
			introVideo.hide();
			
			thanks.addEventListener(Thanks.SHOWING, sendResults, false, 0, true);
			thanks.show();
		}
		
		
		private function retakeFromResults(e:Event):void
		{
			result.removeEventListener(Result.COMPLETE, showThanks);
			result.removeEventListener(Result.RETAKE, retakeFromResults);
			result.hide();
			
			//should also keep their makeup/triple/nomakeup selection
			showSelection();//photo screen with solo/group already selected - they can go back to reselect that
		}
		
		/**
		 * called 200ms after thanks shows itself 
		 * @param	e
		 */
		private function sendResults(e:Event):void		
		{
			thanks.removeEventListener(Thanks.SHOWING, sendResults);			
			
			var b64:String;
			var bmd:BitmapData = solo.userPhoto;
			
			var jpeg:ByteArray = getJpeg(bmd);			
			var imageString:String = getBase64(jpeg);
			
			var theData:Object = result.data;//isEmail,num,opt			
			theData.customer = current.customer; //bool
			theData.image = imageString;			
			
			queue.add(theData);
			
			var a:Timer = new Timer(6000, 1);
			a.addEventListener(TimerEvent.TIMER, doReset, false, 0, true);
			a.start();
		}
		
		
		private function doReset(e:TimerEvent):void
		{			
			thanks.hide();
			init();
		}
		
		
		//timeout callback
		private function timReset(e:Event):void
		{
			current.hide();//are you a current customer
			selector.hide();//solo - group
			solo.hide();
			result.hide();
			
			init();
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPEGEncoder = new JPEGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		
		private function showCityDialog(e:Event):void
		{
			intro.disableRemote();
			cityDialog.addEventListener(CityDialog.COMPLETE, hideCityDialog, false, 0, true);
			cityDialog.show();
		}
		
		
		private function hideCityDialog(e:Event):void
		{
			cityDialog.removeEventListener(CityDialog.COMPLETE, hideCityDialog);
			intro.enableRemote();//listens for spacebar again
		}
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}