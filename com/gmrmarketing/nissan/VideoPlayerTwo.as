package com.gmrmarketing.nissan
{	
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.net.navigateToURL;

	
	
	public class VideoPlayerTwo extends MovieClip
	{
		private var player:VPlayer;
		
		private var btnPlay:btnPlayPause; //lib clips
		private var btnMute:btnDoMute;
		private var btnBigPlay:btnIntroPlay;
		
		private var head:headImage;
		private var tail:tailImage;
		
		private var statusTimer:Timer;
		private var startTime:Number; //for checking elapsed time - set to initial time in replay()
		private var vidReady:Boolean = false; //set to true when buffer is full
		
		private var ds:DropShadowFilter;
		private var ds2:DropShadowFilter;
		
		//flashvars
		private var theVideo:String;
		private var headTime:int;
		private var link:String;
		private var auto:Boolean;
		
		
		public function VideoPlayerTwo() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			ds = new DropShadowFilter(1, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			ds2 = new DropShadowFilter(0, 0, 0x000000, 1, 10, 10, 1, 2, false, false, false);
			
			head = new headImage();			
			tail = new tailImage();				
			
			theVideo = loaderInfo.parameters.video; //"video/GH8Q69X922EN.flv"; //
			headTime = Number(loaderInfo.parameters.headtime); //ms to show head image
			link = loaderInfo.parameters.link;
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
			btnMute = new btnDoMute();
			
			btnBigPlay = new btnIntroPlay();
			btnBigPlay.x = 160;
			btnBigPlay.y = 93;
			btnBigPlay.filters = [ds2];
			btnBigPlay.alpha = .5;
			btnBigPlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);
			
			if(theVideo != null){
				replay();
			}
		}
		
		public function stopVideo():void {
			player.stopVideo();
			statusTimer.stop();
		}
		
		public function setVars(ob:Object):void
		{
			theVideo = ob.video;
			headTime = ob.headtime;
			link = ob.link;
			auto = ob.auto;
			player.setVidSize({width:ob.width, height:ob.height});		
			replay();
		}
		
		/**
		 * Called from init
		 * Called from clicking replay button inside the tail clip
		 * @param	e
		 */
		private function replay(e:MouseEvent = null):void
		{
			removeButtons();
			
			
			if (contains(tail)) {
				removeChild(tail);
			}
			//show the head image			
			addChild(head);
			
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
			if (contains(btnBigPlay)) {
				removeChild(btnBigPlay);
			}
		}
		
		
		private function addButtons():void
		{			
			btnPlay.x = 13;
			btnPlay.y = 343;
			btnPlay.filters = [ds];
			addChild(btnPlay);
			
			btnMute.x = 48;
			btnMute.y = 343;
			btnMute.filters = [ds];
			addChild(btnMute);
			
			btnPlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);
			btnMute.addEventListener(MouseEvent.CLICK, mute, false, 0, true);	
		}
		
		
		private function removeButtons():void
		{			
			if(contains(btnPlay)){
				removeChild(btnPlay);
				removeChild(btnMute);
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
				if(contains(btnBigPlay)){
					removeChild(btnBigPlay);
				}
			}else {
				player.pauseVideo();
				btnPlay.gotoAndStop(2); //show play
				addChild(btnBigPlay);
			}
		}
		
		
		
		private function mute(e:MouseEvent):void
		{
			if (player.isMuted()) {
				player.unMute();
				btnMute.gotoAndStop(1); //show speaker
			}else {
				player.mute();
				btnMute.gotoAndStop(2); //show no speaker
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
					player.setIndex(numChildren - 5);
					addChild(btnBigPlay);
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
				
				//add the tail clip and enable the buttons within
				addChild(tail);
				tail.btnReplay.addEventListener(MouseEvent.CLICK, replay, false, 0, true);
				tail.btnLink.addEventListener(MouseEvent.CLICK, doLink, false, 0, true);
				tail.btnReplay.buttonMode = true;
				tail.btnLink.buttonMode = true;
			}
		}
		
		
		private function doLink(e:MouseEvent):void
		{
			navigateToURL(new URLRequest(link), "_blank");
		}
		
		
		private function showSeek(e:Event):void
		{
			//trace(player.getDuration());
		}
		
		
	}
	
}