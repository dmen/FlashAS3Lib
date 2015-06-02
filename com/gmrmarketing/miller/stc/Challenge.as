/**
 * Screen with two beer glasses used for physical selection by customer
 */
package com.gmrmarketing.miller.stc
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Point;
	
	public class Challenge extends EventDispatcher
	{	
		public static const COMPLETE:String = "complete";
		public static const BACK:String = "challenBack";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var bgLeft:MovieClip;//references to the background for use with the displacement map
		private var bgRight:MovieClip;
		
		private var filterL:DisplacementMapFilter;
		private var filterR:DisplacementMapFilter;
		
		private var pintClicked:String; //either l or r
		
		
		public function Challenge()
		{
			clip = new mcChallenge();
			
			filterL = new DisplacementMapFilter();
			filterL.scaleX = 90;
			filterL.scaleY = 60;
			filterL.componentX = BitmapDataChannel.RED;
			filterL.componentY = BitmapDataChannel.RED;
			filterL.mode = DisplacementMapFilterMode.IGNORE;
			filterL.alpha = 0;
			filterL.color = 0x000000;
			filterL.mapBitmap = new pintBMD();

			filterR = new DisplacementMapFilter();
			filterR.scaleX = 90;
			filterR.scaleY = 60;
			filterR.componentX = BitmapDataChannel.RED;
			filterR.componentY = BitmapDataChannel.RED;
			filterR.mode = DisplacementMapFilterMode.IGNORE;
			filterR.alpha = 0;
			filterR.color = 0x000000;
			filterR.mapBitmap = new pintBMD();
		}
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(bg:Object):void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			
			clip.theTitle.scaleX = 0;
			clip.pintL.x = -440;
			clip.pintR.x = 2170;
			
			bgLeft = bg.left;
			bgRight = bg.right;
			
			TweenMax.to(clip.theTitle, .5, { scaleX:1, ease:Back.easeOut, delay:.2 } );
			TweenMax.to(clip.pintL, 2, { x:270, delay:.5, ease:Back.easeOut, onUpdate:updateMapPointL } );
			TweenMax.to(clip.pintR, 2, { x:1475, delay:.7, ease:Back.easeOut, onUpdate:updateMapPointR } );
			
			myContainer.addEventListener(Event.ENTER_FRAME, rotateCap);
			clip.pintL.addEventListener(MouseEvent.MOUSE_DOWN, lPintClicked);
			clip.pintR.addEventListener(MouseEvent.MOUSE_DOWN, rPintClicked);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, goBack);
		}
		
		
		private function updateMapPointL():void
		{			
			filterL.mapPoint = new Point(clip.pintL.x, clip.pintL.y);
			bgLeft.filters = [filterL];
		}
		
		
		private function updateMapPointR():void
		{
			filterR.mapPoint = new Point(clip.pintR.x-1080, clip.pintR.y);
			bgRight.filters = [filterR];
		}
		
		
		public function hide():void
		{
			clip.pintL.removeEventListener(MouseEvent.MOUSE_DOWN, lPintClicked);
			clip.pintR.removeEventListener(MouseEvent.MOUSE_DOWN, rPintClicked);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, goBack);
			myContainer.removeEventListener(Event.ENTER_FRAME, rotateCap);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			bgRight.filters = [];
			bgLeft.filters = [];
		}
		
		
		private function goBack(e:MouseEvent):void
		{
			dispatchEvent(new Event(BACK));
		}
		
		
		private function rotateCap(e:Event):void
		{
			clip.cap.rotation += .3;
		}
		
		
		private function lPintClicked(e:MouseEvent):void
		{
			pintClicked = "l";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function rPintClicked(e:MouseEvent):void
		{	
			pintClicked = "r";
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * Returns "l" or "r"
		 */
		public function get clicked():String
		{
			return pintClicked;
		}
		
	}
	
}