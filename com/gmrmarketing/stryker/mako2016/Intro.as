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
		
		public function setFocus():void
		{
			clip.rfid.text = "";
			myContainer.stage.focus = clip.rfid;
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
			
			clip.theText.y = 961;//tap to start
			clip.theText2.y = 1101;//customizing experience...
			
			frameTimer.addEventListener(TimerEvent.TIMER, newFrame, false, 0, true);
			frameTimer.start();
			
			rfidOff();
		}
		
		//rfid pulsing animation
		private function rfidOff():void
		{
			TweenMax.to(clip.rfid1, .5, {alpha:0});
			TweenMax.to(clip.rfid2, .5, {alpha:0, delay:.25});
			TweenMax.to(clip.rfid3, .5, {alpha:0, delay:.5, onComplete:rfidOn});
		}
		
		
		private function rfidOn():void
		{
			TweenMax.to(clip.rfid1, .5, {alpha:1});
			TweenMax.to(clip.rfid2, .5, {alpha:1, delay:.25});
			TweenMax.to(clip.rfid3, .5, {alpha:1, delay:.5, onComplete:rfidOff});
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {	
				myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
				//got enter in field				
				if (clip.rfid.text == ""){
					rfid = "1141091787557505 "; //slaw				
					//rfid = "139643362949542"; //domingo				
					//rfid = "1131511456743553"; //mitchell			
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
			TweenMax.killTweensOf(clip.theText);
			TweenMax.killTweensOf(clip.theText2);
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
			TweenMax.killTweensOf(clip.rfid3);//stops onComplete
			clip.sideBar.x = 1283;
			frameTimer.reset();
			
			TweenMax.to(clip.theText, .5, {y:1101});
			TweenMax.to(clip.theText2, .5, {y:961});
			clip.rfid1.alpha = 0;
			clip.rfid2.alpha = 0;
			clip.rfid3.alpha = 0;
			
			clip.sideBar.gotoAndStop(6);//checking...
			clip.addEventListener(Event.ENTER_FRAME, spinSpinner, false, 0, true);
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