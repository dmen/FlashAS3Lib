//AKA Pie Chart

package com.gmrmarketing.sap.metlife.sentiment
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
		
		private var maskContainer:Sprite;
		private var tweenObject:Object;		
		private var speed:Number;
		private var limit:Number;
		private var deg2rad:Number;
		
		private var myDate:String;
		private var myData:String;
		
		
		public function Main()
		{
			theMask.scaleX = 0;
			pie.scaleX = pie.scaleY = 0;
			
			maskContainer = new Sprite();
			maskContainer.cacheAsBitmap = true;
			addChild(maskContainer);
			greenPie.mask = maskContainer;
			
			//init("10/12/14,Tailgating");
		}
		
		
		/**
		 * ISchedulerMethods
		 * @param	initValue Date,Which - "10/12/14,RunningVsPassing
		 */
		public function init(initValue:String = ""):void
		{
			var items:Array = initValue.split(",");
			myDate = items[0];
			myData = items[1];
			switch(myData) {
				case "RunningVsPassing":
					title.text = "what type of game are fans excited about today?";
					break;
				case "OffenseVsDefense":
					title.text = "what is more important in today's game, offense or defense?"
					break;
				case "HomeVsVisiting":
					title.text = "which fans are more passionate about today's game?";
					break;
				case "Tailgating":
					title.text = "what do fans prefer to eat when tailgating?";
					break;
			}
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
			var r:URLRequest = new URLRequest("http://sapmetlifeapi.thesocialtab.net/api/GameDay/GetPie?gamedate=" + myDate + "&data=" + myData + "&abc=" + String(new Date().valueOf()));
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
			//show();//TESTING
		}
		
		
		private function dataError(e:IOErrorEvent):void	{}
		
		
		/**
		 * ISchedulerMethods
		 * Called right before the task is placed on screen
		 */
		public function show():void
		{
			theVideo.play();
			theMask.scaleX = 0;
			pie.scaleX = pie.scaleY = 0;
			
			leftStat.text = localCache[0].Name + "+" + String(localCache[0].Weight);
			rightStat.text = localCache[1].Name + "+" + String(localCache[1].Weight);
			
			TweenMax.to(pie, .5, { scaleX:.78, scaleY:.78, ease:Back.easeOut, delay:.5, onComplete:showStats } );
			TweenMax.delayedCall(9.25, complete);
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
			maskContainer.graphics.clear();
			refreshData(); //preload next trivia
			theVideo.seek(0);
			theVideo.stop();
		}
		
		
		/**
		 * Scales the mask from center so the stats reveal
		 */
		private function showStats():void
		{
			TweenMax.to(theMask, .5, { scaleX:1 } );
			var per:Number = localCache[0].Weight / 100 * 360;
			drawPie(per);
		}
		
		
		private function drawPie(percent:int):void
		{
			tweenObject = { percent:0 };
			speed = 0;
			limit = 0;
			deg2rad = Math.PI / 180;
			
			maskContainer.x = greenPie.x;
			maskContainer.y = greenPie.y;
			maskContainer.rotation = 270 - percent * .5;
			
			TweenMax.to(tweenObject, 2, { percent:percent, onUpdate:draw_circle } );
		}
		
		
		private function draw_circle():void
        {
            speed += 0.4;
            limit = tweenObject.percent;
            
            maskContainer.graphics.clear();
            maskContainer.graphics.lineStyle(4, 0x00FF00, 1, false, "normal", "none");
            
            for(var i:Number = 0; i <= limit; i++)
            {
                var px:Number =  Math.sin(i * deg2rad) * greenPie.width * .5;
                var py:Number = -Math.cos(i * deg2rad) * greenPie.width * .5;
                maskContainer.graphics.lineTo(px, py);
                maskContainer.graphics.moveTo(0, 0);
            }			
        }		
		
	}
	
}