package com.gmrmarketing.nissan.next
{
	import com.gmrmarketing.ufc.fightcard.SelectImage;
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.display.Sprite;
	import flash.events.*;
	import com.gmrmarketing.utilities.Utility;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication; //for quitting
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filesystem.File;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	
	
	public class TV extends MovieClip
	{
		private var vPlayer:VPlayer;		
		private var curVidIndex:int;		
		private var vids:Array;
		private var autoPlay:Boolean;
		private var autoPlayTimer:Timer;
		private var quit:CornerQuit;		
			
		private var close:MovieClip;		
		
		private var container:Sprite; //holds the video
		
		private var process:NativeProcess;//these for the 100 mile app
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;		
		
		
		public function TV()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			quit = new CornerQuit();			
			quit.init(this, "ll");			
			quit.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			vids = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9);
			vids = Utility.randomizeArray(vids);
			
			curVidIndex = 0;
			
			container = new Sprite();
			
			close = new btnClose();//lib clip
			close.x = 1742;
			close.y = 38;
			
			vPlayer = new VPlayer();
			vPlayer.showVideo(container);
			//vPlayer.autoSizeOff();
			//vPlayer.setVidSize( { width:958, height:614 } );
			vPlayer.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			vPlayer.addEventListener(VPlayer.META_RECEIVED, doCenter, false, 0, true);
			
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			
			autoPlay = true;
			autoPlayTimer = new Timer(10000, 1);
			autoPlayTimer.addEventListener(TimerEvent.TIMER, restartAutoPlay, false, 0, true);			
			autoPlayVideo();
			
			addListeners();
		}
		
		
		
		/**
		 * Called by clicking a video thumbnail
		 * @param	e
		 */
		private function playVideo(e:MouseEvent):void
		{
			TweenMax.killAll();
			removeListeners();
			
			var m:MovieClip = MovieClip(e.currentTarget);			
			
			var n:String = m.name;			
			var num:int = parseInt(n.substr(1, 1)); //1 - 9
			curVidIndex = vids.indexOf(num);
			
			autoPlay = false;
			autoPlayTimer.reset();
			
			autoPlayVideo();
		}
		
		
		private function showClose():void
		{			
			addChild(container);
			addChild(close);
			close.addEventListener(MouseEvent.MOUSE_DOWN, stopVideo, false, 0, true);
			quit.moveToTop();
		}
		
		
		private function hideClose():void
		{
			removeChild(container);			
			removeChild(close);
			close.removeEventListener(MouseEvent.MOUSE_DOWN, stopVideo);
		}
		
		private function addListeners():void
		{
			v1.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v2.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v3.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v4.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			//v5.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v6.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v7.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v8.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v9.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			btn100.addEventListener(MouseEvent.MOUSE_DOWN, show100, false, 0, true);
		}
		
		private function removeListeners():void
		{
			v1.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v2.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v3.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v4.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			//v5.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v6.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v7.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v8.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			v9.removeEventListener(MouseEvent.MOUSE_DOWN, playVideo);
			btn100.removeEventListener(MouseEvent.MOUSE_DOWN, show100);
		}
		
		private function autoPlayVideo():void
		{
			TweenMax.killAll();			
			
			vPlayer.showVideo(container);
			vPlayer.playVideo("assets/v" + vids[curVidIndex] + ".mp4");			
			
			curVidIndex++;
			if (curVidIndex >= vids.length) {
				curVidIndex = 0;
			}
			
			showClose();
		}
		
		
		/**
		 * Called by pressing close (x) button
		 * @param	e
		 */
		private function stopVideo(e:MouseEvent = null):void
		{
			addListeners();
			vPlayer.hideVideo();
			hideClose();
			autoPlayTimer.start(); //calls restartAutoPlay()
		}
	
		
		private function doCenter(e:Event):void
		{
			var size:Object = vPlayer.getVidSize();
			TweenMax.to(container, .75, { x:0, y:0, width:size.width, height:size.height, ease:Back.easeOut, delay:.5} );			
			vPlayer.centerVideo(1920, 1080);
		}
		
		
		private function checkStatus(e:Event):void
		{
			if(vPlayer.getStatus() == "NetStream.Play.Stop"){			
				hideClose();					
				autoPlayTimer.start(); //calls restartAutoPlay()				
			}
		}
		
		
		/**
		 * Called when autoPlayTimer times out
		 * @param	e
		 */
		private function restartAutoPlay(e:TimerEvent):void
		{
			autoPlay = true;
			autoPlayVideo();
		}
		
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function show100(e:MouseEvent):void
		{
			autoPlay = false;
			autoPlayTimer.reset();
			
			try {
				if(NativeProcess.isSupported){				
					var file:File = File.desktopDirectory.resolvePath("leaf_100miles.exe");
					nativeProcessStartupInfo.executable = file;
					
					process = new NativeProcess();
					process.start(nativeProcessStartupInfo);
					
					addEventListener(Event.ENTER_FRAME, monitorProcess, false, 0, true);
				}
			}catch (e:Error) {
				
			}
		}
		
		
		
		private function monitorProcess(e:Event):void
		{
			if (!process.running) {
				//user closed 100 mile
				removeEventListener(Event.ENTER_FRAME, monitorProcess);
				autoPlayTimer.start(); //calls restartAutoPlay()
				addListeners();
			}
		}
		
	}
	
}