package com.gmrmarketing.sap.superbowl.gda.player
{
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
		private var screens:Array; //array of arrays - sub arrays contain objects with clip and data properties
		private var tasks:XMLList;//task list from config.xml
		private var taskFiles:Array; //array of loaded swfs defined in tasks
		private var screenIndex:int;
		private var taskIndex:int;//
		private var topTask:MovieClip;
		private var taskCheckTimer:Timer;
		
		private var taskContainer:Sprite;
		
		
		public function Main()
		{
			Mouse.hide();
			
			taskContainer = new Sprite();
			addChild(taskContainer);
			
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/SuperBowl49/gda/config.xml?abc=" + String(new Date().valueOf()));
			var configLoader:URLLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);
			configLoader.load(req);
			
			addEventListener(Event.ENTER_FRAME, update);
		}		
		
		

		private function update(e:Event):void
		{
			barBottom.rotation += .1;
			barTop.rotation -= .05;
		}
		
		
		private function configLoaded(e:Event):void
		{			
			var xm:XML = XML(URLLoader(e.currentTarget).data);
			
			var theScreens:XMLList = xm.screens.screen;
			screens = new Array();
			
			//trace(screens[0].task[0].@file);
			for (var i:int; i < theScreens.length(); i++) {
				
				var aScreen:Array = new Array();
				var thisScreen:XMLList = theScreens[i].task; //1 or 2 tasks
				
				for (var j:int = 0; j < thisScreen.length(); j++) {//1 or 2
					var thisTask:Object = { };
					thisTask.file = thisScreen[j].@file;
					thisTask.data = thisScreen[j].@initData;
					
					aScreen.push(thisTask);
					trace( i, j, thisScreen[j].@file, thisScreen[j].@initData);
				}
				
				screens.push(aScreen);
			}
			
			
			screenIndex = 0;
			taskIndex = 0;
			
			loadTask();
		}
		
		
		private function configError(e:IOErrorEvent):void
		{
			
		}
		
		
		/**
		 * loadTask and taskLoaded loop until all tasks defined in the config file are loaded.
		 */		
		private function loadTask():void
		{			
			var r:URLRequest = new URLRequest(screens[screenIndex][taskIndex].file);
			var taskLoader:Loader = new Loader();		
			taskLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, taskLoaded, false, 0, true);
			taskLoader.load(r);		
		}
		
		
		private function taskLoaded(e:Event):void
		{
			trace("taskLoaded()");
			var l:Loader = Loader(LoaderInfo(e.target).loader);			
			screens[screenIndex][taskIndex].clip = MovieClip(l.content);			
			
			taskIndex++;
			if (taskIndex < screens[screenIndex].length) {
				loadTask();
			}else {
				taskIndex = 0;
				screenIndex++;
				if (screenIndex < screens.length) {					
					loadTask();
				}else{
					initTasks();
				}
			}
		}
		
		
		/**
		 * Called once all tasks are loaded into taskFiles array
		 * calls init on all tasks then waits for the first task to be ready
		 */
		private function initTasks():void
		{		
			trace("initTasks()");
			screenIndex = 0;
			taskIndex = 0;
			
			while (screenIndex < screens.length) {
				MovieClip(screens[screenIndex][taskIndex].clip).init(screens[screenIndex][taskIndex].data);
				taskIndex++;
				if (taskIndex >= screens[screenIndex].length) {
					taskIndex = 0;
					screenIndex++;
				}
			}			
			
			screenIndex = 0;
			taskIndex = 0;
			
			taskCheckTimer = new Timer(1000);
			taskCheckTimer.addEventListener(TimerEvent.TIMER, checkFirstTask);
			taskCheckTimer.start();
		}
		
		
		/**
		 * Called once per second until the first task is ready
		 * ie its localCache variable has data in it
		 * @param	e
		 */
		private function checkFirstTask(e:TimerEvent):void
		{
			trace("checkFirstTask");
			if (MovieClip(screens[screenIndex][taskIndex].clip).isReady()) {
				taskCheckTimer.removeEventListener(TimerEvent.TIMER, checkFirstTask);
				taskCheckTimer.reset();
				//here we go
				
				screenIndex = -1;//showNextScreen() will increment to 0				
				showNextScreen();
			}
		}
		
		
		private function showNextScreen():void
		{
			screenIndex++;
			if (screenIndex >= screens.length) {
				screenIndex = 0;
			}
			
			topTask = MovieClip(screens[screenIndex][0].clip);
			topTask.x = 0;
			topTask.y = 0;
			//topTask.alpha = 0;
			if (!taskContainer.contains(topTask)) {
				taskContainer.addChild(topTask);
			}			
			
			//TweenMax.to(topTask, .5, { alpha:1 } );
			topTask.addEventListener("finished", taskComplete, false, 0, true);
			topTask.show();//starts task timer
		}
		
		
		private function taskComplete(e:Event):void
		{
			topTask.removeEventListener("finished", taskComplete);
			topTask.cleanup();			
			
			topTask.y = -1500;
			showNextScreen();
		}	
	
	}
	
}