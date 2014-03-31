package com.gmrmarketing.pm
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;	
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import com.greensock.TweenMax;	
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.CornerQuit;	
	import flash.desktop.NativeApplication; //for quitting	
	//import com.gmrmarketing.utilities.KbdEvent;
	import com.gmrmarketing.keyboard.KeyBoard;
	import flash.net.SharedObject;
	import com.gmrmarketing.pm.RFID;	
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	
	import com.gmrmarketing.utilities.CamPic;
	
	

	public class PhotoBooth extends MovieClip
	{
		private var so:SharedObject;
		private var myData:Array;
		
		private var cam:Camera;
		private var theVideo:Video;
		private var camWidth:int;
		private var camHeight:int;
		//private var blank:BitmapData;
		private var cap:Bitmap;
		
		private var btnStart:MovieClip; //lib clip
		private var btnBW:MovieClip;
		private var btnColor:MovieClip;
		private var btnPrint:MovieClip;
		private var btnEmail:MovieClip;
		private var btnBoth:MovieClip;
		
		private var countDown:MovieClip; //lib clip
				
		private var whiteFlash:Shape;
		
		private var filmStrip:filmstrip; //lib clip
		private var grayFilmStrip:filmstrip;
		
		private var restartTimer:Timer;
		private var printTimer:Timer;
		
		private var picNumber:int;
		private var thumbY:int;
		
		private var btnDropShadow:DropShadowFilter;
		private var stripShadow:DropShadowFilter;
		
		private var printJob:PrintJob;
		private var printInColor:Boolean = true;
		
		private var fullStrip:MovieClip;		
		private var fullYPos:int;
		
		private var thanks:MovieClip; //lib clip - thanks your pictures are printing
		private var choose:MovieClip; //the choose black and white or color to begin printing - text image
		private var pError:MovieClip; //lib clip - print error
		
		private var resetTimer:Timer;
		private var captureTimer:Timer;
		
		private var cQuit:CornerQuit;
		private var rfidSkip:CornerQuit;
		
		private var kbd:KeyBoard;
				
		private var halfMatrix:Matrix;
		
		private var rfid:RFID;
		private var rfidURL:String;
		
		private var camPic:CamPic;
		private var camHolder:Sprite;
		
		public function PhotoBooth()
		{			
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();

			rfid = new RFID();
			
			halfMatrix = new Matrix();
			halfMatrix.scale(.375, .375); //for scaling the 1200x2400 full strip to 450x900
			
			cQuit = new CornerQuit(false); //debug mode false so yellow rects are invisible
			rfidSkip = new CornerQuit(false);
			
			btnDropShadow = new DropShadowFilter(7, 45, 0x462b1f, 1, 18, 18, 2, 2, false, false);			
			stripShadow = new DropShadowFilter(7, 45, 0, 1, 16, 16, 2, 2, false, false);
			
			whiteFlash = new Shape();
			whiteFlash.graphics.beginFill(0xFFFFFF);
			whiteFlash.graphics.drawRect(0, 0, 1920, 1080);			
			
			//cam = Camera.getCamera();				
			camPic = new CamPic();
			camHolder = new Sprite();
			camHolder.x = 648;
			camHolder.y = 226;
			
			//if (!cam) {
				//trace("No camera present!");
			//}else {
				init();
			//}
		}
		
		
		
		private function init():void
		{
			//started in printContent when the pics have started printing
			printTimer = new Timer(15000, 1);
			printTimer.addEventListener(TimerEvent.TIMER, reset, false, 0, true);
			
			//started in captureComplete - when the two filmstrips are showing
			resetTimer = new Timer(45000, 1);
			resetTimer.addEventListener(TimerEvent.TIMER, reset, false, 0, true);
			
			//used to time the capture to the white flash
			captureTimer = new Timer(500,1);
			captureTimer.addEventListener(TimerEvent.TIMER, capture, false, 0, true);			
			
			//camwidth,height - full(capture) width,height - display width, height, fps
			camPic.init(800, 800, 0, 0, 593, 593, 24);
			
			camWidth = 0; //cam.width; //set these to actual camera resolution - may not match setMode() above
			camHeight = 0;// cam.height;
			
			kbd = new KeyBoard();
			kbd.loadXML("basicKeyboard.xml");
			kbd.x = 440;
			kbd.y = 436;
			
			fullStrip = new MovieClip();
			fullStrip.graphics.beginFill(0xffffff);
			fullStrip.graphics.drawRect(0, 0, 1200, 2400);
			fullYPos = 69;			
		
			countDown = new countdown();
			countDown.filters = [btnDropShadow];
			countDown.x = 620;
			countDown.y = 834;
			
			filmStrip = new filmstrip();
			filmStrip.x = 1647;
			filmStrip.y = 80;
			filmStrip.rotation = 6;
			
			grayFilmStrip = new filmstrip();
			grayFilmStrip.x = 100;
			grayFilmStrip.y = 110;
			grayFilmStrip.rotation = -6;
			
			btnStart = new btnstart();
			btnStart.filters = [btnDropShadow];
			btnStart.x = 790;
			btnStart.y = 880;
			
			btnBW = new btnbw();
			btnBW.filters = [btnDropShadow];			
			
			btnColor = new btncolor();
			btnColor.filters = [btnDropShadow];			
			
			btnPrint = new btnprint();
			btnPrint.x = 429;
			btnPrint.y = 904;
			btnPrint.filters = [btnDropShadow];
			
			btnEmail = new btnemail();
			btnEmail.x = 786;
			btnEmail.y = 904;
			btnEmail.filters = [btnDropShadow];
			
			btnBoth = new btnPrintEmail();
			btnBoth.x = 1146;
			btnBoth.y = 904;
			btnBoth.filters = [btnDropShadow];			
			
			thanks = new thankYou(); //lib clip
			thanks.x = 510;
			thanks.y = 216;
			
			choose = new choosebw(); //lib clip
			choose.x = 768;
			choose.y = 460;
			
			pError = new printErrorDialog(); //lib clip
			pError.x = 588;
			pError.y = 374;
			
			cQuit.init(this, "ur");
			cQuit.customLoc(1, new Point(1770, 0));
			cQuit.addEventListener(CornerQuit.CORNER_QUIT, quitPhotoBooth, false, 0, true);
			
			rfidSkip.init(this, "ll");
			rfidSkip.setSingleClick();
			rfidSkip.addEventListener(CornerQuit.CORNER_QUIT, rfidScanned, false, 0, true);
			
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			try{
				l.load(new URLRequest("config.xml"));
			}catch (e:Error) {
				quitPhotoBooth();
			}
		}
		
		
		private function configLoaded(e:Event):void
		{
			var data:XML = new XML(e.target.data);
			rfidURL = data.config.sendRFIDURL;
			begin();
		}
		
		
		/**
		 * Called from constructor - adds the take pic button and the camera video to the stage 
		 * called from reset()
		 */
		private function begin():void
		{
			rfid.show(this, rfidURL);
			rfid.addEventListener(RFID.CHECK_GOOD, rfidScanned, false, 0, true);
			fadeInVideo();
			cQuit.moveToTop();
			rfidSkip.moveToTop();
		}
		
		
		private function rfidScanned(e:Event):void
		{
			rfid.removeEventListener(RFID.CHECK_GOOD, rfidScanned);
			rfid.hide();
			
			addChild(btnStart);
			btnStart.addEventListener(MouseEvent.CLICK, beginCountdown, false, 0, true);	
		}
		
		
		/**
		 * Called by listener on cQuit that listens for the eight corner clicks
		 * @param	e
		 */
		private function quitPhotoBooth(e:Event = null):void
		{	
			NativeApplication.nativeApplication.exit();
		}		
		
		
		/**
		 * Called from pressing ok in the print error dialog
		 * or from the resetTimer when it times out
		 * @param	e
		 */
		private function reset(e:TimerEvent = null):void
		{
			//blank = new BitmapData(camHeight, camHeight, false, 0xff0000);
			
			if (contains(filmStrip)) {
				removeChild(filmStrip);
			}
			if (contains(grayFilmStrip)) {
				removeChild(grayFilmStrip);
			}
			if (contains(btnBW)) {
				removeChild(btnBW);
			}
			if (contains(btnColor)) {
				removeChild(btnColor);
			}
			if (contains(pError)) {
				removeChild(pError);
			}
			
			fullStrip = new MovieClip();			
			fullStrip.graphics.beginFill(0xffffff);
			fullStrip.graphics.drawRect(0, 0, 1200, 1800);
			
			while (filmStrip.numChildren > 1) {
				filmStrip.removeChildAt(1);
			}
			while (grayFilmStrip.numChildren > 1) {
				grayFilmStrip.removeChildAt(1);
			}
			if (contains(choose)) {
				removeChild(choose);
			}
			if (contains(thanks)) {
				TweenMax.to(thanks, 1, { alpha:0, onComplete:killThanks } );
			}			
			
			filmStrip.x = 1647;
			filmStrip.y = 80;
			filmStrip.rotation = 6; // /
			
			grayFilmStrip.x = 100;
			grayFilmStrip.y = 110;
			grayFilmStrip.rotation = -6; // \
			
			resetTimer.reset();
			printTimer.reset();
			
			begin();
		}
		
		
		private function killThanks():void
		{
			removeChild(thanks);
		}
		
		
		/**
		 * Called from begin()
		 */
		private function fadeInVideo(e:MouseEvent = null):void
		{		
			addChildAt(camHolder, 0);
			camPic.show(camHolder);
		}
		
		
		private function beginCountdown(e:MouseEvent = null):void
		{		
			btnStart.removeEventListener(MouseEvent.CLICK, beginCountdown);
			addChild(countDown);
			removeChild(btnStart);
			
			picNumber = 1;
			
			thumbY = 11; //initial thumb position inside the filmstrip
			fullYPos = 69;
			
			countDown.threeGlow.alpha = 0;
			countDown.twoGlow.alpha = 0;
			countDown.oneGlow.alpha = 0;
			countDown.flashGlow.alpha = 0;
			flash3();
		}
		
		
		private function flash3():void
		{			
			TweenMax.to(countDown.threeGlow, 0, { alpha:1, delay:1} );
			TweenMax.to(countDown.threeGlow, .8, { alpha:0, delay:1.2, onComplete:flash2 } );			
		}
		
		
		private function flash2():void
		{
			countDown.twoGlow.alpha = 1;
			TweenMax.to(countDown.twoGlow, .8, { alpha:0, delay:.2, onComplete:flash1 } );
		}
		
		
		private function flash1():void
		{
			countDown.oneGlow.alpha = 1;
			TweenMax.to(countDown.oneGlow, .8, { alpha:0, delay:.2, onComplete:flash0 } );
		}
		
		
		private function flash0():void
		{
			countDown.flashGlow.alpha = 1;
			TweenMax.to(countDown.flashGlow, .8, { alpha:0, delay:.2 } );
			addChild(whiteFlash);
			whiteFlash.alpha = 1;
			TweenMax.to(whiteFlash, .35, { alpha:0, delay:.2, onComplete:killWhiteFlash } );
			
			captureTimer.start();
		}
	
		
		private function killWhiteFlash():void
		{
			removeChild(whiteFlash);
		}
		
		
		private function capture(e:TimerEvent):void
		{	
			var fullBorder:Shape = new Shape();
			fullBorder.graphics.lineStyle(2, 0, 1);
			fullBorder.graphics.drawRect(0, 0, 525, 525);
			var fullBorder2:Shape = new Shape()
			fullBorder2.graphics.lineStyle(2, 0, 1);
			fullBorder2.graphics.drawRect(0, 0, 525, 525);
			
			var fullSize:BitmapData = new BitmapData(525, 525);
			var fullSize2:BitmapData = new BitmapData(525, 525);
			
			var fm:Matrix = new Matrix();
			fm.scale(525 / 800, 525 / 800); //camPic.getCapture() returns 800x800 image
			
			fullSize.draw(camPic.getCapture(), fm, null, null, null, true);
			fullSize2.draw(camPic.getCapture(), fm, null, null, null, true);
			
			var full:Bitmap = new Bitmap(fullSize);
			var full2:Bitmap = new Bitmap(fullSize);
			
			fullStrip.addChild(full);
			fullStrip.addChild(fullBorder);
			fullStrip.addChild(full2);
			fullStrip.addChild(fullBorder2);
			full.x = 37;
			fullBorder.x = 37;
			full2.x = 613;
			fullBorder2.x = 613;
			full.y = fullYPos;
			full2.y = fullYPos;
			fullBorder.y = fullYPos;
			fullBorder2.y = fullYPos;
			
			fullYPos += 562; //525 + 37 pixel border
			
			if(!contains(filmStrip)){
				addChild(filmStrip);
				filmStrip.filters = [stripShadow];
			}
			if(!contains(grayFilmStrip)){
				addChild(grayFilmStrip);
				grayFilmStrip.filters = [stripShadow];
			}
			
			var thumb:BitmapData = new BitmapData(196, 206, false, 0xff0000);
			var grayThumb:BitmapData = new BitmapData(196, 206, false, 0xff0000);
			
			var m2:Matrix = new Matrix();
			m2.scale(196 / 800, 206 / 800);
			
			thumb.draw(camPic.getCapture(), m2, null, null, null, true);
			grayThumb.draw(camPic.getCapture(), m2, null, null, null, true);
			
			var border:Shape = new Shape()
			border.graphics.lineStyle(1, 0, 1);
			border.graphics.drawRect(0, 0, 196, 206);
			
			var border2:Shape = new Shape()
			border2.graphics.lineStyle(1, 0, 1);
			border2.graphics.drawRect(0, 0, 196, 206);
			
			var thumbPic:Bitmap = new Bitmap(thumb);
			var grayThumbPic:Bitmap = new Bitmap(grayThumb);
			
			//grayscale
			TweenMax.to(grayThumbPic, 0, { colorMatrixFilter: { saturation:0 } });
			
			filmStrip.addChild(thumbPic);
			filmStrip.addChild(border);
			
			grayFilmStrip.addChild(grayThumbPic);
			grayFilmStrip.addChild(border2);
			
			thumbPic.x = 12;			
			grayThumbPic.x = 12;
			border.x = 12;
			border2.x = 12;
			
			thumbPic.y = thumbY;
			grayThumbPic.y = thumbY;
			border.y = thumbY;
			border2.y = thumbY;
			
			thumbY += 11 + thumb.height;
			
			picNumber++;
			if (picNumber < 4) {
				flash3();
			}else {
				captureComplete();
			}
		}
		
		
		/**
		 * All four pics taken
		 */
		private function captureComplete():void
		{	
			//addChild(fullStrip);
			var saveData:BitmapData = new BitmapData(450, 900, false, 0x000000);
			saveData.draw(fullStrip, halfMatrix);			
			
			TweenMax.to(grayFilmStrip, 1, { x:525, y:150, rotation:7.475, delay:.3, ease:Bounce.easeOut } );
			//grayFilmStrip.x = 525;
			//grayFilmStrip.y = 150;
			//grayFilmStrip.rotation = 7.475;
			
			TweenMax.to(filmStrip, 1, { x:1162, y:160, rotation: -7.215, delay:.3, ease:Bounce.easeOut } );
			//filmStrip.x = 1162;
			//filmStrip.y = 160;
			//filmStrip.rotation = -7.215;
			
			choose.alpha = 0;
			addChild(choose);
			TweenMax.to(choose, 1, { alpha:1 } );			
			
			btnBW.x = 630;
			btnBW.y = 880;
			btnBW.alpha = 0;
			btnColor.x = 980;
			btnColor.y = 880;
			btnColor.alpha = 0;
			addChild(btnBW);
			addChild(btnColor);
			TweenMax.to(btnBW, .5, { alpha:1 } );
			TweenMax.to(btnColor, .5, { alpha:1 } );
			
			removeChild(countDown);
			
			resetTimer.start(); //45 seconds to make choice before app resets
			
			btnBW.addEventListener(MouseEvent.CLICK, chooseBW, false, 0, true);
			btnColor.addEventListener(MouseEvent.CLICK, chooseColor, false, 0, true);
		}
		
		
		private function chooseBW(e:MouseEvent):void
		{
			removeChild(btnBW);
			removeChild(btnColor);
			printInColor = false;
			printContent();			
		}
		
		
		private function chooseColor(e:MouseEvent):void
		{
			removeChild(btnBW);
			removeChild(btnColor);
			printInColor = true;
			printContent();			
		}
		
		
		private function printContent(evt:MouseEvent = null):void
		{
			//stop the reset timer
			resetTimer.reset();			
			
			if (contains(grayFilmStrip)) {
				removeChild(grayFilmStrip);
			}
			if (contains(filmStrip)) {
				removeChild(filmStrip);
			}
			if (contains(choose)) {
				removeChild(choose);
			}
			
			thanks.alpha = 0;
			addChild(thanks);
			TweenMax.to(thanks, 1, { alpha:1 } );
			
			printJob = new PrintJob();	
			
			if (!printInColor) {
				var fullGrayStrip:BitmapData = new BitmapData(1200, 2400);
				TweenMax.to(fullStrip, 0, { colorMatrixFilter: { saturation:0 } } );
				fullGrayStrip.draw(fullStrip);
				var fullGray:Bitmap = new Bitmap(fullGrayStrip);
				var fullPrint:Sprite = new Sprite();
				fullPrint.addChild(fullGray);
			}
			
			//suppress print dialog with start2
			if (printJob.start2(null, false)) {
				if(printInColor){
					if (fullStrip.width > printJob.pageWidth) {
						fullStrip.width = printJob.pageWidth;
						fullStrip.scaleY = fullStrip.scaleX;
					}
					try{
						printJob.addPage(fullStrip);
					}catch(e:Error) {
						printError();
					}
				}else {
					if (fullPrint.width > printJob.pageWidth) {
						fullPrint.width = printJob.pageWidth;
						fullPrint.scaleY = fullPrint.scaleX;
					}
					try{
						printJob.addPage(fullPrint);
					}catch (e:Error) {
						printError();
						
					}
				}
				
				try{
					printJob.send();
				}catch (e:Error) {
					printError();
				}				
			}
			
			//starts the 30 sec print timer
			printTimer.start();			
		}
		
		
		private function printError():void
		{
			if (!contains(pError)) {
				addChild(pError);
			}
			pError.btnOK.addEventListener(MouseEvent.CLICK, removePrintError, false, 0, true);
		}
		
		
		private function removePrintError(e:MouseEvent):void
		{
			pError.btnOK.removeEventListener(MouseEvent.CLICK, removePrintError);
			reset();
		}
		
				
		private function emailContent(e:MouseEvent):void
		{
			btnPrint.removeEventListener(MouseEvent.CLICK, printContent);
			btnEmail.removeEventListener(MouseEvent.CLICK, emailContent);
			
			removeChild(btnPrint);
			removeChild(btnEmail);
			
			addChild(kbd);
		}
		
		
	}
	
}