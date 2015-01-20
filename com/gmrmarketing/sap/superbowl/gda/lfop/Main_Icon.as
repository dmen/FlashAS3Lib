//Live Fan Opinion Poll - AKA Pie Chart - Icon Version

package com.gmrmarketing.sap.superbowl.gda.lfop
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import com.gmrmarketing.sap.superbowl.gda.lfop.Icon;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main_Icon extends MovieClip implements IModuleMethods
	{
		private const DISPLAY_TIME:Number = 9.25; //seconds this screen is shown for
		
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;		
		private var iconContainer:Sprite;
		private var tweenObject:Object;		
		private var speed:Number;
		private var limit:Number;
		
		private var sentimentType:String //passed from config.xm in init()
		
		private var initPoint:Point;
		
		private var TESTING:Boolean = false;
		
		
		public function Main_Icon()
		{			
			iconContainer = new Sprite();
			addChild(iconContainer);
			if (TESTING) {
				init("Tailgating");//Tailgating or FanExcitement
			}
		}
		
		
		/** 
		 * Called once by Player at initial load of all tasks
		 * @param initValue String - one of: FanExcitement, Tailgating, Weather, Passion, Blowout
		 * for this one - with the circle, only use Weather,Passion,or Blowout
		 * FanExcitement and Tailgating are for the icon based version
		 */
		public function init(initValue:String = ""):void
		{
			question.alpha = 0;
			question.y = 10;
			sentimentType = initValue;
			refreshData();
		}
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetCachedFeed?feed=OpinionPollFanExcitement");
			r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			try{
				l.load(r);
			}catch (e:Error) {
				
			}
		}		
		
		
		private function dataLoaded(e:Event = null):void
		{
			if(e){
				localCache = JSON.parse(e.currentTarget.data);
			}
			if (TESTING) {
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		/**
		 * Called right before the task is placed on screen
		 */
		public function show():void
		{			
			question.alpha = 0;
			question.y = 10;
			question.text = localCache.Question;
		
			TweenMax.to(question, 1, { y:74, alpha:1, delay:.3, ease:Back.easeOut, onComplete:showIcons } );			
			TweenMax.delayedCall(DISPLAY_TIME, complete);
		}
		
		
		private function showIcons():void
		{
			var ic:Icon;
			var ty:int = 330;
			
			for (var i:int = 0; i < localCache.PollValues.length; i++ ) {
				switch(localCache.PollValues[i].Name) {
					
					//tailgating
					case "Cornhole":
						ic = new Icon();
						ic.icon = new cornhole();//lib
						ic.container = iconContainer;
						ic.show(95, ty, localCache.PollValues[i].Weight / 100, "CORNHOLE");
						break;
					case "Kan Jam":
						ic = new Icon();
						ic.icon = new kanjam();//lib
						ic.container = iconContainer;
						ic.show(245, ty, localCache.PollValues[i].Weight / 100, "KAN JAM", .2);
						break;
					case "Ladder Toss":
						ic = new Icon();
						ic.icon = new laddertoss();//lib
						ic.container = iconContainer;
						ic.show(395, ty, localCache.PollValues[i].Weight / 100, "LADDER TOSS", .4);
						break;
					case "Football":
						ic = new Icon();
						ic.icon = new football();//lib
						ic.container = iconContainer;
						ic.show(545, ty, localCache.PollValues[i].Weight / 100, "FOOTBALL", .6);
						break;
						
					//fan excitement
					case "The Game":
						ic = new Icon();
						ic.icon = new game();//lib
						ic.container = iconContainer;
						ic.show(115, ty, localCache.PollValues[i].Weight / 100, "THE GAME");
						break;
					case "Halftime":
						ic = new Icon();
						ic.icon = new halftime();//lib
						ic.container = iconContainer;
						ic.show(320, ty, localCache.PollValues[i].Weight / 100, "THE HALFTIME SHOW", .2);
						break;
					case "Commercials":
						ic = new Icon();
						ic.icon = new commercials();//lib
						ic.container = iconContainer;
						ic.show(525, ty, localCache.PollValues[i].Weight / 100, "THE COMMERCIALS", .4);
						break;
				}
			}
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{			
			while (iconContainer.numChildren) {
				iconContainer.removeChildAt(0);
			}
			question.alpha = 0;
			question.y = 10;
			
			refreshData(); //preload next
		}			
		
	}
	
}