/**
 * Main class for text face
 */
package com.gmrmarketing.testing
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import com.greensock.*;
	import flash.geom.ColorTransform;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import com.gmrmarketing.testing.RectFinder;
	import com.gmrmarketing.testing.Swatches;
	import com.gmrmarketing.utilities.Slider;
	
	public class CamRects extends MovieClip
	{
		private const CAM_WIDTH:int = 1920;
		private const CAM_HEIGHT:int = 1080;
		
		private var cam:Camera;
		private var vid:Video;
		private var displayData:BitmapData;		
		private var display:Bitmap;
		private var textDisplay:Bitmap;
		private var rectFinder:RectFinder;
		private var rectsShowing:Boolean;
		private var slider:Slider;
		private var currentThreshold:int;
		private var swatches:Swatches;
		private var controlsOpen:Boolean;
		
		public function CamRects()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;

			rectFinder = new RectFinder();
			
			currentThreshold = 117;
			sideControls.thresh.text = String(currentThreshold);
			
			swatches = new Swatches();
			swatches.setContainer(sideControls);
			
			slider = new Slider(sideControls.slidermc, sideControls.track, "v");
			slider.addEventListener(Slider.DRAGGING, updateThreshold, false, 0, true);
			
			cam = Camera.getCamera();
			cam.setMode(CAM_WIDTH, CAM_HEIGHT, 24, false);
			cam.setQuality(0, 88);

			vid = new Video(CAM_WIDTH, CAM_HEIGHT);
			vid.attachCamera(cam);
			
			displayData = new BitmapData(CAM_WIDTH, CAM_HEIGHT, false, 0xffffff);
			display = new Bitmap(displayData);
			
			addChildAt(display, 0);
			
			rectsShowing = false;
			
			controlsOpen = false;
			arrow.addEventListener(MouseEvent.CLICK, toggleSideControls, false, 0, true);
			
			sideControls.btnGetRects.addEventListener(MouseEvent.CLICK, getRects, false, 0, true);
			sideControls.checkGrid.addEventListener(MouseEvent.CLICK, toggleGrid, false, 0, true);
			sideControls.checkRects.addEventListener(MouseEvent.CLICK, toggleRects, false, 0, true);
			sideControls.checkText.addEventListener(MouseEvent.CLICK, toggleText, false, 0, true);
			sideControls.btnAdd.addEventListener(MouseEvent.CLICK, addColor, false, 0, true);
			sideControls.btnClear.addEventListener(MouseEvent.CLICK, clearColors, false, 0, true);
			sideControls.sampSize.restrict = "0-9";
			
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		
		
		private function toggleSideControls(e:MouseEvent):void
		{
			controlsOpen = !controlsOpen;
			if (controlsOpen) {
				TweenMax.to(vid, 0, {colorMatrixFilter:{threshold:currentThreshold}});
				TweenMax.to(sideControls, .5, { x:1770 } );				
			}else {
				TweenMax.to(vid, 0, { colorMatrixFilter: { threshold:0, remove:true }} );
				TweenMax.to(sideControls, .5, { x:1930 } );
			}
		}
		
		
		private function getRects(e:MouseEvent):void
		{
			if (!rectsShowing) {
				
				TweenMax.to(vid, 0, {colorMatrixFilter:{threshold:currentThreshold}});              
				displayData.draw(vid);
			
				var bmd:BitmapData = rectFinder.createRects(displayData, sideControls.checkGrid.currentFrame == 2, sideControls.checkRects.currentFrame == 2, sideControls.checkText.currentFrame == 2, parseInt(sideControls.sampSize.text), sideControls.bgcolor.selectedColor, swatches.getColors());
				textDisplay = new Bitmap(bmd);
				addChildAt(textDisplay,1);
				rectsShowing = true;
				
			}else {
				
				if(!controlsOpen){
					TweenMax.to(vid, 0, { colorMatrixFilter: { threshold:0, remove:true }} ); 
				}
				removeChild(textDisplay);
				rectsShowing = false;
				
			}
		}
		
		
		private function toggleGrid(e:MouseEvent):void
		{
			if (sideControls.checkGrid.currentFrame == 1) {
				sideControls.checkGrid.gotoAndStop(2);
			}else {
				sideControls.checkGrid.gotoAndStop(1);
			}
		}
		
		private function toggleRects(e:MouseEvent):void
		{
			if (sideControls.checkRects.currentFrame == 1) {
				sideControls.checkRects.gotoAndStop(2);
			}else {
				sideControls.checkRects.gotoAndStop(1);
			}
		}
		
		private function toggleText(e:MouseEvent):void
		{
			if (sideControls.checkText.currentFrame == 1) {
				sideControls.checkText.gotoAndStop(2);
			}else {
				sideControls.checkText.gotoAndStop(1);
			}
		}
		private function addColor(e:MouseEvent):void
		{
			swatches.addColor(sideControls.textColor.selectedColor);
		}
		private function clearColors(e:MouseEvent):void
		{
			swatches.clear();
		}
		
		
		private function updateThreshold(e:Event):void
		{
			currentThreshold = Math.round(slider.getPosition() * 250);
			sideControls.thresh.text = String(currentThreshold);
			TweenMax.to(vid, 0, {colorMatrixFilter:{threshold:currentThreshold}});
		}
		
		/**
		 * Called on ENTER_FRAME
		 * draws video to the image buffer
		 * @param	e
		 */
		private function update(e:Event):void
		{	             
			displayData.draw(vid);
		}

	}
	
}