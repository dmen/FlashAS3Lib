package com.gmrmarketing.sap.metlife.trivia
{
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.text.TextFormat;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;
		private var myDate:String;
		
		
		public function Main()
		{
			//init("10/12/14");//TESTING
		}
		
		
		/**
		 * ISchedulerMethods
		 * @param	initValue
		 */
		public function init(initValue:String = ""):void
		{
			myDate = initValue;
			refreshData();
		}
		
		
		/**
		 * ISchedulerMethods
		 * Returns true if localCache has data in it
		 * ie if the service has completed successfully at least once
		 * @return
		 */
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetTeamInsights?gamedate=" + myDate + "&abc=" + String(new Date().valueOf()));
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}
		
		
		private function dataLoaded(e:Event):void
		{
			localCache = JSON.parse(e.currentTarget.data);
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		/**
		 * ISchedulerMethods
		 * Called right before the task is placed on screen
		 */
		public function show():void
		{
			theVideo.play();
			
			holder.trivia.theText.text = localCache.Body;
			holder.trivia.theText.y = -128 + ((254 - holder.trivia.theText.textHeight) * .5);
			var baseSize:int = 44;
			var myFormat:TextFormat = new TextFormat();			
			while (holder.trivia.theText.y < -130) {
				baseSize--;
				myFormat.size = baseSize;
				holder.trivia.theText.setTextFormat(myFormat);
				holder.trivia.theText.y = -128 + ((254 - holder.trivia.theText.textHeight) * .5);
			}
			holder.metric.textHolder.theText.text = localCache.Stat;
			
			holder.metricMask.x = -77;
			TweenMax.to(holder.metricMask, 1, { x: -420, delay:2 } );
			
		}
		
		
		/**
		 * ISchedulerMethods
		 * 
		 */
		public function cleanup():void
		{
			refreshData(); //preload next trivia
		}
		
	}
	
}