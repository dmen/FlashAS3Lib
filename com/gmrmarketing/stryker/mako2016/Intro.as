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
			frameTimer = new Timer(7000);			
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
			clip.removeEventListener(Event.ENTER_FRAME, spinSpinner);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		/**
		 * Called from Main.rfidScanned()
		 * animates the scan message while user data is being retrieved from orchestrate
		 */
		public function scanning():void
		{
			TweenMax.killTweensOf(clip.sideBar);
			clip.sideBar.x = 1283;
			frameTimer.reset();
			
			clip.sideBar.gotoAndStop(6);//checking...
			clip.addEventListener(Event.ENTER_FRAME, spinSpinner, false, 0, true);
			
			var w1:Array = ["recalibrating", "initializing", "finalizing", "locking", "fueling", "extracting", "binding", "aligning", "calibrating", "acquiring", "integrating"];
			var w2:Array = ["flux", "data", "satellite", "spline", "cache", "storage", "laser", "electron", "plasma", "matter", "anti-matter", "warp"];
			var w3:Array = ["capacitor", "conductor", "detector", "exchange", "drives", "container", "bay"];
			
			var word1:String = w1[Math.floor(Math.random() * (w1.length - 1))];
			var word2:String = w1[Math.floor(Math.random() * (w2.length - 1))];
			var word3:String = w1[Math.floor(Math.random() * (w3.length - 1))];
			
			clip.sideBar.theText.text = word1 + " " + word2 + " " + word3;
		}
		
		
		private function spinSpinner(e:Event):void
		{
			clip.sideBar.spinner.rotation += 2;
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