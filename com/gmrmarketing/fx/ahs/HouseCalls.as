package com.gmrmarketing.fx.ahs
{	
	import flash.display.MovieClip;
	import flash.events.*;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import fl.video.*;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	public class HouseCalls extends MovieClip
	{
		//used for starting/stopping the background sound
		public static const HOUSE_CALL_STARTED:String = "houseCallIsPlaying";
		public static const HOUSE_CALL_STOPPED:String = "houseCallIsStopped";
		
		private var clips:Array;
		private var player:MovieClip; //library clip
		private var baseURL:String = "http://gmrappdevelopers.s3.amazonaws.com/FXHorrorShow/";
		
		private var isVedPlayer:Boolean = true;
		
		
		public function HouseCalls()
		{	
			var curClip:MovieClip;
			
			hc1.vid = "hc1_couple.flv";
			hc2.vid = "hc2_roomates.flv";
			hc3.vid = "mainVid.flv"; //should be montage.flv but Nick/Pete renamed for use on home page... should fix
			hc4.vid = "hc3_jacuzzi.flv";
			hc5.vid = "hc5.flv";
			hc6.vid = "hc6.flv";
			hc7.vid = "hc7.flv";
			hc8.vid = "hc8.flv";
			hc9.vid = "hc9.flv";
			hc10.vid = "hc10.flv";
			hc11.vid = "hc11.flv";
			hc12.vid = "hc12.flv";
			
			clips = new Array(hc1, hc2, hc3, hc4, hc5, hc6, hc7, hc8, hc9, hc10, hc11, hc12);	
			
			for (var i:int = 0; i < clips.length; i++) {
				curClip = MovieClip(clips[i]);
				curClip.buttonMode = true;
				curClip.addEventListener(MouseEvent.CLICK, playMovie, false, 0, true);
				curClip.addEventListener(MouseEvent.MOUSE_OVER, doGlow, false, 0, true);
				curClip.addEventListener(MouseEvent.MOUSE_OUT, noGlow, false, 0, true);
			}
			
			TweenPlugin.activate([GlowFilterPlugin, DropShadowFilterPlugin]);
			
			btnTwitter.buttonMode = true;
			btnTwitter.addEventListener(MouseEvent.CLICK, goTwitter, false, 0, true);
			
			//comment these three lines vor Ved player
			player = new vidClip();
			player.x = 450;
			player.y = 368;
		}
		
		private function goTwitter(e:MouseEvent):void
		{
			navigateToURL(new URLRequest("http://twitter.com/#!/search/ahsfx"), "_blank");
		}
		
		private function playMovie(e:MouseEvent):void
		{
			var clip:MovieClip = MovieClip(e.currentTarget);
			
			//comment all below for Ved player
			/*
			if (parent.contains(player)) {
				closeVideo();
			}
			parent.addChild(player);
			TweenLite.to(player, 3, { dropShadowFilter: { color:0x000000, alpha:1, blurX:224, blurY:16, distance: -4, angle:51, quality:3, strength:3 }} );
			
			player.vid.source = baseURL + clip.vid;
			player.vid.playWhenEnoughDownloaded();
			player.loading.visible = false;
			
						
			player.loading.scaleX = player.loading.scaleY = 1;
			player.loading.x = -48;
			player.loading.y = -18;
			
			
			player.vid.addEventListener(VideoEvent.READY, vidReady, false, 0, true);
			player.vid.addEventListener(VideoEvent.PLAYING_STATE_ENTERED, vidPlaying, false, 0, true);
			addEventListener(Event.ENTER_FRAME, rotateLoader, false, 0, true);
			
			player.btnClose.buttonMode = true;
			player.btnClose.addEventListener(MouseEvent.CLICK, closeVideo, false, 0, true);
			*/
			//stop commenting for ved player
			
			//uncomment for ved player
			ExternalInterface.call("playHouseCall", baseURL + clip.vid);
			
			dispatchEvent(new Event(HOUSE_CALL_STARTED));
		}
		
		//comment for ved player
		/*
		private function vidReady(e:VideoEvent):void
		{
			player.loading.visible = true;
			player.loading.scaleX = player.loading.scaleY = .5;
			player.loading.x = 180;
			player.loading.y = 110;
		}
		
		
		private function vidPlaying(e:VideoEvent = null):void
		{			
			player.loading.visible = false;
			removeEventListener(Event.ENTER_FRAME, rotateLoader);
		}
		
		
		private function rotateLoader(e:Event):void
		{
			player.loading.circ.rotation += 2;
		}
		*/
		//stop commenting for ved player
		
		private function doGlow(e:MouseEvent):void
		{
			var clip:MovieClip = MovieClip(e.currentTarget);			
			TweenLite.to(clip, 1, {glowFilter:{color:0xcc9933, alpha:1, blurX:20, blurY:20, strength:2}});
		}
		
		
		private function noGlow(e:MouseEvent):void
		{
			var clip:MovieClip = MovieClip(e.currentTarget);
			TweenLite.to(clip, 1, {glowFilter:{color:0xcc9933, alpha:0, blurX:20, blurY:20}});
		}
		
		//comment for vedPlayer
		/*
		private function closeVideo(e:MouseEvent = null):void
		{
			player.vid.stop();
			parent.removeChild(player);
			dispatchEvent(new Event(HOUSE_CALL_STOPPED));
			TweenLite.to(player, 0, { dropShadowFilter: { color:0x000000, alpha:0, blurX:224, blurY:16, distance: -4, angle:51, quality:3, strength:3 }} );			
		}
		*/
	}
	
}