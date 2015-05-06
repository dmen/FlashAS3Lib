package com.gmrmarketing.comcast.taylorswift.photobooth
{
	import com.greensock.TweenMax;
	import flash.display.*;
	import flash.events.Event;
	import flash.ui.*;	
	import com.gmrmarketing.particles.Dust;
	
	public class Main extends MovieClip
	{
		private var intro:Intro;
		private var takePhoto:TakePhoto;
		private var print:Print;
		private var thanks:Thanks;
		private var mainContainer:Sprite;
		private var dustContainer:Sprite;
		private var queue:Queue;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			//Mouse.hide();
			
			queue = new Queue();
			
			mainContainer = new Sprite();
			dustContainer = new Sprite();
			addChild(mainContainer);
			addChild(dustContainer);
			
			intro = new Intro();
			intro.container = mainContainer;
			
			takePhoto = new TakePhoto();
			takePhoto.container = mainContainer;
			
			print = new Print();
			print.container = mainContainer;
			
			thanks = new Thanks();
			thanks.container = mainContainer;
			
			for(var i:int = 0; i < 150; i++){
				var d:Dust = new Dust();
				d.x = Math.random() * 1920;
				d.y = Math.random() * 1080;
				dustContainer.addChild(d);
			}
			
			init();
		}
		
		
		private function init():void
		{
			intro.addEventListener(Intro.COMPLETE, introComplete);
			intro.show();
		}
		
		
		private function introComplete(e:Event):void
		{
			takePhoto.show();
			takePhoto.addEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.addEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.addEventListener(TakePhoto.PRINT, printPhoto);
		}
		
		
		private function hideIntro(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			intro.hide();
		}
		
		
		private function cancelPhoto(e:Event):void
		{
			takePhoto.removeEventListener(TakePhoto.SHOWING, hideIntro);
			takePhoto.removeEventListener(TakePhoto.CANCEL, cancelPhoto);
			takePhoto.removeEventListener(TakePhoto.PRINT, printPhoto);
			takePhoto.hide();
			init();
		}
		
		
		private function printPhoto(e:Event):void
		{
			var pics:Array = takePhoto.getPhotos();//three 750x750 BMD's
			
			print.addEventListener(Print.SHOWING, hideTakePhoto);
			print.addEventListener(Print.COMPLETE, showThanks);
			print.show(pics);
		}
		
		
		private function hideTakePhoto(e:Event):void
		{
			print.removeEventListener(Print.SHOWING, hideTakePhoto);
			takePhoto.hide();
		}
		
		
		private function showThanks(e:Event):void
		{
			print.removeEventListener(Print.COMPLETE, showThanks);
			
			thanks.addEventListener(Thanks.SHOWING, hidePrint);
			thanks.addEventListener(Thanks.COMPLETE, thanksComplete);
			
			var sendEmail:Boolean = print.data.email != "" ? true : false;
			
			thanks.show(sendEmail);
			
			if (sendEmail) {
				queue.add(print.data);
			}
		}
		
		
		private function hidePrint(e:Event):void
		{
			thanks.removeEventListener(Thanks.SHOWING, hidePrint);
			print.hide();
		}
		
		
		private function thanksComplete(e:Event):void
		{
			intro.addEventListener(Intro.SHOWING, hideThanks);
			init();
		}
		
		
		private function hideThanks(e:Event):void
		{
			intro.removeEventListener(Intro.SHOWING, hideThanks);
			thanks.hide();
		}
		
	}
	
}