package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	public class WinLose extends EventDispatcher
	{
		public static const COMPLETE:String = "gameComplete";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		private var click:Sprite;
		private var numClicks:int;
		
		
		public function WinLose()
		{
			click = new Sprite();
			click.graphics.beginFill(0x00ff00, 1);
			click.graphics.drawRect(0, 0, 100, 100);
			//upper right corner
			click.x = 924;
			click.y = 0;
			click.alpha = 0;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(which:String):void
		{
			if (which == "win") {
				clip = new mcWin();
			}else {
				clip = new mcLose();
			}
			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if (!clip.contains(click)) {
				clip.addChild(click);
			}
			
			numClicks = 0;
			click.addEventListener(MouseEvent.MOUSE_DOWN, urClick, false, 0, true);
			
			clip.topText.alpha = 0;
			clip.hlines.alpha = 0;
			clip.title.alpha = 0;
			clip.bottomText.alpha = 0;
			
			clip.topText.y -= 20;
			clip.hlines.scaleY = 1.3;
			clip.title.scaleX = 1.2;
			clip.bottomText.y += 20;
			
			TweenMax.to(clip.topText, .5, { y:"20", alpha:1 } );
			TweenMax.to(clip.hlines, .5, { scaleY:1, alpha:1, delay:.4 } );
			TweenMax.to(clip.title, .5, { scaleX:1, alpha:1, delay:.8 } );
			TweenMax.to(clip.bottomText, .5, { y:"-20", alpha:1, delay:1.25 } );
		}
		
		
		public function hide():void
		{
			if (myContainer && clip) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if (clip.contains(click)) {
					clip.removeChild(click);
				}
			}
			click.removeEventListener(MouseEvent.MOUSE_DOWN, urClick);
		}
		
		
		private function urClick(e:MouseEvent):void
		{
			numClicks++;
			if (numClicks == 2) {
				dispatchEvent(new Event(COMPLETE));
			}
		}
		
	}
	
}