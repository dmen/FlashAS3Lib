package com.gmrmarketing.bcbs.livefearless
{
	import flash.display.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "clipShowing";
		public static const EDIT:String = "editText";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var cam:CamPic;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			cam = new CamPic();					
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(message:String):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.theText.text = message;
			clip.textOverlay.theText.text = message;
			
			cam.init(1920, 1080, 0, 0, 1717, 964, 30); //set camera and capture res to 1920x1080 and display at 1717x964 (24 fps)	
			cam.show(clip.camImage);//black box behind bg image
			
			clip.btnEdit.addEventListener(MouseEvent.MOUSE_DOWN, editText, false, 0, true);
			
			clip.btnContinue.alpha = 0;
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, delay:.5, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			clip.btnEdit.removeEventListener(MouseEvent.MOUSE_DOWN, editText);
			cam.dispose();
		}
		
		
		private function editText(e:MouseEvent):void
		{
			dispatchEvent(new Event(EDIT));
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
	}
	
}