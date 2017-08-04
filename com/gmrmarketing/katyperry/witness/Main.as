package com.gmrmarketing.katyperry.witness
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var intro:Intro;
		private var introVideo:IntroVideo;
		private var selector:Selector;
		private var triple:TripleFace;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mainContainer = new Sprite();
			addChild(mainContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			introVideo = new IntroVideo();
			introVideo.container = mainContainer;
			
			selector = new Selector();
			selector.container = mainContainer;
			
			triple = new TripleFace();
			triple.container = mainContainer;
			
			init();
		}
		
		
		private function init():void
		{
			//triple.show();
			intro.addEventListener(Intro.COMPLETE, showIntroVideo, false, 0, true);
			intro.show();
		}
		
		
		private function showIntroVideo(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, showIntroVideo);
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
			
		}
		
	}
	
}