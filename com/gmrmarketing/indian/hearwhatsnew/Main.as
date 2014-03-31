//Video Player - Hear What's New

package com.gmrmarketing.indian.hearwhatsnew
{
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.website.VPlayer;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	public class Main extends MovieClip
	{
		private var redLeather:MovieClip;
		private var logo:MovieClip;
		private var touchToBegin:MovieClip;
		private var touchToQuit:MovieClip;
		private var chan:SoundChannel;
		
		private var player:VPlayer;
		private var vidContainer:Sprite;
		
		private var cq:CornerQuit;
		
		private var config:XML;
		
		private var loader:URLLoader;
		private var engineSound:Sound;
		private var engineVolume:SoundTransform;
		private var engineChannel:SoundChannel;
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Mouse.hide();	
			
			redLeather = new mc_redLeather();
			logo = new mc_logo();
			touchToBegin = new mc_touchToBegin();
			touchToQuit = new mc_touchToQuit();
			
			player = new VPlayer();
			player.autoSizeOff();
			player.setVidSize({width:1920, height:1080 } );
			
			cq = new CornerQuit();
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			cq.init(this, "ul");
			
			vidContainer = new Sprite(); //holds the video
			//vidContainer.x = 320;
			//vidContainer.y = 80;
			
			engineSound = new engineRev(); //lib sound			
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			loader.load(new URLRequest("config.xml"));			
		}
		
		
		private function xmlLoaded(e:Event):void
		{
			config = new XML(e.target.data);
			
			player.setSoundLevel(Number(config.videoAudioLevel) / 10);
			//engineVolume is used in cueReceived
			engineVolume = new SoundTransform(Number(config.engineAudioLevel) / 10);
			
			init();
		}
		
		
		private function init():void
		{			
			redLeather.alpha = 0;
			logo.alpha = 0;
			touchToBegin.alpha = 0;
			
			
			if (!contains(redLeather)) {
				addChild(redLeather);
			}
			if (!contains(logo)) {
				addChild(logo);
			}
			if (!contains(touchToBegin)) {
				addChild(touchToBegin);
			}
					
			logo.mouseChildren = false;
			logo.mouseEnabled = false;
			touchToBegin.mouseChildren = false;
			touchToBegin.mouseEnabled = false;
			touchToQuit.mouseChildren = false;
			touchToQuit.mouseEnabled = false;
			vidContainer.mouseChildren = false;
			vidContainer.mouseEnabled = false;
			
			TweenMax.to(redLeather, 2, { alpha:1 } );
			TweenMax.to(logo, 2, { alpha:1, delay:1 } );
			TweenMax.to(touchToBegin, 2, { alpha:1, delay:2 } );
			
			cq.moveToTop();
			
			redLeather.addEventListener(MouseEvent.MOUSE_DOWN, moveText, false, 0, true);
		}
		
		
		private function moveText(e:MouseEvent):void
		{			
			redLeather.removeEventListener(MouseEvent.MOUSE_DOWN, moveText);
			//soundEngineRev.play();
			//TweenMax.to(logo, 1, { x:60, y:810, width:576, height:324 } );
			TweenMax.killTweensOf(touchToBegin);
			TweenMax.to(touchToBegin, 1, { alpha:0 } );
			
			if (!contains(vidContainer)) {
				addChild(vidContainer);
				vidContainer.alpha = 0;
			}
			if (!contains(touchToQuit)) {
				addChild(touchToQuit);
			}
			touchToQuit.alpha = 0;
			TweenMax.to(touchToQuit, 1, { alpha:1 } );
			
			player.showVideo(vidContainer);
			player.addEventListener(VPlayer.META_RECEIVED, doFade, false, 0, true);
			player.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			player.addEventListener(VPlayer.CUE_RECEIVED, cueReceived, false, 0, true);
			
			player.playVideo("images/hearWhatsNew.f4v");			
		}
		
		
		private function cueReceived(e:Event):void
		{
			engineChannel = engineSound.play();
			engineChannel.soundTransform = engineVolume;
		}		
		
		
		/**
		 * Fades in the video once metaData is returned
		 * @param	e
		 */
		private function doFade(e:Event):void
		{
			player.removeEventListener(VPlayer.META_RECEIVED, doFade);
			TweenMax.to(vidContainer, 1, { alpha:1 } );
			TweenMax.to(touchToQuit, 1, { alpha:1 } );
			redLeather.addEventListener(MouseEvent.MOUSE_DOWN, quitVid, false, 0, true);
		}
		
		
		private function quitVid(e:MouseEvent):void
		{			
			doReset();
		}
		
		
		private function checkStatus(e:Event):void
		{
			if (player.getStatus() == "NetStream.Play.Stop") {
				doReset();
			}
		}
		
		/**
		 * Called from quitVid() by pressing the quit button while the video is playing
		 * or when the video ends from checkStatus()
		 */
		private function doReset():void
		{
			redLeather.removeEventListener(MouseEvent.MOUSE_DOWN, quitVid);
			player.pauseVideo();
			if(engineChannel){
				engineChannel.stop();
			}
			TweenMax.to(vidContainer, 1, { alpha:0 } );
			//TweenMax.to(logo, 2, { x:0, y:0, width:1920, height:1080 } );
			TweenMax.to(touchToBegin, 1, { alpha:1 } );
			TweenMax.to(touchToQuit, 1, { alpha:0 } );
			redLeather.addEventListener(MouseEvent.MOUSE_DOWN, moveText, false, 0, true);
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}