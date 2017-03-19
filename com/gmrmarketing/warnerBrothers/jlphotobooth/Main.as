package com.gmrmarketing.warnerBrothers.jlphotobooth
{
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		
		private var intro:Intro;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;

			mainContainer = new Sprite();
			
			addChild(mainContainer);
			
			
			intro = new Intro();
			intro.container = mainContainer;
			intro.show();
			
			TweenMax.to(black, 5, {alpha:0, delay:.1});
		
		}
		
	}
	
}