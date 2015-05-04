package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.Event;
	import flash.ui.*;	
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var takePhoto:TakePhoto;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			intro = new Intro();
			intro.container = this;
			
			takePhoto = new TakePhoto();
			takePhoto.container = this;
			
			intro.addEventListener(Intro.COMPLETE, introComplete);
			intro.show();
		}
		
		
		private function introComplete(e:Event):void
		{
			takePhoto.show();
			takePhoto.addEventListener(TakePhoto.SHOWING, hideIntro);
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			intro.hide();
		}
		
	}
	
}