package 
{
	
	/**
	 * ...
	 * @author ...
	 */
	public class  
	{
		
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
				//initTask();
			}
		}
		
		
		//called once all tasks are loaded into taskFiles array
		private function initTask():void
		{			
			thisTask = taskFiles[currentTask];		
			thisTask.addEventListener("ready", taskReadyToShow);
			//thisTask.addEventListener("error", abortTask);
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
			//thisTask.removeEventListener("error", abortTask);
			thisTask.x = 0;//just off stage left
			thisTask.y = 160;
			addChild(thisTask);
			
			//lastTask is undefined until ?
			if (lastTask) {				
				lastTask.doStop();
				TweenMax.to(lastTask, 1, { x:1008, onComplete:hideLastTask } );
			}else {				
				TweenMax.to(thisTask, .75, { x:0, onComplete:showTask } );
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
			}
			lastTask = thisTask;
			initTask();
		}
	}
	
}