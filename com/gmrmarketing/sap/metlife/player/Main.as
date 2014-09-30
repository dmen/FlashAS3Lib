package com.gmrmarketing.sap.metlife.player
{
	import com.gmrmarketing.sap.metlife.Flare;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.utils.Timer;
	
	
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
		private var sapRunSimple:MovieClip;//logo and text
		
		
		public function Main()
		{
			BGClip = new stadium(); //lib clip
			
			flareClip = new flare();//lib clip
			flareClip.x = 504;
			flareClip.y = 283;
			flareClip.blendMode = BlendMode.LIGHTEN;
			
			sapRunSimple = new runSimple();//lib clip
			sapRunSimple.x = 504;
			sapRunSimple.y = 283;
			
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/metlife/gda/config.xml?abc=" + String(new Date().valueOf()));
			var configLoader:URLLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);
			configLoader.load(req);
		}
		
		
		private function configLoaded(e:Event):void
		{			
			var xm:XML = XML(URLLoader(e.currentTarget).data);	
			trace(xm);
			tasks = xm.tasks.task;		
			currentTask = 0;
			taskFiles = new Array();
			loadTask();//begin loading task files
		}
		
		
		private function configError(e:IOErrorEvent):void
		{
			
		}
		
		
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
			if (contains(BGClip)) {
				//transition was running
				removeChild(BGClip);
				removeChild(sapRunSimple);
			}
			currentTask++;
			if (currentTask >= taskFiles.length) {
				currentTask = 0;
			}
			theTask = MovieClip(taskFiles[currentTask]);
			theTask.x = 0;
			theTask.y = 0;
			theTask.alpha = 0;
			addChild(theTask);
			TweenMax.to(theTask, .3, { alpha:1 } );
			theTask.addEventListener("finished", showTransition, false, 0, true);
			theTask.show();//starts task timer
		}
		
		
		private function showTransition(e:Event):void
		{
			theTask.removeEventListener("finished", showTransition);
			flareClip.scaleX = flareClip.scaleY = 0;
			flareClip.alpha = 1;
			addChild(flareClip);
			TweenMax.to(flareClip, .6, {scaleX:10, scaleY:10,ease:Linear.easeNone});
			TweenMax.to(flareClip, .3, {alpha:0,delay:.3, onStart:logoTransition, onComplete:removeFlare});
		}
		
		
		/**
		 * Called at the start of fading the flare out - ie when it's at full brightness
		 */
		private function logoTransition():void
		{
			removeChild(theTask); //remove the current task now behind the flare
			theTask.cleanup();
			
			//add the logo transition			
			addChildAt(BGClip, numChildren - 1);//add behind the flare
			addChild(sapRunSimple);
			sapRunSimple.scaleX = sapRunSimple.scaleY = .5;
			sapRunSimple.alpha = 1;
			
			TweenMax.to(sapRunSimple, .5, { scaleX:3, scaleY:3, delay:.75, alpha:0, onComplete:showNextTask } );
		}
		
		
		private function removeFlare():void
		{
			removeChild(flareClip);
		}
		
	
	}
	
}