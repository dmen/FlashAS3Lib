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
		
		
		private function loadNextTask():void
		{
			if (thisTask) {
				thisTask.hide();
			}
			var r:URLRequest = new URLRequest(tasks[currentTask].@file);		
			taskLoader.load(r);
		}
		
		
		private function taskLoaded(e:Event):void
		{
			thisTask = MovieClip(taskLoader.contentLoaderInfo.content);
			addChild(thisTask);
			
			//if there is a config attribute on the task then setConfig will be called with that data
			if (tasks[currentTask].@config != "") {
				thisTask.setConfig(tasks[currentTask].@config);
			}
			
			thisTask.show();
			thisTask.x = -1500;
			TweenMax.to(thisTask, 2, { x:0, ease:Back.easeOut } );
			
			var taskTimer:Timer = new Timer(parseFloat(tasks[currentTask].@time) * 60 * 1000, 1);
			taskTimer.addEventListener(TimerEvent.TIMER, taskComplete, false, 0, true);
			taskTimer.start();
		}
		
		
		private function taskComplete(e:TimerEvent):void
		{
			currentTask++;
			if (currentTask >= tasks.length()) {
				currentTask = 0;
			}
			TweenMax.to(thisTask, 2, { x:1950, ease:Back.easeIn, onComplete:loadNextTask } );
		}
		
	}
	
}