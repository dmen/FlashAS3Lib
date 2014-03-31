package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	
	public class LanguageSelect extends EventDispatcher 
	{
		public static const LANGUAGE_EN:String = "languageEn";
		public static const LANGUAGE_FR:String = "languageFr";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function LanguageSelect()
		{
			clip = new mcEnFr();
			clip.x = 1480;
			clip.y = 995;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.btnEn.addEventListener(MouseEvent.MOUSE_DOWN, chooseEn, false, 0, true);
			clip.btnFr.addEventListener(MouseEvent.MOUSE_DOWN, chooseFr, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnEn.removeEventListener(MouseEvent.MOUSE_DOWN, chooseEn);
			clip.btnFr.removeEventListener(MouseEvent.MOUSE_DOWN, chooseFr);
		}
		
		
		private function chooseEn(e:MouseEvent):void
		{
			dispatchEvent(new Event(LANGUAGE_EN));
			clip.gotoAndStop(2);
		}
		
		
		private function chooseFr(e:MouseEvent):void
		{
			dispatchEvent(new Event(LANGUAGE_FR));
			clip.gotoAndStop(1);
		}
		
	}
	
}