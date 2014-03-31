package com.gmrmarketing.nissan
{
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	
		
	public class VideoPlayerOne extends MovieClip
	{
		private var player:VPlayer;
		
		private var btnPlay:btnPlayPause; //lib clips
		private var btnMute:btnDoMute;
		private var btnBigPlay:btnIntroPlay;
		
		private var ds:DropShadowFilter;
		private var ds2:DropShadowFilter; //big play button shadow
		
		private var theVideo:String;
		private var auto:Boolean;
		
		
		
		public function VideoPlayerOne() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			ds = new DropShadowFilter(1, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			ds2 = new DropShadowFilter(0, 0, 0x000000, 1, 10, 10, 1, 2, false, false, false);
			
			theVideo = loaderInfo.parameters.video; //"video/GH8Q69X922EN.flv";//
			auto = loaderInfo.parameters.auto == "true" ? true : false;
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setSmoothing(true);			
			player.showVideo(this);
			player.setVidSize({width:stage.stageWidth, height:stage.stageHeight});
			player.playVideo(theVideo);
			player.addEventListener(VPlayer.STATUS_RECEIVED, vidStatus, false, 0, true);
			player.addEventListener(VPlayer.META_RECEIVED, showSeek, false, 0, true);
			
			btnBigPlay = new btnIntroPlay();
			btnBigPlay.x = 240;
			btnBigPlay.y = 140;
			btnBigPlay.filters = [ds2];
			btnBigPlay.alpha = .5;
			btnBigPlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);
			
			btnPlay = new btnPlayPause();
			btnPlay.x = 13;
			btnPlay.y = 448;
			btnPlay.filters = [ds];
			addChild(btnPlay);
			btnMute = new btnDoMute();
			btnMute.x = 48;
			btnMute.y = 448;
			btnMute.filters = [ds];
			addChild(btnMute);
			btnPlay.addEventListener(MouseEvent.CLICK, playPause, false, 0, true);
			btnMute.addEventListener(MouseEvent.CLICK, mute, false, 0, true);
			
			if(theVideo != null){
				if (!auto) {				
					playPause();
				}
			}
			
		}
		public function setVars(ob:Object):void
		{
			theVideo = ob.video;			
			auto = ob.auto;
			player.setVidSize({width:ob.width, height:ob.height});		
			if (!auto) {				
				playPause();
			}
		}
		
	
		
		private function playPause(e:MouseEvent = null):void
		{
			if (player.isPaused()) {
				player.resumeVideo();
				btnPlay.gotoAndStop(1); //show pause
				removeChild(btnBigPlay);
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
		
		
		private function vidStatus(e:Event):void
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				player.stopVideo();
				player.playVideo(theVideo);
				playPause();
			}
		}
		
		
		
		private function showSeek(e:Event):void
		{
			//trace(player.getDuration());
		}
		
		
	}
	
}