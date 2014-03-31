/**
 * Instantiated by Main
 */
package com.gmrmarketing.nissan.next
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenMax;
	import flash.filters.GlowFilter;
	import flash.net.*;
	import flash.display.Loader;
	import com.gmrmarketing.nissan.next.Video;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Innovations extends EventDispatcher
	{
		public static const VIDEO_STARTED:String = "videoStarted"; //listened to by Main - stops the cloud video
		public static const VIDEO_CLOSED:String = "videoClosed";//listened to by Main - restarts the cloud video
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var loader:Loader;
		private var content:MovieClip; //loaded swf - set in swfLoaded()
		
		private var menuPick:String;
		private var video:Video;
		private var btnClose:MovieClip; //buttonClose lib clip
		private var timeoutHelper:TimeoutHelper;
		
		
		public function Innovations()
		{
			clip = new innovationsClip(); //lib clip with left side menu
			loader = new Loader();
			menuPick = "";
			
			timeoutHelper = TimeoutHelper.getInstance();
			
			btnClose = new buttonClose(); //lib clip			
			btnClose.x = 1185;
			btnClose.y = 600;
		}
		
		
		public function show($container:DisplayObjectContainer):void
		{
			TweenMax.killTweensOf(clip);
			TweenMax.killTweensOf(content);
			kill();
			
			timeoutHelper.buttonClicked();
			
			container = $container;			
			container.addChild(clip);
			clip.alpha = 1;
			
			//side menu buttons
			clip.btnCVT.addEventListener(MouseEvent.MOUSE_DOWN, showCVT, false, 0, true);
			clip.btnConnect.addEventListener(MouseEvent.MOUSE_DOWN, showConnect, false, 0, true);
			clip.btnStPete.addEventListener(MouseEvent.MOUSE_DOWN, showStPete, false, 0, true);
			clip.btnNismo.addEventListener(MouseEvent.MOUSE_DOWN, showNismo, false, 0, true);
			clip.btnRobots.addEventListener(MouseEvent.MOUSE_DOWN, showRobots, false, 0, true);
			
			if (menuPick == "") {
				menuPick = "innovation_cvt.swf";
			}
			
			getInnovation(menuPick);
		}
		
		
		private function showCVT(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			getInnovation("innovation_cvt.swf");
		}
		
		
		private function showConnect(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			getInnovation("innovation_connect.swf");
		}
		
		private function showNismo(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			getInnovation("innovation_nismo.swf");
		}
		
		private function showStPete(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			getInnovation("innovation_stpete.swf");
		}
		
		private function showRobots(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			moveHiliter(MovieClip(e.currentTarget));
			getInnovation("innovation_robots.swf");
		}
		
		
		private function moveHiliter(btn:MovieClip):void
		{
			timeoutHelper.buttonClicked();
			clip.hiliter.y = btn.y;
			clip.hiliter.alpha = 0;
			clip.hiliter.height = btn.height;
			TweenMax.to(clip.hiliter, .5, { alpha:.35 } );
		}
		
		
		public function hide():void
		{
			closeVideo();
			
			if(container){
				if (container.contains(clip)) {
					TweenMax.to(content, .5, { alpha:0 } );
					TweenMax.to(clip, .5, { alpha:0, onComplete:kill } );
				}
				
				clip.btnCVT.removeEventListener(MouseEvent.MOUSE_DOWN, showCVT);
				clip.btnConnect.removeEventListener(MouseEvent.MOUSE_DOWN, showConnect);
				clip.btnStPete.removeEventListener(MouseEvent.MOUSE_DOWN, showStPete);
				clip.btnNismo.removeEventListener(MouseEvent.MOUSE_DOWN, showNismo);
				clip.btnRobots.removeEventListener(MouseEvent.MOUSE_DOWN, showRobots);
			}
		}
		
		
		private function kill():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				if (container.contains(content)) {
					container.removeChild(content);
				}
			}
			if(content){
				content.playVid.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			}
			if(loader){
				loader.unload();
			}
		}
		
		
		private function getInnovation(whichSWF:String):void
		{
			menuPick = whichSWF;
			if(content){
				TweenMax.to(content, .5, { alpha:0, onComplete:loadSwf } );
			}else {
				loadSwf();
			}
		}
		
		
		private function loadSwf():void
		{
			loader.unload();
			if (container) {
				if (content) {					
					if (container.contains(content)) {
						container.removeChild(content);
					}
				}
			}
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded, false, 0, true);			
			loader.load(new URLRequest("picassets/" + menuPick));
		}
		
		
		/**
		 * Called by listener on loader.COMPLETE event
		 * @param	e
		 */
		private function swfLoaded(e:Event):void
		{
			timeoutHelper.buttonClicked();
			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfLoaded);
			
			content = MovieClip(loader.content);
			container.addChildAt(content, 0); //add behind the left side menu
			
			content.gotoAndPlay(2);
			
			content.playVid.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
		}
		
		
		/**
		 * Called by pressing the Play Video button
		 * @param	e
		 */
		private function playVideo(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			var vid:String;
			switch(menuPick) {
				case "innovation_cvt.swf":
					vid = "innovation_cvt.mp4";
					break;
				case "innovation_stpete.swf":
					vid = "innovation_stpete.mp4";
					break;
				case "innovation_connect.swf":
					vid = "innovation_connect.mp4";
					break;
				case "innovation_nismo.swf":
					vid = "innovation_nismo.mp4";
					break;
				case "innovation_robots.swf":
					vid = "innovation_robots.mp4";
					break;
			}
			
			video = new Video();			
			video.show(container, vid);
			video.addEventListener(Video.VIDEO_STOPPED, closeVideo, false, 0, true);
			
			container.addChild(btnClose);
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeVideo, false, 0, true);
			
			dispatchEvent(new Event(VIDEO_STARTED));
		}
		
		
		/**
		 * Called by pressing close or if the video ends
		 * @param	e
		 */
		public function closeVideo(e:* = null):void
		{	
			timeoutHelper.buttonClicked();
			
			if(video){
				video.hide();
				video.removeEventListener(Video.VIDEO_STOPPED, closeVideo);
			}
			
			if (btnClose) {
				btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, closeVideo);
				if(container){
					if(container.contains(btnClose)){
						container.removeChild(btnClose);
					}
				}
			}
			//listened for by Main - restarts the cloud video
			dispatchEvent(new Event(VIDEO_CLOSED));
		}
		
	}
	
}