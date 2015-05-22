package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var imageContainer:Sprite;
		
		
		public function Intro()
		{
			myClip = new mcIntro();
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
			myClip.alpha = 0;
			TweenMax.to(myClip, .5, { alpha:1 } );
			TweenMax.to(myClip.heart, .75, {scaleX:1.15, scaleY:1.15, yoyo:true, repeat:-1});
			myClip.addEventListener(MouseEvent.MOUSE_DOWN, introClicked);
		}
		
		
		public function hide():void
		{
			TweenMax.killTweensOf(clip.heart);
			if (myContainer.contains(myClip)) {
				myContainer.removeChild(myClip);
			}
		}
		
		
		private function introClicked(e:MouseEvent):void
		{
			myClip.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}