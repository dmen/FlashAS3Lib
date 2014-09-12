/**
 * Scheduler V2
 */
package com.gmrmarketing.sap.levisstadium.scheduler
{	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.AIRXML;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import fl.video.*;
	import com.gmrmarketing.sap.ticker.Encoder;
	
	
	public class Main_2 extends MovieClip
	{		
		private var tasks:XMLList;//task list from config.xml - each task has file, time and config attributes
		private var taskFiles:Array; //array of loaded swfs defined in tasks
		private var currentTask:int;
		
		private var thisTask:MovieClip; //the loaded swf
		private var lastTask:MovieClip; //previous task swf - set in loadNextTask()
		
		private var encoder:Encoder;//for writing to video
		private var encoderImage:BitmapData;
		
		private var config:AIRXML;
		private var configLoader:URLLoader;
		
		
		public function Main_2()
		{			
			Mouse.hide();				
			
			encoder = new Encoder(768, 512);
			encoderImage = new BitmapData(768, 512, false, 0x000000);
			
			player.autoRewind = true;
			player.addEventListener(MetadataEvent.CUE_POINT, loop);//listen for cue point one frame back
			
			var req:URLRequest = new URLRequest("http://design.gmrstage.com/sap/levis/gda/config.xml");
			configLoader = new URLLoader();
			configLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			configLoader.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);			
			configLoader.load(req);
			//configError();//TESTING - forces loading of local config
		}
		
		
		/**
		 * Called when a cuepoint is passed in the video
		 * for looping the video background
		 * @param	e
		 */
		private function loop(e:MetadataEvent):void
		{
			player.seek(0);
			player.play();
		}		
		
		/**
		 * called when config.xml has been loaded from the server
		 * creates tasks array: each task has file, time and config attributes 
		 * @param	e
		 */
		private function configLoaded(e:Event):void
		{
			configLoader.removeEventListener(Event.COMPLETE, configReady);
			configLoader.removeEventListener(IOErrorEvent.IO_ERROR, configError);
			
			configLoader.removeEventListener(Event.COMPLETE, configLoaded);
			var xm:XML = XML(configLoader.data);
			
			tasks = xm.tasks.task;
			if(xm.record == "true"){
				encoder.record();
				addEventListener(Event.ENTER_FRAME, addFrame);
			}
			currentTask = 0;
			taskFiles = new Array();
			loadTask();//begin loading task files
		}
		
		
		private function configError(e:IOErrorEvent = null):void
		{
			configLoader.removeEventListener(Event.COMPLETE, configReady);
			configLoader.removeEventListener(IOErrorEvent.IO_ERROR, configError);
			
			config = new AIRXML(); //reads config.xml in the apps folder
			config.addEventListener(Event.COMPLETE, configReady);
			config.readXML();
		}
		
		/**
		 * Called when the config.xml file has been loaded from local disk
		 * creates tasks array: each task has file, time and config attributes
		 * @param	e
		 */
		private function configReady(e:Event):void
		{	
			config.removeEventListener(Event.COMPLETE, configReady);
			tasks = config.getXML().tasks.task;
			
			if(config.getXML().record == "true"){
				encoder.record();
				addEventListener(Event.ENTER_FRAME, addFrame);
			}
			
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
			thisTask.addEventListener("error", abortTask);
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
			thisTask.removeEventListener("error", abortTask);
			thisTask.x = -768;//just off stage left
			addChild(thisTask);
			
			//lastTask is undefined until ?
			if (lastTask) {				
				lastTask.doStop();
				TweenMax.to(lastTask, 1, { x:1920, onComplete:hideLastTask } );
			}else {				
				TweenMax.to(thisTask, .75, { x:0, onComplete:showTask } );
			}			
		}
		
		
		/**
		 * Called if error event is received from the task
		 * @param	e
		 */
		private function abortTask(e:Event):void
		{
			thisTask.removeEventListener("ready", taskReadyToShow);
			thisTask.removeEventListener("error", abortTask);
			thisTask.doStop();
			if (lastTask) {				
				lastTask.doStop();
				TweenMax.to(lastTask, 1, { x:1920, onComplete:hideLastTaskAbort } );
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
			TweenMax.to(thisTask, .75, { x:0, onComplete:showTask } );	
			
		}
		
		private function hideLastTaskAbort():void
		{
			lastTask.kill();
			lastTask = null;
			TweenMax.killAll();
			taskComplete();	
			
		}
		
		
		/**
		 * Calls show() on the task
		 */
		private function showTask():void
		{	
			thisTask.show();
			
			//give the task one second to show before starting the clock
			TweenMax.delayedCall(1, startCount);
		}
		
		
		private function startCount():void
		{
			var taskTimer:Timer = new Timer(parseFloat(tasks[currentTask].@time) * 1000, 1);
			taskTimer.addEventListener(TimerEvent.TIMER, taskComplete, false, 0, true);
			taskTimer.start();
		}
		
		
		private function taskComplete(e:TimerEvent = null):void
		{			
			currentTask++;
			if (currentTask >= tasks.length()) {
				currentTask = 0;
				//loop ended
				encoder.stop();
				removeEventListener(Event.ENTER_FRAME, addFrame);
			}
			lastTask = thisTask;
			initTask();
		}
		
		
		private function addFrame(e:Event):void
		{
			encoderImage.draw(stage);
			encoder.addFrame(encoderImage);
		}
	
	}
	
}