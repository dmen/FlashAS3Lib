/**
 * Intro screen that does the attract loop and RFID scan
 */

package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Strings;
	import flash.utils.Timer;
	
	
	public class Intro extends EventDispatcher 
	{
		public static const GOT_RFID:String = "gotRFID";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var rfid:String;
		private var curFrame:int;
		private var frameTimer:Timer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			frameTimer = new Timer(8000);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.rfid.text = "";
			myContainer.stage.focus = clip.rfid;
			myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkRFID, false, 0, true);
			
			curFrame = 1;
			clip.sideBar.gotoAndStop(1);
			clip.sideBar.x = 1283;
			frameTimer.addEventListener(TimerEvent.TIMER, newFrame, false, 0, true);
			frameTimer.start();
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
			
			if (e.charCode == 13) {				
				//got enter in field				
				if (clip.rfid.text == ""){
					rfid = "1389847433464192";					
					dispatchEvent(new Event(GOT_RFID));
				}else{
					rfid = Strings.removeLineBreaks(clip.rfid.text);
					rfid = parseInt(rfid, 16).toString();//convert the hex to a long int
					dispatchEvent(new Event(GOT_RFID));
				}
			}
		}
		
		
		public function get RFID():String
		{
			return rfid;
		}

		
		public function hide():void
		{
			frameTimer.reset();
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function newFrame(e:TimerEvent):void
		{
			frameTimer.stop();
			
			curFrame++;
			if (curFrame > 5){
				curFrame = 1;
			}
			
			TweenMax.to(clip.sideBar, .5, {x:1920, onComplete:showBar});
		}
		
		
		private function showBar():void
		{
			clip.sideBar.gotoAndStop(curFrame);
			TweenMax.to(clip.sideBar, .5, {x:1283});
			frameTimer.start();
		}		
	}
	
}