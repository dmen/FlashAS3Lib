package com.gmrmarketing.nestle.dolcegusto2016.photobooth
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class QuitDialog extends EventDispatcher
	{
		public static const QUIT:String = "quitPressed";
		public static const ADVANCE_BG:String = "advanceBackground";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function QuitDialog()
		{
			clip = new mcQuitDialog();
			clip.x = 700;
			clip.y = 600;
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
			
			clip.btnCloseDialog.addEventListener(MouseEvent.MOUSE_DOWN, closeDialog, false, 0, true);
			clip.btnAdvance.addEventListener(MouseEvent.MOUSE_DOWN, advance, false, 0, true);
			clip.btnCloseApp.addEventListener(MouseEvent.MOUSE_DOWN, closeApp, false, 0, true);
		}
		
		
		
		private function closeDialog(e:MouseEvent):void
		{
			clip.btnCloseDialog.removeEventListener(MouseEvent.MOUSE_DOWN, closeDialog);
			clip.btnAdvance.removeEventListener(MouseEvent.MOUSE_DOWN, advance);
			clip.btnCloseApp.removeEventListener(MouseEvent.MOUSE_DOWN, closeApp);
			
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
		}
		
		
		private function advance(e:MouseEvent):void
		{
			dispatchEvent(new Event(ADVANCE_BG));
		}
		
		
		private function closeApp(e:MouseEvent):void
		{
			dispatchEvent(new Event(QUIT));
		}
	}
	
}