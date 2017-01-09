package com.gmrmarketing.esurance.sxsw_2016.photobooth
{
	import flash.display.*	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Intro extends EventDispatcher
	{
		public static const RFID:String = "gotRFID";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var rfid:String = "dmenTest";
		
		
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
			clip.alpha = 0;
			clip.rfid.text = "";
			myContainer.stage.focus = clip.rfid;
			myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkRFID, false, 0, true);
			//clip.addEventListener(MouseEvent.MOUSE_DOWN, manual, false, 0, true);
			TweenMax.to(clip, 1, { alpha:1 } );
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{
			myContainer.stage.focus = clip.rfid;
			if (e.charCode == 13) {
				//got enter in field
				rfid = Strings.removeLineBreaks(clip.rfid.text);
				//trace("rfid:", rfid);
				if (rfid.length < 50 && rfid.length > 0) {				
					dispatchEvent(new Event(RFID));
				}else {
					clip.rfid.text = "";					
				}
			}		
		}
		
		
		private function manual(e:MouseEvent):void
		{
			dispatchEvent(new Event(RFID));
		}
		
		
		public function getRFID():String
		{
			return rfid;
		}

		
		public function hide():void
		{
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, manual);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}		
		
	}	
	
}