//Live Fan Opinion Poll - AKA Pie Chart

package com.gmrmarketing.sap.superbowl.gda.lfop
{
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		private const DISPLAY_TIME:Number = 9.25; //seconds this screen is shown for
		
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var localCache:Object;
		
		private var maskContainer:Sprite;
		private var lineContainer:Sprite;
		private var tweenObject:Object;		
		private var speed:Number;
		private var limit:Number;
		private var deg2rad:Number;
		
		private var sentimentType:String //passed from config.xm in init()
		
		private var initPoint:Point;
		
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			maskContainer = new Sprite();
			maskContainer.cacheAsBitmap = true;
			addChild(maskContainer);
			greenPie.mask = maskContainer;
			
			lineContainer = new Sprite();
			addChild(lineContainer);
			
			if (TESTING) {
				init();
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
			sentimentType = initValue == "" ? "Blowout" : initValue;
			refreshData();
		}		
		
		
		private function refreshData():void
		{
			var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetOpinionPoll?data=" + sentimentType + "&abc=" + String(new Date().valueOf()));
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
			pieBG.alpha = 1;
			
			theMask.scaleX = 0;
			pie.scaleX = pie.scaleY = 0;
			
			question.alpha = 0;
			question.y = 10;
			question.text = localCache.Question;
			
			leftStat.text = "0%\n" + localCache.PollValues[0].Name;
			rightStat.text = "0%\n" + localCache.PollValues[1].Name;			
			
			TweenMax.to(pie, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );			
			TweenMax.to(theMask, 1, { scaleX:1, delay:.3, onComplete:showPie } );
			TweenMax.to(question, 1, { y:67, alpha:1, delay:.3, ease:Back.easeOut } );
			
			TweenMax.delayedCall(DISPLAY_TIME, complete);
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{			
			maskContainer.graphics.clear();
			lineContainer.graphics.clear();
			refreshData(); //preload next
		}
		
		
		private function showPie():void
		{			
			var per:Number = localCache.PollValues[0].Weight / 100 * 360;
			drawPie(per);
			
		}
		
		
		private function drawPie(percent:int):void
		{
			tweenObject = { percent:0, leftStat:0, rightStat:0 };
			speed = 0;
			limit = 0;
			deg2rad = Math.PI / 180;
			
			maskContainer.x = greenPie.x;
			maskContainer.y = greenPie.y;
			maskContainer.rotation = 270 - percent * .5;
			
			lineContainer.x = greenPie.x;
			lineContainer.y = greenPie.y;
			lineContainer.rotation = 270 - percent * .5;
		
			initPoint = new Point();
			initPoint.x =  Math.sin(0) * greenPie.width * .5;
            initPoint.y = -Math.cos(0) * greenPie.width * .5;
			
			TweenMax.to(tweenObject, 2, { percent:percent, leftStat:localCache.PollValues[0].Weight, rightStat:localCache.PollValues[1].Weight, onUpdate:draw_circle } );
		}
		
		
		private function draw_circle():void
        {
            speed += 0.4;
            limit = tweenObject.percent;
            
            maskContainer.graphics.clear();
            maskContainer.graphics.lineStyle(2, 0x26184a, 1, false, "normal", "none");
			
			leftStat.text = String(parseInt(tweenObject.leftStat)) + "%\n" + localCache.PollValues[0].Name;
			rightStat.text = String(parseInt(tweenObject.rightStat)) + "%\n" + localCache.PollValues[1].Name;	
			
            for(var i:Number = 0; i <= limit; i++)
            {
                var px:Number =  Math.sin(i * deg2rad) * greenPie.width * .5;
                var py:Number = -Math.cos(i * deg2rad) * greenPie.width * .5;
                maskContainer.graphics.lineTo(px, py);
                maskContainer.graphics.moveTo(0, 0);
				
				lineContainer.graphics.clear();
				lineContainer.graphics.lineStyle(1, 0x000000, 1, false, "normal", "none");
				lineContainer.graphics.moveTo(initPoint.x, initPoint.y);
				lineContainer.graphics.lineTo(0, 0);
				lineContainer.graphics.lineTo(px, py);
            }			
        }		
		
	}
	
}