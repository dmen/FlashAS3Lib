package com.gmrmarketing.humana.rrbighead
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
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import flash.media.Sound;
	import com.gmrmarketing.bicycle.Manipulator;
	
	
	public class Confirm extends EventDispatcher
	{
		public static const CONFIRM_SHOWING:String = "confirmShowing";
		public static const RETAKE:String = "retakePressed";
		public static const PRINT:String = "printPressed";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var overlayContainer:Sprite;				
		
		private var butt:Sound;
		private var tim:TimeoutHelper;
		
		private var white:BitmapData; //whiteCircle bmd in library
		private var whiteAlpha:BitmapData;
		
		private var maniph:Manipulator;//headband and moustache
		private var manipm:Manipulator;
		
		private var headband:MovieClip;//two overlay clips
		private var moustache:MovieClip;
		
		private var shad:DropShadowFilter;
		
		
		public function Confirm()
		{
			clip = new mcConfirm();
			
			shad = new DropShadowFilter(4, 90, 0, 1, 5, 5, .5, 2);
			
			headband = new mcHeadband();
			moustache = new mcMoustache();			
			headband.filters = [shad];
			moustache.filters = [shad];
			
			butt = new sndButton();//sound			
			white = new whiteCircle();//
			
			overlayContainer = new Sprite();
			overlayContainer.x = 25;//corner of gray box around circle
			overlayContainer.y = 210;
			
			maniph = new Manipulator();
			maniph.setObject(headband);
			maniph.limitScale(.3, 1.75);
			
			manipm = new Manipulator();
			manipm.setObject(moustache);
			manipm.limitScale(.4, 3);
			
			tim = TimeoutHelper.getInstance();
		}	
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * image is 1405x800
		 * @param	image
		 */
		public function show(image:BitmapData):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			while (overlayContainer.numChildren) {
				overlayContainer.removeChildAt(0);
			}
			
			tim.buttonClicked();			
			
			clip.addChild(overlayContainer);
			
			//image.copyPixels(white, new Rectangle(0, 0, 791, 791), new Point(309, 0), whiteAlpha, new Point(0, 0), true);
			
			var bmp:Bitmap = new Bitmap(image);			
			clip.addChildAt(bmp, 0); //add behind bg
			bmp.x = -215; 
			bmp.y = 240;
			
			clip.alpha = 0;
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnPrint.addEventListener(MouseEvent.MOUSE_DOWN, print, false, 0, true);			
			
			clip.btnHeadband.addEventListener(MouseEvent.MOUSE_DOWN, addHeadband, false, 0, true);
			clip.btnMoustache.addEventListener(MouseEvent.MOUSE_DOWN, addMoustache, false, 0, true);
			
			clip.outlineHeadband.gotoAndStop(1);//gray outlines
			clip.outlineMoustache.gotoAndStop(1);
			
			clip.btnRetake.x = 1300;
			clip.btnRetake.alpha = 0;
			clip.btnPrint.x = 1400;
			clip.btnPrint.alpha = 0;
			
			TweenMax.to(clip.btnRetake, .5, { x:980, alpha:1, ease:Back.easeOut, delay:.5 });
			TweenMax.to(clip.btnPrint, .5, { x:1252, alpha:1, ease:Back.easeOut, delay:.75 });
			TweenMax.to(clip, 1, { alpha:1, onComplete:showing } );			
		}
		
		
		private function showing():void
		{			
			dispatchEvent(new Event(CONFIRM_SHOWING));
		}
		
		
		public function hide():void
		{
			maniph.hide();
			manipm.hide();
			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnPrint.removeEventListener(MouseEvent.MOUSE_DOWN, print);
			
			clip.btnHeadband.removeEventListener(MouseEvent.MOUSE_DOWN, addHeadband);
			clip.btnMoustache.removeEventListener(MouseEvent.MOUSE_DOWN, addMoustache);
			
			myContainer.removeEventListener(MouseEvent.MOUSE_DOWN, removeManip);
			
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}	
		}		
		
		
		/**
		 * clip is 1920 x 1080
		 * circle is 800 x 800 at x,y: 58,239
		 * 
		 * @param	withWhite 
		 * @return	800 x 800 BitmapData
		 */
		public function getPic(withWhite:Boolean = true):BitmapData
		{		
			maniph.hide();
			manipm.hide();
			
			var bmd:BitmapData = new BitmapData(1920, 1080);
			bmd.draw(clip);
			
			var ret:BitmapData = new BitmapData(800, 800);
			
			ret.copyPixels(bmd, new Rectangle(58, 239, 800, 800), new Point(0, 0));
			
			if(withWhite){
				ret.copyPixels(white, new Rectangle(0, 0, 800, 800), new Point(0, 0), null, null, true);
			}	
			
			return ret;
		}
		
		
		private function retake(e:Event):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function print(e:Event):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(PRINT));
		}
		
		
		private function addHeadband(e:MouseEvent):void
		{			
			tim.buttonClicked();
			
			if (!overlayContainer.contains(headband)) {
				overlayContainer.addChild(headband);			
			
				butt.play();
				
				clip.outlineHeadband.gotoAndStop(2);//red outline
				
				headband.x = 425;
				headband.y = 290;
				headband.scaleX = headband.scaleY = 1;
				headband.rotation = 0;
				
				manipHeadband();
				
				headband.addEventListener(MouseEvent.MOUSE_DOWN, manipHeadband, false, 0, true);
				myContainer.addEventListener(MouseEvent.MOUSE_DOWN, removeManip, false, 0, true);
			}
		}
		
		
		private function manipHeadband(e:MouseEvent = null):void
		{
			//manipm.removeEventListener(Manipulator.DELETE, removeMoustache);
			
			if(e){
				e.stopImmediatePropagation();//prevent stage from receiving and removing the manip
			}			
			
			maniph.hide();
			maniph.show();
			maniph.addEventListener(Manipulator.DELETE, removeHeadband, false, 0, true);
			
			if (e) {
				maniph.startMove();
			}
		}
		
		
		private function removeHeadband(e:Event):void
		{
			e.stopImmediatePropagation();
			clip.outlineHeadband.gotoAndStop(1);//gray			
			headband.removeEventListener(MouseEvent.MOUSE_DOWN, manipHeadband);
			maniph.hide();
			if (overlayContainer.contains(headband)) {
				overlayContainer.removeChild(headband);
			}			
		}
		
		
		private function addMoustache(e:MouseEvent):void
		{			
			tim.buttonClicked();
			
			if (!overlayContainer.contains(moustache)) {
				overlayContainer.addChild(moustache);
				
				butt.play();						
			
				clip.outlineMoustache.gotoAndStop(2);//red outline		
				
				moustache.x = 425;
				moustache.y = 540;
				moustache.scaleX = moustache.scaleY = 1;
				moustache.rotation = 0;
				
				manipMoustache();	
				
				moustache.addEventListener(MouseEvent.MOUSE_DOWN, manipMoustache, false, 0, true);
				myContainer.addEventListener(MouseEvent.MOUSE_DOWN, removeManip, false, 0, true);
			}
		}	
		
		
		private function removeMoustache(e:Event):void
		{
			e.stopImmediatePropagation();
			clip.outlineMoustache.gotoAndStop(1);//gray			
			moustache.removeEventListener(MouseEvent.MOUSE_DOWN, manipMoustache);
			manipm.hide();
			if (overlayContainer.contains(moustache)) {
				overlayContainer.removeChild(moustache);
			}			
		}
		
		
		private function removeManip(e:MouseEvent = null):void
		{
			maniph.hide();
			manipm.hide();
		}
		
		
		private function manipMoustache(e:MouseEvent = null):void
		{
			//manip.removeEventListener(Manipulator.DELETE, removeHeadband);
			
			if(e){
				e.stopImmediatePropagation();//prevent stage from receiving and removing the manip
			}
			
			manipm.hide();
			//manip.setObject(moustache);
			manipm.show();
			manipm.addEventListener(Manipulator.DELETE, removeMoustache, false, 0, true);
			
			if (e) {
				manipm.startMove();
			}
		}
		
	}
	
}