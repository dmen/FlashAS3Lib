package com.gmrmarketing.sap.metlife.playercomp
{
	import com.gmrmarketing.sap.metlife.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;
		
		
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
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetPlayerHighlights?gamedate=" + myDate + "&abc=" + String(new Date().valueOf()));
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
		
		
	}
}