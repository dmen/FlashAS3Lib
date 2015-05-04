package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	
	
	public class Intro extends EventDispatcher
	{
		public static const COMPLETE:String = "introComplete";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var imageContainer:Sprite;
		private var kenBurns:KenBurns;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			
			imageContainer = new Sprite();
			clip.addChildAt(imageContainer, 0);//behind the logo
			
			kenBurns = new KenBurns();
			kenBurns.container = imageContainer;
			kenBurns.images = [new introLoop1(), new introLoop2(), new introLoop3()];
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
			kenBurns.show();
			clip.redBar.addEventListener(MouseEvent.MOUSE_DOWN, introClicked);
		}
		
		
		public function hide():void
		{
			kenBurns.stop();
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function introClicked(e:MouseEvent):void
		{
			clip.redBar.removeEventListener(MouseEvent.MOUSE_DOWN, introClicked);
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}