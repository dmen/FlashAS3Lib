package com.gmrmarketing.sap.levisstadium.countdown
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready"; //scheduler requires the READY event to be the string "ready"
		public static const ERROR:String = "error";
		
		private var degToRad:Number = 0.0174532925; //PI / 180
		private var endDate:Date; //kick off date/time set in dataLoaded
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
		
		private var analogClock:MovieClip;
		private var hourRatio:Number = 60 / 360;		
		
		private var step:int = 0;
		private var radius:int;
		private var lineThickness:int;
		
		private var introSecs:Number = 0;//for animating the intro
		private var introMins:Number = 0;
		private var introHours:Number = 0;
		private var introDays:Number = 0;		
		private var isDays:Boolean;//true if days clip is being used		
		
		private const BASE_COLOR:Number = 0xA5A8C6;
		private const MAIN_COLOR:Number = 0xE5b227;
		
		private var localCache:Date;
		
		
		public function Main()
		{
			updateTimer = new Timer(1000);
			updateTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			
			analogClock = new analog(); //lib
			analogClock.x = 725;
			analogClock.y = 473;
			analogClock.scaleX = analogClock.scaleY = .4;	
			
			//Containers
			daysClip = new Sprite();
			hoursClip = new Sprite();
			minutesClip = new Sprite();
			secondsClip = new Sprite();
			
			//Days
			daysBase = new Sprite();
			daysColor = new Sprite();
			
			daysClip.addChild(daysBase);
			daysClip.addChild(daysColor);
			
			daysTextClip = new theText();
			daysTextClip.theLabel.text = "days";
			daysClip.addChildAt(daysTextClip, 0);
			daysTextClip.x = -95;
			daysTextClip.y = -105;
			daysTextClip.alpha = 0;
			daysTextClip.scaleX = daysTextClip.scaleY = .1;
			
			//Hours
			hoursBase = new Sprite();
			hoursColor = new Sprite();
			
			hoursClip.addChild(hoursBase);
			hoursClip.addChild(hoursColor);			
			
			hoursTextClip = new theText();
			hoursTextClip.theLabel.text = "hr";
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
			minsTextClip.theLabel.text = "min";
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
			secsTextClip.theLabel.text = "sec";
			secondsClip.addChildAt(secsTextClip, 0);
			secsTextClip.x = -97;
			secsTextClip.y = -100;
			secsTextClip.alpha = 0;
			secsTextClip.scaleX = secsTextClip.scaleY = .1;
			//dataLoaded();
		}
		
		
		/**
		 * ISChedulerMethods
		 * First method called from scheduler
		 * refreshes the data from the service
		 * dispatches 'ready' once the data is loaded
		 */
		public function init(initValue:String = ""):void
		{
			//get kickoff time from the web service
			var r:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/api/netbase/GetKickoffTime"+"?abc="+String(new Date().valueOf()));
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
				endDate = new Date(String(e.currentTarget.data));
			}
			localCache = endDate;
			//endDate = new Date("8/29/2014 5:00 PM");
			
			dispatchEvent(new Event(READY));
			
			//show();//TESTING
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			if (localCache) {
				endDate = localCache;
				dispatchEvent(new Event(READY));
				//show();
			}else {
				dispatchEvent(new Event(ERROR));
			}
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{			
			//calculate time delta: endDate - now
			var now:Date = new Date();
			var delta:Number = endDate.valueOf() - now.valueOf(); //ms
			
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
				introDays *= 11.6; //based on max 31 days in month
				
				introSecs /= 20; //steps to get back to original
				introMins /= 20;
				introHours /= 20;
				introDays /= 20;
				
				step = 0;
			}
			
			radius = 90; //radius for without days clip
			lineThickness = 25;
			
			if (days > 0) {
				isDays = true;
				theTitle.text = "Next Home Game";
				
				radius = 50; //smaller - when days circle is on
				lineThickness = 14;
				
				addChild(daysClip);
				daysClip.alpha = 0;
				draw_arc(daysBase.graphics, -100, -100, radius * 1.75, 0, 360, 25, BASE_COLOR, .6);
				
				daysClip.x = 583;
				daysClip.y = 320;
				
				hoursClip.x = 455;
				hoursClip.y = 500;
				
				minutesClip.x = 583;
				minutesClip.y = 500;
				
				secondsClip.x = 710;					
				secondsClip.y = 500;
				
			}else {
				//days = 0 	
				isDays = false;				
				
				theTitle.text = "Kick Off Countdown";
				
				hoursClip.x = 355;
				hoursClip.y = 340;
				
				minutesClip.x = 583;
				minutesClip.y = 340;
				
				secondsClip.x = 810;					
				secondsClip.y = 340;	
				
				
			}
			analogClock.alpha = 0;
			addChild(analogClock);
			
			addChild(hoursClip);
			addChild(minutesClip);
			addChild(secondsClip);
			
			hoursClip.alpha = 0;
			minutesClip.alpha = 0;
			secondsClip.alpha = 0;
			
			//draw and show the gray bg circles			
			draw_arc(hoursBase.graphics, -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, .6);
			draw_arc(minutesBase.graphics,  -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, .6);
			draw_arc(secondsBase.graphics,  -100, -100, radius, 0, 360, lineThickness, BASE_COLOR, .6);			
			
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
			
			TweenMax.to(daysColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );
			TweenMax.to(secondsColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );
			TweenMax.to(minutesColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );
			TweenMax.to(hoursColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );			
			
			analogClock.theSecond.rotation = now.getSeconds() * 6;
			analogClock.theMinute.rotation = now.getMinutes() * 6;
			analogClock.theHour.rotation = ((now.getHours() % 12) * 30) + (now.getMinutes() * .5);
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function kill():void
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
			if (contains(analogClock)) {
				removeChild(analogClock);
			}
			TweenMax.killTweensOf(analogClock);
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
				updateTimer.start();
				
			if(isDays){
				TweenMax.to(daysTextClip, .5, { scaleX:1.2, scaleY:1.2, alpha:1, ease:Back.easeOut } );
				TweenMax.to(secsTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut } );
				TweenMax.to(minsTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut, delay:.25 } );
				TweenMax.to(hoursTextClip, .5, { scaleX:.7, scaleY:.7, alpha:1, ease:Back.easeOut, delay:.5 } );
			}else {
				TweenMax.to(daysTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut } );
				TweenMax.to(secsTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut } );
				TweenMax.to(minsTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.25 } );
				TweenMax.to(hoursTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
			}				
				TweenMax.to(analogClock, 2, { alpha:1} );
			}else {		
				draw_arc(daysColor.graphics, -100, -100, radius*1.75, 0, introDays * step, 25, MAIN_COLOR);				
				draw_arc(secondsColor.graphics, -100, -100, radius, 0, introSecs * step, lineThickness, MAIN_COLOR);
				draw_arc(minutesColor.graphics, -100, -100, radius, 0, introMins * step, lineThickness, MAIN_COLOR);
				draw_arc(hoursColor.graphics, -100, -100, radius, 0, introHours * step, lineThickness, MAIN_COLOR);
			}
        }
		
		
		private function update(e:TimerEvent):void
		{
			var now:Date = new Date();
			var delta:Number = endDate.valueOf() - now.valueOf(); //ms
			
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
				
				analogClock.theSecond.rotation = now.getSeconds() * 6;
				analogClock.theMinute.rotation = now.getMinutes() * 6;
				analogClock.theHour.rotation = ((now.getHours() % 12) * 30) + (now.getMinutes() * .5);
				
				draw_arc(daysColor.graphics, -100, -100, radius*1.75, 0, days * 11.6, 25, MAIN_COLOR);				
				draw_arc(secondsColor.graphics, -100, -100, radius, 0, secs * 6, lineThickness, MAIN_COLOR);				
				draw_arc(minutesColor.graphics, -100, -100, radius, 0, mins * 6, lineThickness, MAIN_COLOR);		
				draw_arc(hoursColor.graphics, -100, -100, radius, 0, hours * 15, lineThickness, MAIN_COLOR);
			}else {
				updateTimer.reset();
			}
		}
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number, alph:Number = 1):void
		{
			g.clear();
			//g.lineStyle(1, lineColor, alph, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			if(angle_diff > 0){
				g.beginFill(lineColor, alph);
				g.moveTo(px_inner, py_inner);
				
				var i:int;
			
				// drawing the inner arc
				for (i = 1; i <= steps; i++) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
				}
				
				// drawing the outer arc
				for (i = steps; i >= 0; i--) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
				}
				
				g.lineTo(px_inner, py_inner);
				g.endFill();
			}
		}
		
		private function getX(angle:Number, radius:Number, center_x:Number):Number
		{
			return Math.cos((angle-90) * degToRad) * radius + center_x;
		}
		
		
		private function getY(angle:Number, radius:Number, center_y:Number):Number
		{
			return Math.sin((angle-90) * degToRad) * radius + center_y;
		}
		
		
	}	
	
}