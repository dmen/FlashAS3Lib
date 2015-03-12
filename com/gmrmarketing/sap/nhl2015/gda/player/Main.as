package com.gmrmarketing.sap.nhl2015.gda.player
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import flash.utils.Timer;
	import flash.desktop.NativeApplication;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.AIRXML;
	
	
	public class Main extends MovieClip
	{
		private var screens:Array; //array of arrays - sub arrays contain objects with clip and data properties
		private var tasks:XMLList;//task list from config.xml
		private var taskFiles:Array; //array of loaded swfs defined in tasks
		private var screenIndex:int;
		private var taskIndex:int;//
		private var topTask:MovieClip;
		private var botTask:MovieClip;
		private var taskCheckTimer:Timer;
		
		private var bgContainer:Sprite;
		private var taskContainer:Sprite;
		private var airXML:AIRXML;		
		
		private var video:VideoLoader;
		
		
		public function Main()
		{
			Mouse.hide();
			
			bgContainer = new Sprite();
			addChild(bgContainer);
			taskContainer = new Sprite();
			addChild(taskContainer);//behind nfl logo
			
			taskCheckTimer = new Timer(1000);
			taskCheckTimer.addEventListener(TimerEvent.TIMER, checkFirstTask);
			
			video = new VideoLoader("bg.mp4", { width:768, height:512, x:0, y:0, autoPlay:true, container:bgContainer, repeat:-1 } );
			video.load();			
			video.playVideo();
			//video.addEventListener(VideoLoader.VIDEO_COMPLETE, done);
			
			airXML = new AIRXML();
			airXML.addEventListener(Event.COMPLETE, configLoaded);
			airXML.readXML();			
		}		
		private function done():void
		{
			video.playVideo();
		}
		
		private function configLoaded(e:Event):void
		{			
			var xm:XML = airXML.getXML();
			//var xm:XML = XML(URLLoader(e.currentTarget).data);
			
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
					thisTask.y = parseInt(thisScreen[j].@y);
					aScreen.push(thisTask);
				}
				
				aScreen[0].waitForTop = theScreens[i].@waitForTop == "true" ? true : false;			
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
			var l:Loader = Loader(LoaderInfo(e.target).loader);			
			screens[screenIndex][taskIndex].clip = MovieClip(l.content);			
			screens[screenIndex][taskIndex].clip.x = 640; //place loaded clips off screen right
			taskIndex++;
			if (taskIndex < screens[screenIndex].length) {
				loadTask();
			}else {
				taskIndex = 0;
				screenIndex++;
				if (screenIndex < screens.length) {					
					loadTask();
				}else {
					screenIndex = 0;
					taskIndex = 0;
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
			//screenIndex = 0;
			//taskIndex = 0;
			
			//while (screenIndex < screens.length) {
				MovieClip(screens[screenIndex][taskIndex].clip).init(screens[screenIndex][taskIndex].data);
				//taskIndex++;
				//if (taskIndex >= screens[screenIndex].length) {
					//taskIndex = 0;
					//screenIndex++;
				//}
			//}			
			
			//screenIndex = 0;
			//taskIndex = 0;
			
			//taskCheckTimer = new Timer(1000);
			//taskCheckTimer.addEventListener(TimerEvent.TIMER, checkFirstTask);
			//taskCheckTimer.start();
			
			
			taskCheckTimer.start();
		}
		
		
		/**
		 * Called once per second until the first task is ready
		 * ie its localCache variable has data in it
		 * @param	e
		 */
		private function checkFirstTask(e:TimerEvent):void
		{
			if (MovieClip(screens[screenIndex][taskIndex].clip).isReady()) {
				//taskCheckTimer.removeEventListener(TimerEvent.TIMER, checkFirstTask);
				taskCheckTimer.reset();
				
				taskIndex++;
				if (taskIndex >= screens[screenIndex].length) {
					taskIndex = 0;
					screenIndex++;
					if (screenIndex < screens.length) {					
						initTasks();
					}else {
						screenIndex = -1;
						showNextScreen();
					}
				}else {
					initTasks();
				}
				//screenIndex = -1;//showNextScreen() will increment to 0				
				//showNextScreen();
			}
		}
		
		
		private function showNextScreen():void
		{
			screenIndex++;
			if (screenIndex >= screens.length) {
				screenIndex = 0;
			}
			
			topTask = MovieClip(screens[screenIndex][0].clip);
			topTask.x = 640;//off screen right
			topTask.y = screens[screenIndex][0].y;
			if(screens[screenIndex][0].waitForTop){
				topTask.addEventListener("finished", taskComplete, false, 0, true);//only listen on the top task
			}
			//topTask.alpha = 0;
			if (!taskContainer.contains(topTask)) {
				taskContainer.addChild(topTask);
			}
			
			
			//topTask.show();//starts task timer
			TweenMax.to(topTask, .5, { x:0, ease:Linear.easeNone, onComplete:showTop } );
			
			//bottom task
			if (screens[screenIndex].length > 1) {
				botTask = MovieClip(screens[screenIndex][1].clip);
				botTask.x = 640;
				botTask.y = screens[screenIndex][1].y;
				if(!screens[screenIndex][0].waitForTop){
					botTask.addEventListener("finished", taskComplete, false, 0, true);//only listen on the top task
				}
				//botTask.alpha = 0;
				if (!taskContainer.contains(botTask)) {
					taskContainer.addChild(botTask);
				}
				TweenMax.to(botTask, .5, { x:0, ease:Linear.easeNone, delay:.2, onComplete:showBot } );
				//botTask.show();
			}
		}
		private function showTop():void
		{
			topTask.show();			
		}
		private function showBot():void
		{
			botTask.show();			
		}
		
		
		/**
		 * callback for complete listener on the top task
		 * @param	e FINISHED event
		 */
		private function taskComplete(e:Event):void
		{
			topTask.removeEventListener("finished", taskComplete);
			topTask.cleanup();
			
			if (botTask) {
				botTask.cleanup();
				botTask.y = -1500;
				//botTask = null;
			}
			
			topTask.y = -1500;
			showNextScreen();
		}	
	
	}
	
}