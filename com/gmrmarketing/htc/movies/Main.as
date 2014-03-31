/**
 * Document class for kiosk
 */

package com.gmrmarketing.htc.movies
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import com.gmrmarketing.htc.movies.ConfigData;
	import com.gmrmarketing.htc.movies.Images;
	import com.gmrmarketing.htc.movies.ImageDisplay;
	import com.gmrmarketing.htc.movies.Overlay;
	
	
	public class Main extends MovieClip
	{		
		private var images:Images; //loads the images xml		
		private var imageDisplay1:ImageDisplay; //displays the images in the imageContainer	1	
		private var imageDisplay2:ImageDisplay; //displays the images in the imageContainer	2	
		private var imageContainer1:Sprite; //image holder
		private var imageContainer2:Sprite; //image holder
		
		private var vid:VideoManager;
		private var videoContainer:Sprite; //video holder
		private var overlay:Overlay;
		private var overlay2:Overlay;
		
		public function Main()
		{
			images = new Images();
			vid = new VideoManager();
			
			overlay = new Overlay();
			overlay2 = new Overlay();
			
			//background
			var bg:Bitmap;
			if (ConfigData.LANGUAGE == "fr") {
				bg = new Bitmap(new fr()); //lib clips
			}else {
				bg = new Bitmap(new en());
			}
			addChild(bg);
			
			//image containers
			imageContainer1 = new Sprite();
			imageContainer1.x = ConfigData.IMAGEX;
			imageContainer1.y = ConfigData.IMAGEY;
			
			imageContainer2 = new Sprite();
			imageContainer2.x = ConfigData.IMAGEX2;
			imageContainer2.y = ConfigData.IMAGEY2;	
			
			//Mask for images 1
			var imMask1:Sprite = new Sprite();
			imMask1.graphics.beginFill(0x00ff00, 1);
			imMask1.graphics.drawRect(0, 0, ConfigData.IMAGE_WIDTH, ConfigData.IMAGE_HEIGHT);
			imMask1.graphics.endFill();
			imMask1.x = ConfigData.IMAGEX;
			imMask1.y = ConfigData.IMAGEY;
			
			//Mask for images 2
			var imMask2:Sprite = new Sprite();
			imMask2.graphics.beginFill(0x00ff00, 1);
			imMask2.graphics.drawRect(0, 0, ConfigData.IMAGE_WIDTH2, ConfigData.IMAGE_HEIGHT2);
			imMask2.graphics.endFill();
			imMask2.x = ConfigData.IMAGEX2;
			imMask2.y = ConfigData.IMAGEY2;
			
			imageContainer1.mask = imMask1;
			imageContainer2.mask = imMask2;
			
			videoContainer = new Sprite();
			videoContainer.x = ConfigData.VIDEOX;
			videoContainer.y = ConfigData.VIDEOY;
			
			addChild(imageContainer1);
			addChild(imMask1);
			
			addChild(imageContainer2);
			addChild(imMask2);
			
			addChild(videoContainer);
			
			imageDisplay1 = new ImageDisplay(imageContainer1, new Rectangle(ConfigData.IMAGEX, ConfigData.IMAGEY, ConfigData.IMAGE_WIDTH, ConfigData.IMAGE_HEIGHT));
			imageDisplay2 = new ImageDisplay(imageContainer2, new Rectangle(ConfigData.IMAGEX2, ConfigData.IMAGEY2, ConfigData.IMAGE_WIDTH2, ConfigData.IMAGE_HEIGHT2));
			
			vid.setContainer(videoContainer);//also starts video playing
			
			if(ConfigData.SHOW_OVERLAYS){
				overlay.setContainer(this, ConfigData.IMAGEX, ConfigData.IMAGEY + ConfigData.IMAGE_HEIGHT);
				overlay2.setContainer(this, ConfigData.IMAGEX2, ConfigData.IMAGEY2 + ConfigData.IMAGE_HEIGHT2);
			}
			
			getImageList();
		}
		
		
		private function getImageList():void
		{
			images.addEventListener(Images.IMAGES_LOADED, refreshImagesComplete, false, 0, true);
			images.refresh();
		}
		
		
		private function refreshImagesComplete(e:Event):void
		{			
			images.removeEventListener(Images.IMAGES_LOADED, refreshImagesComplete);
			imageDisplay1.setImageList(images.getImages1());
			imageDisplay2.setImageList(images.getImages2());			
		}
		
	}
	
}