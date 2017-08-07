package com.gmrmarketing.katyperry.witness
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.geom.*;
	import brfv4.BRFManager;//in the ANE
	import com.gmrmarketing.utilities.CornerQuit;
	
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var cornerContainer:Sprite;
		private var intro:Intro;
		private var introVideo:IntroVideo;
		private var selector:Selector;
		private var solo:SoloFace;
		
		private const _width:Number = 1280;//Camera
		private const _height:Number = 720;
		private var brfManager:BRFManager;
		
		private var cityDialog:CityDialog;
		private var cityCorner:CornerQuit;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mainContainer = new Sprite();
			cornerContainer = new Sprite();
			
			addChild(mainContainer);
			addChild(cornerContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			introVideo = new IntroVideo();
			introVideo.container = mainContainer;
			
			selector = new Selector();
			selector.container = mainContainer;
			
			solo = new SoloFace();
			solo.container = mainContainer;			
			
			brfManager = new BRFManager();
			var resolution:Rectangle = new Rectangle(0, 0, _width, _height);
			
			brfManager.init(resolution, resolution, "com.gmrmarketing.brftest");			
			
			var maxFaceSize:Number = _height;		
	
			//set params as percentages of screen size
			brfManager.setFaceDetectionParams(maxFaceSize * 0.20, maxFaceSize, 12, 8);
			brfManager.setFaceTrackingStartParams(maxFaceSize * 0.20, maxFaceSize, 32, 35, 32);
			brfManager.setFaceTrackingResetParams(maxFaceSize * 0.15, maxFaceSize, 40, 55, 32);	
			
			cityDialog = new CityDialog();
			cityDialog.container = mainContainer;
			
			cityCorner = new CornerQuit();
			cityCorner.init(cornerContainer, "ll");
			
			init();
		}
		
		
		private function init():void
		{			
			cityCorner.addEventListener(CornerQuit.CORNER_QUIT, showCityDialog, false, 0, true);
			
			intro.addEventListener(Intro.COMPLETE, showIntroVideo, false, 0, true);
			intro.show();
		}
		
		
		private function showIntroVideo(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, showIntroVideo);
			
			//only listen for city dialog on intro screen
			cityCorner.removeEventListener(CornerQuit.CORNER_QUIT, showCityDialog);
			
			intro.hide();
			
			introVideo.addEventListener(IntroVideo.COMPLETE, showSelector, false, 0, true);
			introVideo.show();
		}
		
		
		private function showSelector(e:Event):void
		{
			introVideo.removeEventListener(IntroVideo.COMPLETE, showSelector);
			introVideo.hide();
			
			selector.addEventListener(Selector.COMPLETE, showSelection, false, 0, true);
			selector.show();
		}
		
		
		private function showSelection(e:Event):void
		{
			selector.removeEventListener(Selector.COMPLETE, showSelection);
			selector.hide();
			
			var sel:String = selector.selection;//solo or group			
			if (sel == "solo"){
				
				brfManager.setNumFacesToTrack(1);
				solo.addEventListener(SoloFace.COMPLETE, soloComplete, false, 0, true);
				solo.show(brfManager, false);
				
			}else{
				
				brfManager.setNumFacesToTrack(4);
				solo.addEventListener(SoloFace.COMPLETE, soloComplete, false, 0, true);
				solo.show(brfManager, true);
				
			}
		}
		
		
		private function soloComplete(e:Event):void
		{
			solo.removeEventListener(SoloFace.COMPLETE, soloComplete);
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
		
	}
	
}