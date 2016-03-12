package com.gmrmarketing.comcast.nascar.broadcaster
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var rfid:String = "";
		
		
		public function Intro()
		{
			clip = new mcIntro();
			clip.x = 112;
			clip.y = 90;
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
			
			clip.scanHere.alpha = 0;
			clip.errorMessage.alpha = 0;
			clip.hLinesTop.scaleY = 0;
			clip.titleText.alpha = 0;
			clip.subText.alpha = 0;
			clip.xfinZone.alpha = 0;
			clip.xfinNascar.alpha = 0;
			clip.hLinesBottom.scaleX = 0;			
			
			clip.rfid.text = "";
			myContainer.stage.focus = clip.rfid;
			//myContainer.stage.addEventListener(MouseEvent.MOUSE_DOWN, checkRFID, false, 0, true);
			myContainer.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkRFID, false, 0, true);
			
			TweenMax.to(clip.hLinesTop, .5, { scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.titleText, .5, { alpha:1, delay:.5 } );
			TweenMax.to(clip.subText, .5, { alpha:1, delay:.75 } );
			TweenMax.to(clip.hLinesBottom, .5, { scaleX:1, ease:Back.easeOut, delay:1 } );
			TweenMax.to(clip.xfinZone, 1, { alpha:1, delay:1.5 } );
			TweenMax.to(clip.xfinNascar, 1, { alpha:1, delay:1.75 } );
			TweenMax.to(clip.scanHere, 1, { alpha:1, delay:2 } );
		}
		
		
		public function hide():void
		{
			myContainer.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkRFID);
			
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		private function checkRFID(e:KeyboardEvent):void
		{			
			//dispatchEvent(new Event(COMPLETE));			
			
			if (e.charCode == 13) {
				//got enter in field
				rfid = Strings.removeLineBreaks(clip.rfid.text);
				if (rfid.length < 100) {				
					dispatchEvent(new Event(COMPLETE));
				}else {
					clip.errorMessage.alpha = 1;
					clip.scanHere.alpha = 0;
					TweenMax.to(clip.errorMessage, 1, { alpha:0, delay:2 } );
					TweenMax.to(clip.scanHere, 1, { alpha:1, delay:3 } );
				}
			}		
		}
		
		
		public function get RFID():String
		{
			return rfid;
		}

	}
	
}