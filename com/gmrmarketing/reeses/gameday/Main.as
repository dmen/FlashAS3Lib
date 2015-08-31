package com.gmrmarketing.reeses.gameday
{
	import flash.display.*;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip
	{
		private var vb:VideoBackground;
		private var intro:Intro;
		private var instructions:Instructions;
		private var capture:Capture;
		
		private var vidContainer:Sprite;
		private var mainContainer:Sprite;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();

			vidContainer = new Sprite();
			mainContainer = new Sprite();
			
			addChild(vidContainer);
			addChild(mainContainer);
			
			vb = new VideoBackground(vidContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			instructions = new Instructions();
			instructions.container = mainContainer;
			
			capture = new Capture();
			capture.container = mainContainer;
			
			intro.addEventListener(Intro.BEGIN, showInstructions, false, 0, true);
			intro.show();
		}
		
		
		private function showInstructions(e:Event):void
		{
			intro.removeEventListener(Intro.BEGIN, showInstructions);
			intro.hide();
			instructions.addEventListener(Instructions.COMPLETE, showCapture);
			instructions.show();
		}
		
		
		private function showCapture(e:Event):void
		{
			instructions.removeEventListener(Instructions.COMPLETE, showCapture);
			instructions.hide();
			capture.show();
		}
	}
	
}