package com.gmrmarketing.metrx.photobooth2017
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class QuizProgress
	{
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var ratio:Number;
		
		
		public function QuizProgress()
		{
			clip = new quizProgress();
			ratio = 1920 / 7; //100 percent of width / 7 questions
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			clip.y = 0;
			clip.orange.width = 0;
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip, .5, {y: -86, ease:Expo.easeOut, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
		}
		
		
		public function set question(num:int):void
		{
			TweenMax.to(clip.orange, 2, {width:ratio * num, ease:Expo.easeOut});
			
			switch(num){
				case 1:
					clip.theText.text = "QUESTION 1";
					break;
				case 2:
					clip.theText.text = "QUESTION 2A";
					break;
				case 3:
					clip.theText.text = "QUESTION 2B";
					break;
				case 4:
					clip.theText.text = "QUESTION 3";
					break;
				case 5:
					clip.theText.text = "QUESTION 4";
					break;
				case 6:
					clip.theText.text = "QUESTION 5";
					break;
				case 7:
					clip.theText.text = "QUESTION 6";
					break;
			}
		}
	}
	
}