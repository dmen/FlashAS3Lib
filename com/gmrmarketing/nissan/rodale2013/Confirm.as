package com.gmrmarketing.nissan.rodale2013
{
	import com.gmrmarketing.nissan.rodale2013.Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.*;
	import com.gmrmarketing.utilities.Slider;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.media.Sound;
	
	
	public class Confirm extends EventDispatcher
	{
		public static const RETAKE:String = "retake";
		public static const CONTINUE:String = "continue";		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var overlayContainer:Sprite;
		private var currentOverlay:MovieClip;		
		
		private var btnBack:Button;
		private var btnPrint:Button;
		private var butt:Sound;
		
		private var zoomSlider:Slider;
		private var zoomMultiplier:Number;
		private var tim:TimeoutHelper;
		
		private var white:BitmapData; //whiteCirc in library
		private var whiteAlpha:BitmapData;
		
		
		public function Confirm()
		{
			clip = new mcConfirm();
			
			btnBack = new Button(clip, "white", "Retake", 968, 809);
			btnPrint = new Button(clip, "red", "Print", 1430, 809);
			butt = new sndButton();
			
			overlayContainer = new Sprite();
			overlayContainer.x = 400;
			overlayContainer.y = 400;
			
			clip.tempMask.alpha = 0;//template mask
			
			tim = TimeoutHelper.getInstance();
			
			white = new whiteCirc();
			whiteAlpha = new BitmapData(791, 791, true, 0x77ffffff);
			
			zoomSlider = new Slider(clip.zoomSlider, clip.zoomTrack);
		}	
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show(image:BitmapData):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			tim.buttonClicked();
			
			currentOverlay = new mcHeadband();	
			clip.addChild(overlayContainer);
			
			//image.copyPixels(white, new Rectangle(0, 0, 791, 791), new Point(309, 0), whiteAlpha, new Point(0, 0), true);
			
			var bmp:Bitmap = new Bitmap(image);			
			clip.camHolder.addChild(bmp);
			clip.camHolder.mask = clip.theMask;
			
			clip.alpha = 0;
			btnBack.addEventListener(Button.PRESSED, retake, false, 0, true);
			btnPrint.addEventListener(Button.PRESSED, cont, false, 0, true);
			
			clip.iconHighlight.x = 1593;//no overlay
			clip.iconHighlight.width = 160;
			
			clip.btnHeadband.addEventListener(MouseEvent.MOUSE_DOWN, addHeadband, false, 0, true);
			clip.btnEyeblack.addEventListener(MouseEvent.MOUSE_DOWN, addEyeblack, false, 0, true);
			clip.btnNoOverlay.addEventListener(MouseEvent.MOUSE_DOWN, removeTemplate, false, 0, true);
			
			zoomSlider.reset();
			
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.from(clip.theText, 1, { alpha:0, x:"100", delay:.5 } );
		}
		
		
		public function hide():void
		{
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, cont);
			TweenMax.to(clip, 1, { alpha:0, onComplete:kill } );
		}
		
		
		public function getPic(withWhite:Boolean = true):BitmapData
		{
			clip.printBlock.visible = false;
			var bmd:BitmapData = new BitmapData(1920, 1080);
			bmd.draw(clip);
			var ret:BitmapData = new BitmapData(791, 791);
			
			//85,188 is because the bitmap is inside camHolder at x:-224 and the masked portion is at x:85,y:188
			ret.copyPixels(bmd, new Rectangle(85, 188, 791, 791), new Point(0, 0));
			
			if(withWhite){
				ret.copyPixels(white, new Rectangle(0, 0, 791, 791), new Point(0, 0), null, null, true);
			}
			clip.printBlock.visible = true;
			
			var m:Matrix = new Matrix();
			m.scale(4, 4);
			
			var doubleSize:BitmapData = new BitmapData(3164,3164);
			doubleSize.draw(ret, m, null, null, null, true);
			
			var cl:BitmapData = new cornerLogo(); //lib clip
			doubleSize.copyPixels(cl, new Rectangle(0, 0, cl.width, cl.height), new Point(2730, 2671));
			
			return doubleSize;
		}
		
		
		private function retake(e:Event):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function cont(e:Event):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(CONTINUE));
		}
		
		
		private function addHeadband(e:MouseEvent):void
		{		
			butt.play();
			tim.buttonClicked();
			TweenMax.to(clip.iconHighlight, .75, { x:952, width:188, alpha:1, ease:Back.easeOut } );
			
			if (overlayContainer.contains(currentOverlay)) {
				overlayContainer.removeChild(currentOverlay);
			}
			currentOverlay = new mcHeadband();
			
			overlayContainer.addChild(currentOverlay);
			currentOverlay.x = 0 - currentOverlay.width * .5;
			currentOverlay.y = 0 - currentOverlay.height * .5;
			overlayContainer.scaleX = overlayContainer.scaleY = 1;
			overlayContainer.x = 480;
			overlayContainer.y = 550;
			
			currentOverlay.mask = clip.tempMask;			
			currentOverlay.mouseEnabled = false;
			zoomMultiplier = 1;
			zoomSlider.reset();
			zoomSlider.addEventListener(Slider.DRAGGING, updateTemplateScale, false, 0, true);
			enableDrag();
		}
		
		
		private function addEyeblack(e:MouseEvent):void
		{
			butt.play();
			tim.buttonClicked();
			TweenMax.to(clip.iconHighlight, .75, { x:1228, width:278, alpha:1, ease:Back.easeOut } );
			
			if (overlayContainer.contains(currentOverlay)) {
				overlayContainer.removeChild(currentOverlay);
			}
			currentOverlay = new mcEyeblack();			
			
			overlayContainer.addChild(currentOverlay);
			
			currentOverlay.y = 0 - currentOverlay.height * .5;
			overlayContainer.scaleX = overlayContainer.scaleY = .5;
			overlayContainer.x = 480;
			overlayContainer.y = 660;
			
			currentOverlay.mask = clip.tempMask;
			currentOverlay.mouseEnabled = false;
			zoomMultiplier = .5;
			zoomSlider.reset();
			zoomSlider.addEventListener(Slider.DRAGGING, updateTemplateScale, false, 0, true);
			enableDrag();
		}
		
		
		private function removeTemplate(e:MouseEvent = null):void
		{
			tim.buttonClicked();
			
			if(e != null){
				butt.play();
			}
			
			TweenMax.to(clip.iconHighlight, .75, { x:1593, width:160, alpha:1, ease:Back.easeOut } );
			if(overlayContainer && currentOverlay){
				if (overlayContainer.contains(currentOverlay)) {
					overlayContainer.removeChild(currentOverlay);
				}
			}
			zoomSlider.removeEventListener(Slider.DRAGGING, updateTemplateScale);			
		}
		
		
		private function updateTemplateScale(e:Event):void
		{
			tim.buttonClicked();
			overlayContainer.scaleX = overlayContainer.scaleY = (zoomSlider.getPosition() + .5) * zoomMultiplier;
		}
		
		
		private function enableDrag():void
		{
			clip.setChildIndex(clip.tempClicker, clip.numChildren - 1);
			clip.tempClicker.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
			//currentOverlay.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
		}
		
		
		private function beginDrag(e:MouseEvent):void
		{			
			tim.buttonClicked();
			currentOverlay.startDrag();
			container.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		private function endDrag(e:MouseEvent):void
		{
			tim.buttonClicked();
			currentOverlay.stopDrag();			
			container.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
		}
		
		
		private function kill():void
		{			
			zoomSlider.removeEventListener(Slider.DRAGGING, updateTemplateScale);
			removeTemplate();
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}			
		}
		
	}
	
}