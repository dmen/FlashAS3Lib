package com.gmrmarketing.sap.levisstadium.avatar.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;	
	import flash.display.StageAlign;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.ui.Mouse;	
	
	public class BGDisplay
	{
		private var window:NativeWindow;
		private var hasTwoMonitors:Boolean;
		
		public function BGDisplay()
		{
			hasTwoMonitors = false;
			
			//put the window on the 2nd monitor
			if (Screen.screens.length > 1) {
				var ops:NativeWindowInitOptions = new NativeWindowInitOptions();
                ops.systemChrome = NativeWindowSystemChrome.NONE;
				
				var screen:Screen = Screen.screens[1];
				
				window = new NativeWindow(ops);
				window.bounds = screen.bounds;
				window.activate();
				
				window.stage.displayState = StageDisplayState.FULL_SCREEN;
				window.stage.align = StageAlign.TOP_LEFT;
				window.stage.scaleMode = StageScaleMode.NO_SCALE;
				window.stage.color = 0x000000;
				
				//window.move(screen.visibleBounds.left, screen.visibleBounds.top);
				window.x = screen.bounds.left;
				hasTwoMonitors = true;
			}
		}
		
		
		public function showImage(bmd:BitmapData):void
		{
			if (hasTwoMonitors) {
				var image:Bitmap = new Bitmap(bmd);
				while (window.stage.numChildren > 1) {
					window.stage.removeChildAt(1);
				}
				window.stage.addChild(image);
			}
		}
	}
	
}