package com.gmrmarketing.jimbeam.boldchoice
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	
	public class Choices extends EventDispatcher
	{
		public static const CHOICES_ADDED:String = "choicesAdded";
		public static const CHOICE_MADE:String = "choiceMade";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var choice:String = "";
		
		public function Choices()
		{
			clip = new choices(); //lib clip
		}
		
		public function show($container:DisplayObjectContainer):void
		{
			container = $container;
			
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.btnMusic.addEventListener(MouseEvent.MOUSE_DOWN, chooseMusic, false, 0, true);
			clip.btnSports.addEventListener(MouseEvent.MOUSE_DOWN, chooseSports, false, 0, true);
			clip.btnBoth.addEventListener(MouseEvent.MOUSE_DOWN, chooseBoth, false, 0, true);
			clip.btnMusic.buttonMode = true;
			clip.btnSports.buttonMode = true;
			clip.btnBoth.buttonMode = true;
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:clipAdded } );
		}
		
		public function hide():void
		{
			container.removeChild(clip);
			
			clip.btnMusic.removeEventListener(MouseEvent.MOUSE_DOWN, chooseMusic);
			clip.btnSports.removeEventListener(MouseEvent.MOUSE_DOWN, chooseSports);
			clip.btnBoth.removeEventListener(MouseEvent.MOUSE_DOWN, chooseBoth);
		}
		
		public function getChoice():String
		{
			return choice;
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(CHOICES_ADDED));
		}
		
		private function chooseMusic(e:MouseEvent):void
		{
			choice = "music";
			dispatchEvent(new Event(CHOICE_MADE));
		}
		
		
		private function chooseSports(e:MouseEvent):void
		{			
			choice = "sports";
			dispatchEvent(new Event(CHOICE_MADE));
		}
		
		
		private function chooseBoth(e:MouseEvent):void
		{
			choice = "both";
			dispatchEvent(new Event(CHOICE_MADE));
		}
	}
	
}