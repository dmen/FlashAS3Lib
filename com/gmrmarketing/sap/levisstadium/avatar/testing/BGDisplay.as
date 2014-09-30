package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.Mouse;	
	import com.greensock.TweenMax;
	import flash.utils.Timer;
	
	
	public class BGDisplay
	{
		private var window:NativeWindow;
		private var hasTwoMonitors:Boolean;
		
		private var bgArray:Array;
		private var bgLoader:Loader; //for loading the bg images
		private var bgIndex:int; //index in bgArray
		private var bgTimer:Timer;
		
		private const useBG:Boolean = false;
		
		public function BGDisplay()
		{
			bgIndex = 0;
			
			//images in the backgrounds folder
			bgArray = new Array();
			bgArray.push("bg2014.png", "bg2005.png", "bg1996.png");
			bgArray.push("bg1994.png", "bg1984.png", "bg1963.png", "bg1952.png", "bg1946.png");
			
			bgLoader = new Loader();
			bgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaded);
			
			bgTimer = new Timer(10000, 1);
			
			hasTwoMonitors = false;			
			
			//put the window on the 2nd monitor
			if(useBG){
				if (Screen.screens.length > 1) {
					var ops:NativeWindowInitOptions = new NativeWindowInitOptions();
					ops.systemChrome = NativeWindowSystemChrome.NONE;
					
					var i:int = 0;
					while(i < Screen.screens.length){
						var screen:Screen = Screen.screens[i];
						if(screen.bounds.height == 1920){//could do || 1680 to use testing monitor
							window = new NativeWindow(ops);
							window.bounds = screen.bounds;
							window.activate();
							
							window.stage.displayState = StageDisplayState.FULL_SCREEN;
							window.stage.align = StageAlign.TOP_LEFT;
							window.stage.scaleMode = StageScaleMode.NO_SCALE;
							window.stage.color = 0x000000;
							
							//window.move(screen.visibleBounds.left, screen.visibleBounds.top);
							window.x = screen.bounds.left;
							window.y = screen.bounds.top;
							hasTwoMonitors = true;
							
							break;
						}
						i++;
					}
				}
			}
			
		}
		
		
		public function usingBG():Boolean
		{
			return useBG;
		}
		
		
		private function loadNextBG(e:TimerEvent = null):void
		{
			bgLoader.load(new URLRequest("backgrounds/" + bgArray[bgIndex]));
			bgIndex++;
			if (bgIndex >= bgArray.length) {
				bgIndex = 0;
			}
			
		}
		
		
		private function bgLoaded(e:Event):void
		{
			var b:Bitmap = Bitmap(e.target.content);
			b.smoothing = true;			
			b.alpha = 0;
			window.stage.addChild(b);
			var bi:Bitmap = Bitmap(window.stage.getChildAt(0));
			if(bi){
				TweenMax.to(bi, 3, { alpha:0 } );
			}
			TweenMax.to(b, 3, { alpha:.4, onComplete:killUnder } );
		}
		
		
		/**
		 * removes image under the one that just faded in, in bgLoaded()
		 */
		private function killUnder():void
		{
			while (window.stage.numChildren > 1) {
				window.stage.removeChildAt(0);
			}
			bgTimer.start();
		}
		
		
		public function showSlideshow():void
		{
			if (hasTwoMonitors) {
				bgIndex = 0;
				bgTimer.addEventListener(TimerEvent.TIMER, loadNextBG, false, 0, true);
				loadNextBG();
			}
		}
		
		
		public function stopSlideshow():void
		{
			bgTimer.reset();
			bgTimer.removeEventListener(TimerEvent.TIMER, loadNextBG);
		}
		
		
		public function showImage(bmp:Bitmap):void
		{
			stopSlideshow();
			if (hasTwoMonitors) {		
				
				bmp.alpha = 0;
				window.stage.addChild(bmp);
				var bi:Bitmap = Bitmap(window.stage.getChildAt(0));
				if(bi){
					TweenMax.to(bi, 3, { alpha:0 } );
				}
				TweenMax.to(bmp, 3, { alpha:.4, onComplete:killUnder2 } );
			}
		}
		
		
		private function killUnder2():void
		{
			while (window.stage.numChildren > 1) {
				window.stage.removeChildAt(0);
			}
		}
	}
	
}