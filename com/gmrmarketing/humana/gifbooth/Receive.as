
package com.gmrmarketing.humana.gifbooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Receive extends EventDispatcher
	{
		public static const CANCEL:String = "receiveCancel";
		public static const COMPLETE:String = "receiveComplete";
		public static const SHOWING:String = "receiveShowing";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Receive()
		{
			clip = new mcReceive();
			clip.cEmail.visible = false;
			clip.cText.visible = false;
			clip.cPrint.visible = false;
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
			
			clip.cEmail.visible = false;
			clip.cText.visible = false;
			clip.cPrint.visible = true;
			
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, checkEmail, false, 0, true);
			clip.btnText.addEventListener(MouseEvent.MOUSE_DOWN, checkText, false, 0, true);
			clip.btnPrint.addEventListener(MouseEvent.MOUSE_DOWN, checkPrint, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, doCancel, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		public function clear():void
		{
			clip.cEmail.visible = false;
			clip.cText.visible = false;
			clip.cPrint.visible = false;
		}
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);					
				}
			}
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, checkEmail);
			clip.btnText.removeEventListener(MouseEvent.MOUSE_DOWN, checkText);
			clip.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, checkPrint);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, doCancel);
		}
		
		
		public function get bg():MovieClip
		{
			return clip;
		}
		
		
		public function get choice():Object
		{
			var o:Object = { };
			o.email = clip.cEmail.visible;
			o.text = clip.cText.visible;
			o.print = clip.cPrint.visible;
			return o;
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function checkEmail(e:MouseEvent):void
		{
			if (clip.cEmail.visible) {
				clip.cEmail.visible = false;
			}else {
				clip.cEmail.visible = true;
			}
		}
		
		
		private function checkText(e:MouseEvent):void
		{
			if (clip.cText.visible) {
				clip.cText.visible = false;
			}else {
				clip.cText.visible = true;
			}
		}
		
		
		private function checkPrint(e:MouseEvent):void
		{
			if (clip.cPrint.visible) {
				clip.cPrint.visible = false;
			}else {
				clip.cPrint.visible = true;
			}
		}
		
		
		private function doNext(e:MouseEvent):void
		{
			if (clip.cEmail.visible || clip.cText.visible || clip.cPrint.visible) {
				dispatchEvent(new Event(COMPLETE));
			}else {
				clip.theTitle.text = "\nPlease choose at least one option";
				TweenMax.to(clip.theTitle, .5, { alpha:0, delay:1, onComplete:doTitle } );
			}
		}
		
		
		private function doTitle():void
		{
			clip.theTitle.text = "How would you like to receive\nyour animated GIF?";
			TweenMax.to(clip.theTitle, .5, { alpha:1 } );
		}
		
		
		private function doCancel(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCEL));
		}
	}
	
}