/**
 * Main image tools clip
 */
package com.gmrmarketing.ufc.fightcard
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.BitmapData;	
	import flash.display.Bitmap;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import flash.utils.Timer;
	import com.sagecollective.utilities.SliderV;
	

	
	public class Outliner extends MovieClip
	{
		public static const OUTLINE_CLIP_ADDED:String = "outlineClipAdded";
		public static const OUTLINE_DONE:String = "outlineDone";
		public static const OUTLINE_SHOW_PREVIEW:String = "showOutlinePreview";
		public static const OUTLINE_HIDE_PREVIEW:String = "hideOutlinePreview";
		public static const OUTLINE_RESTART:String = "restartApp";
		
		private var holder:Sprite; //contains the images,mask and outline
		
		private var image:Bitmap;
		
		private var outline:MovieClip; //template - library clip
		private var maskData:BitmapData;
		private var maskBitmap:Bitmap;//contains maskData
		
		private var dots:Array; //array of points in the outline
		
		private var blur:BlurFilter;
		
		private var clip:MovieClip; //the library clip for this object
		private var container:DisplayObjectContainer;
		
		private var eraserMode:Boolean;
		private var drawColor:uint;
		
		private var delayTimer:Timer; //for auto move,rotate,scale
		private var autoMoveDirection:int;
		
		private var brushSize:int;
		
		private var brushGhost:Sprite;
		
		private var contrastSlider:SliderV;
		private var saturationSlider:SliderV;
		
		private var clearBitmap:BitmapData; //filled with alpha 0
		
		
		public function Outliner()
		{
			clip = new image_outliner();
			
			holder = new Sprite(); //container for image, and mask			
			
			blur = new BlurFilter(3, 3, 2);//for a slight antialiasing of the mask edge
			
			brushGhost = new Sprite();
			brushGhost.blendMode = BlendMode.INVERT;
			
			delayTimer = new Timer(250, 1);
			
			maskData = new BitmapData(400, 569, true, 0x00000000);
			maskBitmap = new Bitmap(maskData);
			
			clearBitmap = new BitmapData(400, 569, true, 0x00000000);
			
			TweenPlugin.activate([ColorMatrixFilterPlugin]);				
		}
		
		
		/**
		 * clears the mask, empties holder
		 */
		public function reset():void
		{
			//clears maskData
			maskData.copyChannel(clearBitmap, new Rectangle(0, 0, 400, 569), new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			while(holder.numChildren){
				holder.removeChildAt(0);
			}
			if(clip.contains(holder)){
				clip.removeChild(holder);
			}
			if(clip.contains(brushGhost)){
				clip.removeChild(brushGhost);
			}
		}
		
		/**
		 * 
		 * @param	$container
		 * @param	templateNumber int 1-4
		 * @param	$image Full size capture image (currently 600x800)
		 */
		public function show($container:DisplayObjectContainer, templateNumber:int, $image:Bitmap):void
		{			
			container = $container;
			
			clip.alpha = 0;			
			container.addChild(clip);
			
			image = $image;
			
			//scale image to fit in space - 399x569
			var scw:Number = 400 / image.width;
			var sch:Number = 569 / image.height;
			var sc:Number = Math.max(scw, sch);
			image.scaleX = image.scaleY = sc;
			
			holder.addChild(image);
			holder.addChild(maskBitmap);
			
			//trace("holder numChildren:", holder.numChildren);
			
			//draw mask image into maskBitmap
			switch(templateNumber) {
				case 1:
					maskData.draw(new tm2());
					break;
				case 2:
					maskData.draw(new tm2());
					break;
				case 3:
					maskData.draw(new tm3());
					break;
				case 4:
					maskData.draw(new tm1());
					break;
			}
			
			
			image.cacheAsBitmap = true;
			maskBitmap.cacheAsBitmap = true;//needed - even for bitmaps
			
			image.mask = maskBitmap;
			
			holder.x = 12;
			holder.y = 127;
			
			clip.addChild(holder);						
			
			enableDrawing(); //adds stage listeners	
			
			clip.btnMode.addEventListener(MouseEvent.CLICK, toggleEraser, false, 0, true);			
			
			//arrows for moving the image
			clip.imageRight.addEventListener(MouseEvent.MOUSE_DOWN, startMoveImage, false, 0, true);
			clip.imageDown.addEventListener(MouseEvent.MOUSE_DOWN, startMoveImage, false, 0, true);
			clip.imageLeft.addEventListener(MouseEvent.MOUSE_DOWN, startMoveImage, false, 0, true);
			clip.imageUp.addEventListener(MouseEvent.MOUSE_DOWN, startMoveImage, false, 0, true);
			clip.imageRight.addEventListener(MouseEvent.MOUSE_UP, endMoveImage, false, 0, true);
			clip.imageDown.addEventListener(MouseEvent.MOUSE_UP, endMoveImage, false, 0, true);
			clip.imageLeft.addEventListener(MouseEvent.MOUSE_UP, endMoveImage, false, 0, true);
			clip.imageUp.addEventListener(MouseEvent.MOUSE_UP, endMoveImage, false, 0, true);
			
			clip.imageRight.buttonMode = true;
			clip.imageDown.buttonMode = true;
			clip.imageLeft.buttonMode = true;
			clip.imageUp.buttonMode = true;
			
			//rotation
			clip.rotateLeft.addEventListener(MouseEvent.MOUSE_DOWN, startRotateImage, false, 0, true);
			clip.rotateRight.addEventListener(MouseEvent.MOUSE_DOWN, startRotateImage, false, 0, true);
			clip.rotateLeft.addEventListener(MouseEvent.MOUSE_UP, endRotateImage, false, 0, true);
			clip.rotateRight.addEventListener(MouseEvent.MOUSE_UP, endRotateImage, false, 0, true);
			
			clip.rotateLeft.buttonMode = true;
			clip.rotateRight.buttonMode = true;
			
			//scale
			clip.scalePlus.addEventListener(MouseEvent.MOUSE_DOWN, startScaleImage, false, 0, true);
			clip.scaleMinus.addEventListener(MouseEvent.MOUSE_DOWN, startScaleImage, false, 0, true);
			clip.scalePlus.addEventListener(MouseEvent.MOUSE_UP, endScaleImage, false, 0, true);
			clip.scaleMinus.addEventListener(MouseEvent.MOUSE_UP, endScaleImage, false, 0, true);
			
			clip.scalePlus.buttonMode = true;
			clip.scaleMinus.buttonMode = true;
			
			//brushes			
			clip.b22.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b20.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b18.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b16.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b14.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b12.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b10.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b8.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			clip.b6.addEventListener(MouseEvent.CLICK, changeBrushSize, false, 0, true);
			
			clip.b22.buttonMode = true;
			clip.b20.buttonMode = true;
			clip.b18.buttonMode = true;
			clip.b16.buttonMode = true;
			clip.b14.buttonMode = true;
			clip.b12.buttonMode = true;
			clip.b10.buttonMode = true;
			clip.b8.buttonMode = true;
			clip.b6.buttonMode = true;
			
			//contrast/saturation		
			contrastSlider = new SliderV(clip.contrastSlider, clip.contrastTrack);
			contrastSlider.addEventListener(SliderV.DRAGGING, updateConSat, false, 0, true);
			saturationSlider = new SliderV(clip.satSlider, clip.satTrack);
			saturationSlider.addEventListener(SliderV.DRAGGING, updateConSat, false, 0, true);			
					
			//bottom buttons
			clip.btnDone.addEventListener(MouseEvent.CLICK, done, false, 0, true);
			clip.btnPreview.addEventListener(MouseEvent.CLICK, previewCard, false, 0, true);			
			clip.btnRestart.addEventListener(MouseEvent.CLICK, doRestart, false, 0, true);
			
			clip.btnDone.buttonMode = true;
			clip.btnPreview.buttonMode = true;		
			clip.btnRestart.buttonMode = true;
			
			eraserMode = false;			
			
			changeBrushSize(); //sets default brush size to 14
			toggleEraser();
			
			//for brush ghost
			addEventListener(Event.ENTER_FRAME, updateGhost, false, 0, true);
			clip.addChild(brushGhost);
			
			TweenLite.to(clip, 1, { alpha:1, onComplete:clipAdded } );		
		}
		
		//these are called from main to to stop drawing while the preview is showing
		public function enableDrawing():void
		{
			container.stage.addEventListener(MouseEvent.MOUSE_DOWN, beginDrawing, false, 0, true);
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDrawing, false, 0, true);		
		}
		public function disableDrawing():void
		{
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrawing);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrawing);		
		}
		
		
		public function hide():void
		{			
			//arrows for moving the image
			clip.imageRight.removeEventListener(MouseEvent.MOUSE_DOWN, startMoveImage);
			clip.imageDown.removeEventListener(MouseEvent.MOUSE_DOWN, startMoveImage);
			clip.imageLeft.removeEventListener(MouseEvent.MOUSE_DOWN, startMoveImage);
			clip.imageUp.removeEventListener(MouseEvent.MOUSE_DOWN, startMoveImage);
			clip.imageRight.removeEventListener(MouseEvent.MOUSE_UP, endMoveImage);
			clip.imageDown.removeEventListener(MouseEvent.MOUSE_UP, endMoveImage);
			clip.imageLeft.removeEventListener(MouseEvent.MOUSE_UP, endMoveImage);
			clip.imageUp.removeEventListener(MouseEvent.MOUSE_UP, endMoveImage);
			
			//rotation
			clip.rotateLeft.removeEventListener(MouseEvent.MOUSE_DOWN, startRotateImage);
			clip.rotateRight.removeEventListener(MouseEvent.MOUSE_DOWN, startRotateImage);
			clip.rotateLeft.removeEventListener(MouseEvent.MOUSE_UP, endRotateImage);
			clip.rotateRight.removeEventListener(MouseEvent.MOUSE_UP, endRotateImage);
			
			//scale
			clip.scalePlus.removeEventListener(MouseEvent.MOUSE_DOWN, startScaleImage);
			clip.scaleMinus.removeEventListener(MouseEvent.MOUSE_DOWN, startScaleImage);
			clip.scalePlus.removeEventListener(MouseEvent.MOUSE_UP, endScaleImage);
			clip.scaleMinus.removeEventListener(MouseEvent.MOUSE_UP, endScaleImage);
			
			//brushes
			clip.b22.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b20.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b18.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b16.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b14.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b12.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b10.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b8.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			clip.b6.removeEventListener(MouseEvent.CLICK, changeBrushSize);
			
			//ghost
			removeEventListener(Event.ENTER_FRAME, updateGhost);
			
			//sliders
			contrastSlider.resetSlider();
			saturationSlider.resetSlider();
			contrastSlider.removeEventListener(SliderV.DRAGGING, updateConSat);			
			saturationSlider.removeEventListener(SliderV.DRAGGING, updateConSat);
			
			container.stage.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrawing);
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrawing);			
			
			clip.btnMode.removeEventListener(MouseEvent.CLICK, toggleEraser);
			clip.btnDone.removeEventListener(MouseEvent.CLICK, done);
			clip.btnPreview.removeEventListener(MouseEvent.CLICK, previewCard);
			clip.btnRestart.removeEventListener(MouseEvent.CLICK, doRestart);
			
			container.removeChild(clip);
		}
		
		
		private function toggleEraser(e:MouseEvent = null):void
		{
			eraserMode = !eraserMode;
			if(eraserMode){
				drawColor = 0x00ff0000;
				clip.btnMode.gotoAndStop(2);
			}else {
				drawColor = 0xffff0000;				
				clip.btnMode.gotoAndStop(1);				
			}
		}		
		
		private function updateGhost(e:Event):void
		{
			//only display ghost when it's in the holder rect
			if(mouseX > 20 && mouseX < 422 && mouseY > 125 && mouseY < 697){
				brushGhost.x = mouseX;
				brushGhost.y = mouseY;
			}else {
				brushGhost.x = -500;
			}
		}
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(OUTLINE_CLIP_ADDED));
		}
		
		
		
		private function beginDrawing(e:MouseEvent):void
		{
			addEventListener(Event.ENTER_FRAME, updateDrawing, false, 0, true);			
		}
		
		
		/**
		 * Stops drawing
		 * @param	e MOUSE_UP event
		 */
		private function endDrawing(e:MouseEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrawing);			
			
			endMoveImage();
			endRotateImage();
			endScaleImage();
		}
		
		
		private function updateDrawing(e:Event):void
		{	
			var h:int;
			
			maskData.lock();
			for (var theX:int = -brushSize; theX < brushSize ; theX++)
			{
				h = Math.round(Math.sqrt(brushSize * brushSize - theX * theX));
			
				for (var theY:int = -h; theY < h; theY++)
					maskData.setPixel32(theX + holder.mouseX, theY + holder.mouseY, drawColor);
			}
			
			maskData.unlock();
		}
		
		
		/**
		 * Called by clicking the done button
		 * @param	e
		 */
		private function done(e:MouseEvent):void
		{
			dispatchEvent(new Event(OUTLINE_DONE));
		}
		
		
		/**
		 * Called by clicking the preview button
		 * @param	e
		 */
		private function previewCard(e:MouseEvent):void
		{
			dispatchEvent(new Event(OUTLINE_SHOW_PREVIEW));
		}
		
		

		public function grabImage():BitmapData
		{
			image.mask = null;
			if (holder.contains(maskBitmap)) {
				holder.removeChild(maskBitmap);
			}
			
			var mdat:BitmapData = new BitmapData(400, 569, true, 0);
			mdat.draw(maskData);
			mdat.applyFilter(maskData, new Rectangle(0,0,mdat.width,mdat.height), new Point(0, 0), blur);
			
			var bmd:BitmapData = new BitmapData(400, 569, true, 0);
			
			var userImage:BitmapData = new BitmapData(400, 569, true, 0);
			userImage.draw(holder);
			
			bmd.copyPixels(userImage, new Rectangle(0, 0, 400, 569), new Point(0, 0), mdat, new Point(0, 0), false);
			
			holder.addChild(maskBitmap);
			image.mask = maskBitmap;
			
			return bmd;
		}
		
		
		/**
		 * Called whenever a circle brush icon is clicked
		 * called from show() to set default brush size (e = null)
		 * @param	e
		 */
		private function changeBrushSize(e:MouseEvent = null):void
		{
			brushGhost.graphics.clear();
			var n:String;
			if(e){
				//gets b24 - b8
				n = MovieClip(e.currentTarget).name;
			}else {
				n = "b14"; //default brush size
			}
			
			brushSize = parseInt(n.substr(1)) - 4; //remove the b			
			
			brushGhost.graphics.lineStyle(1, 0xff0000, 1);
			var radius:Number = brushSize;
			brushGhost.graphics.drawCircle( 0, 0, radius);
		}
		
		
		
		//MOVE
		/**
		 * Called on mouseDown on any of the arrow buttons
		 * @param	e
		 */
		private function startMoveImage(e:MouseEvent):void
		{
			var btn:String = MovieClip(e.currentTarget).name;
			switch(btn) {
				case "imageRight":
					image.x += 5;
					autoMoveDirection = 1;
					break;
				case "imageLeft":
					image.x -= 5;
					autoMoveDirection = 2;
					break;
				case "imageUp":
					image.y -= 5;
					autoMoveDirection = 3;
					break;
				case "imageDown":
					image.y += 5;
					autoMoveDirection = 4;
					break;
			}
			
			delayTimer.addEventListener(TimerEvent.TIMER, autoMoveStart, false, 0, true);
			delayTimer.start();
		}
		
		
		
		private function endMoveImage(e:MouseEvent = null):void
		{
			delayTimer.removeEventListener(TimerEvent.TIMER, autoMoveStart);
			removeEventListener(Event.ENTER_FRAME, autoMove);
			delayTimer.stop();		
		}
		
		
		private function autoMoveStart(e:TimerEvent):void
		{
			endMoveImage();
			addEventListener(Event.ENTER_FRAME, autoMove, false, 0, true);
		}
		
		
		private function autoMove(e:Event):void
		{
			switch(autoMoveDirection) {
				case 1:
					image.x += 2;
					break;
				case 2:
					image.x -= 2;
					break;
				case 3:
					image.y -= 2;
					break;
				case 4:
					image.y += 2
					break;
			}
		}
		
		
		
		//ROTATE
		private function startRotateImage(e:MouseEvent):void
		{
			var btn:String = MovieClip(e.currentTarget).name;
			switch(btn) {
				case "rotateLeft":
					image.rotation -= 3;
					autoMoveDirection = 1;
					break;
				case "rotateRight":
					image.rotation += 3;
					autoMoveDirection = 2;
					break;
			}
			delayTimer.addEventListener(TimerEvent.TIMER, autoRotateStart, false, 0, true);
			delayTimer.start();
		}
		
		private function endRotateImage(e:MouseEvent = null):void
		{
			delayTimer.removeEventListener(TimerEvent.TIMER, autoRotateStart);
			removeEventListener(Event.ENTER_FRAME, autoRotate);
			delayTimer.stop();		
		}
		
		private function autoRotateStart(e:TimerEvent):void
		{
			endRotateImage();
			addEventListener(Event.ENTER_FRAME, autoRotate, false, 0, true);
		}
		
		private function autoRotate(e:Event):void
		{
			switch(autoMoveDirection) {
				case 1:
					image.rotation -= 1;
					break;
				case 2:
					image.rotation += 1;
					break;				
			}
		}
		
		
		
		//SCALE
		private function startScaleImage(e:MouseEvent):void
		{
			var btn:String = MovieClip(e.currentTarget).name;
			switch(btn) {
				case "scalePlus":
					image.scaleX += .025;
					image.scaleY += .025;
					autoMoveDirection = 1;
					break;
				case "scaleMinus":
					image.scaleX -= .025;
					image.scaleY -= .025;
					autoMoveDirection = 2;
					break;
			}
			delayTimer.addEventListener(TimerEvent.TIMER, autoScaleStart, false, 0, true);
			delayTimer.start();
		}
		
		private function endScaleImage(e:MouseEvent = null):void
		{
			delayTimer.removeEventListener(TimerEvent.TIMER, autoScaleStart);
			removeEventListener(Event.ENTER_FRAME, autoScale);
			delayTimer.stop();		
		}
		
		private function autoScaleStart(e:TimerEvent):void
		{
			endScaleImage();
			addEventListener(Event.ENTER_FRAME, autoScale, false, 0, true);
		}
		
		private function autoScale(e:Event):void
		{
			switch(autoMoveDirection) {
				case 1:
					image.scaleX += .025;
					image.scaleY += .025;
					break;
				case 2:
					image.scaleX -= .025;
					image.scaleY -= .025;
					break;				
			}
		}
		
		
		
		//contrast - saturation
		private function updateConSat(e:Event):void
		{
			var c:Number = (1 - contrastSlider.getPosition()) + 1; //1 - 2
			var s:Number = ((1 - saturationSlider.getPosition()) * 2) + 1; //1 - 3
			
			TweenLite.to(image, .5, {colorMatrixFilter:{contrast:c, saturation:s}});
		}
		
		
		
		/**
		 * Called by clicking the bottom restart button
		 * @param	e
		 */
		private function doRestart(e:MouseEvent):void
		{
			dispatchEvent(new Event(OUTLINE_RESTART));
		}
	
	}
}