package com.gmrmarketing.reeses.gameday
{	
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class Review extends EventDispatcher
	{
		public static const CANCELED:String = "userCanceled";
		public static const OKED:String = "userOKed";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Review()
		{
			clip = new mcConfirm();
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
			
			clip.title.alpha = 0;
			clip.theTitle.scaleX = 0;
			clip.subText.alpha = 0;
			clip.grCancel.scaleX = clip.grCancel.scaleY = 0;
			clip.grOk.scaleX = clip.grOk.scaleY = 0;
			
			TweenMax.to(clip.theTitle, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.grCancel, .4, { scaleX:1, scaleY:1, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.grOk, .4, { scaleX:1, scaleY:1, delay:.4, ease:Back.easeOut } );
			TweenMax.to(clip.subText, 1, { alpha:1, delay:.8 } );
			TweenMax.to(clip.title, .5, { alpha:1, delay:1 } );
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, canceled, false, 0, true);
			clip.btnOk.addEventListener(MouseEvent.MOUSE_DOWN, oked, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, canceled);
			clip.btnOk.removeEventListener(MouseEvent.MOUSE_DOWN, oked);
			
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		private function canceled(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCELED));
		}
		
		
		private function oked(e:MouseEvent):void
		{
			dispatchEvent(new Event(OKED));
		}
	}
	
}