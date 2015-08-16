package com.gmrmarketing.png.gifphotobooth
{	
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.CamPic;
	import flash.geom.*;
	import flash.utils.ByteArray;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.Utility;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "takePhotoShowing";
		public static const COMPLETE:String = "takePhotoFinished";
		
		private const EVERY_NTH:int = 10; //capture every n frames ~3 fps
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
		
		private var arcContainer:Sprite;//added to clip.theCount
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			
			arcContainer = new Sprite();
			clip.theCount.addChild(arcContainer);
			
			camContainer = new Sprite();
			camContainer.x = 311;
			camContainer.y = 184;
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
			arcContainer.graphics.clear();
			camPic.show(camContainer);
			//camPic.addEventListener(CamPic.CAMERA_UPDATE, updatePreview, false, 0, true);
			
			clip.btnTake.alpha = 1;
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, startCounting, false, 0, true);			
			
			clip.theCount.visible = false;
			clip.theCount.scaled.theText.text = "3";
			
			clip.sideText.alpha = 1;
			
			clip.alpha = 0;
			TweenMax.to(clip, .5, { alpha:1, onComplete:showComplete } );
		}
		
		
		public function hide():void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, startCounting);
			camPic.pause();
			//camPic.removeEventListener(CamPic.CAMERA_UPDATE, updatePreview);
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
		}
		
		/**
		 * Returns an array of BitmapData objects
		 * frames are 749x657
		 */
		public function get video():Array
		{
			return frames;
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
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, startCounting);
			
			clip.theCount.visible = true;
			clip.theCount.alpha = 0;
			TweenMax.to(clip.btnTake, .5, { alpha:0 } );
			TweenMax.to(clip.theCount, .5, { alpha:1 } );
			TweenMax.to(clip.sideText, .5, { alpha: 0 } );
			
			clip.theCount.scaled.theText.text = "3";
			clip.theCount.scaled.theText.x = -27;
			clip.theCount.scaled.theText..y = -57;
			clip.theCount.scaled.theText.alpha = 1;
			TweenMax.to(clip.theCount.scaled.theText, 1, { alpha:.1, onComplete:countTwo } );
		}
		
		private function countTwo():void
		{
			clip.theCount.scaled.theText.text = "2";
			clip.theCount.scaled.theText.x = -28;
			clip.theCount.scaled.theText..y = -59;
			clip.theCount.scaled.theText.alpha = 1;
			TweenMax.to(clip.theCount.scaled.theText, 1, { alpha:.1, onComplete:countOne } );
		}
		
		private function countOne():void
		{
			clip.theCount.scaled.theText.text = "1";
			clip.theCount.scaled.theText.x = -33;
			clip.theCount.scaled.theText..y = -58;
			clip.theCount.scaled.theText.alpha = 1;
			TweenMax.to(clip.theCount.scaled.theText, 1, { alpha:.1, onComplete:startRecording } );
		}
		
		
		private function startRecording():void
		{
			//clip.theCount.visible = false;
			clip.theCount.theTitle.text = "Recording:";
			
			frames = [];
			frameCount = 0;
			
			clip.addEventListener(Event.ENTER_FRAME, grabFrame);			
		}
		
		
		private function grabFrame(e:Event):void
		{
			frameCount++;
			if (frameCount % EVERY_NTH == 0) {
				//crop - capture at 1280x720
				var a:BitmapData = new BitmapData(749, 657);
				a.copyPixels(camPic.getCapture(), new Rectangle(265, 31, 749, 657), new Point(0, 0));
				frames.push(a);
			}
			if (frames.length >= MAX_FRAMES) {
				stopRecording();
			}
			
			Utility.drawArc(arcContainer.graphics, 0, 0, 98, 0, 360 * (frames.length / MAX_FRAMES), 25, 0xffffff, 1);
		}
		
		
		private function stopRecording(e:MouseEvent = null):void
		{
			clip.removeEventListener(Event.ENTER_FRAME, grabFrame);			
			
			dispatchEvent(new Event(COMPLETE));			
		}
	}
	
}