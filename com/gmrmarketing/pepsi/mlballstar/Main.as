package com.gmrmarketing.pepsi.mlballstar
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.gmrmarketing.utilities.CamPic;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;	
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import flash.display.Bitmap;
	import flash.filters.DropShadowFilter;
	import com.dynamicflash.util.Base64;
	import flash.utils.ByteArray;
	import com.adobe.images.JPGEncoder;
	import flash.display.LoaderInfo;
	import flash.external.ExternalInterface;
	
	
	public class Main extends MovieClip
	{
		private var camPic:CamPic;
		private var countdownCounter:int;
		private var countdownTimer:Timer;
		private var shutter:Sound;
		private var countBeep:Sound;
		
		private var theCapture:BitmapData;
		
		private var vidContainer:Sprite;
		private var flashContainer:Sprite;
		private var controlsContainer:Sprite;
		
		private var whiteFlash:Shape;
		private var btnShadow:DropShadowFilter;
		
		//controls
		private var btnTakePic:MovieClip;
		private var btnRetakePic:MovieClip;
		private var btnContinue:MovieClip;
		private var c1:MovieClip;
		private var c2:MovieClip;
		private var c3:MovieClip;
		
		private var progress:MovieClip;
		private var curBar:int;
		private var barTimer:Timer;
		
		//flashvars
		private var userID:String = loaderInfo.parameters.id;		
		private var pageURL:String = loaderInfo.parameters.Url;		
		
		
		public function Main()
		{
			//pageURL = ExternalInterface.call('window.location.href.toString');			
			
			camPic = new CamPic();
			camPic.init(400, 300, 0, 0, 342, 223, 24);
			
			shutter = new soundShutter(); //lib
			countBeep = new soundBeep();
			
			progress = new progIndicator();
			progress.x = 98;
			progress.y = 116;
			
			barTimer = new Timer(100);
			
			countdownTimer = new Timer(1000);
			
			vidContainer = new Sprite();
			flashContainer = new Sprite();
			controlsContainer = new Sprite();
			
			btnShadow = new DropShadowFilter(0, 0, 0, .8, 5, 5, 1, 2);
			
			whiteFlash = new Shape();
			whiteFlash.graphics.beginFill(0xffffff, 1);
			whiteFlash.graphics.drawRect(0, 0, 342, 223);
			whiteFlash.graphics.endFill();
			whiteFlash.alpha = 0;
			
			//lib clips - controls
			btnTakePic = new btnTake();
			btnTakePic.filters = [btnShadow];
			btnRetakePic = new btnRetake();
			btnRetakePic.filters = [btnShadow]
			btnContinue = new btnCont();
			btnContinue.filters = [btnShadow];			
			c1 = new count1();
			c2 = new count2();
			c3 = new count3();
			c1.filters = [btnShadow];
			c2.filters = [btnShadow];
			c3.filters = [btnShadow];
			
			flashContainer.addChild(whiteFlash);
			
			addChild(vidContainer);
			addChild(flashContainer);
			addChild(controlsContainer);
			
			init();
		}
		
		
		public function init():void
		{
			while (controlsContainer.numChildren) {
				controlsContainer.removeChildAt(0);
			}
			//final x 314
			c3.x = 354; //off screen
			c3.y = 73;			
			c2.x = 354;
			c2.y = 103;
			c1.x = 354; 
			c1.y = 133;			
			
			c1.alpha = 1;
			c2.alpha = 1;
			c3.alpha = 1;
			
			btnTakePic.x = 131;
			btnTakePic.y = 233; //end at 193
			
			btnRetakePic.x = 50;
			btnRetakePic.y = 233;
			
			btnContinue.x = 212;
			btnContinue.y = 233;
			
			controlsContainer.addChild(c1);
			controlsContainer.addChild(c2);
			controlsContainer.addChild(c3);
			controlsContainer.addChild(btnTakePic);
			controlsContainer.addChild(btnRetakePic);
			controlsContainer.addChild(btnContinue);
			
			camPic.show(vidContainer);
			
			TweenLite.to(btnTakePic, .5, { y:193, ease:Back.easeOut } );
			btnTakePic.addEventListener(MouseEvent.CLICK, startCountDown, false, 0, true);
		}
		
		
		private function startCountDown(e:MouseEvent):void
		{
			btnTakePic.removeEventListener(MouseEvent.CLICK, startCountDown);
			
			//show 3-2-1- count
			TweenLite.to(c3, .5, { x:314, ease:Back.easeOut } );
			TweenLite.to(c2, .5, { x:314, delay:.1, ease:Back.easeOut } );
			TweenLite.to(c1, .5, { x:314, delay:.2, ease:Back.easeOut } );
			
			countdownCounter = 4;
			countdownTimer.addEventListener(TimerEvent.TIMER, updateCountdown, false, 0, true);
			countdownTimer.start();
		}
		
		
		private function updateCountdown(e:TimerEvent):void
		{
			countdownCounter--;
			if (countdownCounter == 0) {				
				stopCountdown();
				takePic();
			}else {
				countBeep.play();
				TweenLite.to(this["c" + countdownCounter], .3, { alpha:.3 } );
			}
		}
		
		
		private function stopCountdown():void
		{
			countdownTimer.removeEventListener(TimerEvent.TIMER, updateCountdown);
			countdownTimer.stop();
		}
		
		
		private function takePic():void
		{
			shutter.play();
			
			whiteFlash.alpha = 1;			
			TweenLite.to(whiteFlash, 1, { alpha:0 } );
			
			theCapture = camPic.getCapture();//fullsize
			
			camPic.pause();
			
			//hide countdown numbers
			TweenLite.to(c3, .5, { x:354 } );
			TweenLite.to(c2, .5, { x:354 } );
			TweenLite.to(c1, .5, { x:354 } );
			
			//show retake and continue - hide take
			TweenLite.to(btnRetakePic, .5, { y:193 } );
			TweenLite.to(btnContinue, .5, { y:193 } );
			TweenLite.to(btnTakePic, .5, { y:233 } );
			
			btnRetakePic.addEventListener(MouseEvent.CLICK, doRetake, false, 0, true);
			btnContinue.addEventListener(MouseEvent.CLICK, picTaken, false, 0, true);
		}
		
		
		private function doRetake(e:MouseEvent = null):void
		{
			btnRetakePic.removeEventListener(MouseEvent.CLICK, doRetake);
			btnContinue.removeEventListener(MouseEvent.CLICK, picTaken);
			TweenLite.to(btnRetake, .5, { y:233 } );
			TweenLite.to(btnContinue, .5, { y:233 } );
			
			init();
		}
		
		
		private function picTaken(e:MouseEvent):void
		{
			btnRetakePic.removeEventListener(MouseEvent.CLICK, doRetake);
			btnContinue.removeEventListener(MouseEvent.CLICK, picTaken);
			saveImage();
		}
		
		
		public function saveImage():void
		{
			camPic.dispose();
			
			showSpinIndicator(); //progress
			
			var jpeg:ByteArray = getJpeg(theCapture);			
			var imageString:String = getBase64(jpeg);
			
			//post to the page we're on
			var request:URLRequest = new URLRequest(pageURL);
				
			var vars:URLVariables = new URLVariables();
			vars.imagestr = imageString;
			vars.id = userID;
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, saveError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
			
			try{
				lo.load(request);
			}catch (e:Error) {
				trace("could not post request");
				if (contains(progress)) {
					removeChild(progress);
				}
				barTimer.reset();
				barTimer.removeEventListener(TimerEvent.TIMER, updateSpinIndicator);				
			}
		}
		
		public function showSpinIndicator():void
		{
			curBar = 0;			
			addChild(progress);
			barTimer.addEventListener(TimerEvent.TIMER, updateSpinIndicator, false, 0, true);
			barTimer.start();			
		}
		
		private function updateSpinIndicator(e:TimerEvent):void
		{	
			curBar++;
			if (curBar > 8) {
				curBar = 1;
			}
			TweenLite.to(progress["b" + curBar], .25, { alpha:0 } );
			TweenLite.to(progress["b" + curBar], .25, { alpha:1, delay:.3, overwrite:0 } );			
		}
		
		private function saveDone(e:Event):void
		{		
			if (contains(progress)) {
				removeChild(progress);
			}
			barTimer.reset();
			barTimer.removeEventListener(TimerEvent.TIMER, updateSpinIndicator);
			
			var pageData:String = e.target.data;
			var st:int = pageData.indexOf("START");
			var en:int = pageData.indexOf("END");
			var msg:String = pageData.substring(st + 5, en);
			
			ExternalInterface.call("webcam_match", msg); //flashVar
			
			doRetake();
		}
		
		
		private function saveError(e:IOErrorEvent):void
		{			
			trace("saveError:",e.toString());
		}
		
		
		private function getBase64(ba:ByteArray):String
		{
			return Base64.encodeByteArray(ba);
		}
		
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
	}
	
}