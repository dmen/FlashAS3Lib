package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.*	
	import flash.events.*;
	import com.greensock.TweenMax;
	import fl.video.*;
	
	public class Intro extends EventDispatcher
	{
		public static const SHOWING:String = "introShowing";
		public static const MANUAL_START:String = "userTouchedScreen";		
		private var clip:MovieClip;
		private var vid:FLVPlayback;
		private var container:DisplayObjectContainer;
		
		
		public function Intro()
		{
			clip = new mcIntro();
			
			vid = new FLVPlayback();
			vid.fullScreenTakeOver = false;
			vid.autoPlay = false;
			vid.autoRewind = true;
			vid.isLive = false
			vid.skin = null;
			vid.bufferTime = .1;
			vid.x = 0;
			vid.y = 0;
			vid.width = 1920;
			vid.height = 1080;
			vid.source = "assets/attract.f4v";
			vid.addEventListener(MetadataEvent.CUE_POINT, cueListener, false, 0, true);	
			
			clip.addChild(vid);
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}	
			vid.seek(0);
			vid.play();
			clip.addEventListener(MouseEvent.MOUSE_DOWN, manualStart, false, 0, true);
		}
		
		
		public function hide():void
		{			
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, manualStart);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			vid.stop();
		}
		
		
		private function cueListener(e:MetadataEvent):void 
		{
			vid.seek(0);
			vid.play();
		}
		
		
		private function showing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function manualStart(e:MouseEvent):void
		{
			dispatchEvent(new Event(MANUAL_START));
		}
		
	}	
	
}