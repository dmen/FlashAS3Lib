package com.gmrmarketing.pm.quickdraw
{
	import com.greensock.TweenLite;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.system.fscommand;
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.ui.Mouse;
	
	
	
	public class Engine extends Sprite
	{	
		private var controller:IController;
		private var crosshair:CrossHair;		
		private var irDebug:IRDebugger;
		private var intro:Intro;
		
		private var levelLoader:Loader;
		//private var currentTargets:Array;
		
		private var mouseInterceptor:Sprite;
		private var theLevel:MovieClip;
		
		private var channel:SoundChannel; //for playing sounds
		private var fire:shot; //lib sound
		
		private var totalShots:int; //total times gun was fired
		private var gameIsOver:Boolean = false;
		
		public function Engine()
		{	
			fscommand("allowscale", "true");
			fscommand("fullscreen", "true");
			
			
			Mouse.hide();
			
			fire = new shot();	//library sound
			
			//fscommand("exec", "test.exe"); //run compiled AHK script to start GlovePIE
			levelLoader = new Loader();
			
			controller = new MouseController();
			crosshair = new CrossHair();
			
			//shows the ir blobs that the camera sees
			//irDebug = new IRDebugger(controller, this);
			//for when using the MouseController can comment these two lines if using wii remote
			createMouseClickInterceptor();
			controller.containerToListenOn = mouseInterceptor;
			
			addChild(crosshair);			
			crosshair.mouseEnabled = false;
			addEventListener(Event.ENTER_FRAME, gameLoop);
			
			begin();
		}
		
		private function begin():void
		{
			gameIsOver = false;
			totalShots = 0;
			
			if(theLevel){
				if (contains(theLevel)) { 
					removeChild(theLevel);
				}
			}
			intro = new Intro(controller);
			intro.addEventListener(intro.CONTENT_LOADED, centerIntro, false, 0, true);
			addChild(intro); //shows initial 'Press trigger to begin'	
		}		
		
		
		/**
		 * Creates a big rect to absorb mouse clicks
		 */
		private function createMouseClickInterceptor():void
		{
			//left mouse is the trigger
			mouseInterceptor = new Sprite();
			mouseInterceptor.graphics.beginFill(0x00FF00, 0);
			mouseInterceptor.graphics.drawRect(0, 0, 1280, 720);
			mouseInterceptor.graphics.endFill();
			addChild(mouseInterceptor);
		}
		
		
		/**
		 * Called when intro is done loading, centers it
		 * @param	e
		 */
		private function centerIntro(e:Event):void
		{
			intro.removeEventListener(intro.CONTENT_LOADED, centerIntro);
			controller.addEventListener(controller.trigger, beginIntro, false, 0, true);
			intro.x = (stage.stageWidth - intro.width) * .5;
			intro.y = (stage.stageHeight - intro.height) * .5;
		}
		
		
		/**
		 * Calls intro.begin() once the trigger on the controller is pressed
		 * @param	e
		 */
		private function beginIntro(e:Event):void
		{
			controller.removeEventListener(controller.trigger, beginIntro);
			intro.begin(); //shows 'holster gun' message
			intro.addEventListener(intro.COMPLETE, removeIntro, false, 0, true);
		}
		
		
		/**
		 * Called when intro dispatches a COMPLETE event
		 * @param	e
		 */
		private function removeIntro(e:Event):void
		{
			intro.removeEventListener(intro.COMPLETE, removeIntro);
			
			removeChild(intro);
			intro = null;
			
			//currentTargets = new Array();
			//theLevel = new Level1();
			levelLoader.load(new URLRequest("levelOne.swf"));
			levelLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, l1Loaded, false, 0, true);
		}
		
		private function l1Loaded(e:Event):void
		{
			theLevel = MovieClip(levelLoader.content);
			addChildAt(theLevel,1); //addBehind the crossHair and in front of black bg shape
			//currentTargets = theLevel.getTargets();
			theLevel.addEventListener(theLevel.LEVEL_COMPLETE, gameOver, false, 0, true);
			controller.addEventListener(controller.trigger, shoot);
			theLevel.start();
		}
		
		private function gameOver(e:Event):void
		{
			gameIsOver = true;
			theLevel.removeEventListener(theLevel.LEVEL_COMPLETE, gameOver);
			theLevel.addTimes(totalShots);
		}
		
		/*
		private function grabTargets(e:Event):void
		{
			theLevel.removeEventListener(theLevel.CONTENT_LOADED, grabTargets);
			//currentTargets = theLevel.getTargets();						
		}
		*/
		
		/**
		 * Moves cross hair to position supplied from controller
		 * 
		 * @param	e ENTER_FRAME Event
		 */
		private function gameLoop(e:Event):void
		{				
			crosshair.setPosition(controller.getPosition());			
		}
		
		
		/**
		 * Called when controller trigger is pressed
		 * Poll cross hair position against current target list
		 * 
		 * @param	e controller.TRIGGER event
		 */
		private function shoot(e:Event):void
		{	
			if(!gameIsOver){
				channel = fire.play();
				totalShots++;
				
				var p:Point = crosshair.getPosition();
				//crosshair.animTest(); //pulse
				var currentTargets:Array = theLevel.getTargets();
				
				for (var i:int = 0; i < currentTargets.length; i++) {
				
					if (currentTargets[i].hitTestPoint(p.x, p.y, true)) {
						theLevel.shoot(currentTargets[i].name);
					}
				}
			}else {
				//game over - remove level and start over
				controller.removeEventListener(controller.trigger, shoot);				
				begin();
			}
		}
	
	}
	
}