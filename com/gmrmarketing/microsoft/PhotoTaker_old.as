package com.gmrmarketing.microsoft
{	
	import away3d.events.MouseEvent3D;
	import flash.net.SharedObject;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.*;	
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;	
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import com.greensock.TweenMax;	
	import com.greensock.easing.*;
	import com.dynamicflash.util.Base64;
	import com.adobe.images.JPGEncoder;
	import flash.utils.ByteArray;	
	import com.gmrmarketing.microsoft.AIRFile;
	import com.gmrmarketing.microsoft.Thumbnail;
	import com.gmrmarketing.utilities.XMLLoader;
	import flash.display.StageDisplayState;
	import com.gmrmarketing.kiosk.CornerQuit;
	import flash.desktop.NativeApplication;
	

	public class PhotoTaker extends MovieClip
	{
		//private var so:SharedObject;
		//private var adminData:Object;
		
		private var cam:Camera;
		private var theVideo:Video;
		private var camWidth:int;
		private var camHeight:int;
		
		private var captureTimer:Timer; //timer for between captures
		private var picNumber:int; //the index of the pic being taken
		
		private var previewData:BitmapData; //live preview of camera
		private var preview:Bitmap;
		private var previewMatrix:Matrix; //for scaling the camera image into the preview bitmap
		
		//private var configDialog:MovieClip; //lib clip
		
		//private var captures:Array; //array of bitmapDatas that will be saved once capturing is complete
		private var airFile:AIRFile;
		private var filenames:Array; //uses the index of the image in the captures array in order to name the file
		
		private var encoder:JPGEncoder;
		private var saveScreen:MovieClip; //lib clip - savingDialog				
		
		private var xml:XMLLoader; //for loading the path variable from config.xml
		private var folderTimeStamp:String; //formatted with hyphens for folder naming
		private var timeStamp:String; //normal format for inclusion in CSV file
		private var encodingIndex:int; //index in captures, of the image being encoded
		private var encodingCount:int; 
		
		private var cq:CornerQuit;
		
		//cam config from config.xml
		private var configWidth:int;
		private var configHeight:int;
		private var configFps:int;
		
		private var thumbArray:Array; //array of Thumbnail objects
		
		private var errorDlg:MovieClip; //lib clip with theText text field
		
		
		
		public function PhotoTaker()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			cq = new CornerQuit();
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);
			cq.init(this);
			
			errorDlg = new errorDialog();
			errorDlg.x = 650;
			errorDlg.y = 233;
			
			xml = new XMLLoader();
			xml.load("config.xml");
			xml.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			xml.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);	
			
			//admin data - number of pics in group, time between shots
			//so = SharedObject.getLocal("MSPhotoData", "/");
			
			//configDialog = new config();
			saveScreen = new savingDialog();		
			airFile = new AIRFile();
			
			encoder = new JPGEncoder(80);
			
			filenames = new Array("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve");
			
			cam = Camera.getCamera();
			
			thumbArray = new Array();
			
			/*
			if (!cam) {
				trace("No camera present!");
			}else {
				init();
			}
			*/
		}
		
		
		
		/**
		 * Called on successful load of the config.xml file		
		 * 
		 * @param	e COMPLETE event
		 */		
		private function configLoaded(e:Event):void
		{	
			var b:XML = xml.getXML();
			airFile.setBasePath(b.basepath);
			airFile.setCameraSavePath(b.camsavepath); //folder to be monitored (the eyeFi folder)
			airFile.addEventListener(AIRFile.NEW_IMAGE_IN_FOLDER, getNewImage, false, 0, true);			
			
			configWidth = parseInt(b.camwidth);
			configHeight = parseInt(b.camheight);
			configFps = parseInt(b.camfps);
			
			xml.removeEventListener(Event.COMPLETE, configLoaded);
			xml.removeEventListener(IOErrorEvent.IO_ERROR, configError);
			
			init();
		}
		
		
		
		/**
		 * Called if there's an error loading the config.xml file
		 * Sets the basePath to a default
		 * 
		 * @param	e ERROR event
		 */		
		private function configError(e:IOErrorEvent):void
		{
			airFile.setBasePath("c:/MSPhotoTaker/");
			xml.removeEventListener(Event.COMPLETE, configLoaded);
			xml.removeEventListener(IOErrorEvent.IO_ERROR, configError);
		}
		
		
		
		/**
		 * Called from configLoaded()
		 */
		private function init():void
		{
			/*
			adminData = so.data.admin;			
			if (adminData == null) {
				adminData = new Object();
				adminData.numPicsToTake = 4;
				adminData.timeBetweenPics = 2;
			}
			configDialog.numPics.text = String(adminData.numPicsToTake);
			configDialog.frequency.text = String(adminData.timeBetweenPics);
			*/
			
			//captureTimer = new Timer(adminData.timeBetweenPics * 1000, 1);
			//captureTimer.addEventListener(TimerEvent.TIMER, capture, false, 0, true);
			
			cam.setQuality(0, 72);
			cam.setMode(configWidth, configHeight, configFps, false);
			
			camWidth = cam.width;
			camHeight = cam.height;			
			
			//vWindow is on stage video frame
			previewData = new BitmapData(vWindow.width - 12, vWindow.height - 13); //sub 4 for stroke width
			preview = new Bitmap(previewData);
			preview.x = vWindow.x + 4;
			preview.y = vWindow.y + 4; //+2 to compensate for stroke width
			addChild(preview);
			
			//for scaling the video into the preview bitmap
			previewMatrix = new Matrix();
			previewMatrix.scale((vWindow.width - 12) / camWidth, (vWindow.height - 13) / camHeight);
			
			theVideo = new Video(camWidth, camHeight);
			theVideo.attachCamera(cam);
			
			picNumber = 0;
			//captures = new Array();
			
			//capNumber.text = "";
			clearNum();
			//timeInfo.text = "Taking " + String(adminData.numPicsToTake) + " photos at " + String(adminData.timeBetweenPics) + " sec intervals";
			
			addKeyListeners();
			
			//add listener so the video appears in the preview bitmap
			addEventListener(Event.ENTER_FRAME, updateVideo, false, 0, true);
		}
		
		
		/**
		 * Called by listener on airFile - called when
		 * a new image file is added to the camera watch folder
		 */
		private function getNewImage(e:Event):void
		{			
			var im:String = airFile.getLatestImage();
			var th:Thumbnail = new Thumbnail();
			th.x = 1570;
			th.y = 194 + (212 * (thumbArray.length % 4));
			addChild(th);
			thumbArray.push(th);
			th.loadImage(im);
			//when save - need to grab the full size image (getBitmapData) from the last four thumb objects in thumbArray
		}
		
		
		/**
		 * Called from init();
		 */
		private function addKeyListeners():void
		{
			//btnConfig.addEventListener(MouseEvent.CLICK, showConfig, false, 0, true);
			btnStart.addEventListener(MouseEvent.CLICK, beginCapture, false, 0, true);
			
			//numpad			
			k1.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k2.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k3.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k4.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k5.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k6.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k7.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k8.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k9.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			k0.addEventListener(MouseEvent.CLICK, updateNum, false, 0, true);
			kc.addEventListener(MouseEvent.CLICK, clearNum, false, 0, true);
		}
		
		
		/**
		 * Removes the key listeners while the pics are being taken
		 */
		private function removeKeyListeners():void
		{		
			btnStart.removeEventListener(MouseEvent.CLICK, beginCapture);
			//btnConfig.removeEventListener(MouseEvent.CLICK, showConfig);
			
			k1.removeEventListener(MouseEvent.CLICK, updateNum);
			k2.removeEventListener(MouseEvent.CLICK, updateNum);
			k3.removeEventListener(MouseEvent.CLICK, updateNum);
			k4.removeEventListener(MouseEvent.CLICK, updateNum);
			k5.removeEventListener(MouseEvent.CLICK, updateNum);
			k6.removeEventListener(MouseEvent.CLICK, updateNum);
			k7.removeEventListener(MouseEvent.CLICK, updateNum);
			k8.removeEventListener(MouseEvent.CLICK, updateNum);
			k9.removeEventListener(MouseEvent.CLICK, updateNum);
			k0.removeEventListener(MouseEvent.CLICK, updateNum);
			kc.removeEventListener(MouseEvent.CLICK, clearNum);
		}
		
		
		/**
		 * Called by pressing the C config button at upper right
		 * fields for this screen are populated in init() once the SO has been read
		 * @param	e
		 */
		/*
		private function showConfig(e:MouseEvent):void
		{
			configDialog.alpha = 0;
			addChild(configDialog);
			TweenMax.to(configDialog, .5, { alpha:1 } );
			configDialog.btnCancel.addEventListener(MouseEvent.CLICK, hideConfig, false, 0, true);
			configDialog.btnSave.addEventListener(MouseEvent.CLICK, saveConfig, false, 0, true);
			configDialog.numDown.addEventListener(MouseEvent.CLICK, decNumPics, false, 0, true);
			configDialog.numUp.addEventListener(MouseEvent.CLICK, incNumPics, false, 0, true);
			configDialog.secDown.addEventListener(MouseEvent.CLICK, decNumSecs, false, 0, true);
			configDialog.secUp.addEventListener(MouseEvent.CLICK, incNumSecs, false, 0, true);
			
			cq.moveToTop();
		}
		
		
		private function hideConfig(e:MouseEvent = null):void
		{
			configDialog.btnSave.removeEventListener(MouseEvent.CLICK, saveConfig);
			configDialog.btnCancel.removeEventListener(MouseEvent.CLICK, hideConfig);
			configDialog.numDown.removeEventListener(MouseEvent.CLICK, decNumPics);
			configDialog.numUp.removeEventListener(MouseEvent.CLICK, incNumPics);
			configDialog.secDown.removeEventListener(MouseEvent.CLICK, decNumSecs);
			configDialog.secUp.removeEventListener(MouseEvent.CLICK, incNumSecs);
			
			TweenMax.to(configDialog, .5, { alpha:0, onComplete:removeConfig } );
		}
		*/
		
		/**
		 * Called when the save button is pressed in the config screen
		 * @param	e
		 */
		/*
		private function saveConfig(e:MouseEvent):void
		{			
			adminData.numPicsToTake = parseInt(configDialog.numPics.text);
			adminData.timeBetweenPics = parseInt(configDialog.frequency.text);
			
			so.data.admin = adminData;
			so.flush();
			
			timeInfo.text = "Taking " + String(adminData.numPicsToTake) + " photos at " + String(adminData.timeBetweenPics) + " sec intervals";
			captureTimer.delay = adminData.timeBetweenPics * 1000;
			
			hideConfig();
		}
		*/
		/*
		private function removeConfig():void
		{
			removeChild(configDialog);
		}
		*/
		/*
		private function decNumPics(e:MouseEvent):void
		{
			var num:int = parseInt(configDialog.numPics.text);			
			if (num > 1) {
				num--;
			}
			configDialog.numPics.text = String(num);
		}
		
		
		private function incNumPics(e:MouseEvent):void
		{
			var num:int = parseInt(configDialog.numPics.text);
			if (num < 4) {
				num++;
			}
			configDialog.numPics.text = String(num);
		}
		
		
		private function decNumSecs(e:MouseEvent):void
		{
			var num:int = parseInt(configDialog.frequency.text);			
			if (num > 1) {
				num--;
			}
			configDialog.frequency.text = String(num);
		}
		
		
		private function incNumSecs(e:MouseEvent):void
		{
			var num:int = parseInt(configDialog.frequency.text);
			if (num < 30) {
				num++;
			}
			configDialog.frequency.text = String(num);
		}
		*/
		/**
		 * Called from pressing any of the numpad buttons
		 * @param	e
		 */
		private function updateNum(e:MouseEvent):void
		{
			if (participants.text == "0") {
				participants.text = "";
			}
			if(participants.text.length < 2){
				participants.appendText(String(e.currentTarget.name).substr(1));
			}
		}
		
		private function clearNum(e:MouseEvent = null):void
		{
			participants.text = "0";
		}
		
		
		/**
		 * Called by pressing start button
		 * Removes the key listeners and begins monitoring the iFi folder
		 * @param	e
		 */
		private function beginCapture(e:MouseEvent):void
		{			
			if (participants.text == "0") {
				showErrorDialog("Please enter the number of participants in the interaction");
			}else{
				removeKeyListeners();
				//capture();				
				airFile.startMonitoringCameraFolder();
				
				btnSave.addEventListener(MouseEvent.CLICK, showSaveScreen, false, 0, true);
			}
		}
		
		
		/**
		 * Called from capture() if there are more more pics yet to take
		 * resets and starts the captureTimer
		 */
		/*
		private function nextCapture():void
		{
			captureTimer.reset();
			captureTimer.start();
		}		
		*/
		
		/**
		 * Draws the video object onto the preview bitmap
		 * called on enterFrame
		 * @param	e
		 */
		private function updateVideo(e:Event):void
		{
			previewData.draw(theVideo, previewMatrix);
		}
		
		
		/**
		 * Called initially by pressing the start button - so the preview is captured immediately
		 * Called successively by captureTimer
		 * @param	e
		 */
		/*
		private function capture(e:* = null):void
		{	
			picNumber++;
			capNumber.text = "Taking photo #: " + String(picNumber);
			
			var bmp:BitmapData = new BitmapData(camWidth, camHeight);
			bmp.draw(theVideo);
			captures.push(bmp);
			
			if (picNumber < adminData.numPicsToTake) {
				nextCapture();
			}else {
				showSaveScreen();
			}
		}
		*/
		
		
		/**
		 * Called by pressing the save button
		 */
		private function showSaveScreen(e:MouseEvent):void
		{
			saveScreen.alpha = 0;
			saveScreen.theText.text = "SAVING PHOTO #1";
			addChild(saveScreen);
			cq.moveToTop();
			TweenMax.to(saveScreen, .5, { alpha:1, onComplete:captureComplete } );	
		}		
		
		
		
		/**
		 * Called from checkForSave() from Tween complete
		 */
		private function removeSaveScreen():void
		{			
			removeChild(saveScreen);
			
			picNumber = 0;
			//captures = new Array();
			
			//clear the thumbArray
			while (thumbArray.length) {
				var th:Thumbnail = thumbArray.splice(0, 1)[0];
				removeChild(th);
			}
			
			capNumber.text = "";
			clearNum();
			
			addKeyListeners();
		}
		
		
		
		/**
		* Called from showSaveScreen by Tween fade up
		 */
		private function captureComplete():void
		{		
			//create a timestamp for the folder name
			var now:Date = new Date();
			
			//date
			var yr:String = String(now.getFullYear());
			var mo:String = String(now.getMonth() + 1);
			if (mo.length < 2) {
				mo = "0" + mo;				
			}
			var day:String = String(now.getDate());
			if (day.length < 2) {
				day = "0" + day;
			}
			
			//time
			var ho:String = String(now.getHours());
			if (ho.length < 2) {
				ho = "0" + ho;
			}
			var mi:String = String(now.getMinutes());
			if (mi.length < 2) {
				mi = "0" + mi;
			}
			var sec:String = String(now.getSeconds());
			if (sec.length < 2) {
				sec = "0" + sec;
			}
			var ms:String = String(now.getMilliseconds());
			if (ms.length < 3) {
				ms = "0" + ms;
			}
			if (ms.length < 3) {
				ms = "0" + ms;
			}			
			
			//format: 2011-07-14 09-22-14-12
			//uses hyphens in time because we name a folder with this stamp - and folder names can't contain colons
			folderTimeStamp = yr + "-" + mo + "-" + day + " " + ho + "-" + mi + "-" + sec + "-" + ms;
			//normal time stamp format for use in csv
			timeStamp = yr + "-" + mo + "-" + day + " " + ho + ":" + mi + ":" + sec + "." + ms;
			
			encodingIndex = thumbArray.length - 1; //go backwards in the array to get the last four images
			encodingCount = 0;
			
			addEventListener(Event.ENTER_FRAME, checkForSave, false, 0, true);
		}
		
		
		
		/**
		 * Called on enterFrame so the display can update while encoding
		 * @param	e
		 */
		private function checkForSave(e:Event):void
		{
			//if (encodingIndex < captures.length) {
			if (encodingCount < 3) {
				//encode
				saveScreen.theText.text = "SAVING PHOTO #" + String(encodingCount + 1);
				
				//var ba:ByteArray = encoder.encode(captures[encodingIndex]);
				var ba:ByteArray = encoder.encode(thumbArray[encodingIndex].getBitmapData());
				airFile.writeImage(folderTimeStamp, filenames[encodingCount] + ".jpg", ba);
				encodingIndex--;
				encodingCount++;
			}else {
				//done!
				//write this interaction to CSV with timestamp, and number of participants
				airFile.writeCSV(timeStamp + "," + participants.text);
				
				removeEventListener(Event.ENTER_FRAME, checkForSave);
				TweenMax.to(saveScreen, .5, { alpha:0, onComplete:removeSaveScreen } );
			}
		}
		
		
		/**
		 * Called by listener once four clicks at upper right happen
		 * @param	e
		 */
		private function quit(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
		
		
		private function showErrorDialog(msg:String):void
		{
			errorDlg.theText.text = msg;
			addChild(errorDlg);
			errorDlg.alpha = 1;
			TweenMax.to(errorDlg, 1, { alpha:1, delay:1.5, onComplete:removeErrorDialog } );
		}
		
		
		private function removeErrorDialog():void
		{
			if(contains(errorDlg)){
				removeChild(errorDlg);
			}
		}

	}
	
}