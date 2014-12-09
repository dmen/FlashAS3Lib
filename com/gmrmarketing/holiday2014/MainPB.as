package com.gmrmarketing.holiday2014
{
	import com.gmrmarketing.sap.levisstadium.avatar.testing.BGDisplay;
	import flash.display.*;
	import com.gmrmarketing.holiday2014.ColorEmitter;
	import com.gmrmarketing.holiday2014.SpotEmitter;
	import flash.events.Event;
	import com.greensock.TweenMax;
	
	public class MainPB extends MovieClip
	{
		//background 
		private var bgContainer:Sprite;
		private var colorEmitter:ColorEmitter;
		private var spotEmitter:SpotEmitter;
		
		private var fgContainer:Sprite;
		
		private var intro:Intro;
		private var take:Take;
		private var countDown:CountDown;
		private var whiteFlash:WhiteFlash;
		private var retake:RetakeContinue; //retake continue buttons
		private var retakeEmail:RetakeEmail; //retake cancel email buttons
		private var thePic:Bitmap;
		private var overlay:Bitmap;
		
		public function MainPB()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;

			bgContainer = new Sprite();
			addChild(bgContainer);
			
			if(true){
				colorEmitter = new ColorEmitter(bgContainer);
				spotEmitter = new SpotEmitter(bgContainer);
			}else {
				bgContainer.addChild(new Bitmap(new bg()));
			}
			
			fgContainer = new Sprite();
			addChild(fgContainer);
			
			intro = new Intro();
			intro.container = fgContainer;
			
			take = new Take();
			take.container = fgContainer;
			
			countDown = new CountDown();
			countDown.container = fgContainer;
			
			whiteFlash = new WhiteFlash();
			whiteFlash.container = fgContainer;
			
			retake = new RetakeContinue();
			retake.container = fgContainer;
			
			retakeEmail = new RetakeEmail();
			retakeEmail.container = fgContainer;
			
			overlay = new Bitmap(new overlayBMD());
			overlay.x = 512;
			overlay.y = 58;
			
			init();
		}
		
		
		private function init():void
		{
			intro.show();
			intro.addEventListener(Intro.COMPLETE, hideIntro);
		}
		
		
		private function hideIntro(e:Event):void
		{
			intro.removeEventListener(Intro.COMPLETE, hideIntro);
			intro.hide();
			
			take.show();
			take.addEventListener(Take.TAKE, startCount, false, 0, true);
		}
		
		
		private function startCount(e:Event):void
		{
			take.removeEventListener(Take.TAKE, takePhoto);
			
			countDown.addEventListener(CountDown.COMPLETE, takePhoto, false, 0, true);
			countDown.show();//starts counting
		}
		
		
		/**
		 * Called when COMPLETE is received from countDown
		 * @param	e
		 */
		private function takePhoto(e:Event):void
		{
			countDown.hide();
			whiteFlash.show();//shows white and fades out over 1 sec
			
			retake.show(); //show the retake continue buttons
			retake.addEventListener(RetakeContinue.RETAKE, doRetake, false, 0, true);
			retake.addEventListener(RetakeContinue.CONTINUE, doContinue, false, 0, true);
			
			var pic:BitmapData = take.getPic();
			thePic = new Bitmap(pic);
			thePic.x = 544;
			thePic.y = 87;
			thePic.alpha = 0;
			fgContainer.addChild(thePic);
			TweenMax.to(thePic, .5, { alpha:1, delay:.5 } );
		}
		
		
		private function doRetake(e:Event):void
		{
			retake.hide();
			if (fgContainer.contains(thePic)) {
				fgContainer.removeChild(thePic);
			}
			
			take.show();//two lines from hideIntro()
			take.addEventListener(Take.TAKE, startCount, false, 0, true);
		}
		
		
		private function doContinue(e:Event):void
		{
			retake.hide();
			retakeEmail.show();
			
			//add the overlay
			if (!fgContainer.contains(overlay)) {
				fgContainer.addChild(overlay);
			}
			overlay.alpha = 0;
			TweenMax.to(overlay, 1, { alpha:1 } );
		}
		
	}
	
}