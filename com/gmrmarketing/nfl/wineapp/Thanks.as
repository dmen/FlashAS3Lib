package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Thanks extends EventDispatcher
	{
		public static const COMPLETE:String = "thanksComplete";
		public static const HIDDEN:String = "thanksHidden";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		
		
		public function Thanks()
		{
			tim = TimeoutHelper.getInstance();
			clip = new mcThanks();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(didEmail:Boolean):void
		{		
			tim.buttonClicked();
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			if (didEmail) {
				clip.title.theText.text = "YOUR WINE LIST IS ON THE WAY!";
			}else {
				clip.title.theText.text = "THANKS FOR PLAYING!";
			}
			
			clip.subTitle.theText.text = "Please inquire about our live tastings held at the\nexclusive NFL House through Super Bowl City Week.\n\nSee any One Market staff member for more details.\n\nAre you up for another challenge?\nTaste again and put your knowledge to the test!";
			
			clip.title.alpha = 0;
			clip.subTitle.alpha = 0;
			clip.btnPlayAgain.alpha = 0;
			clip.x = 0;
			TweenMax.to(clip.title, 1, { alpha:1 } );
			TweenMax.to(clip.subTitle, 1, { alpha:1, delay:.5 } );
			TweenMax.to(clip.btnPlayAgain, .5, { alpha:1, delay:1, onComplete:addListeners } );
		}
		
		
		public function hide():void
		{
			clip.btnPlayAgain.removeEventListener(MouseEvent.MOUSE_DOWN, doPlayAgain);
			TweenMax.to(clip, .5, { x: -2736, ease:Linear.easeNone, onComplete:kill } );
		}
		
		public function kill():void
		{	
			clip.btnPlayAgain.removeEventListener(MouseEvent.MOUSE_DOWN, doPlayAgain);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}			
			dispatchEvent(new Event(HIDDEN));
		}
		
		private function addListeners():void
		{			
			clip.btnPlayAgain.addEventListener(MouseEvent.MOUSE_DOWN, doPlayAgain, false, 0, true);
		}
		
		
		private function doPlayAgain(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.btnPlayAgain.removeEventListener(MouseEvent.MOUSE_DOWN, doPlayAgain);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}