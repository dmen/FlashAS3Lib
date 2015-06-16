
package com.gmrmarketing.miller.gifphotobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Receive extends EventDispatcher
	{
		public static const COMPLETE:String = "receiveComplete";
		public static const SHOWING:String = "receiveShowing";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Receive()
		{
			clip = new mcReceive();
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
			clip.cBoth.visible = false;
			
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, checkEmail, false, 0, true);
			clip.btnText.addEventListener(MouseEvent.MOUSE_DOWN, checkText, false, 0, true);
			clip.btnBoth.addEventListener(MouseEvent.MOUSE_DOWN, checkBoth, false, 0, true);
			clip.btnNext.addEventListener(MouseEvent.MOUSE_DOWN, doNext, false, 0, true);
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
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
			clip.btnBoth.removeEventListener(MouseEvent.MOUSE_DOWN, checkBoth);
			clip.btnNext.removeEventListener(MouseEvent.MOUSE_DOWN, doNext);
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
			o.both = clip.cBoth.visible;
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
				clip.cText.visible = false;
				clip.cBoth.visible = false;
			}
		}
		
		
		private function checkText(e:MouseEvent):void
		{
			if (clip.cText.visible) {
				clip.cText.visible = false;
			}else {
				clip.cText.visible = true;
				clip.cEmail.visible = false;
				clip.cBoth.visible = false;
			}
		}
		
		
		private function checkBoth(e:MouseEvent):void
		{
			if (clip.cBoth.visible) {
				clip.cBoth.visible = false;
			}else {
				clip.cBoth.visible = true;
				clip.cEmail.visible = false;
				clip.cText.visible = false;
			}
		}
		
		
		private function doNext(e:MouseEvent):void
		{
			if (clip.cEmail.visible || clip.cText.visible || clip.cBoth.visible) {
				dispatchEvent(new Event(COMPLETE));
			}else {
				clip.theTitle.text = "Please choose one option";
				TweenMax.to(clip.theTitle, .5, { alpha:0, delay:1, onComplete:doTitle } );
			}
		}
		
		
		private function doTitle():void
		{
			clip.theTitle.text = "How would you like to receive your GIF?";
			TweenMax.to(clip.theTitle, .5, { alpha:1 } );
		}
	}
	
}