package com.gmrmarketing.katyperry.witness
{	
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip
	{
		private var mainContainer:Sprite;
		private var triple:TripleFace;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			//Mouse.hide();

			mainContainer = new Sprite();
			addChild(mainContainer);
			
			triple = new TripleFace();
			triple.container = mainContainer;
			triple.show();
		}
	}
	
}