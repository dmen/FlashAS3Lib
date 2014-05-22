/**
 * Controls mcReview dialog clip
 */
package com.gmrmarketing.sap.boulevard.avatar
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
		
		private var clip:MovieClip;
		private var btnRetake:MovieClip;
		private var container:DisplayObjectContainer;
		
		private var previewImage:Bitmap;
		private const logoPath:String = "nfl_logos/";
		//private var sidebar:MovieClip;
		private var userImage:BitmapData;
		private var card:BitmapData;
		private var logo:Bitmap;
		
		private var userData:Object;
		
		private var color1:int; //top and bottom bar colors for the sidebar
		private var color2:int;
		
		
		public function Review()
		{
			clip = new mcReview();
			//sidebar = new mcSidebar();//300x780 clip
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		/**
		 * From flare - image is displayed at 316,3 and is 1280x960
		 * with a 712 x 778 chunk for display to the user
		 * extract 712x778 chunk at 281,97
		 * @param	image 1280x960 image from Flare
		 */
		public function show(image:BitmapData, mask:BitmapData):void//, team:String, user:Object):void
		{
			if(container){
				if (!container.contains(clip)) {
					container.addChild(clip);
				}
			}			
			
			//first extract user preview image from 1280x960 camera image
			//we take wider than we need, then move it left 81 pixels... this to compensate for the right card
			//edge being overlayed ontop of the photo
			userImage = new BitmapData(712, 778);
			userImage.copyPixels(image, new Rectangle(240, 55, 712, 778), new Point( 0, 0));			
			
			var bg:BitmapData = new racebg();//lib clip - new background			
			userImage.copyPixels(bg, new Rectangle(0, 0, bg.width, bg.height), new Point(0, 0), mask, new Point(240, 55), true);
			
			var banner:BitmapData = new npbanner(); //nowpik banner from library
			userImage.copyPixels(banner, new Rectangle(0, 0, banner.width, banner.height), new Point(0, 661));
			
			var logo:BitmapData = new gmrLogo();
			userImage.copyPixels(logo, new Rectangle(0, 0, logo.width, logo.height), new Point(40, 0));
			
			//var blur:BitmapData = new blurMask();//lib image
			
			//var blurImage:BitmapData = new BitmapData(719, 780);
			//blurImage.copyPixels(userImage, new Rectangle(0, 0, 719, 780), new Point(0, 0));
			//var blurFilter:BlurFilter = new BlurFilter(22, 22, 2);
			//blurImage.applyFilter(blurImage, new Rectangle(0, 0, 719, 780), new Point(0, 0), blurFilter);
			
			//userImage.copyPixels(blurImage, new Rectangle(0, 0, 719, 780), new Point(0, 0), blur, new Point(0, 0), true);
			
			//var snowB:BitmapData = new snow();//lib clip
			//userImage.copyPixels(snowB, new Rectangle(0, 0, 719, 780), new Point(0, 0),null,null,true);
			
			previewImage = new Bitmap(userImage);
			previewImage.x = 241;
			previewImage.y = 57;
			if (container) {
				container.addChild(previewImage);
			}
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, save, false, 0, true);
			
			clip.alpha = 0;			
			TweenMax.to(clip, 1, { alpha:1 } );
			
			//clip.addChild(new Bitmap(mask));
		}
		
		/*
		private function logoLoaded(e:Event = null):void
		{
			if(logo){
				if (sidebar.contains(logo)) {
					sidebar.removeChild(logo);
				}
			}			
			
			card = new BitmapData(935, 780);
			card.copyPixels(userImage, new Rectangle(0, 0, userImage.width, userImage.height), new Point(0, 0));
			
			var n:BitmapData = new BitmapData(794, 662);
			var m:Matrix = new Matrix();
			m.scale(.8491978, .8491978);
			n.draw(card, m, null, null, null, true);
			
			previewImage = new Bitmap(n);
			
			if (container) {
				container.addChild(previewImage);
			}
			previewImage.x = 268;
			previewImage.y = 218;
			
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retake, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, save, false, 0, true);
			
			clip.alpha = 0;			
			TweenMax.to(clip, 1, { alpha:1 } );
		}		
		*/
		
		public function getCard():BitmapData
		{
			return userImage;
		}
		
		public function hide():void		
		{			
			clip.btnRetake.removeEventListener(MouseEvent.MOUSE_DOWN, retake);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, save);
			TweenMax.to(clip, .5, { alpha:0, y:0, eaase:Back.easeIn, onComplete:killRetake } );
			if(previewImage){
				TweenMax.to(previewImage, .5, { alpha:0 } );
			}
		}
		
		
		private function killRetake():void
		{
			if (container) {
				if (container.contains(clip)) {
					container.removeChild(clip);
				}
				if(previewImage){
					if (container.contains(previewImage)) {
						container.removeChild(previewImage);
					}
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
	}
	
}