
package com.gmrmarketing.microsoft.halo5
{
	import com.gmrmarketing.utilities.CamPic;
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;	
	import flash.media.Camera;
	import flash.media.Video;
	
	
	public class SelectArmor extends EventDispatcher
	{
		public static const COMPLETE:String = "TakePhotoComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		
		private var camContainer:Sprite;
		private var camMask:MovieClip; //lib clip
		private var thePic:BitmapData;
		
		private var whiteFlash:MovieClip;
		
		
		public function SelectArmor()
		{
			clip = new mcSelectArmor();
			
			camContainer = new Sprite();			
			camContainer.x = 440;
			camContainer.y = 150;
			
			camMask = new mcCamMask();
			camMask.x = 440;
			camMask.y = 150;			
			camMask.alpha = .78;
			
			whiteFlash = new mcWhiteFlash();
			
			cam = new CamPic();
			cam.init(1280, 720, 0, 0, 0, 0, 30, true);
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
			
			clip.btnTake.visible = false;
			
			clip.blue2.addEventListener(MouseEvent.MOUSE_DOWN, selectBlue2, false, 0, true);
			clip.blue1.addEventListener(MouseEvent.MOUSE_DOWN, selectBlue1, false, 0, true);
			clip.red2.addEventListener(MouseEvent.MOUSE_DOWN, selectRed2, false, 0, true);
			clip.red1.addEventListener(MouseEvent.MOUSE_DOWN, selectRed1, false, 0, true);
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
			}
			
			cam.pause();
			cam.hide();
			
			clip.blue2.removeEventListener(MouseEvent.MOUSE_DOWN, selectBlue2);
			clip.blue1.removeEventListener(MouseEvent.MOUSE_DOWN, selectBlue1);
			clip.red2.removeEventListener(MouseEvent.MOUSE_DOWN, selectRed2);
			clip.red1.removeEventListener(MouseEvent.MOUSE_DOWN, selectRed1);
		}
		
		
		private function selectBlue2(e:MouseEvent):void
		{
			TweenMax.to(clip.blue1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }} );
			TweenMax.to(clip.blue1, .5, { alpha:0, delay:.5 } );
			
			TweenMax.to(clip.red2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.1} );
			TweenMax.to(clip.red2, .5, { alpha:0, delay:.6 } );
			
			TweenMax.to(clip.red1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.2} );
			TweenMax.to(clip.red1, .5, { alpha:0, delay:.7 } );
			
			TweenMax.to(clip.blue2, .75, { scaleX:3, scaleY:3, x:"-50", y:"-100", delay:.75, ease:Back.easeInOut, onComplete:showCam} );
		}
		
		
		private function selectBlue1(e:MouseEvent):void
		{
			TweenMax.to(clip.blue2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }} );
			TweenMax.to(clip.blue2, .5, { alpha:0, delay:.5 } );
			
			TweenMax.to(clip.red2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.1} );
			TweenMax.to(clip.red2, .5, { alpha:0, delay:.6 } );
			
			TweenMax.to(clip.red1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.2} );
			TweenMax.to(clip.red1, .5, { alpha:0, delay:.7 } );
			
			TweenMax.to(clip.blue1, .75, { scaleX:3, scaleY:3, x:"-500", y:"-100", delay:.75, ease:Back.easeInOut, onComplete:showCam} );
		}
		
		
		private function selectRed2(e:MouseEvent):void
		{
			TweenMax.to(clip.blue1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }} );
			TweenMax.to(clip.blue1, .5, { alpha:0, delay:.5 } );
			
			TweenMax.to(clip.blue2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.1} );
			TweenMax.to(clip.blue2, .5, { alpha:0, delay:.6 } );
			
			TweenMax.to(clip.red1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.2} );
			TweenMax.to(clip.red1, .5, { alpha:0, delay:.7 } );
			
			TweenMax.to(clip.red2, .75, { scaleX:1.6, scaleY:1.6, x:"-200", delay:.75, ease:Back.easeInOut, onComplete:showCam} );
		}
		
		
		private function selectRed1(e:MouseEvent):void
		{
			TweenMax.to(clip.blue1, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }} );
			TweenMax.to(clip.blue1, .5, { alpha:0, delay:.5 } );
			
			TweenMax.to(clip.blue2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.1} );
			TweenMax.to(clip.blue2, .5, { alpha:0, delay:.6 } );
			
			TweenMax.to(clip.red2, 1, { glowFilter: { color:0xffffff, blurX:80, blurY:80, strength:50, quality:3, alpha:1, inner:true }, delay:.2} );
			TweenMax.to(clip.red2, .5, { alpha:0, delay:.7 } );
			
			TweenMax.to(clip.red1, .75, { scaleX:1.6, scaleY:1.6, x:"-400", delay:.75, ease:Back.easeInOut, onComplete:showCam} );
		}
		
		
		private function showCam():void
		{
			myContainer.addChild(camContainer);
			myContainer.addChild(camMask);
			
			cam.show(camContainer);
			
			clip.btnTake.visible = true;
			clip.btnTake.alpha = 0;
			TweenMax.to(clip.btnTake, .5, { alpha:1 } );
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePhoto, false, 0, true);
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
		
		
		public function get photo():BitmapData
		{
			return thePic;
		}
		
	}
	
}