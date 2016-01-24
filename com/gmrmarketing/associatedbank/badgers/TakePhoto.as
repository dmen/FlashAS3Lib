package com.gmrmarketing.associatedbank.badgers
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.*;
	import flash.ui.Mouse;	
	import flash.media.Camera;
	import flash.media.Video;
	import com.greensock.TweenMax;
	import flash.utils.getTimer;
	
	
	public class TakePhoto extends EventDispatcher
	{
		public static const CAPTURE_COMPLETE:String = "captureComplete";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var vid:Video;
		private var cam:Camera;	
		
		private var pics:Array//all four images
		private var thumbs:Array;
		private var scaler:Matrix;
		
		
		public function TakePhoto() 
		{			
			clip = new mcTakePhoto();
			
			vid = new Video(1280, 720);
			vid.x = 160;
			vid.y = 170;
			
			pics = [];
			thumbs = [];
			
			scaler = new Matrix();
			scaler.scale(320 / 1280, 180 / 720);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function get userPics():Array
		{
			return pics;
		}
		
		
		public function show():void
		{			
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			pics = [];
			thumbs = [];
			
			cam = Camera.getCamera();
			cam.setMode(1280, 720, 30);
			vid.attachCamera(cam);
			
			myContainer.addChild(vid);
			
			clip.btnTake.theText.text = "TAKE PHOTO 1";
			clip.btnTake.addEventListener(MouseEvent.MOUSE_DOWN, take, false, 0, true);			
		}
		
		
		public function hide():void
		{			
			vid.attachCamera(null);
			clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, take);
			if(myContainer){
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
				if (myContainer.contains(vid)) {
					myContainer.removeChild(vid);
				}
				while (thumbs.length) {
					myContainer.removeChild(thumbs.shift());
				}
			}
		}
	
		
		private function take(e:MouseEvent):void
		{			
			var a:BitmapData = new BitmapData(cam.width, cam.height);
			cam.drawToBitmapData(a);
			
			pics.push(a);
			
			var bd:BitmapData = new BitmapData(320, 180, false, 0xffffff);
			bd.draw(a, scaler, null, null, null, true);
			
			var b:Bitmap = new Bitmap(bd);
			myContainer.addChild(b);
			b.x = 1514;
			b.y = 136 + (200 * (pics.length - 1));
			thumbs.push(b);
			
			if(pics.length < 4){
			
				clip.btnTake.theText.text = "TAKE PHOTO " + String(pics.length + 1);
				
			}else {
				clip.btnTake.theText.text = "COMPLETE";
				clip.btnTake.removeEventListener(MouseEvent.MOUSE_DOWN, take);
				TweenMax.delayedCall(1, done);
			}
		}
		
		
		private function done():void
		{
			dispatchEvent(new Event(CAPTURE_COMPLETE));
		}
		
	}
	
}