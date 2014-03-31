package com.gmrmarketing.nissan.motorsports.videokiosk_2013
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class Intro extends EventDispatcher
	{
		public static const SHOWING:String = "introShowing";
		public static const QR_SCANNED:String = "QRScanned";
		public static const QR_SKIPPED:String = "QRSkipped";		
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var rfid:String;
		
		
		public function Intro()
		{
			clip = new mcIntro();
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
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
			
			clip.rfidField.text = "";
			
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkField, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_DOWN, bypassQR, false, 0, true); 		
			
			setFocus();
		}
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		private function setFocus(e:MouseEvent = null):void
		{
			container.stage.focus = clip.rfidField;//make sure the field is type 'input' and not 'dynamic'
		}
		
		
		public function getQR():String
		{
			return rfid;
		}
		
		
		public function hide():void
		{
			if(container.contains(clip)){
				container.removeChild(clip);
			}
			container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, bypassQR);			
		}		
		
		
		private function bypassQR(e:MouseEvent):void
		{
			dispatchEvent(new Event(QR_SKIPPED));
		}
		
		
		private function checkField(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				
				container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkField);
				container.stage.removeEventListener(Event.ENTER_FRAME, setFocus);
				
				rfid = clip.rfidField.text;				
				
				dispatchEvent(new Event(QR_SCANNED));
			}
		}
		
	}
	
}