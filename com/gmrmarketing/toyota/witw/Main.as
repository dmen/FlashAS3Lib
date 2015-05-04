package com.gmrmarketing.toyota.witw
{
	import com.gmrmarketing.testing.Circle;
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	
	
	public class Main extends MovieClip
	{
		private const INTRO_TIME:int = 30; //seconds to show intro for each loop
		private const WALL_TIME:int = 60; //seconds to show main wall for each loop
		
		private var bg:Background;//circles with connecting lines
		
		private var intro:Intro;
		private var social:Social;
		private var startTime:Number;//epoch time when intro starts
		
		private var handleManager:HandleManager;//the grouping of handles in the middle of the social wall
		private var handleContainer:Sprite;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			bg = new Background();
			addChild(bg);
			bg.alpha = .35;
			
			social = new Social();
			social.addEventListener(Social.READY, socialReady);
			social.container = this;
			
			intro = new Intro();
			intro.container = this;
			
			handleContainer = new Sprite();
			addChild(handleContainer);
			handleManager = new HandleManager();
			handleManager.container = handleContainer;
			handleManager.defaults();
			
			init();
		}
		
		
		private function init(e:Event = null):void
		{
			social.removeEventListener(Social.FINISHED_HIDING, init);
			startTime = new Date().valueOf();
			intro.show();			
		}
		
		
		private function socialReady(e:Event = null):void
		{
			social.removeEventListener(Social.READY, socialReady);
			
			var elapsed:Number = Math.floor((new Date().valueOf() - startTime) / 1000);			
			
			if (elapsed > INTRO_TIME) {
				hideIntro();
			}else {
				TweenMax.delayedCall(INTRO_TIME - elapsed, hideIntro);
			}
		}
		
		
		private function hideIntro():void
		{
			intro.addEventListener(Intro.FINISHED_HIDING, showWall, false, 0, true);
			intro.hide();
		}
		
		
		private function showWall(e:Event):void
		{
			intro.removeEventListener(Intro.FINISHED_HIDING, showWall);
			social.show();
			TweenMax.delayedCall(1, handleManager.show);
			TweenMax.delayedCall(WALL_TIME, hideWall);
		}
		
		
		private function hideWall():void
		{
			social.addEventListener(Social.FINISHED_HIDING, restart);
			social.hide();//does a TweenMax.killAll()
			handleManager.hide();
		}
		
		
		private function restart(e:Event):void
		{
			social.removeEventListener(Social.FINISHED_HIDING, restart);
			startTime = new Date().valueOf();
			intro.show();
			socialReady();
		}
		
	}	
}