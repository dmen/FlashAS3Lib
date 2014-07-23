package com.gmrmarketing.sap.levisstadium.scheduler
{
	import flash.display.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.AIRXML;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	public class Main extends MovieClip
	{
		private var config:AIRXML;
		private var tasks:XMLList;//task list from config.xml - each task has file, time and config attributes
		private var currentTask:int;
		private var taskLoader:Loader;
		private var thisTask:MovieClip; //the loaded swf
		private var lastTask:MovieClip;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();			
			
			taskLoader = new Loader();
			taskLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, taskLoaded, false, 0, true);
			
			config = new AIRXML(); //reads config.xml in the apps folder
			config.addEventListener(Event.COMPLETE, configReady, false, 0, true);
			config.readXML();
		}
		
		
		private function configReady(e:Event):void
		{
			tasks = config.getXML().tasks.task;			
			currentTask = 0;
			loadNextTask();
		}
		
		/**
		 * Called from configReady() and taskComplete()
		 */
		private function loadNextTask():void
		{
			if (thisTask) {
				trace("calling task stop");
				//thisTask.doStop();//was plain stop()
				lastTask = thisTask;
				//thisTask.hide();
			}
			var r:URLRequest = new URLRequest(tasks[currentTask].@file);		
			taskLoader.load(r);//calls taskLoaded() when complete
		}
		
		
		private function taskLoaded(e:Event):void
		{
			thisTask = MovieClip(taskLoader.contentLoaderInfo.content);
			thisTask.addEventListener("ready", taskReadyToShow, false, 0, true);
			thisTask.x = -1920;
			
			addChild(thisTask);
			
			//if there is a config attribute on the task then setConfig will be called with that data
			if (tasks[currentTask].@config != "") {
				thisTask.setConfig(tasks[currentTask].@config);
			}
		}
		
		private function taskReadyToShow(e:Event):void
		{			
			thisTask.removeEventListener("ready", taskReadyToShow);
			
			if (lastTask) {
				lastTask.doStop();//moved from loadNextTask() - waits for next task to be loaded 
				TweenMax.to(lastTask, 1, { x:1920, ease:Back.easeIn, onComplete:hideLastTask } );
			}else {
				TweenMax.to(thisTask, 1, { x:0, ease:Back.easeOut, onComplete:showTask } );
			}
			
			var taskTimer:Timer = new Timer(parseFloat(tasks[currentTask].@time) * 1000, 1);
			taskTimer.addEventListener(TimerEvent.TIMER, taskComplete, false, 0, true);
			taskTimer.start();
		}
		
		
		private function taskComplete(e:TimerEvent):void
		{
			currentTask++;
			if (currentTask >= tasks.length()) {
				currentTask = 0;
			}
			loadNextTask();
		}
		
		private function hideLastTask():void
		{
			TweenMax.to(thisTask, 1, { x:0, ease:Back.easeOut, onComplete:showTask } );
			lastTask.hide();
		}
		
		private function showTask():void
		{
			thisTask.show();
		}
		
	}
	
}