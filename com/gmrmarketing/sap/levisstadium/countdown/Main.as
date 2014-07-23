package com.gmrmarketing.sap.levisstadium.countdown
{
	import com.gmrmarketing.sap.levisstadium.ISchedulerMethods;
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Main extends MovieClip implements ISchedulerMethods
	{
		public static const READY:String = "ready";
		
		private var degToRad:Number = 0.0174532925; //PI / 180
		private var endDate:Date;
		private var updateTimer:Timer;
		
		//container
		private var hoursClip:Sprite;
		private var minutesClip:Sprite;
		private var secondsClip:Sprite;		
		
		private var hoursBase:Sprite;
		private var hoursColor:Sprite;
		
		private var minutesBase:Sprite;
		private var minutesColor:Sprite;
		
		private var secondsBase:Sprite;
		private var secondsColor:Sprite;
		
		private var hoursTextClip:MovieClip;
		private var minsTextClip:MovieClip;
		private var secsTextClip:MovieClip;
		
		private var analogClock:MovieClip;
		private var hourRatio:Number = 60 / 360;		
		
		private var step:int = 0;
		
		private var introSecs:Number = 0;//for animating the intro
		private var introMins:Number = 0;
		private var introHours:Number = 0;
		
		private var endTime:String;
		
		private const RADIUS:int = 90;
		private const LINE_THICKNESS:int = 25;
		private const BASE_COLOR:Number = 0xA5A8C6;
		private const MAIN_COLOR:Number = 0xE5b227;
		
		public function Main()
		{
			updateTimer = new Timer(1000);
			updateTimer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
			
			analogClock = new analog(); //lib
			analogClock.x = 700;
			analogClock.y = 445;
			analogClock.scaleX = analogClock.scaleY = .5;	
			
			//Containers
			hoursClip = new Sprite();
			minutesClip = new Sprite();
			secondsClip = new Sprite();
			
			hoursClip.x = 355;
			hoursClip.y = 340;
			minutesClip.x = 583;
			minutesClip.y = 340;
			secondsClip.x = 810;					
			secondsClip.y = 340;					
			
			//Hours
			hoursBase = new Sprite();
			hoursColor = new Sprite();
			
			hoursClip.addChild(hoursBase);
			hoursClip.addChild(hoursColor);
			
			draw_arc(hoursBase.graphics, -100, -100, RADIUS, 0, 360, LINE_THICKNESS, BASE_COLOR, .6);
			
			hoursTextClip = new theText();
			hoursTextClip.theLabel.text = "hours";
			hoursClip.addChildAt(hoursTextClip, 0);
			hoursTextClip.x = -95;
			hoursTextClip.y = -105;
			hoursTextClip.alpha = 0;
			hoursTextClip.scaleX = hoursTextClip.scaleY = .1;
			
			//Minutes
			minutesBase = new Sprite();
			minutesColor = new Sprite();
			
			minutesClip.addChild(minutesBase);
			minutesClip.addChild(minutesColor);			
			
			draw_arc(minutesBase.graphics,  -100, -100, RADIUS, 0, 360, LINE_THICKNESS, BASE_COLOR, .6);
			
			minsTextClip = new theText();
			minsTextClip.theLabel.text = "minutes";
			minutesClip.addChildAt(minsTextClip, 0);
			minsTextClip.x = -95;
			minsTextClip.y = -105;
			minsTextClip.alpha = 0;
			minsTextClip.scaleX = minsTextClip.scaleY = .1;
			
			//Seconds
			secondsBase = new Sprite();
			secondsColor = new Sprite();
			
			secondsClip.addChild(secondsBase);
			secondsClip.addChild(secondsColor);
			
			draw_arc(secondsBase.graphics,  -100, -100, RADIUS, 0, 360, LINE_THICKNESS, BASE_COLOR, .6);
			
			secsTextClip = new theText();
			secsTextClip.theLabel.text = "seconds";
			secondsClip.addChildAt(secsTextClip, 0);
			secsTextClip.x = -95;
			secsTextClip.y = -105;
			secsTextClip.alpha = 0;
			secsTextClip.scaleX = secsTextClip.scaleY = .1;
			
			//TESTING
			setConfig("3:45 PM");
			show();
			//TESTING
		}
		
		
		/**
		 * ISChedulerMethods
		 * Sets the time to countdown until as a string like:
		   dispatches ready event to scheduler so it can be shown
		 */
		public function setConfig(config:String):void
		{
			endTime = config;
			dispatchEvent(new Event(READY));
		}
		
		
		/**
		 * ISChedulerMethods
		 */
		public function show():void
		{			
			addChild(hoursClip);
			addChild(minutesClip);
			addChild(secondsClip);
			
			hoursClip.alpha = 0;
			minutesClip.alpha = 0;
			secondsClip.alpha = 0;
			
			analogClock.alpha = 0;
			addChild(analogClock);			
			
			//show the gray bg circles
			hoursClip.x -= 150;
			hoursClip.scaleX = hoursClip.scaleY = .1;
			minutesClip.x -= 150;
			minutesClip.scaleX = minutesClip.scaleY = .1;
			secondsClip.x -= 150;
			secondsClip.scaleX = secondsClip.scaleY = .1;
			TweenMax.to(hoursClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1 } );
			TweenMax.to(minutesClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1, delay:.25 } );
			TweenMax.to(secondsClip, .5, { alpha:1, x:"50", scaleX:1, scaleY:1, delay:.5, onComplete:addListener  } );			
			
			TweenMax.to(secondsColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );
			TweenMax.to(minutesColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );
			TweenMax.to(hoursColor, 0, { glowFilter: { color:MAIN_COLOR, alpha:1, blurX:30, blurY:30 }} );			
			
			var now:Date = new Date();
			var s:String = String(now.month + 1) + "/" + String(now.date) + "/" + String(now.fullYear) + " " + endTime;
			setEndDate(new Date(s));			
			
			var delta:Number = endDate.valueOf() - now.valueOf(); //ms
			
			analogClock.theSecond.rotation = now.getSeconds() * 6;
			analogClock.theMinute.rotation = now.getMinutes() * 6;
			analogClock.theHour.rotation = ((now.getHours() % 12) * 30) + (now.getMinutes() * .5);
			
			if (delta > 0) {       
				var secs:Number = Math.floor(delta / 1000)-2;//subtract 2 seconds to account for animation time
				var mins:Number = Math.floor(secs / 60);
				var hours:Number = Math.floor(mins / 60);

				introSecs = secs % 60; //0 - 60
				introMins = mins % 60;
				introHours = hours % 24;
				
				var secsText:String = introSecs.toString();
				var minsText:String = introMins.toString();
				var hoursText:String = introHours.toString();

				if (secsText.length < 2) {secsText = "0" + secsText;}
				if (minsText.length < 2) {minsText = "0" + minsText;}
				if (hoursText.length < 2) { hoursText = "0" + hoursText; }
				
				hoursTextClip.scaler.theText.text = hoursText;
				minsTextClip.scaler.theText.text = minsText;
				secsTextClip.scaler.theText.text = secsText;
				
				introSecs *= 6; //angle 0-360
				introMins *= 6;
				introHours *= 15;
				
				introSecs /= 20; //steps to get back to original
				introMins /= 20;
				introHours /= 20;
				
				step = 0;
			}			
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function hide():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			updateTimer.reset();
			if (contains(hoursClip)) {
				removeChild(hoursClip);
				removeChild(minutesClip);
				removeChild(secondsClip);
			}
			TweenMax.killTweensOf(analogClock);
		}
		
		/**
		 * ISChedulerMethods
		 */
		public function doStop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		/**
		 * callback from show - called by TweenMax
		 */
		private function addListener():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		
		private function onEnterFrame(e:Event):void
		{           
			step++;
			if (step > 20) {
				step = 0;
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				updateTimer.start();
				
				TweenMax.to(secsTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut } );
				TweenMax.to(minsTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.25 } );
				TweenMax.to(hoursTextClip, .5, { scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut, delay:.5 } );
				
				TweenMax.to(analogClock, 2, { alpha:1} );
			}else{		
				draw_arc(secondsColor.graphics, -100, -100, RADIUS, 0, introSecs * step, LINE_THICKNESS, MAIN_COLOR);
				draw_arc(minutesColor.graphics, -100, -100, RADIUS, 0, introMins * step, LINE_THICKNESS, MAIN_COLOR);
				draw_arc(hoursColor.graphics, -100, -100, RADIUS, 0, introHours * step, LINE_THICKNESS, MAIN_COLOR);
			}
        }
		
		
		public function setEndDate(ed:Date):void
		{
			endDate = ed;		
		}		
		
		
		private function update(e:TimerEvent):void
		{
			var now:Date = new Date();
			var delta:Number = endDate.valueOf() - now.valueOf(); //ms
			
			if (delta > 0) {       
				var secs:Number = Math.floor(delta / 1000);
				var mins:Number = Math.floor(secs / 60);
				var hours:Number = Math.floor(mins / 60);

				secs = secs % 60; //0 - 60
				mins = mins % 60;
				hours = hours % 24;				
				
				var secsText:String = secs.toString();
				var minsText:String = mins.toString();
				var hoursText:String = hours.toString();

				if (secsText.length < 2) {secsText = "0" + secsText;}
				if (minsText.length < 2) {minsText = "0" + minsText;}
				if (hoursText.length < 2) {hoursText = "0" + hoursText;}				
				
				hoursTextClip.scaler.theText.text = hoursText;
				minsTextClip.scaler.theText.text = minsText;
				secsTextClip.scaler.theText.text = secsText;
				
				analogClock.theSecond.rotation = now.getSeconds() * 6;
				analogClock.theMinute.rotation = now.getMinutes() * 6;
				analogClock.theHour.rotation = ((now.getHours() % 12) * 30) + (now.getMinutes() * .5);
				
				draw_arc(secondsColor.graphics, -100, -100, RADIUS, 0, secs * 6, LINE_THICKNESS, MAIN_COLOR);				
				draw_arc(minutesColor.graphics, -100, -100, RADIUS, 0, mins * 6, LINE_THICKNESS, MAIN_COLOR);		
				draw_arc(hoursColor.graphics, -100, -100, RADIUS, 0, hours * 15, LINE_THICKNESS, MAIN_COLOR);
			}else {
				updateTimer.reset();
			}
		}
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:int, lineColor:Number, lineAlpha:Number = 1):void
		{
			g.clear();
			g.lineStyle(lineThickness, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:int = (angle_to) - (angle_from);
			var steps:int = angle_diff * 1;//1 is precision... use higher numbers for more.
			var angle:int = angle_from;
			var px:Number = center_x + radius * Math.cos((angle-90) * degToRad);//sub 90 here and below to rotate the arc to start at 12oclock
			var py:Number = center_y + radius * Math.sin((angle-90) * degToRad);

			g.moveTo(px, py);

			for (var i:int = 1; i <= steps; i++) {
				angle = angle_from + angle_diff / steps * i;
				g.lineTo(center_x + radius * Math.cos((angle-90) * degToRad), center_y + radius * Math.sin((angle-90) * degToRad));
			}
		}
		
		
	}	
	
}