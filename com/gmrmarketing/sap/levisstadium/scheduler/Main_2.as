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
	
	public class Main_2 extends MovieClip
	{		
		private var tasks:XMLList;//task list from config.xml - each task has file, time and config attributes
		private var taskFiles:Array; //array of loaded swfs defined in tasks
		private var currentTask:int;
		private var config:AIRXML;
		private var thisTask:MovieClip; //the loaded swf
		private var lastTask:MovieClip; //previous task swf - set in loadNextTask()
		private var lastTaskWas3D:Boolean;
		
		
		public function Main_2()
		{			
			Mouse.hide();				
			
			player.autoRewind = true;
			player.addEventListener(MetadataEvent.CUE_POINT, loop);//listen for cue point one frame back
			
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
		 * creates tasks array: each task has file, time and config attributes
		 * @param	e
		 */
		private function configReady(e:Event):void
		{	
			config.removeEventListener(Event.COMPLETE, configReady);
			tasks = AIRXML(e.currentTarget).getXML().tasks.task;	
			currentTask = 0;
			taskFiles = new Array();
			loadTask();//begin loading task files
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
			thisTask = MovieClip(l.content);
			
			taskFiles.push(thisTask);			
			
			currentTask++;
			if (currentTask < tasks.length()) {
				loadTask();
			}else {
				currentTask = 0;
				initTask();
			}
			
		}
		
		
		//called once all tasks are loaded into taskFiles array
		private function initTask():void
		{			
			thisTask = taskFiles[currentTask];		
			thisTask.addEventListener("ready", taskReadyToShow);
			thisTask.init(tasks[currentTask].@initData);//value or "" - causes the task to refresh data from the net	
		}
		
		
		/**
		 * Called once a task dispatches a 'ready' event
		 * adds taks off stage left
		 * @param	e
		 */
		private function taskReadyToShow(e:Event):void
		{
			thisTask.removeEventListener("ready", taskReadyToShow);
			thisTask.x = -768;//just off stage left
			addChild(thisTask);
			
			//lastTask is undefined until ?
			if (lastTask) {
				//thisTask is ready - stop the one on screen - and move it off stage right
				if (lastTaskWas3D) {					
					player.x = 0;//move video player back on screen
				}
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
			lastTask.kill();
			lastTask = null;
			TweenMax.killAll();
			TweenMax.to(thisTask, 1, { x:0, ease:Back.easeOut, onComplete:showTask } );	
			
		}
		
		
		/**
		 * Calls show() on the task
		 */
		private function showTask():void
		{			
			if (tasks[currentTask].@file == "usmap.swf") {				
				thisTask.addEventListener("3Dready", hidePlayer);
			}
			
			thisTask.show();
			
			//give the task one second to show before starting the clock
			TweenMax.delayedCall(1, startCount);
		}
		
		private function hidePlayer(e:Event):void
		{
			thisTask.removeEventListener("3Dready", hidePlayer);
			addEventListener(Event.ENTER_FRAME, updateMapVideo, false, 0, true);
			player.x = -768;
		}
		
		private function startCount():void
		{
			var taskTimer:Timer = new Timer(parseFloat(tasks[currentTask].@time) * 1000, 1);
			taskTimer.addEventListener(TimerEvent.TIMER, taskComplete, false, 0, true);
			taskTimer.start();
		}
		
		
		private function taskComplete(e:TimerEvent):void
		{
			lastTaskWas3D = false;
			if (tasks[currentTask].@file == "usmap.swf") {
				removeEventListener(Event.ENTER_FRAME, updateMapVideo);
				lastTaskWas3D = true;
			}
				
			currentTask++;
			if (currentTask >= tasks.length()) {
				currentTask = 0;
			}
			lastTask = thisTask;
			initTask();
		}
		
		private function updateMapVideo(e:Event):void
		{
			thisTask.videoUpdate(player);
		}
	}
	
}