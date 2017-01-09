package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class CalculatingResults extends EventDispatcher 
	{
		public static const COMPLETE:String = "calculatingResultsComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function CalculatingResults()
		{			
			clip = new mcCalculatingResults();
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}		
		
		
		public function show(showWelcomeBack:Boolean = false):void
		{		
			timeoutHelper.buttonClicked();
			
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			clip.halfCircle.gotoAndStop(1);
			clip.arrow.gotoAndStop(1);
			clip.coffee.alpha = 0;	
			clip.calcText.alpha = 0;					
				
			clip.halfCircle.gotoAndPlay(2);//40 frames to play
			TweenMax.to(clip.coffee, .5, {alpha:1, onComplete:showArc});
			TweenMax.to(clip.calcText, 1.5, {alpha:1, delay:1});
		}
		
		
		private function showArc():void
		{				
			clip.arrow.gotoAndPlay(2);//46 fr - loops			
			TweenMax.delayedCall(3.5, allDone);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function allDone():void
		{			
			dispatchEvent(new Event(COMPLETE));
		}
		
	}	
}