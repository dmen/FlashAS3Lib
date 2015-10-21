package com.gmrmarketing.associatedbank.mnwild
{
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Timer;	
	import com.gmrmarketing.hp.multicam.Encoder;
	
	
	public class Review extends EventDispatcher
	{
		public static const RETAKE:String = "retakePhoto";
		public static const SAVE:String = "savePhoto";
		public static const COMPLETE:String = "encodingComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var bmd:BitmapData;
		private var bmp:Bitmap;
		private var frames:Array;
		private var curFrame:int;
		private var frameTimer:Timer;		
		private var encoder:Encoder;
		private var overlay:Bitmap;
		
		
		public function Review()
		{
			clip = new mcReview();			
			frameTimer = new Timer(90);
			
			encoder = new Encoder();
			encoder.width = 420;
			encoder.height = 236;
			encoder.overlay = new overlay420();//library clip
			
			overlay = new Bitmap(new overlay1280());
			overlay.x = 320;
			overlay.y = 170;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get GIF():String
		{
			return encoder.GIF;
		}
		
		
		/**
		 * 
		 * @param	$frames Array of BitmapData's
		 */
		public function show($frames:Array):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			bmd = new BitmapData(1280, 720, false, 0xffdedede);
			
			bmp = new Bitmap(bmd);
			bmp.x = 320;
			bmp.y = 170;
			
			clip.addChild(bmp);//for gif playback
			myContainer.addChild(overlay);
			
			frames = $frames;
			
			clip.progress.scaleY = 0;//green progress bar to show gif encoding
			
			curFrame = 0;			
			
			frameTimer.addEventListener(TimerEvent.TIMER, nextFrame, false, 0, true);
			frameTimer.start();
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePhoto, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, savePhoto, false, 0, true);
		}
		
		
		public function hide():void
		{
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePhoto);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, savePhoto);
			
			frameTimer.reset();
			
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}				
				if (myContainer.contains(overlay)) {
					myContainer.removeChild(overlay);
				}
			}
			if (bmp) {
				if (clip.contains(bmp)) {
					clip.removeChild(bmp);
				}
			}
		}
		
		
		public function process(em:String = null):void
		{
			frameTimer.stop();
			
			encoder.addEventListener(Encoder.COMPLETE, encodingComplete, false, 0, true);
			encoder.addEventListener(Encoder.UPDATE, encoderUpdate, false, 0, true);
			
			if(em){
				encoder.addFrames(frames, true, em, "mnWild");
			}else {
				encoder.addFrames(frames);
			}
		}
		
		
		private function encoderUpdate(e:Event):void
		{
			clip.progress.scaleY = encoder.progress;
		}
		
		
		private function encodingComplete(e:Event):void
		{
			encoder.removeEventListener(Encoder.COMPLETE, encodingComplete);
			encoder.removeEventListener(Encoder.UPDATE, encoderUpdate);
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function nextFrame(e:TimerEvent):void
		{
			bmp.bitmapData = frames[curFrame];
			
			curFrame++;
			if (curFrame >= frames.length) {
				curFrame = 0;
			}
		}
		
		
		private function retakePhoto(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function savePhoto(e:MouseEvent):void
		{
			dispatchEvent(new Event(SAVE));
		}
		
		
		
	}
	
}