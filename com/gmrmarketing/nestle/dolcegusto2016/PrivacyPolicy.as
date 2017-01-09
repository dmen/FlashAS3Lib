package com.gmrmarketing.nestle.dolcegusto2016
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class PrivacyPolicy extends EventDispatcher
	{				
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var timeoutHelper:TimeoutHelper;
		
		
		public function PrivacyPolicy()
		{
			clip = new mcPrivacy();
			timeoutHelper = TimeoutHelper.getInstance();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			timeoutHelper.buttonClicked();
			
			clip.gotoAndStop(1);
			clip.alpha = 0;
			TweenMax.to(clip, .5, {alpha:1});
			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closePressed, false, 0, true);
			clip.btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, leftPressed, false, 0, true);
			clip.btnRight.addEventListener(MouseEvent.MOUSE_DOWN, rightPressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closePressed);
			clip.btnLeft.removeEventListener(MouseEvent.MOUSE_DOWN, leftPressed);
			clip.btnRight.removeEventListener(MouseEvent.MOUSE_DOWN, rightPressed);
			
			TweenMax.to(clip, .5, {alpha:0, onComplete:kill});
		}
		
		
		private function kill():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function closePressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			hide();
		}
		
		
		
		private function leftPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			var c:int = clip.currentFrame;
			if (c > 1){
				clip.gotoAndStop(c - 1);
			}
		}
		
		
		private function rightPressed(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			var c:int = clip.currentFrame;
			if (c < 9){
				clip.gotoAndStop(c + 1);
			}
		}
		
	}
	
}