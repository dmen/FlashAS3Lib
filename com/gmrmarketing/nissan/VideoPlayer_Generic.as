package com.gmrmarketing.nissan
{	
	import flash.display.Loader;
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.net.navigateToURL;

	
	
	public class VideoPlayer_Generic extends MovieClip
	{
		private var player:VPlayer;
		
		private var btnPlay:btnPlayPause; //lib clips
		private var btnReplay:btnRep;
		
		private var head:Loader;		
		
		private var statusTimer:Timer;
		private var startTime:Number; //for checking elapsed time - set to initial time in replay()
		private var vidReady:Boolean = false; //set to true when buffer is full
		
		private var ds:DropShadowFilter;		
		
		//flashvars
		private var theVideo:String;
		private var headTime:int;
		private var headImage:String;
		//private var link:String;
		private var auto:Boolean;
		
		
		
		public function VideoPlayer_Generic() 
		{	
			ds = new DropShadowFilter(0, 0, 0x000000, 1, 5, 5, 1, 2, false, false, false);			
			
			head = new Loader();
			head.contentLoaderInfo.addEventListener(Event.COMPLETE, headLoaded, false, 0, true);
			
			theVideo = loaderInfo.parameters.video; //"YSFE_Trailer.flv"; //
			headImage = loaderInfo.parameters.headimage; //"ysfe_thumb.jpg";	
			headTime = Number(loaderInfo.parameters.headtime); //ms to show head image			
			auto = loaderInfo.parameters.auto == "true" ? true : false;			
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setSmoothing(true);
			player.setVidSize({width:stage.stageWidth, height:stage.stageHeight});
			player.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);
			player.addEventListener(VPlayer.META_RECEIVED, showSeek, false, 0, true);
			
			//check status every 1/2 second
			statusTimer = new Timer(500);
			statusTimer.addEventListener(TimerEvent.TIMER, checkStatus, false, 0, true);
			
			btnPlay = new btnPlayPause();
			btnPlay.x = 3;
			btnPlay.y = 320;
			//btnPlay.filters = [ds];
			
			btnReplay = new btnRep();
			btnReplay.x = 3;
			btnReplay.y = 320;
			//btnReplay.filters = [ds];
			
			if (headImage != "" && headImage != null) {
				loadHeadImage(headImage);
			}else {
				headImage = "";
				headTime = 0;
				replay();
			}
			
			/*
			//TESTING ONLY
			var ob:Object = new Object();
			ob.video = "gaynstar@yahoo.com.mp4";
			ob.headImage = "ysfe_thumb.jpg";
			ob.auto = "true";
			ob.headtime = 2000;			
			setVars(ob);
			*/
		}		
		
		public function setVars(ob:Object):void
		{
			theVideo = ob.video;
			headTime = ob.headtime;	
			auto = ob.auto;			
			loadHeadImage(ob.headImage);
			//replay();
		}
		
		private function loadHeadImage(im:String):void
		{
			head.load(new URLRequest(im));
		}
		
		private function headLoaded(e:Event):void
		{
			replay();
		}		
		
		public function stopVideo():void {
			player.stopVideo();
			statusTimer.stop();
		}
		
		
		/**
		 * Called from init
		 * Called from clicking replay button
		 * @param	e
		 */
		private function replay(e:MouseEvent = null):void
		{
			removeButtons();			
			
			//show the head image
			if(headImage != ""){
				addChild(head);
			}
			
			//begin status checking
			startTime = getTimer();
			statusTimer.reset();
			statusTimer.start();
			
			//begin buffering
			player.playVideo(theVideo);
			player.mute();	
		}
		
		
		private function begin():void
		{			
			player.showVideo(this);
			player.resumeVideo();			
		}
		
		
		private function addButtons():void
		{		
			addChild(btnPlay);			
			btnPlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);			
		}
		
		
		private function removeButtons():void
		{			
			if(contains(btnPlay)){
				removeChild(btnPlay);				
				btnPlay.removeEventListener(MouseEvent.CLICK, playPause);
			}
			if (contains(btnReplay)) {
				removeChild(btnReplay);				
				btnReplay.removeEventListener(MouseEvent.CLICK, replay);
			}
		}
		
		
		/**
		 * Called by clicking the play/pause button
		 * @param	e
		 */
		private function playPause(e:MouseEvent = null):void
		{			
			if(contains(head)){
				removeChild(head);
			}
			if (player.isPaused()) {
				player.resumeVideo();
				btnPlay.gotoAndStop(1); //show pause				
			}else {
				player.pauseVideo();
				btnPlay.gotoAndStop(2); //show play				
			}
		}		
		
		
		/**
		 * called every 1/2 second by statusTimer
		 * @param	e
		 */
		private function checkStatus(e:TimerEvent):void
		{		
			//if video is done buffering and the head image has been shown long
			//enough begin playback
			if (vidReady && (getTimer() - startTime > headTime)) {
				statusTimer.reset();
				player.stopVideo();
				player.unMute();
				
				//if autoplay is on then remove head image and begin
				if (auto) {
					if(contains(head)){
						removeChild(head);
					}
					begin();
				}
				//ad nav buttons
				addButtons();				
				
				//if autoplay is off change play button to show play symbol
				if (!auto) {
					btnPlay.gotoAndStop(2);
					player.showVideo(this);
					player.setIndex(0);					
				}
			}
		}
		
		
		
		private function vidStatus(e:Event):void
		{			
			if(player.getStatus() == "NetStream.Buffer.Full"){				
				vidReady = true;
			}
			if(player.getStatus() == "NetStream.Play.Stop"){				
				player.hideVideo();
				if (headImage != "") {
					headTime = 0;
					addChild(head);
				}
				addChild(btnReplay);
				btnReplay.addEventListener(MouseEvent.CLICK, replay, false, 0, true);
			}
		}
		
		
		private function showSeek(e:Event):void
		{
			//trace(player.getDuration());
		}
				
	}
	
}