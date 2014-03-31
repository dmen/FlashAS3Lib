
package com.gmrmarketing.website
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo; //for flashvars
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	import flash.display.Shape;
	import flash.display.Sprite;

	import flash.events.*;
	import gs.TweenLite;
	import gs.easing.*;
	import gs.plugins.*;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.net.navigateToURL;
	import flash.display.MovieClip;


	public class LanguageSelector extends MovieClip
	{
		// create a movie clip in displace_mc to draw perlin noise in
		private var disp1:MovieClip;//instance of disp clip with ramp inside it		
		private var ramp:MovieClip; //red gradient already present in disp
		private var speed:int = 3; // speed at which noise is shifted (causes flap)		

		// create BitmapData object encompasing the size of the displace ramp
		// for the displacement and create a displace filter that uses it
		private var displaceBitmap:BitmapData;
		private var displaceFilter:DisplacementMapFilter;

		// create BitmapData object for the noise and apply perlinNoise.  It will be repeated
		// along y so it  only needs to be 1 pixel high.  How long it is determines the
		// variants of noise produced.  With the stitching and thanks to beginGradientFill,
		// we will just loop the noise over time.
		private var noiseBitmap:BitmapData;
		
		// the shift matrix allows for the noise to be moved over time
		// using beginBitmapFill since the noise is only created once
		// and just looped for the flag effect
		private var shift:Matrix;
		
		
		public function LanguageSelector()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;			
			
			shift = new Matrix();			
			
			disp1 = new disp();//library clip
			disp1.addChildAt(new Sprite(), 0);			
			
			displaceBitmap = new BitmapData(disp1.ramp.width, disp1.ramp.height);
			displaceFilter = new DisplacementMapFilter(displaceBitmap, new Point(0,-1), 1, 1, 60, 20, "clamp", 0, 0);
			
			noiseBitmap = new BitmapData(500, 1);
			noiseBitmap.perlinNoise(50, 0, 1, 10, true, true, 1, false);			
			
			//addEventListener(Event.ENTER_FRAME, loopPerlin, false, 0, true);
			
			fiveBoxes.theMap.us.addEventListener(MouseEvent.CLICK, goUS, false, 0, true);
			fiveBoxes.theMap.sp.addEventListener(MouseEvent.CLICK, goSP, false, 0, true);
			fiveBoxes.theMap.gr.addEventListener(MouseEvent.CLICK, goGR, false, 0, true);
			
			fiveBoxes.theMap.us.buttonMode = true;
			fiveBoxes.theMap.sp.buttonMode = true;
			fiveBoxes.theMap.gr.buttonMode = true;
			
			addEventListener(Event.ADDED_TO_STAGE, onStageResize, false, 0, true);
		}

		private function goUS(e:MouseEvent):void
		{			
			navigateToURL(new URLRequest("en/"), "_parent");	 
		}
		private function goSP(e:MouseEvent):void
		{			
			navigateToURL(new URLRequest("sp/"), "_parent");	 
		}
		private function goGR(e:MouseEvent):void
		{			
			navigateToURL(new URLRequest("gr/"), "_parent");	 
		}
		
		
		private function onStageResize(event:Event = null):void
		{
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			if(stage.stageWidth > fiveBoxes.width){
				fiveBoxes.x = ((stage.stageWidth - fiveBoxes.width) * .5);				
			}
		}
		
		



		private function loopPerlin(e:Event):void
		{
			// move the matrix by speed along x to shift the noise
			shift.translate(speed, 0);
			
			// drawing in the perlin movie clip,
			// create a rectangle with the perlin noise
			// drawn in it with an offset supplied by the
			// shift matrix
			var s:DisplayObject = disp1.getChildAt(0);
			with (s){
				graphics.clear();
				graphics.beginBitmapFill(noiseBitmap, shift);
				graphics.moveTo(0,0);
				graphics.lineTo(disp1.ramp.width, 0);
				graphics.lineTo(disp1.ramp.width, disp1.ramp.height);
				graphics.lineTo(0, disp1.ramp.height);
				graphics.lineTo(0, 0);
				graphics.endFill();
			}
			displaceBitmap.draw(disp1);
			
			fiveBoxes.theMap.us.filters = [displaceFilter];
			fiveBoxes.theMap.sp.filters = [displaceFilter];
			fiveBoxes.theMap.gr.filters = [displaceFilter];
		}
	}
}	

