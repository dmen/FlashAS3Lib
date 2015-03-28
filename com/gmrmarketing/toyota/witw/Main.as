package com.gmrmarketing.toyota.witw
{
	import com.gmrmarketing.testing.Circle;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private var bg:Background;
		private var intro:Intro;
		private var social:Social;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			bg = new Background();
			addChild(bg);
			bg.alpha = .2;
			
			social = new Social();
			social.addEventListener(Social.READY, hideIntro);
			social.container = this;
			
			intro = new Intro();
			intro.container = this;
			intro.show();
			
			//TODO - fist time through wait for complete from web/social
			//TweenMax.delayedCall(20, hideIntro);
		}
		
		
		private function hideIntro(e:Event):void
		{
			social.removeEventListener(Social.READY, hideIntro);
			//wait for hide intro to be done
			intro.addEventListener(Intro.FINISHED, showWall, false, 0, true);
			intro.hide();
		}
		
		
		private function showWall(e:Event):void
		{
			intro.removeEventListener(Intro.FINISHED, showWall);
			social.show();
		}
	}	
}