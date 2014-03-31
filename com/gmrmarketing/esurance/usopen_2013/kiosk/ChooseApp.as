package com.gmrmarketing.esurance.usopen_2013.kiosk
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class ChooseApp extends EventDispatcher
	{
		public static const FYN_PICKED:String = "FYNPicked";
		public static const PIC_PICKED:String = "PicPicked";
		public static const BACK_TO_RFID:String = "backToRfidScreen";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var tim:TimeoutHelper;
		
		
		public function ChooseApp()
		{
			clip = new mcPickApp();
			tim = TimeoutHelper.getInstance();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			tim.buttonClicked();
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			
			clip.btnFYN.addEventListener(MouseEvent.MOUSE_DOWN, fynPicked, false, 0, true);
			clip.btnPic.addEventListener(MouseEvent.MOUSE_DOWN, picPicked, false, 0, true);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, backPressed, false, 0, true);			
		}	
		
		
		public function hide():void
		{
			tim.buttonClicked();
			
			clip.btnFYN.removeEventListener(MouseEvent.MOUSE_DOWN, fynPicked);
			clip.btnPic.removeEventListener(MouseEvent.MOUSE_DOWN, picPicked);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, backPressed);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
		}
		
		
		private function fynPicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.btnFYN);
			clip.btnFYN.alpha = 1;
			TweenMax.to(clip.btnFYN, .5, { alpha:0 } );
			
			dispatchEvent(new Event(FYN_PICKED));
		}
		
		
		private function picPicked(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			TweenMax.killTweensOf(clip.btnPic);
			clip.btnPic.alpha = 1;
			TweenMax.to(clip.btnPic, .5, { alpha:0 } );
			
			dispatchEvent(new Event(PIC_PICKED));
		}
		
		
		private function backPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(BACK_TO_RFID));
		}
	}
	
}