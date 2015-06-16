package com.gmrmarketing.miller.gifphotobooth
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.CamPic;
	import flash.geom.*;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "takePhotoShowing";
		public static const COMPLETE:String = "takePhotoFinished";
		
		private const EVERY_NTH:int = 10; //capture every n frames
		private const MAX_FRAMES:int = 10;
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var camPic:CamPic;
		private var camContainer:Sprite;
		
		private var frames:Array;
		private var frameCount:int;
		
		private var previewBMD:BitmapData;
		private var preview:Bitmap;
		
		private var tim:TimeoutHelper;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			
			camContainer = new Sprite();
			camContainer.x = 362;
			camContainer.y = 174;
			camContainer.graphics.beginFill(0x000000);
			camContainer.graphics.drawRect(0, 0, 1280, 720);
			camContainer.graphics.endFill();
			clip.addChildAt(camContainer, 0);
			/*
			previewBMD = new BitmapData(320, 240, false, 0x000000);
			preview = new Bitmap(previewBMD);
			clip.addChild(preview);
			preview.x = 958;
			preview.y = 790;
			*/
			
			tim = TimeoutHelper.getInstance();
			
			camPic = new CamPic();
			camPic.init(1280, 720, 0, 0, 0, 0, 30);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		public function get bg():MovieClip
		{
			return clip;
		}
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			camPic.show(camContainer);
			//camPic.addEventListener(CamPic.CAMERA_UPDATE, updatePreview, false, 0, true);
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, startCounting, false, 0, true);
			clip.addEventListener(Event.ENTER_FRAME, updateCap);
			clip.progBar.progress.scaleX = 0;
			clip.theCount.visible = false;
			clip.theCount.theText.text = "3";
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showComplete } );
		}
		
		
		public function hide():void
		{
			camPic.pause();
			//camPic.removeEventListener(CamPic.CAMERA_UPDATE, updatePreview);
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		
		public function get video():Array
		{
			return frames;
		}
		
		
		private function updateCap(e:Event):void
		{
			clip.cap.rotation += .2;
		}
		
		
		/**
		 * callback for listener on CamPic
		 * updates the preview bitmap
		 * @param	e
		 */
		/*
		private function updatePreview(e:Event):void
		{
			var a:BitmapData = new BitmapData(812, 610);
			a.copyPixels(camPic.getCapture(), new Rectangle(234, 55, 812, 610), new Point(0, 0));
			var m:Matrix = new Matrix();
			m.scale(.394088, .39345); //320x240
			previewBMD.draw(a, m, null, null, null, true);
		}
		*/
		
		private function showComplete():void
		{
			dispatchEvent(new Event(SHOWING));
		}
		
		
		//called by pressing the take photos cap
		private function startCounting(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.theCount.visible = true;
			clip.theCount.theText.text = "3";
			clip.theCount.theText.alpha = 1;
			TweenMax.to(clip.theCount.theText, 1, { alpha:.1, onComplete:countTwo } );
		}
		
		private function countTwo():void
		{
			clip.theCount.theText.text = "2";
			clip.theCount.theText.alpha = 1;
			TweenMax.to(clip.theCount.theText, 1, { alpha:.1, onComplete:countOne } );
		}
		
		private function countOne():void
		{
			clip.theCount.theText.text = "1";
			clip.theCount.theText.alpha = 1;
			TweenMax.to(clip.theCount.theText, 1, { alpha:.1, onComplete:startRecording } );
		}
		
		
		private function startRecording():void
		{
			clip.theCount.visible = false;
			
			frames = [];
			frameCount = 0;
			clip.progBar.progress.scaleX = 0;
			
			clip.addEventListener(Event.ENTER_FRAME, grabFrame);			
		}
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % EVERY_NTH == 0) {
				//crop
				var a:BitmapData = new BitmapData(812, 610);
				a.copyPixels(camPic.getCapture(), new Rectangle(234, 55, 812, 610), new Point(0, 0));
				frames.push(a);
			}
			if (frames.length >= MAX_FRAMES) {
				stopRecording();
			}
			clip.progBar.progress.scaleX = frames.length / MAX_FRAMES;
		}
		
		
		private function stopRecording(e:MouseEvent = null):void
		{
			clip.removeEventListener(Event.ENTER_FRAME, grabFrame);
			clip.progBar.progress.scaleX = 1;
			
			dispatchEvent(new Event(COMPLETE));			
		}
	}
	
}