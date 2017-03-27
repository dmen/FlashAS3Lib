package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	
	public class Results extends EventDispatcher
	{
		public static const COMPLETE:String = "resultsComplete";
		public static const HIDDEN:String = "resultsHidden";
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		private var badge:MovieClip;
		
		private var treadPic:SlideReveal;
		private var rank:String;
		
		
		public function Results()
		{
			clip = new mcResults();//has orange bg in it
			
			treadPic = new SlideReveal(new resTread(), 7);
			treadPic.x = -420;
			treadPic.y = 180;
			treadPic.rotation = -25;
			//treadPic.scaleX = 1.005;
			treadPic.scaleY = 1.01;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		/**
		 * returns rookie, weekend or legend
		 */
		public function get ranking():String
		{
			return rank;
		}
		
		
		public function show(totalPoints:Number):void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}			
			
			if (totalPoints > 35){
				badge = new mcResultLegend();
				rank = "legend";
				clip.title1.text = "YOU KILL IT";
				clip.title2.text = "EVERY TIME IN\nYOUR WORKOUTS";
				clip.title3.text = "DON'T BE HELD BACK BY YOUR ROUTINE.\nLIVE LIFE WITH ZERO BOUNDARIES.";
				clip.title3.y = 550;
				
			}else if (totalPoints > 20){
				badge = new mcResultWeekend();
				rank = "weekend";
				clip.title1.text = "CLEARLY, YOU KNOW";
				clip.title2.text = "YOUR WAY\nAROUND A GYM!";
				clip.title3.text = "WANT TO TAKE THE NEXT STEP?\nWE CAN HELP YOU STEP UP YOUR GAME.";
				clip.title3.y = 550;
				
			}else{				
				badge = new mcResultRookie();
				rank = "rookie";
				clip.title1.text = "YOU'RE";
				clip.title2.text = "A NATURAL!";
				clip.title3.text = "EMBRACE THE JOURNEY.\nWE KNOW IT TAKES TIME AND EFFORT.\nBRING US WITH YOU.";
				clip.title3.y = 488;
			}
			
			clip.title1.x = 1950;
			clip.title2.x = 1950;
			clip.title3.x = 1950;
			
			clip.logo.x = 1950;
			
			clip.x = 0;
			clip.btnNext.alpha = 0;
			clip.btnNext.scaleX = clip.btnNext.scaleY = .5;
			clip.alpha = 0;
			clip.bg.alpha = 1;
			clip.theText.alpha = 0;
			clip.theText.scaleX = clip.theText.scaleY = .5;
			TweenMax.to(clip, .5, {alpha:1, onComplete:showText});
		}
		
		
		//shows the big - "your fitness profile" text
		private function showText():void
		{
			TweenMax.to(clip.theText, .75, {scaleX:1, scaleY:1, alpha:1, ease:Back.easeOut});
			TweenMax.delayedCall(1.5, showTread);
		}
		
		
		private function showTread():void
		{			
			clip.addChildAt(treadPic, 2);
			treadPic.reveal();
			
			if (!clip.contains(badge)){
				clip.addChild(badge);
			}
			
			badge.x = 532;
			badge.y = 513;
			badge.alpha = 0;
			badge.scaleX = badge.scaleY = 0;
			
			TweenMax.to(badge, .75, {scaleX:1.2, scaleY:1.2, alpha:1, ease:Back.easeOut, delay:1});
			
			//remove bg components now behind the tread pic
			TweenMax.to(clip.bg, .5, {alpha:0, delay:1});
			TweenMax.to(clip.theText, .5, {alpha:0, delay:1});			
			
			//right side text components
			TweenMax.to(clip.title1, .5, {x:932, ease:Expo.easeOut, delay:2});
			TweenMax.to(clip.title2, .5, {x:866, ease:Expo.easeOut, delay:2.1});
			TweenMax.to(clip.title3, .5, {x:956, ease:Expo.easeOut, delay:2.2});
			
			TweenMax.to(clip.logo, .5, {x:1120, ease:Expo.easeOut, delay:2.3});
			
			TweenMax.to(clip.btnNext, .5, {alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut, delay:3});
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, resultsComplete, false, 0, true);
		}
		
		
		private function resultsComplete(e:MouseEvent):void
		{			
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, resultsComplete);
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		public function hide():void
		{
			TweenMax.to(clip.btnNext, .5, {alpha:0});
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (clip.contains(badge)){
				clip.removeChild(badge);
			}
			if (clip.contains(treadPic)){
				clip.removeChild(treadPic);
			}
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			dispatchEvent(new Event(HIDDEN));
		}		
	
		
	}
	
}