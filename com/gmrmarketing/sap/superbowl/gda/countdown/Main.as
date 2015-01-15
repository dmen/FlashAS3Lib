package com.gmrmarketing.sap.superbowl.gda.countdown
{	
	import com.gmrmarketing.sap.superbowl.gda.IModuleMethods;
	import com.gmrmarketing.utilities.Utility;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements IModuleMethods
	{
		
		private const DISPLAY_TIME:Number = 15; //seconds this screen is shown for
		
		public static const FINISHED:String = "finished";//dispatched when the task is complete. Player will call cleanup() now
		
		private var degToRad:Number = 0.0174532925; //PI / 180		
		private var updateTimer:Timer;
		
		//containers
		private var daysClip:Sprite;
		private var hoursClip:Sprite;
		private var minutesClip:Sprite;
		private var secondsClip:Sprite;		
		
		private var daysBase:Sprite;
		private var daysColor:Sprite;
		
		private var hoursBase:Sprite;
		private var hoursColor:Sprite;
		
		private var minutesBase:Sprite;
		private var minutesColor:Sprite;
		
		private var secondsBase:Sprite;
		private var secondsColor:Sprite;
		
		private var daysTextClip:MovieClip;
		private var hoursTextClip:MovieClip;
		private var minsTextClip:MovieClip;
		private var secsTextClip:MovieClip;		
		
		private var hourRatio:Number = 60 / 360;		
		
		private var step:int = 0;
		private var radius:int = 55;
		private var lineThickness:int = 14;
		
		private var introSecs:Number = 0;//for animating the intro
		private var introMins:Number = 0;
		private var introHours:Number = 0;
		private var introDays:Number = 0;		
		
		private var isDays:Boolean;//true if days clip is being used		
		
		private const BASE_COLOR:Number = 0xFFFFFF;// 0xA5A8C6;
		private const MAIN_COLOR:Number = 0xE5b227;
		
		private var localCache:Date;//the target end date - set in dataLoaded()		
		private var TESTING:Boolean = false;
		
		
		public function Main()
		{
			updateTimer = new Timer(1000);
			updateTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);			
			
			//Containers
			daysClip = new Sprite();			
			hoursClip = new Sprite();
			minutesClip = new Sprite();
			secondsClip = new Sprite();
			
			//purple backgrounds
			daysClip.graphics.beginFill(0x6b5c8c);
			daysClip.graphics.drawCircle( -97, -100, radius);
			hoursClip.graphics.beginFill(0x6b5c8c);
			hoursClip.graphics.drawCircle( -97, -100, radius);
			minutesClip.graphics.beginFill(0x6b5c8c);
			minutesClip.graphics.drawCircle( -97, -100, radius);
			secondsClip.graphics.beginFill(0x6b5c8c);
			secondsClip.graphics.drawCircle(-97, -100, radius);
			
			//Days
			daysBase = new Sprite();
			daysColor = new Sprite();
			
			daysClip.addChild(daysBase);
			daysClip.addChild(daysColor);
			
			daysTextClip = new theText();
			daysTextClip.theLabel.text = "DAYS";
			daysClip.addChildAt(daysTextClip, 0);
			daysTextClip.x = -97;
			daysTextClip.y = -100;
			daysTextClip.alpha = 0;
			daysTextClip.scaleX = daysTextClip.scaleY = .1;
			
			//Hours
			hoursBase = new Sprite();
			hoursColor = new Sprite();
			
			hoursClip.addChild(hoursBase);
			hoursClip.addChild(hoursColor);			
			
			hoursTextClip = new theText();
			hoursTextClip.theLabel.text = "HOURS";
			hoursClip.addChildAt(hoursTextClip, 0);
			hoursTextClip.x = -97;
			hoursTextClip.y = -100;
			hoursTextClip.alpha = 0;
			hoursTextClip.scaleX = hoursTextClip.scaleY = .1;
			
			//Minutes
			minutesBase = new Sprite();
			minutesColor = new Sprite();
			
			minutesClip.addChild(minutesBase);
			minutesClip.addChild(minutesColor);		
			
			minsTextClip = new theText();
			minsTextClip.theLabel.text = "MINS";
			minutesClip.addChildAt(minsTextClip, 0);
			minsTextClip.x = -97;
			minsTextClip.y = -100;
			minsTextClip.alpha = 0;
			minsTextClip.scaleX = minsTextClip.scaleY = .1;
			
			//Seconds
			secondsBase = new Sprite();
			secondsColor = new Sprite();
			
			secondsClip.addChild(secondsBase);
			secondsClip.addChild(secondsColor);
			
			secsTextClip = new theText();
			secsTextClip.theLabel.text = "SEC";
			secondsClip.addChildAt(secsTextClip, 0);
			secsTextClip.x = -97;
			secsTextClip.y = -100;
			secsTextClip.alpha = 0;
			secsTextClip.scaleX = secsTextClip.scaleY = .1;
			
			if (TESTING) {
				//if service is down localCache date here will be used - show will be called from dataError()
				//if service is up - localCache will be replaced in dataLoaded()
				localCache = new Date("01/20/2015 8:00 AM");
				init();
			}
		}
		

		/**		
		 * called from player on initial module load
		 */
		public function init(initValue:String = ""):void
		{
			refreshData();	
		}
		
		
		public function refreshData():void
		{
			//get kickoff time from the web service
			var r:URLRequest = new URLRequest("http://sapsb49api.thesocialtab.net/api/GameDay/GetKickOffTime");
			//r.requestHeaders.push(hdr);
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, dataLoaded, false, 0, true);
			l.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			l.load(r);		
		}
		
		
		/**
		 * Callback from webservice call
		 * Gets the endTime which is a string like: 8/17/2014 1:00 PM
		 * @param	e
		 */
		private function dataLoaded(e:Event = null):void
		{
			if(e != null){
				localCache = new Date(String(e.currentTarget.data));
			}		
			
			if (TESTING) {					
				show();
			}
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{			
			if (TESTING) {					
				show();
			}
		}
		
		
		public function isReady():Boolean
		{
			return localCache != null;
		}
		
		
		public function show():void
		{			
			//calculate time delta: localCache - now
			var now:Date = new Date();
			var delta:Number = localCache.valueOf() - now.valueOf(); //ms
			
			if (delta > 0) {       
				var secs:Number = Math.floor((delta / 1000)) - 2;//subtract 2 seconds to account for animation time
				var mins:Number = Math.floor(secs / 60);
				var hours:Number = Math.floor(mins / 60);
				var days:Number = Math.floor(hours / 24);

				introSecs = secs % 60; //0 - 60
				introMins = mins % 60;
				introHours = hours % 24;
				introDays = days;
				
				var secsText:String = introSecs.toString();
				var minsText:String = introMins.toString();
				var hoursText:String = introHours.toString();
				var daysText:String = introDays.toString();

				if (secsText.length < 2) {secsText = "0" + secsText;}
				if (minsText.length < 2) {minsText = "0" + minsText;}
				if (hoursText.length < 2) { hoursText = "0" + hoursText; }
				//if (daysText.length < 2) { daysText = "0" + daysText; }
				
				daysTextClip.scaler.theText.text = daysText;
				hoursTextClip.scaler.theText.text = hoursText;
				minsTextClip.scaler.theText.text = minsText;
				secsTextClip.scaler.theText.text = secsText;
				
				introSecs *= 6; //starting angle 0-360
				introMins *= 6;
				introHours *= 15;
				introDays *= 11.6; //based on max 31 days in month (360/31)
				
				introSecs /= 20; //steps to get back to original
				introMins /= 20;
				introHours /= 20;
				introDays /= 20;
				
				step = 0;
			}
			
			var cY:int = 320;
			
			if (days > 0) {
				isDays = true;
				
				if (!contains(daysClip)) {
					addChild(daysClip);
				}
				daysClip.alpha = 0;
				Utility.drawArc(daysBase.graphics, -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, 1);
				
				daysClip.x = 310;
				daysClip.y = cY;
				
				hoursClip.x = 450;
				hoursClip.y = cY;
				
				minutesClip.x = 590;
				minutesClip.y = cY;
				
				secondsClip.x = 730;					
				secondsClip.y = cY;
				
			}else {
				//days = 0 	
				isDays = false;
				
				hoursClip.x = 378;
				hoursClip.y = cY;
				
				minutesClip.x = 518;
				minutesClip.y = cY;
				
				secondsClip.x = 658;					
				secondsClip.y = cY;	
			}			
			
			if (!contains(hoursClip)) {
				addChild(hoursClip);
				addChild(minutesClip);
				addChild(secondsClip);
			}						
			
			hoursClip.alpha = 0;
			minutesClip.alpha = 0;
			secondsClip.alpha = 0;
			
			//draw and show the gray bg circles			
			Utility.drawArc(hoursBase.graphics, -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, 1);
			Utility.drawArc(minutesBase.graphics,  -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, 1);
			Utility.drawArc(secondsBase.graphics,  -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, 1);			
			
			daysClip.x -= 150;
			daysClip.scaleX = daysClip.scaleY = .1;
			hoursClip.x -= 150;
			hoursClip.scaleX = hoursClip.scaleY = .1;
			minutesClip.x -= 150;
			minutesClip.scaleX = minutesClip.scaleY = .1;
			secondsClip.x -= 150;
			secondsClip.scaleX = secondsClip.scaleY = .1;
			
			TweenMax.to(daysClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1 } );
			TweenMax.to(hoursClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1 } );
			TweenMax.to(minutesClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1, delay:.25 } );
			TweenMax.to(secondsClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1, delay:.5, onComplete:addListener  } );
		}		
	
		
		private function complete():void
		{
			dispatchEvent(new Event(FINISHED));
		}
		
		
		public function cleanup():void
		{
			daysBase.graphics.clear();
			hoursBase.graphics.clear();
			minutesBase.graphics.clear();
			secondsBase.graphics.clear();
			
			daysColor.graphics.clear();
			hoursColor.graphics.clear();
			minutesColor.graphics.clear();
			secondsColor.graphics.clear();
			
			daysTextClip.scaler.theText.text = "";
			hoursTextClip.scaler.theText.text = "";
			minsTextClip.scaler.theText.text = "";
			secsTextClip.scaler.theText.text = "";
			
			daysTextClip.alpha = 0;
			hoursTextClip.alpha = 0;
			minsTextClip.alpha = 0;
			secsTextClip.alpha = 0;
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			updateTimer.reset();
			if (contains(hoursClip)) {
				removeChild(hoursClip);
				removeChild(minutesClip);
				removeChild(secondsClip);
			}
			if (contains(daysClip)) {
				removeChild(daysClip);
			}
		}
		
		
		/**
		 * callback from show - called by TweenMax
		 * start the orange animating on to the start times
		 */
		private function addListener():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		/**
		 * Animates the orange drawing on in 20 steps
		 * and then starts the updateTimer when finished
		 * @param	e
		 */
		private function onEnterFrame(e:Event):void
		{           
			step++;
			if (step > 20) {
				step = 0;
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				updateTimer.start();//calls update()
				TweenMax.delayedCall(DISPLAY_TIME, complete);//will dispatch FINISHED
				
				TweenMax.to(daysTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut } );
				TweenMax.to(hoursTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut, delay:.25 } );
				TweenMax.to(minsTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut, delay:.5 } );
				TweenMax.to(secsTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut, delay:.75 } );
				
			}else {		
				Utility.drawArc(daysColor.graphics, -100, -100, radius, 0, introDays * step, lineThickness, MAIN_COLOR);				
				Utility.drawArc(secondsColor.graphics, -100, -100, radius, 0, introSecs * step, lineThickness, MAIN_COLOR);
				Utility.drawArc(minutesColor.graphics, -100, -100, radius, 0, introMins * step, lineThickness, MAIN_COLOR);
				Utility.drawArc(hoursColor.graphics, -100, -100, radius, 0, introHours * step, lineThickness, MAIN_COLOR);
			}
        }
		
		
		private function update(e:TimerEvent):void
		{
			var now:Date = new Date();
			var delta:Number = localCache.valueOf() - now.valueOf(); //ms
			
			if (delta > 0) {       
				var secs:Number = Math.floor(delta / 1000);
				var mins:Number = Math.floor(secs / 60);
				var hours:Number = Math.floor(mins / 60);
				var days:Number = Math.floor(hours / 24);

				secs = secs % 60; //0 - 60
				mins = mins % 60;
				hours = hours % 24;				
				
				var secsText:String = secs.toString();
				var minsText:String = mins.toString();
				var hoursText:String = hours.toString();
				var daysText:String = days.toString();

				if (secsText.length < 2) {secsText = "0" + secsText;}
				if (minsText.length < 2) {minsText = "0" + minsText;}
				if (hoursText.length < 2) {hoursText = "0" + hoursText;}				
				//if (daysText.length < 2) {daysText = "0" + daysText;}				
				
				daysTextClip.scaler.theText.text = daysText;
				hoursTextClip.scaler.theText.text = hoursText;
				minsTextClip.scaler.theText.text = minsText;
				secsTextClip.scaler.theText.text = secsText;
				
				Utility.drawArc(daysColor.graphics, -100, -100, radius, 0, days * 11.6, lineThickness, MAIN_COLOR);				
				Utility.drawArc(secondsColor.graphics, -100, -100, radius, 0, secs * 6, lineThickness, MAIN_COLOR);				
				Utility.drawArc(minutesColor.graphics, -100, -100, radius, 0, mins * 6, lineThickness, MAIN_COLOR);		
				Utility.drawArc(hoursColor.graphics, -100, -100, radius, 0, hours * 15, lineThickness, MAIN_COLOR);
			}else {
				updateTimer.reset();
			}
		}		
	}	
}