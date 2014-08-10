package com.gmrmarketing.sap.levisstadium.scheduler
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.AIRXML;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import fl.video.*;
	
	public class Main extends MovieClip
	{		
		private var tasks:XMLList;//task list from config.xml - each task has file, time and config attributes
		private var currentTask:int;
		private var config:AIRXML;
		private var thisTask:MovieClip; //the loaded swf
		private var lastTask:MovieClip; //previous task swf - set in loadNextTask()
		
		
		public function Main()
		{			
			Mouse.hide();				
			
			player.autoRewind = true;
			player.addEventListener(MetadataEvent.CUE_POINT, loop);
			
			config = new AIRXML(); //reads config.xml in the apps folder
			config.addEventListener(Event.COMPLETE, configReady);
			config.readXML();
		}
		
		
		/**
		 * for looping the video background
		 * @param	e
		 */
		private function loop(e:MetadataEvent):void
		{
			player.seek(0);
			player.play();
		}
		
		
		/**
		 * Called when the config.xml file has been loaded
		 * @param	e
		 */
		private function configReady(e:Event):void
		{			
			tasks = AIRXML(e.currentTarget).getXML().tasks.task;	
			currentTask = 0;
			loadNextTask();
		}
		
		
		/**
		 * Called from configReady() and taskComplete()
		 * loads the next task
		 * stores the current task in lastTask, if defined
		 */
		private function loadNextTask():void
		{
			if (thisTask) {
				lastTask = thisTask;
			}
			var r:URLRequest = new URLRequest(tasks[currentTask].@file);
			var taskLoader:Loader = new Loader();		
			taskLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, taskLoaded, false, 0, true);
			taskLoader.load(r);
		}
		
		
		/**
		 * Called once a task swf has been loaded
		 * Calls setConfig() on the task if the xml tasks config attribute has a value
		 * Waits for a 'ready' event from the task
		 * @param	e
		 */
		private function taskLoaded(e:Event):void
		{
			var l:Loader = Loader(LoaderInfo(e.target).loader);
			thisTask = MovieClip(l.content);
			thisTask.addEventListener("ready", taskReadyToShow, false, 0, true);
			thisTask.x = -768;
			
			//if there is a config attribute on the task then setConfig will be called with that data
			if (tasks[currentTask].@config != "") {
				thisTask.setConfig(tasks[currentTask].@config);
			}
			
			addChild(thisTask);
		}
		
		
		/**
		 * Called once a task dispatches a 'ready' event
		 * @param	e
		 */
		private function taskReadyToShow(e:Event):void
		{			
			thisTask.removeEventListener("ready", taskReadyToShow);
			
			if (lastTask) {
				//thisTask is ready - stop the one on screen - and move it off stage right
				lastTask.doStop();
				TweenMax.to(lastTask, 1, { x:1920, ease:Back.easeIn, onComplete:hideLastTask } );
			}else {
				TweenMax.to(thisTask, 1, { x:0, ease:Back.easeOut, onComplete:showTask } );
			}
		}
		
		
		/**
		 * Tween callback - called once lastTask has moved off stage right
		 * Moves the current task onto the stage
		 */
		private function hideLastTask():void
		{
			TweenMax.to(thisTask, 1, { x:0, ease:Back.easeOut, onComplete:showTask } );			
			lastTask = null;
		}
		
		
		private function showTask():void
		{
			thisTask.show();
			
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
		
	}
	
}