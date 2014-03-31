package com.gmrmarketing.comcast.flex
{
	import flash.display.MovieClip;
	import flash.events.Event;	
	import flash.geom.ColorTransform;
	import flash.filters.DropShadowFilter;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
		
	public class MenuButton extends MovieClip
	{
		private var col:ColorTransform;
		private var shadow:DropShadowFilter;
		
		public var currentText:String; //button text
		private var restoreTimer:Timer;
		
		//these are injected by main.as when the button is instantiated
		public var buttonIndex:int; 
		public var theMenu:String;
		
		
		public function MenuButton()
		{
			shadow = new DropShadowFilter(3, 45, 0x000000, 1, 0, 0, 1, 2, false);
			col = new ColorTransform();
			
			restoreTimer = new Timer(500, 1);
		}
		
		
		public function highlight():void
		{
			col.color = 0xFAF49E; //light yellow
			theText.textColor = 0x000000;
			theText.filters = [];
			theFill.transform.colorTransform = col;
			
			dispatchEvent(new Event("buttonHighlighted"));
		}
		
		
		public function normal():void
		{
			restoreTimer.removeEventListener(TimerEvent.TIMER, returnToHighlight);
			restoreTimer.reset();
			if(currentText != null){
				theText.text = currentText;
			}
			col.color = 0x275592;
			theText.textColor = 0xFFFFFF;
			theText.filters = [shadow];
			theFill.transform.colorTransform = col;
		}
		
		
		public function notAvailable():void
		{
			currentText = theText.text;
			theText.text = "Not Available";
			theText.textColor = 0x990000;
			theText.filters = [];
			col.color = 0xFFFFFF;
			theFill.transform.colorTransform = col;
			
			restoreTimer.addEventListener(TimerEvent.TIMER, returnToHighlight, false, 0, true);
			restoreTimer.start();
		}
		
		
		private function returnToHighlight(e:TimerEvent):void
		{
			restoreTimer.removeEventListener(TimerEvent.TIMER, returnToHighlight);
			restoreTimer.reset();
			
			theText.text = currentText;
			
			//highlight();
			normal();//iPad
		}
		
	}
	
}