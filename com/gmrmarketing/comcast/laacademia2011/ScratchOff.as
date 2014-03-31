package com.gmrmarketing.comcast.laacademia2011
{
	import com.gmrmarketing.particles.Spark;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import com.gmrmarketing.comcast.laacademia2011.*;
	import com.gmrmarketing.utilities.GenMessageEvent;
	import com.gmrmarketing.kiosk.CornerQuit;	
	import flash.utils.Timer;
	//import flash.desktop.NativeApplication;
	import flash.external.ExternalInterface; //for calling ffish scripts
	import com.gmrmarketing.particles.Spark;
	

	public class ScratchOff extends MovieClip
	{
		private const STAGE_WIDTH:int = 1920;
		private const STAGE_HEIGHT:int = 1080;
		
		//number of pixels in the circular cover - used to fill the rects array
		private const PIXELS_IN_COVER:int = 76453;
		
		private const SOURCE_RECT:Rectangle = new Rectangle(0, 0, STAGE_WIDTH, STAGE_HEIGHT)
		private const DEST_POINT:Point = new Point(0, 0);
		
		//number of pixels that need to be removed in order to have the cover scratched off enough - 60%
		private const ENOUGH_PIXELS:int = Math.floor(PIXELS_IN_COVER * .6);
		
		//the color used for drawing the scratch, and then also for the threshold test that replaces this color with 0x00000000
		private const DRAW_COLOR:uint = 0xFF888888;
		
		//contains the number of pixels remaining in each scratch area
		private var rects:Array;
		
		//background and cover images
		private var bg:BitmapData;
		private var cov1:BitmapData;
		private var cov2:BitmapData;
		private var cov3:BitmapData;
		private var cov4:BitmapData;
		private var cov5:BitmapData;
		private var cov6:BitmapData;
		
		//original covers - not touched by scratching - for copyPixeling when the cover is not scratched in
		private var ocov1:BitmapData;
		private var ocov2:BitmapData;
		private var ocov3:BitmapData;
		private var ocov4:BitmapData;
		private var ocov5:BitmapData;
		private var ocov6:BitmapData;
		
		//visual representation
		private var canvas:BitmapData;
		private var canvasBMP:Bitmap;		

		//drawing contains the line drawn by the mouse
		private var drawing:Sprite;
		
		//drawingData is a bitmap copy of drawing - uses draw method to copy drawing
		private var drawingData:BitmapData;
		
		//last mouse position
		private var lastPoint:Point;
		
		//either english or spanish
		private var lang:String;
		private var langSelector:MovieClip;
		
		//scratched contains the indexes of the scratched covers - used to get the number of pixels remaining in a cover from the rects array
		//index is pushed in updateDrawing depending on which cover is scratched in
		private var scratched:Array;
		//the number of covers that have been scratched in - 3 is the max
		private var scratchedCount:int;
		
		//c is the number of pixels that threshold affects
		private	var c:uint;
		
		//user data form
		private var form:FormController;
		//simple error dialog
		private var dialog:DialogController;
		//prizing dialog
		private var prizeDialog:PrizeDialogController;
		//win dialog
		private var winDialog:WinDialogController;
		//screen saver
		private var ss:ScreenSaver;
		
		//reads the zips.txt file - used to check if user entered zip is in the comcast zip list
		private var zipReader:ZipReader;
		
		private var cq:CornerQuit;
		private var openConfig:CornerQuit;
		
		//used in endGame to identify which prize was won - set in addIcons()
		//1 2, 3, 4 - 4 is grand
		private var winTier:int;
		
		private var timeoutTimer:Timer;
		//private var screenSaverTimer:Timer;
		
		private var iconPositions:Array;
		private var indicatorRing:BitmapData; //ring placed around a scratch circle to show it's scratched enough
		
		private var tripleWords:MovieClip;
		
		
		public function ScratchOff():void
		{
			cq = new CornerQuit();			
			openConfig = new CornerQuit();
			
			iconPositions = new Array( { x:308, y:274 }, { x:792, y:274 }, { x:1278, y:274 }, { x:308, y:634 }, { x:792, y:634 }, { x:1278, y:634 } );			
			
			//screenSaverTimer = new Timer(90000, 1);
			//screenSaverTimer.addEventListener(TimerEvent.TIMER, screenSaverTimeOut, false, 0, true);
			
			timeoutTimer = new Timer(45000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, gameTimedOut, false, 0, true);
			
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);			
			openConfig.addEventListener(CornerQuit.CORNER_QUIT, showConfig, false, 0, true);
			
			lang = "english";
			langSelector = new languageSelector();	//lib clip
			
			canvas = new BitmapData(STAGE_WIDTH, STAGE_HEIGHT);
			canvasBMP = new Bitmap(canvas);
			addChild(canvasBMP);
			
			drawing = new Sprite();
			
			dialog = new DialogController(this);
			prizeDialog = new PrizeDialogController(this);
			winDialog = new WinDialogController(this);
			form = new FormController(this);
			ss = new ScreenSaver(this);
			
			zipReader = new ZipReader();
			
			cq.init(this, "ullr");
			openConfig.init(this, "ur");
			
			init();
		}
		
		
		
		private function init():void
		{
			lastPoint = new Point(0, 0);
			indicatorRing = new iconRing();
			
			bg = new background(STAGE_WIDTH, STAGE_HEIGHT);
			addIcons();
			
			rects = new Array(PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER, PIXELS_IN_COVER);
			
			//six original covers to be scratched off
			cov1 = new cover1(STAGE_WIDTH, STAGE_HEIGHT);
			cov2 = new cover2(STAGE_WIDTH, STAGE_HEIGHT);
			cov3 = new cover3(STAGE_WIDTH, STAGE_HEIGHT);
			cov4  = new cover4(STAGE_WIDTH, STAGE_HEIGHT);
			cov5 = new cover5(STAGE_WIDTH, STAGE_HEIGHT);
			cov6  = new cover6(STAGE_WIDTH, STAGE_HEIGHT);
			
			ocov1 = new cover1(STAGE_WIDTH, STAGE_HEIGHT);
			ocov2 = new cover2(STAGE_WIDTH, STAGE_HEIGHT);
			ocov3 = new cover3(STAGE_WIDTH, STAGE_HEIGHT);
			ocov4  = new cover4(STAGE_WIDTH, STAGE_HEIGHT);
			ocov5 = new cover5(STAGE_WIDTH, STAGE_HEIGHT);
			ocov6  = new cover6(STAGE_WIDTH, STAGE_HEIGHT);			
			
			//initial blit - so you can see the image
			canvas.copyPixels(bg, SOURCE_RECT, DEST_POINT);			
			canvas.copyPixels(cov1, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			canvas.copyPixels(cov2, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			canvas.copyPixels(cov3, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			canvas.copyPixels(cov4, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			canvas.copyPixels(cov5, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			canvas.copyPixels(cov6, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);
			
			drawingData = new BitmapData(STAGE_WIDTH, STAGE_HEIGHT, true, 0x00000000);
			
			drawing.graphics.clear();
			drawing.graphics.lineStyle(42, DRAW_COLOR);
			
			scratched = new Array();
			scratchedCount = 0;
			
			langSelector.dialog.btnEnglish.addEventListener(MouseEvent.CLICK, selectEnglish, false, 0, true);
			langSelector.dialog.btnSpanish.addEventListener(MouseEvent.CLICK, selectSpanish, false, 0, true);
			langSelector.dialog.btnOK.addEventListener(MouseEvent.CLICK, languageSelected, false, 0, true);
			lang = "english";
			langSelector.dialog.btnEnglish.gotoAndStop(2); //show default of english
			langSelector.dialog.btnSpanish.gotoAndStop(1);
			addChild(langSelector);
			
			//start the screen saver timer when the language selector shows
			//screenSaverTimer.reset();
			//screenSaverTimer.start();
			
			timeoutTimer.reset();
			
			cq.moveToTop();
			openConfig.moveToTop();
		}

		
		
		/**
		 * Called if the screenSaverTimer times out - 1 min on the language selector screen
		 * @param	e
		 */
		private function screenSaverTimeOut(e:TimerEvent):void
		{			
			ss.show();
			ss.addEventListener(ScreenSaver.SS_CLOSED, restartSS, false, 0, true);
		}
		
		private function restartSS(e:Event):void
		{
			//restart the screen saver timer
			//screenSaverTimer.reset();
			//screenSaverTimer.start();
		}
		
		
		
		private function selectEnglish(e:MouseEvent):void
		{
			lang = "english";
			langSelector.dialog.btnEnglish.gotoAndStop(2);
			langSelector.dialog.btnSpanish.gotoAndStop(1);
			
		}
		
		
		private function selectSpanish(e:MouseEvent):void
		{
			lang = "spanish";
			langSelector.dialog.btnEnglish.gotoAndStop(1);
			langSelector.dialog.btnSpanish.gotoAndStop(2);
		}
		
		
		private function languageSelected(e:MouseEvent):void
		{
			//screenSaverTimer.reset();
			
			langSelector.dialog.btnEnglish.removeEventListener(MouseEvent.CLICK, selectEnglish);
			langSelector.dialog.btnSpanish.removeEventListener(MouseEvent.CLICK, selectSpanish);
			langSelector.dialog.btnOK.removeEventListener(MouseEvent.CLICK, languageSelected);
			
			removeChild(langSelector);			
			
			if(tripleWords){
				if (contains(tripleWords)) {
					removeChild(tripleWords);
					tripleWords = null;
				}
			}
			if (lang == "english") {
				tripleWords = new tripleEnglish();
				tripleWords.x = 1270;
				tripleWords.y = 60;
			}else {
				tripleWords = new tripleSpanish();
				tripleWords.x = 1130;
				tripleWords.y = 60;
			}
			addChild(tripleWords);
			
			//showForm();
			
			cq.moveToTop();
			openConfig.moveToTop();
			
			//NEW 10/5/2011 - move form to end
			beginGame();
		}
		
		private function showForm():void
		{
			form.addEventListener(GenMessageEvent.GENERAL_MESSAGE, messageReceived, false, 0, true);
			form.addEventListener(FormController.FORM_SUBMITTED, formSubmitted, false, 0, true);
			form.addEventListener(FormController.FORM_CANCELLED, formTimedOut, false, 0, true);
			form.addEventListener(FormController.FORM_TIMEDOUT, formTimedOut, false, 0, true);
			form.init(lang);
			form.showForm();
		}
		
		private function formTimedOut(e:Event = null):void
		{
			form.removeEventListener(GenMessageEvent.GENERAL_MESSAGE, messageReceived);
			form.removeEventListener(FormController.FORM_SUBMITTED, formSubmitted);
			form.removeEventListener(FormController.FORM_CANCELLED, formTimedOut);
			form.removeEventListener(FormController.FORM_TIMEDOUT, formTimedOut);
			form.hideForm();
			dialog.showDialog("Thank You");
			dialog.addEventListener(DialogController.DIALOG_CLOSED, dlgInit, false, 0, true);
		}
		
		private function dlgInit(e:Event):void
		{
			dialog.removeEventListener(DialogController.DIALOG_CLOSED, dlgInit);
			init();
		}
		
		
		
		/**
		 * Called by listener when formGood is dispatched from the form
		 * @param	e
		 */
		private function formSubmitted(e:Event):void
		{			
			form.removeEventListener(GenMessageEvent.GENERAL_MESSAGE, messageReceived);
			form.removeEventListener(FormController.FORM_SUBMITTED, formSubmitted);
			form.removeEventListener(FormController.FORM_TIMEDOUT, formTimedOut);
			
			var fName:String;
			if (zipReader.containsZip(form.getZipCode())) {
				fName = "in_region.xml";
			}else {
				fName = "out_of_region.xml";
			}
			
			form.saveUserData(fName);
			formTimedOut();
		}
		
		
		
		private function beginGame():void
		{
			if(lang == "english"){
				dialog.showDialog("Scratch off three circles to<br/>reveal the XFINITY icons.", 3);
			}else {
				dialog.showDialog("Raspe los tres círculos para<br/>ver el símbolo de Xfinity.", 3);
			}	
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDrawing);
			timeoutTimer.start();
		}
		
		
		
		/**
		 * Adds the match icons to the background bitmapData object
		 */
		private function addIcons():void
		{
			//t1,t2,t3 contain whole number percents for each tier
			//t1 phone, t2 internet, t3 tv
			var configData:Object = prizeDialog.getData();
			
			var icon:BitmapData;
			
			var winner:Number = Math.random();
			
			if (configData.grandChecked && prizeDialog.isGrandPrizeTime()) {
				icon = new iconTriple();
				winTier = 4;
			}else{
				if (winner < (configData.t3 / 100)) {
					//tier 3 TV
					icon = new iconTV();
					winTier = 3;
				}else if (winner < (configData.t2 / 100)) {
					//tier 2 - Internet
					icon = new iconMouse();
					winTier = 2;
				}else {
					//tier 1 - Phone
					icon = new iconPhone();
					winTier = 1;
				}			
			}
			
			//add icons to bg
			for (var i:int = 0; i < iconPositions.length; i++) {
				bg.copyPixels(icon, new Rectangle(0, 0, icon.width, icon.height), new Point(iconPositions[i].x, iconPositions[i].y));				
			}
		}
		
		
		
		/**
		 * Called on stage mouseDown
		 * @param	e MOUSE_DOWN event
		 */
		private function startDrawing(e:MouseEvent):void
		{
			timeoutTimer.reset();
			addEventListener(Event.ENTER_FRAME, updateDrawing);
			lastPoint.x = mouseX;
			lastPoint.y = mouseY;
			drawing.graphics.moveTo(lastPoint.x, lastPoint.y);
		}
		
		
		
		/**
		 * Called on stage mouseUp
		 * @param	e MOUSE_UP event
		 */
		private function endDrawing(e:MouseEvent):void
		{
			timeoutTimer.start();
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
		}		
		
		
		
		/**
		 * Called on enter frame while the user is dragging the mouse/finger
		 * @param	e ENTER_FRAME event
		 */
		private function updateDrawing(e:Event):void
		{
			drawing.graphics.lineTo(mouseX, mouseY);
			
			lastPoint.x = mouseX;
			lastPoint.y = mouseY;
			drawingData.draw(drawing); //draws sprite image into bitmapData
			
			cov1.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			cov2.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			cov3.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			cov4.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			cov5.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			cov6.copyPixels(drawingData, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);			
		
			c = cov1.threshold(cov1, SOURCE_RECT, DEST_POINT, "==", DRAW_COLOR, 0x00000000);
			rects[0] -= c;
			if (c > 0) {				
				if(scratchedCount < 3){
					if(scratched.indexOf(0) == -1){
						scratchedCount++;
						scratched.push(0);
					}
				}
			}
			
			c = cov2.threshold(cov2, SOURCE_RECT, DEST_POINT ,"==", DRAW_COLOR, 0x00000000);
			rects[1] -= c;
			if (c > 0) {				
				if(scratchedCount < 3){
					if(scratched.indexOf(1) == -1){
						scratchedCount++;
						scratched.push(1);
					}
				}
			}
			
			c = cov3.threshold(cov3, SOURCE_RECT, DEST_POINT ,"==", DRAW_COLOR, 0x00000000);
			rects[2] -= c;
			if (c > 0) {
				if(scratchedCount < 3){
					if(scratched.indexOf(2) == -1){
						scratchedCount++;
						scratched.push(2);
					}
				}
			}
			
			c = cov4.threshold(cov4, SOURCE_RECT, DEST_POINT ,"==", DRAW_COLOR, 0x00000000);
			rects[3] -= c;
			if (c > 0) {
				if(scratchedCount < 3){
					if(scratched.indexOf(3) == -1){
						scratchedCount++;
						scratched.push(3);
					}
				}
			}
			
			c = cov5.threshold(cov5, SOURCE_RECT, DEST_POINT ,"==", DRAW_COLOR, 0x00000000);
			rects[4] -= c;
			if (c > 0) {
				if(scratchedCount < 3){
					if(scratched.indexOf(4) == -1){
						scratchedCount++;
						scratched.push(4);
					}
				}
			}
			
			c = cov6.threshold(cov6, SOURCE_RECT, DEST_POINT ,"==", DRAW_COLOR, 0x00000000);
			rects[5] -= c;
			if (c > 0) {
				if(scratchedCount < 3){
					if(scratched.indexOf(5) == -1){
						scratchedCount++;
						scratched.push(5);
					}
				}
			}
			
			
			
			//blit the images onto the canvas so it can be seen
			//copy the cov images if that cover has been scratched in or copy the original if not scratched in
			canvas.copyPixels(bg, SOURCE_RECT, DEST_POINT);
			
			if(scratched.indexOf(0) != -1){
				canvas.copyPixels(cov1, SOURCE_RECT, DEST_POINT, cov1, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov1, SOURCE_RECT, DEST_POINT, ocov1, DEST_POINT, true);
			}
			if(scratched.indexOf(1) != -1){
				canvas.copyPixels(cov2, SOURCE_RECT, DEST_POINT, cov2, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov2, SOURCE_RECT, DEST_POINT, ocov2, DEST_POINT, true);
			}
			if(scratched.indexOf(2) != -1){
				canvas.copyPixels(cov3, SOURCE_RECT, DEST_POINT, cov3, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov3, SOURCE_RECT, DEST_POINT, ocov3, DEST_POINT, true);
			}
			if(scratched.indexOf(3) != -1){
				canvas.copyPixels(cov4, SOURCE_RECT, DEST_POINT, cov4, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov4, SOURCE_RECT, DEST_POINT, ocov4, DEST_POINT, true);
			}
			if (scratched.indexOf(4) != -1) {
				canvas.copyPixels(cov5, SOURCE_RECT, DEST_POINT, cov5, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov5, SOURCE_RECT, DEST_POINT, ocov5, DEST_POINT, true);
			}
			if (scratched.indexOf(5) != -1) {
				canvas.copyPixels(cov6, SOURCE_RECT, DEST_POINT, cov6, DEST_POINT, true);
			}else {
				canvas.copyPixels(ocov6, SOURCE_RECT, DEST_POINT, ocov6, DEST_POINT, true);
			}	
			
			
			if (rects[scratched[0]] <= ENOUGH_PIXELS) {
				canvas.copyPixels(indicatorRing, new Rectangle(0, 0, indicatorRing.width, indicatorRing.height), new Point(iconPositions[scratched[0]].x, iconPositions[scratched[0]].y), indicatorRing, DEST_POINT, true);
			}
			if (rects[scratched[1]] <= ENOUGH_PIXELS) {
				canvas.copyPixels(indicatorRing, new Rectangle(0, 0, indicatorRing.width, indicatorRing.height), new Point(iconPositions[scratched[1]].x, iconPositions[scratched[1]].y), indicatorRing, DEST_POINT, true);
			}
			if (rects[scratched[2]] <= ENOUGH_PIXELS) {
				canvas.copyPixels(indicatorRing, new Rectangle(0, 0, indicatorRing.width, indicatorRing.height), new Point(iconPositions[scratched[2]].x, iconPositions[scratched[2]].y), indicatorRing, DEST_POINT, true);
			}
			
			
			//test for completion
			if (rects[scratched[0]] <= ENOUGH_PIXELS && rects[scratched[1]] <= ENOUGH_PIXELS && rects[scratched[2]] <= ENOUGH_PIXELS) {
				endGame();
			}
		}		
		
		
		
		/**
		 * Called from updateDrawing once enough pixels are removed in three areas
		 */
		private function endGame():void
		{
			timeoutTimer.reset();
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrawing);
			
			if (winTier == 4) {
				prizeDialog.grandPrizeWon();
			}
			
			winDialog.showDialog(lang, winTier);
			winDialog.addEventListener(WinDialogController.WIN_CLOSE, newGame, false, 0, true);
			
			cq.moveToTop();
			openConfig.moveToTop();
		}
		
		
		
		private function newGame(e:Event):void
		{	
			showForm();
			
			winDialog.removeEventListener(WinDialogController.WIN_CLOSE, newGame);
			//init();
		}
		
		
		
		/**
		 * Called by event handler attached to form
		 * @param	e
		 */
		private function messageReceived(e:GenMessageEvent):void
		{
			dialog.showDialog(e.message);
		}
		
		
		
		/**
		 * Callback from listener on the cornerQuit object (cq)
		 * @param	e
		 */
		private function quit(e:Event):void
		{			
			//NativeApplication.nativeApplication.exit(); //AIR
			ExternalInterface.call("quit");
		}
		
		private function gameTimedOut(e:TimerEvent):void
		{
			removeEventListener(Event.ENTER_FRAME, updateDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, startDrawing);
			stage.removeEventListener(MouseEvent.MOUSE_UP, endDrawing);
			init();
		}
		
		/**
		 * Callback from listener on the openConfig object
		 * @param	e
		 */
		private function showConfig(e:Event):void
		{
			prizeDialog.showDialog();
			cq.moveToTop();
			prizeDialog.addEventListener(PrizeDialogController.PRIZE_SAVED, updatePrizing, false, 0, true);
		}
		
		
		
		/**
		 * Callback from pressing OK or Cancel in the prizing config dialog
		 *
		 * @param	e
		 */
		private function updatePrizing(e:Event):void
		{
			prizeDialog.removeEventListener(PrizeDialogController.PRIZE_SAVED, updatePrizing);
		}

	}
	
}