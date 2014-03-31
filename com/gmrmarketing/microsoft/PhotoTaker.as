package com.gmrmarketing.microsoft
{	
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
		private var cam:Camera;
		private var theVideo:Video;
		private var camWidth:int;
		private var camHeight:int;
		
		private var captureTimer:Timer; //timer for between captures		
		
		private var previewData:BitmapData; //live preview of camera
		private var preview:Bitmap;
		private var previewMatrix:Matrix; //for scaling the camera image into the preview bitmap
		
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
		
		private var imageOverlay:BitmapData;
		
		private var data:MovieClip;
		
		
		
		public function PhotoTaker()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			
			cq = new CornerQuit();
			cq.addEventListener(CornerQuit.CORNER_QUIT, quit, false, 0, true);
			cq.init(this);
			
			errorDlg = new errorDialog(); //lib clip
			errorDlg.x = 547;
			errorDlg.y = 273;
			
			data = new config(); //lib clip
			
			imageOverlay = new overlay(600,400); //kinect wave in the library
			
			xml = new XMLLoader();
			xml.load("config.xml");
			xml.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			xml.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);	
			
			saveScreen = new savingDialog();		
			airFile = new AIRFile();
			
			encoder = new JPGEncoder(80);
			
			filenames = new Array("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve");
			
			cam = Camera.getCamera();
			
			thumbArray = new Array();
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
			airFile.startMonitoringCameraFolder();	
			
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
			
			clearNum();
			
			btnPart.addEventListener(MouseEvent.CLICK, saveParticipantsOnly, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, showSaveScreen, false, 0, true);
			btnConfig.addEventListener(MouseEvent.CLICK, showConfig, false, 0, true);
			
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
		}
		
		
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
		 * Called by pressing the save participants only button - no photo interaction
		 * @param	e
		 */
		private function saveParticipantsOnly(e:MouseEvent):void
		{
			if (participants.text == "0") {
				showErrorDialog("Please enter the number of participants in the interaction");
			}else{
				createTimeStamp();
				//write this interaction to CSV with timestamp, and number of participants
				airFile.writeCSV(timeStamp + "," + participants.text);
				showErrorDialog("Interaction has been saved");
				removeSaveScreen();
			}
		}
			
		
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
		 * Called by pressing the save button
		 */
		private function showSaveScreen(e:MouseEvent):void
		{			
			if (thumbArray.length > 0) {
				if (participants.text == "0") {
					showErrorDialog("Please enter the number of participants in the interaction");
				}else{
					saveScreen.alpha = 0;
					saveScreen.theText.text = "SAVING PHOTO #1";
					addChild(saveScreen);
					cq.moveToTop();
					TweenMax.to(saveScreen, .5, { alpha:1, onComplete:captureComplete } );
				}
			}else {
				showErrorDialog("Please take at least one picture before saving");
			}
		}
		
		
		
		private function showConfig(e:MouseEvent):void
		{
			addChild(data);
			data.btnClose.addEventListener(MouseEvent.CLICK, closeConfig, false, 0, true);
			
			//reads interactions.txt
			var f:Array = airFile.readLines();
			
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
			var today:String = yr + "-" + mo + "-" + day;
			
			var intToday:int = 0
			var participantsToday:int = 0;			
			var totalParticipants:int = 0;
			
			var curData:Array;
			var dat:Array;
			
			for (var i:int = 0; i < f.length; i++) {
				curData = f[i].split(","); //split at comma to get timestamp and interactions	
				dat = curData[0].split(" "); //split timestamp at space to get date/time
				if (dat[0] == today) {
					participantsToday += parseInt(curData[1]);
					intToday++; //interactions
				}
				if(curData[1] != undefined){
					totalParticipants += parseInt(curData[1]);					
				}
			}
			
			data.intToday.text = String(intToday);
			data.intTotal.text = String(f.length);
			data.partToday.text = String(participantsToday);
			data.partTotal.text = String(totalParticipants);			
			
			var totalEmails:int = 0;
			var emailsToday:int = 0;
			var redemptionsToday:int = 0;
			var totalRedemptions:int = 0;
			
			f = airFile.readLog();
			for (i = 0; i < f.length; i++) {
				curData = f[i].split(",");
				dat = curData[0].split(" ");
				if (dat[0] == today) {
					emailsToday++;
					redemptionsToday += parseInt(curData[1]);
				}
				if(curData[1] != undefined){
					totalRedemptions += parseInt(curData[1]);
				}
			}
			data.emailToday.text = String(emailsToday);
			data.emailTotal.text = String(f.length);
			
			data.redeemToday.text = String(redemptionsToday);
			data.redeemTotal.text = String(totalRedemptions);
		}
		
		
		
		private function closeConfig(e:MouseEvent):void
		{
			data.btnClose.removeEventListener(MouseEvent.CLICK, closeConfig);
			removeChild(data);
		}
		
		
		/**
		 * Called from checkForSave() from Tween complete
		 */
		private function removeSaveScreen():void
		{		
			if(contains(saveScreen)){
				removeChild(saveScreen);
			}
			
			//clear the thumbArray
			while (thumbArray.length) {
				var th:Thumbnail = thumbArray.splice(0, 1)[0];
				removeChild(th);
			}
			
			//delete all files in the camera watch folder
			airFile.deleteFiles();
			
			clearNum(); //sets participants text to 0
		}
		
		
		private function createTimeStamp():void
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
		}
		
		
		/**
		* Called from showSaveScreen by Tween fade up
		 */
		private function captureComplete():void
		{		
			createTimeStamp();
			
			//go backwards in the array to get the last four images, or the entire array if less than four images in it
			encodingIndex = thumbArray.length - 1;			
			encodingCount = 0;
			
			addEventListener(Event.ENTER_FRAME, checkForSave, false, 0, true);
		}
		
		
		
		/**
		 * Called on enterFrame so the display can update while encoding
		 * @param	e
		 */
		private function checkForSave(e:Event):void
		{			
			if (encodingCount < 4 && encodingIndex >= 0) {
				//encode
				saveScreen.theText.text = "SAVING PHOTO #" + String(encodingCount + 1);				
				
				var bmd:BitmapData = thumbArray[encodingIndex].getBitmapData();
				bmd.draw(imageOverlay);
				
				var ba:ByteArray = encoder.encode(bmd);
				airFile.writeImage(folderTimeStamp, filenames[encodingCount] + ".jpg", ba);
				encodingIndex--;
				encodingCount++;
			}else {				
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
			TweenMax.to(errorDlg, 1, { alpha:0, delay:1.5, onComplete:removeErrorDialog } );
		}
		
		
		private function removeErrorDialog():void
		{
			if(contains(errorDlg)){
				removeChild(errorDlg);
			}
		}

	}	
}