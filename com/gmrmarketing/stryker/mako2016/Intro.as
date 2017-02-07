package com.gmrmarketing.stryker.mako2016
{
	import flash.display.*	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Intro extends EventDispatcher 
	{
		public static const GOT_RFID:String = "gotRFID";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var rfid:String;
		
		
		public function Intro()
		{
			clip = new mcIntro();			
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
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
			trace("checkRFID");
			if (e.charCode == 13) {
				trace("gotenter");
				//got enter in field				
				if (clip.rfid.text == ""){
					rfid = "1131511456743553";
					trace("manual");
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
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}	
	}
	
}