package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*
	import flash.display.*
	import flash.media.Camera;
	import flash.media.Video;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;		
	import com.gmrmarketing.particles.Dust;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const COMPLETE:String = "takePhotoComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		
		private var camContainer:Sprite;
		private var camMask:MovieClip; //lib clip
		private var thePic:BitmapData;
		
		private var whiteFlash:MovieClip;
		private var dustContainer:Sprite;
		
		
		public function TakePhoto()
		{
			clip = new mcTakePhoto();
			dustContainer = new Sprite();
			clip.addChildAt(dustContainer, 1); //add between main bg and dark overlay with logos
			
			camContainer = new Sprite();			
			camContainer.x = 440;
			camContainer.y = 390;
			
			camMask = new mcCamMask();
			camMask.x = 440;
			camMask.y = 390;			
			//camMask.alpha = .78;
			
			whiteFlash = new mcWhiteFlash();
			
			cam = new CamPic();
			cam.init(1280, 720, 0, 0, 0, 0, 30);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			
			for (var i:int = 0; i < 150; i++) {
				var a:Dust = new Dust();
				a.x = Math.random() * 2160;
				a.y = Math.random() * 1440;
				dustContainer.addChild(a);
			}
			
			myContainer.addChild(camContainer);
			myContainer.addChild(camMask);
			
			cam.show(camContainer);
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePhoto, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if (myContainer.contains(camMask)) {
					myContainer.removeChild(camMask);
				}
				if (myContainer.contains(camContainer)) {
					myContainer.removeChild(camContainer);
				}
			}
			
			while (dustContainer.numChildren) {
				dustContainer.removeChildAt(0);
			}
			
			cam.pause();
			cam.hide();
		}		
		
		
		public function get photo():BitmapData
		{
			return thePic;
		}		
		
		
		private function takePhoto(e:MouseEvent):void
		{
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePhoto);
			
			thePic = cam.getCameraImage();
			
			myContainer.addChild(whiteFlash);
			whiteFlash.alpha = 1;
			TweenMax.to(whiteFlash, .75, { alpha:0, onComplete:tookPhoto } );
		}
		
		
			
		private function tookPhoto():void
		{
			myContainer.removeChild(whiteFlash);
			dispatchEvent(new Event(COMPLETE));
		}
		
	}
	
}