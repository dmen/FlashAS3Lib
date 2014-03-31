package com.gmrmarketing.indian.heritage_updates
{
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;	
	import flash.ui.Mouse;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	
	public class VideoLooper extends MovieClip	
	{
		private var player:VPlayer;
		private var cq:CornerQuit;
		
		public function VideoLooper()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Mouse.hide();
			
			cq = new CornerQuit();
			cq.init(this, "ul");
			cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
			
			player = new VPlayer();
			player.showVideo(this);
			player.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			player.autoSizeOff();
			player.setVidSize( { width:1920, height:1080 } );
			player.playVideo("loop.mp4");
		}
		
		
		private function checkStatus(e:Event):void
		{
			if(player.getStatus() == "NetStream.Play.Stop")
			{
				player.playVideo("loop.mp4");
			}
		}
		
		
		private function quitApplication(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
	}
	
}