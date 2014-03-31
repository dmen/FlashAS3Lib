package com.gmrmarketing.smartcar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import com.gmrmarketing.smartcar.*;	
	import flash.display.Sprite;
	import flash.events.*;
	import com.greensock.TweenMax;	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import com.gmrmarketing.utilities.AIRFile;
	
	import com.adobe.images.JPGEncoder;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.display.StageDisplayState;
	import flash.ui.Mouse;
	
	

	public class Main extends MovieClip
	{
		private var airFile:AIRFile;
		
		private var mainMenu:Menu;
		
		//holds scene, audio, etc. dtaa about the car being built
		private var carData:CarData;
		
		private var theCar:SimpleCar;
		
		private var carContainer:Sprite; //holder for SimpleCar
		private var toolContainer:MovieClip;		
		
		private var currentTool:MovieClip;
		private var tool:String; //updated in menuClick(), used in updateFromTool()
		
		//the bg of the module added to module in the constructor
		private var sceneData:BitmapData;
		private var sceneBMP:Bitmap;
		
		//white flash between scene shcnages
		private var whiteData:BitmapData;
		private var whiteBMP:Bitmap;
		
		private var audioPlayer:AudioPlayer;
		
		private var venueSel:VenueSelector;
		
		private var vidLoader:Loader; //for the PlayerUI.swf video player that shows the users creation
		private var scenePreviewData:BitmapData;
		private var scenePreview:Bitmap;
		
		private var dialog:Dialog;
		private var nav:MovieClip; //instance of navBar from the lib
		private var previewClip:MovieClip; //reference to the loaded preview player - set in videoPlayerLoaded()
		
		private var modal:Sprite; //black box behind preview player	
		private var theForm:TheForm;
		private var wait:MovieClip;
		
		private var theCarForm:MovieClip; //car clip that shows while the form is displayed
		
		private var isConnected:Boolean; //set in carDataPosted or carDataNotPosted
		private var config:XML; //contains the paths for when no internet is available
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			Mouse.hide();
			
			airFile = new AIRFile(); //for saving locally
			
			nav = new navBar(); //lib clip
			
			theForm = new TheForm();
			
			modal = new Sprite();
			modal.graphics.beginFill(0x000000, .8);
			modal.graphics.drawRect(0, 0, 1920, 1080);
			
			carData = new CarData();
			
			vidLoader = new Loader();			
			
			audioPlayer = new AudioPlayer(module);
			
			scenePreviewData = new BitmapData(1280, 720, false, 0xffffffff);
			scenePreview = new Bitmap(scenePreviewData);
			
			sceneData = new BitmapData(1500, 1000);
			sceneBMP = new Bitmap(sceneData);
			module.addChildAt(sceneBMP, 0);
			
			//for making white flash
			whiteData = new BitmapData(1500, 1000, true, 0xffffffff);
			whiteBMP = new Bitmap(whiteData);
			module.addChildAt(whiteBMP, 1);
			whiteBMP.alpha = 0;
			
			toolContainer = new MovieClip();			
			addChild(toolContainer);			
			
			dialog = new Dialog(this);
			
			var c:int = airFile.getFiles(StaticData.LOCAL_SAVE_PATH).length;			
			
			//adds the venue selector
			venueSel = new VenueSelector();
			venueSel.addEventListener(VenueSelector.VENUE_SELECTED, venSelected, false, 0, true);			
			addChild(venueSel);
			
			if (c > 0) {
				venueSel.showRecapData(c);
			}
		}
		
		
		/**
		 * Called when continue in the venue selector is pressed
		 * Stores the selected venue id in curVenueID this is used in
		 * the initial post to the webservice
		 * @param	e
		 */
		private function venSelected(e:Event):void
		{			
			carData.setVenueID(venueSel.getVenueID());
			
			venueSel.removeEventListener(VenueSelector.VENUE_SELECTED, venSelected);			
			removeChild(venueSel);
			venueSel = null;
			
			init();
		}
		
		
		private function init():void
		{			
			carContainer = new Sprite();
			addChild(carContainer);
			carContainer.x = 900;
			carContainer.y = 700;
			theCar = new SimpleCar(carContainer);
			theCar.addEventListener(SimpleCar.CAR_LOADED, showCar, false, 0, true);
			
			mainMenu = new Menu(this);
			mainMenu.addEventListener(Menu.MENU_ITEM_CLICKED, menuClick, false, 0, true);
			mainMenu.addEventListener(Menu.READY_CLICKED, menuReadyClick, false, 0, true);
			mainMenu.show(); //calling show causes menu to dispatch a clicked event - so menuClick is called
		}
		
		/**
		 * For testing - updates the camera in theCar based on the sliders
		 * @param	e
		 */
		private function updateCam(e:Event):void
		{
			//theCar.changeCam(czm.value,cx.value,cy.value,cz.value);
		}
		
		/**
		 * Called when simpleCar has finished loading
		 * @param	e Event SimpleCar.CAR_LOADED
		 */
		private function showCar(e:Event):void
		{	
			theCar.removeEventListener(SimpleCar.CAR_LOADED, showCar);
			theCar.show();
		}
		
		
		/**
		 * Called by listener on main menu
		 * initiates a tool change
		 * 
		 * @param	e Event Menu.MENU_ITEM_CLICKED
		 */
		private function menuClick(e:Event = null):void
		{			
			var step:int = mainMenu.getStep();			
			storeToolData();	
			
			switch(step) {
				case 0:
					tool = "scene";					
					swapTools(new SceneSelector(), 1606, 267);					
					break;
				case 1:
					tool = "pattern";					
					swapTools(new PatternSelector(), 1500, 316);					
					break;
				case 2:
					tool = "audio";
					swapTools(new AudioSelector(), 1389, 377);					
					break;				
			}
		}
		
		/**
		 * Stores the data from the current tool in the carData object
		 */
		private function storeToolData():void
		{			
			if (tool == "scene") {
				carData.setScene(currentTool.getScene());
			}
			if (tool == "audio") {
				audioPlayer.stopAll();
				carData.setAudioSelection(currentTool.getAudioSelection());
			}
			if (tool == "pattern") {				
				carData.setCarTexture(currentTool.getTileImage()); //actual tiled image
				carData.setPattern(currentTool.getCurrentPattern()); //string btnKal1 - btnKal4
				carData.setTiling(currentTool.getTiling());
				carData.setBGColor(currentTool.getBGColor());
				carData.setKPoint(currentTool.getKPoint());
				carData.setTilingSliderPosition(currentTool.getSliderPosition());
			}		
		}
		
		
		/**
		 * Called when the Ready to Uncar button in the main menu is clicked
		 * special cased because this has to make sure a pattern and audio
		 * have been selected before moving the slider
		 * 
		 * @param	e Event Menu.READY_CLICKED
		 */
		private function menuReadyClick(e:Event):void
		{	
			storeToolData();
			
			if (carData.textureSet() && carData.audioSet()) {				
				tool = "license";
				swapTools(new LicensePlate(), 0, 0);
				mainMenu.readyOK();				
			}else {
				if (!carData.textureSet()) {
					dialog.show("Please create a wrap first");
				}else {
					dialog.show("Please create a soundtrack first");
				}
			}			
		}
		
		
		/**
		 * NOTE - might need to remove updateFromTool listener on old tools
		 * @param	newTool
		 */
		private function swapTools(newTool:MovieClip, toolX:int, toolY:int):void
		{
			while (toolContainer.numChildren) {
				toolContainer.removeChildAt(0);
			}
			
			currentTool = newTool;
			currentTool.alpha = 0;
			currentTool.addEventListener("toolChange", updateFromTool, false, 0, true);
			toolContainer.addChild(currentTool);
			switch(tool) {
				case "scene":					
					currentTool.init(carData.getScene());
					break;
				case "pattern":						
					currentTool.init(carData.getPattern(), carData.getTiling(), carData.getBGColor(), carData.getKPoint(), carData.getTilingSliderPosition());
					currentTool.addEventListener("makeBit", outputBitmap, false, 0, true);
					carData.texIsSet();
					break;
				case "audio":					
					currentTool.init(carData.getAudioSelection());
					updateFromTool(); //starts the sound playing when we come back to the audio tool
					break;
				case "license":
					theCar.hide();
					mainMenu.hide();
					currentTool.init(carData.getLicense());
					currentTool.addEventListener(LicensePlate.PLATE_DONE, licenseCompleted, false, 0, true);
					currentTool.addEventListener(LicensePlate.PLATE_NOT_DONE, stillEditing, false, 0, true);
					break;
			}					
			
			currentTool.x = toolX;
			currentTool.y = toolY;
			TweenMax.to(currentTool, 1, { alpha:1, dropShadowFilter:{color:0x000000, angle:0, distance:1, blurX:12, blurY:12, strength:3, alpha:1} } );
		}
		
		private function outputBitmap(e:Event):void
		{	var appliedMap:BitmapData = new BitmapData(1500, 1500);
			appliedMap.draw(new baseMap());
			var tex:BitmapData = currentTool.getTileImage();
			appliedMap.copyPixels(tex, tex.rect, new Point(0, 0), new baseMask(), new Point(0, 0), true);
			appliedMap.draw(new baseShadow());	
			
			var saveFileRef:FileReference = new FileReference();
			saveFileRef.save(getJpeg(appliedMap));
		}
		
		private function getJpeg(bmpd:BitmapData, q:int = 80):ByteArray
		{			
			var encoder:JPGEncoder = new JPGEncoder(q);
			var ba:ByteArray = encoder.encode(bmpd);
			return ba;
		}
		
		/**
		 * Called by clicking the back to editing button in the license plate editor
		 * @param	e
		 */
		private function stillEditing(e:Event):void
		{
			currentTool.removeEventListener(LicensePlate.PLATE_DONE, licenseCompleted);
			currentTool.removeEventListener(LicensePlate.PLATE_NOT_DONE, stillEditing);
			
			carData.setLicense(currentTool.getLicense());			
			
			theCar.show();
			mainMenu.show();
		}
		
		private function licenseCompleted(e:Event):void
		{
			currentTool.removeEventListener(LicensePlate.PLATE_DONE, licenseCompleted);
			currentTool.removeEventListener(LicensePlate.PLATE_NOT_DONE, stillEditing);
			
			//removes the license plate tool - turns off the enter frame listener on it
			while (toolContainer.numChildren) {
				toolContainer.removeChildAt(0);
			}
			
			carData.setLicense(currentTool.getLicense());
			carData.setLicenseImage(currentTool.getLicenseImage());
			
			vidLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, videoPlayerLoaded, false, 0, true);
			vidLoader.load(new URLRequest("PlayerUI.swf"));			
		}
		
		private function videoPlayerLoaded(e:Event):void
		{
			vidLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, videoPlayerLoaded);
			//addChild(vidLoader);
			//vidLoader.x = 320;
			//vidLoader.y = 180;			
			
			previewClip = MovieClip(vidLoader.content);
			previewClip.init(carData.getCarTexture(), carData.getScene(), carData.getAudioSelection(), carData.getLicenseImage());
			previewClip.addEventListener("previewHasFinished", previewComplete, false, 0, true);
			//MovieClip(vidLoader.content).addEventListener("shareTheVid", shareVid, false, 0, true);
			
			addChild(modal); //black behind the video player
			
			addChild(scenePreview);
			scenePreview.x = 320;
			scenePreview.y = 180;
			
			nav.x = 320;
			nav.y = 900;
			nav.alpha = 0;
			addChild(nav);
			TweenMax.to(nav, 2, { alpha:1 } );
			
			nav.btnEdit.addEventListener(MouseEvent.CLICK, continueEditing, false, 0, true);
			nav.btnReplay.addEventListener(MouseEvent.CLICK, replayVid, false, 0, true);
			nav.btnShare.addEventListener(MouseEvent.CLICK, shareVid, false, 0, true);
			
			
			addEventListener(Event.ENTER_FRAME, updatePreview, false, 0, true);
		}
		private function updatePreview(e:Event):void
		{
			scenePreviewData.draw(vidLoader);
		}
		/**
		 * Preview complete
		 * show nav controls
		 */
		private function previewComplete(e:Event):void
		{
			
			removeEventListener(Event.ENTER_FRAME, updatePreview);
			/*
			nav.x = 320;
			nav.y = 900;
			nav.alpha = 0;
			addChild(nav);
			TweenMax.to(nav, 2, { alpha:1 } );
			
			nav.btnEdit.addEventListener(MouseEvent.CLICK, continueEditing, false, 0, true);
			nav.btnReplay.addEventListener(MouseEvent.CLICK, replayVid, false, 0, true);
			nav.btnShare.addEventListener(MouseEvent.CLICK, shareVid, false, 0, true);
			*/
		}
		private function removeNavListeners():void
		{
			removeEventListener(Event.ENTER_FRAME, updatePreview);
			previewClip.quitPlayback();
			
			nav.btnEdit.removeEventListener(MouseEvent.CLICK, continueEditing);
			nav.btnReplay.removeEventListener(MouseEvent.CLICK, replayVid);
			nav.btnShare.removeEventListener(MouseEvent.CLICK, shareVid);
		}
		
		private function continueEditing(e:MouseEvent):void
		{
			removeNavListeners();
			removePlayerUI();
			removeChild(nav);
			theCar.show();
			mainMenu.show();
		}
		
		private function replayVid(e:MouseEvent):void
		{
			removeNavListeners();
			removePlayerUI();
			removeChild(nav);
			vidLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, videoPlayerLoaded, false, 0, true);
			vidLoader.load(new URLRequest("PlayerUI.swf"));	
		}
		
		private function shareVid(e:MouseEvent):void
		{
			removeNavListeners();
			removePlayerUI();
			removeChild(nav);
			
			wait = new pleaseWait();
			addChild(wait);
			
			var t:Timer = new Timer(100, 1);
			t.addEventListener(TimerEvent.TIMER, share2, false, 0, true);
			t.start();
		}
		private function share2(e:TimerEvent):void
		{
			//post to web service
			isConnected = true;
			
			carData.addEventListener(CarData.DID_POST, carDataPosted, false, 0, true);
			carData.addEventListener(CarData.DID_NOT_POST, carDataNotPosted, false, 0, true);
			carData.postToService();
		}
		
		private function carDataPosted(e:Event = null):void
		{
			carData.removeEventListener(CarData.DID_POST, carDataPosted);
			carData.removeEventListener(CarData.DID_NOT_POST, carDataNotPosted);			
			
			removeChild(wait);
			addChildAt(theForm, 1);
			
			theCarForm = new carForm(); //lib clip
			theCarForm.x = 1242;
			theCarForm.y = 474;
			addChild(theCarForm);
			
			theForm.init(carData.getDataID(), isConnected);
			theForm.addEventListener(TheForm.FORM_POSTED, removeForm, false, 0, true);
			theForm.addEventListener(TheForm.FORM_CANCELLED, removeForm, false, 0, true);
			theForm.addEventListener(TheForm.BAD_EMAIL, badEmail, false, 0, true);
			theForm.addEventListener(TheForm.BAD_STATE, badState, false, 0, true);
			theForm.addEventListener(TheForm.BAD_ZIP, badZip, false, 0, true);
			theForm.addEventListener(TheForm.ALL_REQUIRED, allRequired, false, 0, true);
		}
		
		private function carDataNotPosted(e:Event):void
		{			
			//not connected
			//call carData.getRequest(), theForm.getRequest() to get the last request objects
			isConnected = false;
			
			carData.removeEventListener(CarData.DID_POST, carDataPosted);
			carData.removeEventListener(CarData.DID_NOT_POST, carDataNotPosted);
			
			//call to show the form
			carDataPosted();
		}
		
		private function badEmail(e:Event):void
		{
			dialog.show("Please enter a valid email address");
		}
		
		private function badState(e:Event):void
		{
			dialog.show("Please enter a valid US state");
		}
		
		private function badZip(e:Event):void
		{
			dialog.show("Please enter a valid zip code");
		}
		
		private function allRequired(e:Event):void
		{
			dialog.show("All form fields are required");
		}
		
		private function removeForm(e:Event = null):void
		{			
			theForm.removeEventListener(TheForm.FORM_POSTED, removeForm);
			theForm.removeEventListener(TheForm.FORM_CANCELLED, removeForm);
			theForm.removeEventListener(TheForm.BAD_EMAIL, badEmail);
			theForm.removeEventListener(TheForm.BAD_STATE, badState);
			theForm.removeEventListener(TheForm.BAD_ZIP, badZip);
			theForm.removeEventListener(TheForm.ALL_REQUIRED, allRequired);
			
			removeChild(theCarForm);//car image on form
			removeChild(theForm);
			
			if (!isConnected) {
				//if no connection from posting car data get both car and form request objects and store in sow
				var a:Object = carData.getRequest();
				a.formData = theForm.getRequest();
				
				airFile.writeData(a, StaticData.LOCAL_SAVE_PATH);
			}
			
			theCar.show();
			mainMenu.show();
			
			//reset car data and texture
			carData.init();
			theCar.updateTexture();
		}
		
		
		
		
		private function removePlayerUI():void
		{
			removeChild(modal);
			removeChild(scenePreview);			
			vidLoader.unload();
		}
		
		/**
		 * Called by a toolChange event
		 * within currentTool
		 * 
		 * tool can be scene, pattern or audio
		 * 
		 * @param	e Event toolChange
		 */
		private function updateFromTool(e:Event = null):void
		{
			if (tool == "scene") {				
				whiteBMP.alpha = 1;
				sceneData.copyPixels(currentTool.getSceneImage(), new Rectangle(0, 0, 1500, 1000), new Point(0, 0));
				TweenMax.to(whiteBMP, 1, { alpha:0 } );
			}
			
			if (tool == "pattern") {				
				theCar.updateTexture(currentTool.getTileImage());
			}
			
			if (tool == "audio") {
				//array of 4 items bass,drums,guitar,synth, the scene from carData changes the visualizer color to match scene color
				audioPlayer.playSelection(currentTool.getAudioSelection(), carData.getScene());				
			}
		}
	}
	
}