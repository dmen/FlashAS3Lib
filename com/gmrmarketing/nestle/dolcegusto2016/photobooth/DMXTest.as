package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.nestle.dolcegusto2016.*;
	
	
	public class DMXTest extends MovieClip
	{
		private var config:Config;
		private var moodControl:MoodControl;
		
		
		public function DMXTest()
		{
			moodControl = new MoodControl();
			config = new Config();
			config.addEventListener(Config.COMPLETE, init, false, 0, true);			
		}
		
		
		private function init(e:Event):void
		{
			config.removeEventListener(Config.COMPLETE, init);
			
			moodControl.init("", config.bridgeUser, config.serproxyPort);
			
			mood.addEventListener(Event.CHANGE, moodChange, false, 0, true);
			btn.addEventListener(MouseEvent.MOUSE_DOWN, btnPressed, false, 0, true);
		}
		
		
		private function moodChange(e:Event):void
		{
			moodControl.mood = mood.selectedItem.data;
			moodControl.advanceBG();
			
			info.appendText("moving " + moodControl.turns + " times\n");
		}
		
		
		private function btnPressed(e:MouseEvent):void
		{
			moodControl.advanceBG();
		}
		
	}
	
}