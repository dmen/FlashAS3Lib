package com.gmrmarketing.bcbs.findyourbalance
{
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.*;
	
	
	public class TimerDisplay
	{
		private var timeDisplay:TextField;
		private var scoreDisplay:TextField;
		private var timer:Timer;
		private var startTime:int;
		private var gameLevel:int;
		private var levelScore:int = 0;
		private var totalScore:int = 0;
		private var delta:Number;
		
		
		public function TimerDisplay(timeField:TextField, scoreField:TextField)
		{
			timeDisplay = timeField;
			scoreDisplay = scoreField;
			
			timer = new Timer(200);
			timer.addEventListener(TimerEvent.TIMER, update, false, 0, true);
		}
		
		
		public function resetTime():void
		{
			timeDisplay.text = "0.0";
		}
		
		
		public function resetScore():void
		{
			scoreDisplay.text = "0";
		}
		
		
		public function start():void
		{
			timeDisplay.text = "0.0";
			scoreDisplay.text = String(totalScore + levelScore);
			
			startTime = getTimer();//ms
			timer.start();
		}
		
		
		public function stop():void
		{
			timer.reset();
		}
		
		
		/**
		 * called from Main.startLevel()
		 * @param	l
		 */
		public function setLevel(l:int):void
		{
			gameLevel = l;
			if (gameLevel == 1) {
				levelScore = 0;
				totalScore = 0;
			}else {
				totalScore += levelScore;
			}
		}
		
		
		public function getScore():int
		{
			return totalScore + levelScore;
		}
		
		
		public function addBonus(bonus:int):void
		{
			totalScore += bonus;
			if (totalScore <= 0) {
				totalScore = 0;
			}
			scoreDisplay.text = String(totalScore + levelScore);
		}
		
		
		/**
		 * retrns the elapsed seconds
		 * @return
		 */
		public function getElapsed():Number
		{
			return delta;
		}
		
		
		/**
		 * called by timer every 200ms
		 * @param	e
		 */
		private function update(e:TimerEvent):void
		{
			delta = (getTimer() - startTime) / 1000;
			
			var deltaString:String = String(delta);
			var i:int = deltaString.indexOf(".");
			if (i != -1) {
				deltaString = deltaString.substr(0, i + 2);
			}
			timeDisplay.text = String(deltaString);
			
			levelScore = (gameLevel * 10) * delta; //10 pts per sec lev 1, 20 per sec lev 2, 30 per sec lev 3
			scoreDisplay.text = String(totalScore + levelScore);
		}
		
	}
	
}