package com.gmrmarketing.sap.metlife.giants.trivia
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
		 */ 
		public function getFlareList():Array
		{
			var fl:Array = new Array();
			
			fl.push([296, 38, 710, "line", 3]);//x, y, to x, type, delay
			fl.push([308, 82, 698, "point", 3.5]);//x, y, to x, type, delay
			
			fl.push([395, 488, 610, "line", 5]);//x, y, to x, type, delay
			fl.push([407, 531, 598, "point", 5.3]);//x, y, to x, type, delay
			//quote
			fl.push([428, 149, 911, "line", 8]);//x, y, to x, type, delay
			fl.push([428, 410, 840, "line", 8.3]);//x, y, to x, type, delay
			
			return fl;
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
			holder.metric.x = 86; //under the text on the right
			holder.metric.textHolder.theText.text = localCache.Stat;			
			
			TweenMax.to(holder.metric, .5, { x:-246, delay:2 } );
			
			TweenMax.delayedCall(15, complete);
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		/**
		 * ISchedulerMethods
		 * 
		 */
		public function cleanup():void
		{
			theVideo.seek(0);
			theVideo.stop();
			refreshData(); //preload next trivia			
		}
		
	}
	
}