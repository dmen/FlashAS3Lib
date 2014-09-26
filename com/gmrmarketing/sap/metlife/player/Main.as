package com.gmrmarketing.sap.metlife.player
{
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
		
		public function Main()
		{
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/metlife/gda/config.xml?");
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
		
		
		private function checkFirstTask(e:TimerEvent):void
		{
			if (MovieClip(taskFiles[0]).isReady()) {
				taskCheckTimer.reset();
				currentTask = 0;
				showNextTask();
			}
		}
		
		
		private function showNextTask():void
		{
			theTask = MovieClip(taskFiles[currentTask]);
			theTask.x = 0;
			theTask.y = 0;
			addChild(theTask);
			theTask.show();
		}
		
		
	
	}
	
}