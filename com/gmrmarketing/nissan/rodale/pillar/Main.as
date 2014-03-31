package com.gmrmarketing.nissan.rodale.pillar
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
	
	
	public class Main extends MovieClip
	{
		private var vPlayer:VPlayer;
		private var container:Sprite;
		private var curVidIndex:int;
		private var lastVidIndex:int;
		private var vids:Array;
		private var autoPlay:Boolean;
		private var autoPlayTimer:Timer;
		private var quit:CornerQuit;
		private var select:MovieClip;
		
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			container = new Sprite();
			container.x = 60;
			container.y = 264;
			addChild(container);
			
			select = new sel();
			select.x = 62;
			select.y = 528;
			select.alpha = 0;
			addChild(select);
			
			quit = new CornerQuit();			
			quit.init(this, "ll");			
			quit.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			vids = new Array(1, 2, 3, 4, 5, 6);
			vids = Utility.randomizeArray(vids);
			curVidIndex = 0;
			lastVidIndex = 0;
			
			vPlayer = new VPlayer();
			vPlayer.showVideo(container);
			vPlayer.autoSizeOff();
			vPlayer.setVidSize( { width:958, height:614 } );
			vPlayer.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			
			v1.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v2.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v3.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v4.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v5.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v6.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v1p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v2p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v3p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v4p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v5p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			v6p.addEventListener(MouseEvent.MOUSE_DOWN, playVideo, false, 0, true);
			
			autoPlay = true;
			autoPlayTimer = new Timer(3000, 1);
			autoPlayTimer.addEventListener(TimerEvent.TIMER, restartAutoPlay, false, 0, true);			
			autoPlayVideo();
		}
		
		
		
		/**
		 * Called by clicking a video thumbnail
		 * @param	e
		 */
		private function playVideo(e:MouseEvent):void
		{
			TweenMax.killAll();
			
			var n:String = e.currentTarget.name;
			var num:int = parseInt(n.substr(1, 1));
			
			select.alpha = 0;
			turnOnLastPlay();
			
			switch(num) {				
				case 1:
					vPlayer.playVideo("assets/v1.mp4");
					marker.x = v1.x;
					marker.y = v1.y;
					v1p.alpha = 0;
					lastVidIndex = vids.indexOf(1);
					break;
				case 2:
					vPlayer.playVideo("assets/v2.mp4");
					marker.x = v2.x;
					marker.y = v2.y;
					v2p.alpha = 0;
					lastVidIndex = vids.indexOf(2);
					break;
				case 3:
					vPlayer.playVideo("assets/v3.mp4");
					marker.x = v3.x;
					marker.y = v3.y;
					v3p.alpha = 0;
					lastVidIndex = vids.indexOf(3);
					break;
				case 4:
					vPlayer.playVideo("assets/v4.mp4");
					marker.x = v4.x;
					marker.y = v4.y;
					v4p.alpha = 0;
					lastVidIndex = vids.indexOf(4);
					break;
				case 5:
					vPlayer.playVideo("assets/v5.mp4");
					marker.x = v5.x;
					marker.y = v5.y;
					v5p.alpha = 0;
					lastVidIndex = vids.indexOf(5);
					break;
				case 6:
					vPlayer.playVideo("assets/v6.mp4");
					marker.x = v6.x;
					marker.y = v6.y;
					v6p.alpha = 0;
					lastVidIndex = vids.indexOf(6);
					break;	
			}
			
			//set latVidIndex to the index of this video
			
			autoPlay = false;
			autoPlayTimer.reset();
		}
		
		
		private function autoPlayVideo():void
		{
			TweenMax.killAll();
			
			vPlayer.playVideo("assets/v" + vids[curVidIndex] + ".mp4");
			select.alpha = 0;
			turnOnLastPlay();
			
			switch(vids[curVidIndex]) {				
				case 1:					
					marker.x = v1.x;
					marker.y = v1.y;
					v1p.alpha = 0;
					break;
				case 2:					
					marker.x = v2.x;
					marker.y = v2.y;
					v2p.alpha = 0;
					break;
				case 3:					
					marker.x = v3.x;
					marker.y = v3.y;
					v3p.alpha = 0;
					break;
				case 4:					
					marker.x = v4.x;
					marker.y = v4.y;
					v4p.alpha = 0;
					break;
				case 5:
					marker.x = v5.x;
					marker.y = v5.y;
					v5p.alpha = 0;
					break;
				case 6:
					marker.x = v6.x;
					marker.y = v6.y;
					v6p.alpha = 0;
					break;
			}
			
			lastVidIndex = curVidIndex;
			
			curVidIndex++;
			if (curVidIndex >= vids.length) {
				curVidIndex = 0;
			}
		}
		
		private function turnOnLastPlay():void
		{
			//turn on last play button for last video		
			switch(vids[lastVidIndex]) {	
				case 1:					
				v1p.alpha = 1;
				break;
			case 2:					
				v2p.alpha = 1;
				break;
			case 3:
				v3p.alpha = 1;
				break;
			case 4:
				v4p.alpha = 1;
				break;
			case 5:
				v5p.alpha = 1;
				break;
			case 6:
				v6p.alpha = 1;
				break;
			}			
		}
		
		
		private function checkStatus(e:Event):void
		{
			if(vPlayer.getStatus() == "NetStream.Play.Stop")
			{
				if (autoPlay) {
					autoPlayVideo();
				}else {
					//wait 3 seconds
					autoPlayTimer.start();
					select.alpha = 0;
					TweenMax.to(select, .5, { alpha:1 } );
					TweenMax.to(select, .5, { alpha:0, delay:.75, overwrite:0 } );
					TweenMax.to(select, .5, { alpha:1, delay:1.5, overwrite:0 } );					
				}
			}
		}
		
		
		private function restartAutoPlay(e:TimerEvent):void
		{
			autoPlay = true;
			autoPlayVideo();
		}
		
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}