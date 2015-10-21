package com.gmrmarketing.microsoft.halo5
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class DialogBox
	{
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		public function DialogBox()
		{
			clip = new mcDialogBox();
			clip.btn.theText.text = "ok";
			clip.x = 548;
			clip.y = 400;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(message:String):void
		{
			TweenMax.killTweensOf(clip);
			
			if(myContainer){
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			clip.alpha = 0;
			clip.theText.text = message;
			clip.btn.addEventListener(MouseEvent.MOUSE_DOWN, closeDialog, false, 0, true);
			
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		
		private function closeDialog(e:MouseEvent):void
		{
			TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
		}
		
		
		private function kill():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
	}
	
}