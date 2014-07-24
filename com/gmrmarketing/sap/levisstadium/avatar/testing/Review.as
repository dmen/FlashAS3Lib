/**
 * Controls mcReview dialog clip
 */
package com.gmrmarketing.sap.levisstadium.avatar.testing
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
		 * From flare - 1280x960
		 * image is displayed in preview at 336,3
		 * with a 761 x 891 chunk for display to the user
		 * display window in preview is at 573,40 - so we need to extract a 761x891 chunk
		 * at 573-336 = 236
		 * 40-3 = 37
		 * preview image size is 589x689 and sits at 314,198
		 * 
		 * @param	image 1280x960 image from Flare
		 */
		public function show(image:BitmapData):void
		{
			if(container){
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}
			
			userImage = new BitmapData(761, 891);
			userImage.copyPixels(image, new Rectangle(236, 37, 761, 891), new Point(0, 0));
			
			//SAP & 49ers logo at upper left
			logo = new lockup();			
			userImage.copyPixels(logo, new Rectangle(0, 0, logo.width, logo.height), new Point(0, 0), null, null, true);
			
			var cardData:BitmapData = new BitmapData(589, 689);
			var cardMatrix:Matrix = new Matrix();
			cardMatrix.scale(.773981, .773981); //for scaling 761x891 to 589x689
			cardData.draw(userImage, cardMatrix, null, null, null, true);
			
			card = new Bitmap(cardData);
			clip.addChild(card);
			
			card.x = 314;
			card.y = 198;
			
			clip.alpha = 0;	
			clip.theText.alpha = 0;
			clip.theText.y -= 75;
			clip.theButtons.alpha = 0;
			clip.theButtons.y += 75;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, save, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, doReset, false, 0, true);
			
			TweenMax.to(clip, 1, { alpha:1 } );
			TweenMax.to(clip.theText, .5, { alpha:1, y:"75", delay:1 } );
			TweenMax.to(clip.theButtons, .5, { alpha:1, y:"-75", delay:1 } );
		}
		
		
		/**
		 * returns the full size 761x891 image
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
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, save);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, doReset);
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