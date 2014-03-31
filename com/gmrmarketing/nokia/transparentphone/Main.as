package com.gmrmarketing.nokia.transparentphone
{
	import flash.display.MovieClip;
	import com.gmrmarketing.website.VPlayer;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.nokia.transparentphone.Photos;
	import com.gmrmarketing.utilities.CamPic;
	

	
	public class Main extends MovieClip
	{
		private var vid:VPlayer;		
		private var happy:VPlayer;
		private var vids:Array;
		private var vidNum:int;
		private var photos:Photos;
		private var showingPhotos:Boolean;
		private var plainWhite:Sprite;
		private var noHoliday:Boolean;
		private var cam:CamPic;
		
		
		public function Main() 
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			Mouse.hide();
			
			photos = new Photos();
			
			cam = new CamPic();
			cam.init(597,896, 0, 0, 1080, 1920);			
			
			vid = new VPlayer();
			vid.showVideo(this);
			vid.autoSizeOff();
			vid.setVidSize( { width:1080, height:1920 } );
			vid.addEventListener(VPlayer.STATUS_RECEIVED, checkStatus, false, 0, true);
			 
			happy = new VPlayer();
			happy.showVideo(this);
			happy.autoSizeOff();
			happy.setVidSize( { width:1080, height:1920 } );
			happy.addEventListener(VPlayer.STATUS_RECEIVED, loopHappy, false, 0, true);
			
			//plain white graphic for one market
			plainWhite = new Sprite();
			plainWhite.graphics.beginFill(0xffffff, 1);
			plainWhite.graphics.drawRect(0, 0, 1080, 1920);
			plainWhite.graphics.endFill();
			noHoliday = true;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress, false, 0, true);
			
			vidNum = 0;
			vids = new Array("phone1.mp4");//, "phone2.mp4", "phone3.mp4"
			
			if (photos.exists()) {
				addChild(photos);
				photos.show();
				showingPhotos = true;
			}else{
				playVideo();
				showingPhotos = false;
			}
		}
		
		
		private function checkStatus(e:Event):void
		{
			if(vid.getStatus() == "NetStream.Play.Stop")
			{
				playVideo();
			}
		}
		
		
		private function loopHappy(e:Event):void
		{
			if(happy.getStatus() == "NetStream.Play.Stop")
			{
				happy.showVideo(this);
				happy.playVideo("happy.mp4");
			}
		}
		 
		
		private function playVideo():void
		{
			vid.showVideo(this);
			vid.playVideo(vids[vidNum]);
			vidNum++;
			if (vidNum >= vids.length) {
				vidNum = 0;
			}
		}
		
		
		private function keyPress(e:KeyboardEvent):void
		{
			if (e.keyCode == 65) {
				//a - user stepped in
				if (showingPhotos) {
					photos.hide();
				}else{
					vid.hideVideo();
				}
				/*
				if (noHoliday) {
					addChild(plainWhite);					
				}else {
					happy.showVideo(this);
					happy.playVideo("happy.mp4");
				}
				*/
				cam.show(this);
			}
			if (e.keyCode == 66) {
				//b - user stepped out
				/*
				if (noHoliday) {
					if(contains(plainWhite)){
						removeChild(plainWhite);
					}
				}else {
					happy.hideVideo();
				}				
				*/
				
				cam.dispose();
				
				if (showingPhotos) {
					photos.unHide();
				}else{
					playVideo();
				}				
			}
		}
	}
	
}