package com.gmrmarketing.holiday2016.photostrip
{
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.filters.DropShadowFilter;
	import com.gmrmarketing.utilities.CamPic;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.esurance.sxsw_2015.photobooth.WhiteFlash;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const SHOWING:String = "takePhotoShowing";
		public static const TAKE_PRESSED:String = "takeButtonPressed";
		public static const CANCEL:String = "cancelButtonPressed";
		public static const PRINT:String = "printButtonPressed";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cam:CamPic;
		private var whiteFlash:WhiteFlash;
		private var countdown:Countdown;
		private var threePhotos:Array;//array of three 750x750 BMD's
		private var previewData:BitmapData;
		private var preview:Bitmap;
		
		private var tim:TimeoutHelper;
		
		
		public function TakePhoto():void
		{
			clip = new mcTakePhoto();//library
			
			cam = new CamPic();
			cam.init(1280, 800, 0, 0, 0, 0, 30);
			cam.show(clip.camPic);//black box behind bg image	- 789X786
			
			whiteFlash = new WhiteFlash(1920, 1080);
			whiteFlash.container = clip;
			
			countdown = new Countdown();
			countdown.container = clip;
			
			tim = TimeoutHelper.getInstance();
			
			previewData = new BitmapData(729, 234, true, 0x00000000);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			clip.previewBg_mc.alpha = 0;			
			
			clip.btnCancel.scaleX = clip.btnCancel.scaleY = 0;
			clip.btnRetake.scaleX = clip.btnRetake.scaleY = 0;
			clip.btnPrint.scaleX = clip.btnPrint.scaleY = 0;
			clip.btnTake.alpha = 1;
			clip.btnTake.scaleX = clip.btnTake.scaleY = 0;
			
			clip.picNum.visible = true;
			clip.picNum.alpha = 0;
			clip.picNum.p1.gotoAndStop(1);
			clip.picNum.p2.gotoAndStop(1);
			clip.picNum.p3.gotoAndStop(1);			
			
			clip.roundRect.y = 828;
			clip.roundRect.theText.text = "";
			
			clip.alpha = 0;
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );
		}
		
		
		public function hide():void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePressed);
			clip.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, printPressed);

			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		/**
		 * Returns an array of three 750x750 BitmapData objects
		 * @return
		 */
		public function getPhotos():Array
		{
			return threePhotos;
		}
		
		
		private function showing():void
		{
			TweenMax.to(clip.btnTake, .6, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			TweenMax.to(clip.picNum, .6, { alpha:1, delay:.6 } );
			
			clip.roundRect.theText.text = "POSE FOR PHOTO";
			TweenMax.to(clip.roundRect, .5, { y:888 } );//pose for photo
			
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, takePressed);
			threePhotos = [];
			dispatchEvent(new Event(SHOWING));
		}
		
		private function takePressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, takePressed);
			clip.btnTake.alpha = .3;
			clip.picNum.p1.gotoAndStop(2);//show pink circle in pos 1
			countdown.addEventListener(Countdown.COUNT_COMPLETE, showFlash, false, 0, true);
			countdown.show();
		}
		
		
		private function showFlash(e:Event):void
		{			
			countdown.hide();
			whiteFlash.show();
			TweenMax.delayedCall(.2, showPhoto);
		}
		
		
		private function showPhoto():void
		{	
			//crop 789x786 out of displayImage
			var a:BitmapData = new BitmapData(789, 786);
			a.copyPixels(cam.getDisplayImage(), new Rectangle(245, 11, 789, 786), new Point(0, 0));
			
			threePhotos.push(a);
			
			if (threePhotos.length < 3) {
				countdown.show();	
				
				if (threePhotos.length == 1) {
					clip.picNum.p2.gotoAndStop(2);
				}else if (threePhotos.length == 2) {
					clip.picNum.p3.gotoAndStop(2);
				}
				
			}else {
				clip.previewBg_mc.alpha = 1;
				var m:Matrix = new Matrix();
				m.scale(0.2953105196451204, 0.2953105196451204); //scale 789 to 233
				
				//m.translate(11, 11);				
				previewData.draw(threePhotos[0], m, null, null, null, true);
				
				m.translate(248, 0);
				previewData.draw(threePhotos[1], m, null, null, null, true);
				
				m.translate(248, 0);
				previewData.draw(threePhotos[2], m, null, null, null, true);
				
				preview = new Bitmap(previewData, "auto", true);
				myContainer.addChild(preview);
				preview.x = 608;
				preview.y = 434;				
				
				TweenMax.to(clip.btnTake, 0, { scaleX:0, scaleY:0} );
				clip.picNum.visible = false;
				
				TweenMax.to(clip.btnCancel, .6, { scaleX:1, scaleY:1, ease:Back.easeOut } );
				TweenMax.to(clip.btnRetake, .6, { scaleX:1, scaleY:1, ease:Back.easeOut } );
				TweenMax.to(clip.btnPrint, .6, { scaleX:1, scaleY:1, ease:Back.easeOut } );
				
				clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
				clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePressed);
				clip.btnPrint.addEventListener(MouseEvent.MOUSE_DOWN, printPressed);
				
				TweenMax.to(clip.roundRect, .5, { y:828, onComplete:showReviewText } );
			}
		}
		private function showReviewText():void
		{
			clip.roundRect.theText.text = "REVIEW PHOTOS";
			TweenMax.to(clip.roundRect, .5, { y:888 } );
		}
		
		
		private function cancelPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCEL));			
		}
		
		
		private function retakePressed(e:MouseEvent):void
		{
			
			tim.buttonClicked();
			
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelPressed);
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retakePressed);
			clip.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, printPressed);
			
			clip.previewBg_mc.alpha = 0;
			
			if (myContainer.contains(preview)) {
				myContainer.removeChild(preview);
			}
			
			show();
		}
		
		
		private function printPressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(PRINT));
		}
		
	}	
	
}