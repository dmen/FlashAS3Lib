package com.gmrmarketing.holiday2012
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.events.MouseEvent;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.CamPicFilters;
	
	public class Choose extends EventDispatcher
	{
		public static const SHOWING:String = "CLIP_SHOWING";
		public static const TAKE_PIC:String = "TAKE_PICTURE";
		public static const CAM_SHOWING:String = "CAMERA_SHOWING";
		public static const RETAKE:String = "RETAKE_PHOTOS";
		public static const CONTINUE:String = "CONTINUE_PRESSED";
		public static const TEMPLATE_CHANGED:String = "TEMPLATE_CHANGED";
		
		private var clip:MovieClip;			
		
		private var camPicContainer:Sprite;
		private var templateNumber:int;
		
		private var previewContainer:Sprite;	
		
		private var container:DisplayObjectContainer;
		private var timeoutHelper:TimeoutHelper;
		
		private var peteShowing:Boolean;
		
		
		public function Choose()
		{
			clip = new mc_choose();			
			
			camPicContainer = new Sprite();
			camPicContainer.x = 504;
			camPicContainer.y = 97;
			
			previewContainer = new Sprite();
			previewContainer.x = 504;
			previewContainer.y = 97;
			
			timeoutHelper = TimeoutHelper.getInstance();
		}
		

		/**
		 * Called by main to get the camera container
		 * @return
		 */
		public function getCamContainer():Sprite
		{
			return camPicContainer;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.chooseTemp.y = 80;
			clip.chooseTemp.alpha = 1;
			//add behind frame
			if (!clip.contains(camPicContainer)) {
				clip.addChildAt(camPicContainer,1);
			}			
			if (!clip.contains(previewContainer)) {
				clip.addChildAt(previewContainer,2);
			}
			
			templateNumber = 0; //no template picked			
			
			clip.alpha = 0;		
			clip.retake.x = 1702;
			clip.cont.x = 1702;
			
			peteShowing = false;
			clip.pete.alpha = 0;
			
			clip.templates.hiliter.x = 474; //off screen right
			clip.templates.pete1.alpha = 1;
			clip.templates.pete2.alpha = 1;
			clip.templates.pete3.alpha = 1;
			clip.templates.pete4.alpha = 1;
			
			//dispatchEvent(new Event(CAM_SHOWING));
			
			TweenMax.to(clip, 1, { alpha:1, onComplete:doneShowing } );						
			TweenMax.to(clip.templates, 1, { x:1260 } );
			
			//template buttons			
			clip.templates.btn1.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn2.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn3.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn4.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			
			//show instructions
			TweenMax.to(clip.directions, .5, { x:34, ease:Back.easeOut } );
			TweenMax.to(clip.i1, .5, { x:37, delay:.1, ease:Back.easeOut } );
			TweenMax.to(clip.i2, .5, { x:37, delay:.2, ease:Back.easeOut } );
			TweenMax.to(clip.i3, .5, { x:37, delay:.3, ease:Back.easeOut } );
			TweenMax.to(clip.i4, .5, { x:37, delay:.4, ease:Back.easeOut } );
			TweenMax.to(clip.i5, .5, { x:37, delay:.5, ease:Back.easeOut } );
		}
		
		
		public function hide():void
		{
			if (container.contains(clip)) {
				container.removeChild(clip);				
				clip.removeChild(previewContainer);
				while(previewContainer.numChildren){
					previewContainer.removeChildAt(0);
				}
				clip.removeChild(camPicContainer);
			}
			
			disableTemplatePicking();
			clip.btnTakePic.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);
			clip.btnTakePic.removeEventListener(MouseEvent.MOUSE_DOWN, retakePic);
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, continueClicked);
			
			//reset templates and instructions positions
			clip.templates.x = 1660;
			clip.directions.x = -350;
			clip.i1.x = -350;
			clip.i2.x = -350;
			clip.i3.x = -350;
			clip.i4.x = -350;
			clip.i5.x = -350;
		}
		
		
		private function doneShowing():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		private function templatePicked(e:MouseEvent):void
		{			
			if (templateNumber == 0) {
				TweenMax.to(clip.takePic, .5, { y:934, ease:Back.easeOut } );
				TweenMax.to(clip.chooseTemp, 1, { alpha:0, onComplete:removeChooseTemp } );
				clip.btnTakePic.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
				
				//easter egg
				clip.egg.doubleClickEnabled = true;
				clip.egg.addEventListener(MouseEvent.DOUBLE_CLICK, showPete, false, 0, true);
			
				dispatchEvent(new Event(CAM_SHOWING));
			}			
			
			clip.templates.pete1.alpha = .5;
			clip.templates.pete2.alpha = .5;
			clip.templates.pete3.alpha = .5;
			clip.templates.pete4.alpha = .5;			
			
			timeoutHelper.buttonClicked();
			
			var btn:MovieClip = MovieClip(e.currentTarget);
			
			clip.templates.hiliter.x = btn.x - 6;
			clip.templates.hiliter.y = btn.y - 5;
			
			templateNumber = parseInt(btn.name.substr(3, 1));
			
			switch(templateNumber) {
				case 1:
					clip.templates.pete1.alpha = 1;
					break;
				case 2:
					clip.templates.pete2.alpha = 1;
					break;
				case 3:
					clip.templates.pete3.alpha = 1;
					break;
				case 4:
					clip.templates.pete4.alpha = 1;
					break;
			}
			
			peteShowing = false;
			clip.pete.alpha = 0;
			
			dispatchEvent(new Event(TEMPLATE_CHANGED));
		}
		
		
		private function removeChooseTemp():void
		{
			clip.chooseTemp.y = 2000;
		}
		
		
		private function showPete(e:MouseEvent):void
		{
			if(getTemplateNumber() == 1 || getTemplateNumber() == 2){
				clip.pete.alpha = 1;
				if(getTemplateNumber() == 2){
					clip.pete.filters = [CamPicFilters.gray()];
				}else {
					clip.pete.filters = [];
				}
				peteShowing = true;
			}
		}
		
		public function getPete():Boolean
		{
			return peteShowing;
		}
		
		
		public function getTemplateNumber():int
		{
			return templateNumber;
		}
		
		
		/**
		 * User pressed the take picture button
		 * @param	e
		 */
		private function takePic(e:Event):void
		{			
			clip.btnTakePic.removeEventListener(MouseEvent.MOUSE_DOWN, takePic);
			clip.egg.removeEventListener(MouseEvent.DOUBLE_CLICK, showPete);
			TweenMax.to(clip.takePic, .5, { y:1094 } ); //hide the button
			disableTemplatePicking();
			dispatchEvent(new Event(TAKE_PIC));			
		}
		
		
		private function disableTemplatePicking():void
		{
			//disable template buttons
			clip.templates.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, templatePicked);
			clip.templates.btn2.removeEventListener(MouseEvent.MOUSE_DOWN, templatePicked);
			clip.templates.btn3.removeEventListener(MouseEvent.MOUSE_DOWN, templatePicked);
			clip.templates.btn4.removeEventListener(MouseEvent.MOUSE_DOWN, templatePicked);
		}
		
		
		public function showPreview(preview:Bitmap):void
		{
			disableTemplatePicking();		
			
			previewContainer.addChild(preview);
			
			TweenMax.to(clip.retake, .5, { x:1294, ease:Back.easeOut } );
			TweenMax.to(clip.cont, .5, { x:1294, ease:Back.easeOut } );
			
			clip.btnContinue.addEventListener(MouseEvent.MOUSE_DOWN, continueClicked, false, 0, true);			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePic, false, 0, true);
		}
		
		
		private function retakePic(e:MouseEvent):void
		{		
			timeoutHelper.buttonClicked();
			
			dispatchEvent(new Event(RETAKE));//clears the photos array in Main
			
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, continueClicked);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePic);
			TweenMax.to(clip.cont, .5, { x:1702 } ); //continue/retake image under the instructions
			TweenMax.to(clip.retake, .5, { x:1702 } );
			
			previewContainer.removeChildAt(0);//preview image
			
			clip.btnTakePic.addEventListener(MouseEvent.MOUSE_DOWN, takePic, false, 0, true);
			TweenMax.to(clip.takePic, .5, { y:934, ease:Back.easeOut } );
			
			//enable template buttons
			clip.templates.btn1.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn2.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn3.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			clip.templates.btn4.addEventListener(MouseEvent.MOUSE_DOWN, templatePicked, false, 0, true);
			
			//enable easter egg
			clip.egg.addEventListener(MouseEvent.DOUBLE_CLICK, showPete, false, 0, true);
		}
		
		
		private function continueClicked(e:MouseEvent):void
		{
			timeoutHelper.buttonClicked();
			
			clip.btnContinue.removeEventListener(MouseEvent.MOUSE_DOWN, continueClicked);
			clip.btnTakePic.removeEventListener(MouseEvent.MOUSE_DOWN, retakePic);
			dispatchEvent(new Event(CONTINUE));
		}
		
	}
	
}