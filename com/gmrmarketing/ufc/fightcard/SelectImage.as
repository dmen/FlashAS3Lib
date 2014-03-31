/**
 * Upload Photo or Use Webcam
 */
package com.gmrmarketing.ufc.fightcard
{
	import com.greensock.plugins.DropShadowFilterPlugin;
	import com.greensock.plugins.SoundTransformPlugin;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.display.Loader;
	import com.greensock.TweenLite;
	import com.sagecollective.corona.atp.CamPic;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.utils.Timer;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	
	
	public class SelectImage extends EventDispatcher
	{
		public static const SELECT_IMAGE_ADDED:String = "selectImageAdded";
		public static const IMAGE_LOADED:String = "imageLoaded";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var templateNumber:int;
		private var fileRef:FileReference;
        private var loader:Loader;
		
		private var camPic:CamPic;
		private var camContainer:Sprite;
		
		private var counter:int;
		private var countTimer:Timer;
		
		private var theCapture:Bitmap; //from camPic the full size pic(600x800) and the preview sized pic(300x400)
		private var thePreview:Bitmap;		
		
		private var preview:MovieClip; //card with outline
		private var nameFormatter:TextFormat;
		
		private var flash:MovieClip;
		private var shutter:Sound;
		private var countBeep:Sound;
		
		
		public function SelectImage()
		{
			TweenPlugin.activate([TintPlugin, GlowFilterPlugin]);
			
			clip = new image_grab(); //upload photo / use webcam
			fileRef = new FileReference();
			
			camPic = new CamPic();
			camContainer = new Sprite(); //holder for the video display
			
			nameFormatter = new TextFormat();			
		}
		
		
		public function show($container:DisplayObjectContainer, $templateNumber:int, lastName:String):void
		{
			container = $container;
			templateNumber = $templateNumber;
			
			clip.alpha = 0;
			container.addChild(clip);
			
			clip.btnTake.y = -200;
			clip.btnKeep.y = -200;
			clip.btnRetake.y = -200;
			clip.theTimer.y = -200;
			
			//card preview
			switch(templateNumber) {
				case 1:
					preview = new jones_camera();
					nameFormatter.italic = false;
					break;
				case 2:
					preview = new alves_camera();
					nameFormatter.italic = true;
					break;
				case 3:
					preview = new edgar_camera();
					nameFormatter.italic = true;
					break;
				case 4:
					preview = new cruz_camera();
					nameFormatter.italic = false;
					break;
			}
			
			preview.bg.theText.autoSize = TextFieldAutoSize.CENTER;
			preview.bg.theText.text = lastName;			
			
			//card width is 400 - fit in 380 for a 10 pixel edge 
			if (preview.bg.theText.textWidth > 380) {
				var d:Number = 380 / preview.bg.theText.textWidth;
				preview.bg.theText.scaleX = d;				
			}
			preview.bg.theText.setTextFormat(nameFormatter);//italic or not			
			preview.bg.theText.x = Math.round((400 - preview.bg.theText.width) / 2);			
			
			preview.x = 61;
			preview.y = 145;
			clip.addChild(preview);
			
			showTop(true);//top text and buttons for use webcam or upload
			
			TweenLite.to(clip, 1, { alpha:1, onComplete:clipAdded } );
		}
		
		
		public function hide():void
		{
			container.removeChild(clip);
			clip.btnSelect.removeEventListener(MouseEvent.CLICK, selectImage); //upload image
			clip.btnConnect.removeEventListener(MouseEvent.CLICK, camImage);
			clip.btnRetake.removeEventListener(MouseEvent.CLICK, retakePic);
			clip.btnKeep.removeEventListener(MouseEvent.CLICK, keepPic);
			fileRef.removeEventListener(Event.SELECT, fileSelected);
			fileRef.removeEventListener(Event.COMPLETE, fileLoaded);
			fileRef.removeEventListener(Event.CANCEL, cancelFile);
		}
		
		
		public function getImage():Bitmap
		{
			return theCapture;
		}
		
		
		private function clipAdded():void
		{
			dispatchEvent(new Event(SELECT_IMAGE_ADDED));
		}
		
		private function hideTop():void
		{
			TweenLite.killTweensOf(clip.btnText);
			TweenLite.killTweensOf(clip.btnSelect);
			TweenLite.killTweensOf(clip.btnConnect);
			
			clip.btnText.alpha = 0;
			clip.btnSelect.alpha = 0;
			clip.btnConnect.alpha = 0;
			
			clip.btnSelect.buttonMode = false;
			clip.btnConnect.buttonMode = false;
			
			clip.btnSelect.removeEventListener(MouseEvent.CLICK, selectImage); //upload image
			clip.btnConnect.removeEventListener(MouseEvent.CLICK, camImage);
		}
		
		private function showTop(delay:Boolean = false ):void
		{			
			var d:int = 0;
			if (delay) { d = 1;}
			TweenLite.to(clip.btnText, 1, { alpha:1, delay:d } );
			TweenLite.to(clip.btnSelect, 1, { alpha:1, delay:d } );
			TweenLite.to(clip.btnConnect, 1, { alpha:1, delay:d } );
			
			clip.btnSelect.buttonMode = true;
			clip.btnConnect.buttonMode = true;
			
			clip.btnSelect.addEventListener(MouseEvent.CLICK, selectImage, false, 0, true); //upload image
			clip.btnConnect.addEventListener(MouseEvent.CLICK, camImage, false, 0, true); //webcam
		}


		/**
		* browse must be called in response to a user event - ie a CLICK
		*/
		public function selectImage(e:MouseEvent):void
		{
			hideTop();
			fileRef.browse([new FileFilter("Images", "*.jpg;*.gif;*.png")]);
			fileRef.addEventListener(Event.SELECT, fileSelected, false, 0, true);
			fileRef.addEventListener(Event.CANCEL, cancelFile, false, 0, true);
		}
		
		
		private function cancelFile(e:Event):void
		{
			showTop();
		}


		private function fileSelected(e:Event):void 
		{
			fileRef.addEventListener(Event.COMPLETE, fileLoaded, false, 0, true);			
			fileRef.load();
		}


		private function fileLoaded(e:Event):void 
		{
			loader = new Loader();
			loader.loadBytes(e.target.data);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler, false, 0, true);
		}
		
		private function loaderCompleteHandler(e:Event):void
		{			
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
			
			fileRef.removeEventListener(Event.SELECT, fileSelected);
			fileRef.removeEventListener(Event.COMPLETE, fileLoaded);
			fileRef.removeEventListener(Event.CANCEL, cancelFile);
			
			theCapture = Bitmap(loader.content);
			
			dispatchEvent(new Event(IMAGE_LOADED));
		}
		
		
		
		//WEBCAM
		//called by clicking the connect button
		private function camImage(e:MouseEvent):void
		{
			if (camPic.isCamAvailable()) {
				
				hideTop();
				
				camContainer = new Sprite();
				
				flash = new camFlash();
				flash.x = 61;
				flash.y = 145;
				flash.alpha = 0;
				
				shutter = new soundShutter(); //lib
				countBeep = new soundBeep();
				
				switch(templateNumber) {
					case 1:
						//jones
						camPic.init(600, 800, 24, 256, 341); //unique camera preview size and loc per card
						camContainer.x = 141;
						camContainer.y = 103;//loc inside of card preview
						break;
					case 2:
						//alves
						camPic.init(600, 800, 24, 256, 341);
						camContainer.x = 144;
						camContainer.y = 34;
						break;
					case 3:
						//edgar
						camPic.init(600, 800, 24, 307, 410);
						camContainer.x = 93;
						camContainer.y = 160;
						break;
					case 4:
						//cruz
						camPic.init(600, 800, 24, 200, 266);
						camContainer.x = 198;
						camContainer.y = 131;
						break;
				}
				
				preview.addChildAt(camContainer, 1);
				camPic.showVideo(camContainer);
				
				//enable take button
				clip.btnTake.y = 112;
				clip.btnTake.alpha = 0;
				TweenLite.to(clip.btnTake, .5, { alpha:1 } );
				clip.btnTake.addEventListener(MouseEvent.CLICK, startCountdown, false, 0, true);
				clip.btnTake.buttonMode = true;
				
				//show Timer
				clip.theTimer.theCount.text = "8";
				clip.theTimer.alpha = 0;
				clip.theTimer.y = 95;
				TweenLite.to(clip.theTimer, .5, { alpha:1 } );
				
			}else {
				//no webcam
			}
		}
		
		
		private function startCountdown(e:MouseEvent):void
		{
			clip.btnTake.removeEventListener(MouseEvent.CLICK, startCountdown);
			clip.btnTake.buttonMode = false;
			
			counter = 8;
			countTimer = new Timer(1000);
			countTimer.addEventListener(TimerEvent.TIMER, updateCountdown, false, 0, true);
			countTimer.start();
		}
		
		
		private function updateCountdown(e:TimerEvent):void
		{
			counter--;
			if (counter == 0) {
				
				//Flash
				shutter.play();
				container.addChild(flash);
				flash.alpha = 1;
				TweenLite.to(flash, 1, { alpha:0, onComplete:killFlash } );
				
				clip.theTimer.theCount.text = "0";
				
				countTimer.stop();
				countTimer.removeEventListener(TimerEvent.TIMER, updateCountdown);
				
				theCapture = new Bitmap(camPic.getCapture());
				thePreview = new Bitmap(camPic.getDisplay());
				
				camContainer.addChild(thePreview);
				
				clip.btnKeep.alpha = 0;
				clip.btnKeep.y = 112;
				clip.btnRetake.alpha = 0;
				clip.btnRetake.y = 112;
				TweenLite.to(clip.btnKeep, .5, { alpha:1 } );
				TweenLite.to(clip.btnRetake, .5, { alpha:1 } );
				
				clip.btnRetake.addEventListener(MouseEvent.CLICK, retakePic, false, 0, true);
				clip.btnKeep.addEventListener(MouseEvent.CLICK, keepPic, false, 0, true);
				clip.btnRetake.buttonMode = true;
				clip.btnKeep.buttonMode = true;
				
			}else {
				if (counter < 4) {
					countBeep.play();
				}
				clip.theTimer.theCount.text = String(counter);
			}
		}
		
		private function killFlash():void
		{
			container.removeChild(flash);
		}
		
		
		/**
		 * Called when retake is pressed
		 * @param	e
		 */
		private function retakePic(e:MouseEvent):void
		{
			camContainer.removeChild(thePreview);
			
			clip.btnTake.addEventListener(MouseEvent.CLICK, startCountdown);
			clip.theTimer.theCount.text = "8";
			
			clip.btnRetake.removeEventListener(MouseEvent.CLICK, retakePic);
			clip.btnKeep.removeEventListener(MouseEvent.CLICK, keepPic);
			clip.btnRetake.alpha = 0;
			clip.btnKeep.alpha = 0;
			clip.btnRetake.buttonMode = false;
			clip.btnKeep.buttonMode = false;
		}
		
		
		private function keepPic(e:MouseEvent):void
		{			
			camPic.dispose();			
			dispatchEvent(new Event(IMAGE_LOADED));
		}
	}
	
}
