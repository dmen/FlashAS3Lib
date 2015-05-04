/**
 * Controls mcReview dialog clip
 */
package com.gmrmarketing.comcast.nascar.sanshelmet
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.*;
	import flash.text.TextFormat;
	
	
	public class Review extends EventDispatcher
	{
		public static const RETAKE:String = "retakePressed";
		public static const SAVE:String = "savePressed";
		public static const RESET:String = "closePressed";
		
		private var clip:MovieClip;
		private var btnRetake:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var userImage:BitmapData;
		private var logo:BitmapData;//lockup lib clip
		
		private var color1:int; //top and bottom bar colors for the sidebar
		private var color2:int;
		
		private var card:Bitmap; //the final image resized to 589x689
		
		
		
		public function Review()
		{
			clip = new mcReview();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * @param	image 992x744 image from Preview
		 */
		public function show(image:BitmapData):void
		{
			if(container){
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}
			
			userImage = new BitmapData(587, 687, true, 0xff0000);
			userImage.copyPixels(image, new Rectangle(213, 29, 587, 687), new Point(0, 0), null, null, true);			
			
			card = new Bitmap(userImage);
			clip.addChild(card);
			
			card.x = 691;//position of blank space in review
			card.y = 237;
			
			clip.alpha = 0;			
			clip.theText.x = -clip.theText.width;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, save, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.to(clip.theText, .5, { x:180, delay:1 } );
		}
		
		
		/**
		 * returns the userImage - 587x687
		 * @return
		 */
		public function getCard():BitmapData
		{
			return userImage;
		}
		
		
		/**
		 * called from main if retake
		 */
		public function hide():void		
		{		
			if(card){
				if (clip.contains(card)) {
					clip.removeChild(card);	
				}
			}
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, save);
			TweenMax.to(clip, .5, { alpha:0, y:0, eaase:Back.easeIn, onComplete:killRetake } );			
		}
		
		
		private function killRetake():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
			}		
		}
		
		
		private function retake(e:MouseEvent):void
		{
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function save(e:MouseEvent):void
		{
			dispatchEvent(new Event(SAVE));
		}
		
		private function doReset(e:MouseEvent):void
		{
			dispatchEvent(new Event(RESET));
		}
		
	}
	
}