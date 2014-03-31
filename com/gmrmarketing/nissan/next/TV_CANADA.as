package com.gmrmarketing.nissan.next
{
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.events.*;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;	
	import flash.ui.Mouse;
	import flash.geom.Point;
	
	
	public class TV_CANADA extends MovieClip
	{
		private var videos:Array;
		private var player:VPlayer;
		private var vidIndex:int;
		private var cq:CornerQuit;
		
		
		public function TV_CANADA() 
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			videos = new Array("v1.mp4", "v2.mp4", "v3.mp4", "v4.mp4");
			
			cq = new CornerQuit();
			cq.init(this, "ll");
			cq.customLoc(1, new Point(0, 930));
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);
			
			player = new VPlayer();			
			player.showVideo(this);
			player.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			vidIndex = 0;
			
			playNextVideo();
		}
		
		private function playNextVideo():void
		{
			player.playVideo("assets/" + videos[vidIndex]);
			cq.moveToTop();
		}
		
		
		private function checkStatus(e:Event):void
		{
			if(player.getStatus() == "NetStream.Play.Stop")
			{
				vidIndex++;
				if (vidIndex >= videos.length) {
					vidIndex = 0;
				}
				playNextVideo();
			}
		}
		
		
		private function quit(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}