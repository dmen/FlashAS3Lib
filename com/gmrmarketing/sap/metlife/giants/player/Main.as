package com.gmrmarketing.sap.metlife.giants.player
{
	import com.gmrmarketing.sap.metlife.player.LensFlares;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	
	public class Main extends MovieClip
	{
		private var tasks:XMLList;//task list from config.xml
		private var taskFiles:Array; //array of loaded swfs defined in tasks
		private var currentTask:int;
		private var theTask:MovieClip;
		private var taskCheckTimer:Timer;
		
		//for transitions
		private var BGClip:MovieClip; //stadium pic
		private var flareClip:MovieClip; //flare png
		
		//images for transition between screens
		private var sapRunSimple:MovieClip;//logo and text
		private var followSports:MovieClip;//logo and text
		private var transitionCounter:int; //take mod of this to switch between transitions
		
		private var taskContainer:Sprite;
		private var flareContainer:Sprite;
		private var lensFlares:LensFlares;//for horizontal flare
		
		
		public function Main()
		{
			addEventListener(Event.ACTIVATE, initWindowPosition);
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			//stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			BGClip = new stadium(); //lib clip
			
			flareClip = new flare();//lib clip
			flareClip.x = 504;
			flareClip.y = 283;
			flareClip.blendMode = BlendMode.LIGHTEN;
			
			sapRunSimple = new runSimple();//lib clip
			sapRunSimple.x = 504;
			sapRunSimple.y = 283;
			
			followSports = new follow();
			followSports.x = 504;
			followSports.y = 283;
			
			transitionCounter = 1;
			
			taskContainer = new Sprite();
			addChild(taskContainer);
			
			flareContainer = new Sprite();
			addChild(flareContainer);
			
			lensFlares = new LensFlares();
			lensFlares.setContainer(flareContainer);
			
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/metlife/giants/gda/config.xml?abc=" + String(new Date().valueOf()));
			var configLoader:URLLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);
			configLoader.load(req);
		}
		
		
		//used to put player within ticker app
		private function initWindowPosition(e:Event):void
		{
			NativeApplication.nativeApplication.activeWindow.x = 0;
			NativeApplication.nativeApplication.activeWindow.y = 160;
		}
		
		
		private function configLoaded(e:Event):void
		{			
			var xm:XML = XML(URLLoader(e.currentTarget).data);
			tasks = xm.tasks.task;		
			currentTask = 0;
			taskFiles = new Array();
			loadTask();//begin loading task files
		}
		
		
		private function configError(e:IOErrorEvent):void
		{
			
		}
		
		
		/**
		 * loadTask and taskLoaded loop until all tasks defined in the config file are loaded.
		 */
		private function loadTask():void
		{
			var r:URLRequest = new URLRequest(tasks[currentTask].@file);
			var taskLoader:Loader = new Loader();		
			taskLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, taskLoaded, false, 0, true);
			taskLoader.load(r);
		}
		
		
		private function taskLoaded(e:Event):void
		{
			var l:Loader = Loader(LoaderInfo(e.target).loader);
			theTask = MovieClip(l.content);
			
			taskFiles.push(theTask);			
			
			currentTask++;
			if (currentTask < tasks.length()) {
				loadTask();
			}else {
				initTasks();
			}
		}
		
		
		/**
		 * Called once all tasks are loaded into taskFiles array
		 * calls init on all tasks then waits for th first task to be ready
		 */
		private function initTasks():void
		{			
			for (var i:int = 0; i < tasks.length(); i++){
				MovieClip(taskFiles[i]).init(tasks[i].@initData);//value or "" - causes the task to refresh data from the net
			}
			taskCheckTimer = new Timer(1000);
			taskCheckTimer.addEventListener(TimerEvent.TIMER, checkFirstTask, false, 0, true);
			taskCheckTimer.start();
		}
		
		
		/**
		 * Called once per second until the first task is ready
		 * ie its localCache variable has data in it
		 * @param	e
		 */
		private function checkFirstTask(e:TimerEvent):void
		{
			if (MovieClip(taskFiles[0]).isReady()) {
				taskCheckTimer.reset();
				currentTask = -1;//showNextTask() will increment to 0
				showNextTask();
			}
		}
		
		
		private function showNextTask():void
		{
			if (taskContainer.contains(BGClip)) {
				//transition was running
				taskContainer.removeChild(BGClip);				
			}
			if (taskContainer.contains(sapRunSimple)) {
				taskContainer.removeChild(sapRunSimple);
			}
			if (taskContainer.contains(followSports)) {
				taskContainer.removeChild(followSports);
			}
			currentTask++;
			if (currentTask >= taskFiles.length) {
				currentTask = 0;
			}
			theTask = MovieClip(taskFiles[currentTask]);
			theTask.x = 0;
			theTask.y = 0;
			theTask.alpha = 0;
			if (!taskContainer.contains(theTask)) {
				taskContainer.addChild(theTask);
			}
			
			lensFlares.show(theTask.getFlareList());
			
			TweenMax.to(theTask, .5, { alpha:1 } );
			theTask.addEventListener("finished", showTransition, false, 0, true);
			theTask.show();//starts task timer
		}
		
		
		private function showTransition(e:Event):void
		{
			theTask.removeEventListener("finished", showTransition);
			flareClip.scaleX = flareClip.scaleY = 0;
			flareClip.alpha = 1;
			taskContainer.addChild(flareClip);
			TweenMax.to(flareClip, .6, {scaleX:10, scaleY:10,ease:Linear.easeNone});
			TweenMax.to(flareClip, .3, {alpha:0,delay:.3, onStart:logoTransition, onComplete:removeFlare});
		}
		
		
		/**
		 * Called at the start of fading the flare out - ie when it's at full brightness
		 */
		private function logoTransition():void
		{			
			theTask.cleanup();
			
			//removeChild(theTask); //remove the current task now behind the flare
			theTask.y = -1500;
			
			//add the logo transition			
			taskContainer.addChildAt(BGClip, numChildren - 1);//add behind the flare - stadium background image
			var tranClip:MovieClip;
			if (transitionCounter % 2 == 0) {
				taskContainer.addChild(sapRunSimple);
				tranClip = sapRunSimple;				
			}else{
				taskContainer.addChild(followSports);
				tranClip = followSports;
			}
			tranClip.scaleX = tranClip.scaleY = .5;
			tranClip.alpha = 1;
			
			transitionCounter++;
			
			TweenMax.to(tranClip, 2.5, { scaleX:.55, scaleY:.55 } );
			TweenMax.to(tranClip, .5, { scaleX:3, scaleY:3, delay:2, alpha:0, onComplete:showNextTask } );
		}
		
		
		private function removeFlare():void
		{
			taskContainer.removeChild(flareClip);
		}
		
	
	}
	
}