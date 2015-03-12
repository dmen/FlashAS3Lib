package com.gmrmarketing.sap.nhl2015.avatar
{
	import flash.display.*	
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.loading.*;
	import com.greensock.loading.display.*;
	import com.greensock.*;
	import com.greensock.events.LoaderEvent;
	
	public class Intro extends EventDispatcher
	{
		public static const SHOWING:String = "introShowing";
		public static const MANUAL_START:String = "userTouchedScreen";		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var video:VideoLoader;
		
		
		public function Intro()
		{
			clip = new mcIntro();
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
			
			video = new VideoLoader("assets/avloop.f4v", { width:1920, height:1080, x:0, y:0, autoPlay:true, container:clip, repeat:-1 } );
			video.load();
			//video.content.alpha = 0;
			
			video.playVideo();
			//video.addEventListener(VideoLoader.VIDEO_COMPLETE, done);
			
			clip.addEventListener(MouseEvent.MOUSE_DOWN, manualStart, false, 0, true);
		}
		
		
		private function done(e:Event):void
		{
			//trace("v done");
		}
		
		
		public function hide():void
		{			
			clip.removeEventListener(MouseEvent.MOUSE_DOWN, manualStart);
			video.dispose(true);
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
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