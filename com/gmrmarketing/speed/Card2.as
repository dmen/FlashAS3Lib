package com.gmrmarketing.speed
{	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo; //for flashVars
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.display.Loader;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.gmrmarketing.utilities.SwearFilter;
	import com.gmrmarketing.utilities.GenericSlider;
	import com.gmrmarketing.speed.FeatureSlider;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import flash.filters.DropShadowFilter;
	import com.gmrmarketing.speed.CardImage;
	import flash.text.TextFieldAutoSize;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	
	

	public class Card2 extends MovieClip
	{
		private var fileRef:FileReference;
		private var loader:Loader;
		private var introDialog:UserData;
		
		private var s1Uploader:MovieClip;
		
		//holder for the stickers
		private var stickerContainer:Sprite;		
		private var carContainer:Sprite;		
		
		private var control:controls; //lib clip
		
		private var userData:Object;
		
		private var stickerList:Array;
		private var currentControl:MovieClip; //reference to the control clip currently being shown
		private var border:MovieClip;
		
		private var swearFilter:SwearFilter;
		
		private var cardData:BitmapData;
		private var cardBMP:Bitmap;
		
		//private var animSticker:MovieClip;
		private var curSticker:MovieClip; //the sticker being dragged - for deleting if the sticker is dragged out of the card
		private var stickerNumber:int = 0;		
		
		private var currentPickColor:Number; //current custom color when user is using the custom color picker
		
		private var cardTxt:MovieClip; //holder for the headline and description text
		
		private var zoomSlider:GenericSlider;
		private var rotateSlider:GenericSlider;
		private var featureSlider:FeatureSlider;
		
		private var initialMoveTimer:Timer;
		private var continualMoveTimer:Timer;		
		
		private var moveDirection:Point;
		
		private var preview:MovieClip;
		
		private var cardImage:CardImage; //used for sending data to the web service
		
		private var stickerShadow:DropShadowFilter;
		
		private var facebookID:String; //facebook id passed in from preloader - set in setID()
		
		private var featureDelta:int;
		
		private var curTemplate:int; //1-2-3 set in swapBorder()
		
		private var paintCan:MovieClip; //lib clip
		
		
		private var almostDoneDialog:MovieClip; //almostDone lib clip
		
		
		
		
		public function Card2()
		{	
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		
		private function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			TweenPlugin.activate([TintPlugin]);
			
			stickerShadow = new DropShadowFilter(0, 0, 0, 1, 4, 4, 1.5, 2, false, false, false);
			
			cardImage = new CardImage();
			
			paintCan = new paintCursor(); //cursor for custom color picker
			
			loader = new Loader();
			
			swearFilter = new SwearFilter();
			
			cardData = new BitmapData(720,570);
			cardBMP = new Bitmap(cardData);
			
			carContainer = new Sprite();
			carContainer.x = 110;
			carContainer.y = 210;
			theCard.addChild(carContainer);
			
			stickerContainer = new Sprite();
			theCard.addChild(stickerContainer);
			
			cardTxt = new cardText(); //lib clip
			cardTxt.x = 9;
			cardTxt.y = 6;
			theCard.addChild(cardTxt);
			cardTxt.mouseEnabled = false;
			cardTxt.mouseChildren = false;
			
			var tinyLogos:MovieClip = new smallLogos();
			tinyLogos.x = 571;
			theCard.addChild(tinyLogos);
			tinyLogos.mouseEnabled = false;
			tinyLogos.mouseChildren = false;
			
			fileRef = new FileReference();		
			
			control = new controls();
			control.y = 458;
			addChild(control);
			
			showTemplate1(); //show the first border/template on the card
			
			introDialog = new UserData();
			introDialog.addEventListener("userDataEntered", startBuilder, false, 0, true);
			introDialog.y = 60;
			addChild(introDialog);
			
			stickerList = new Array();
			stickerList.push(control.stickerBox.s1, control.stickerBox.s2, control.stickerBox.s3, control.stickerBox.s4);
			stickerList.push(control.stickerBox.s5, control.stickerBox.s6, control.stickerBox.s7, control.stickerBox.s8);
			stickerList.push(control.stickerBox.s9, control.stickerBox.s10, control.stickerBox.s11, control.stickerBox.s12);
			stickerList.push(control.stickerBox.s13, control.stickerBox.s14, control.stickerBox.s15, control.stickerBox.s16);			
			
			control.tabImage.addEventListener(MouseEvent.CLICK, showImage, false, 0, true);
			control.tabInfo.addEventListener(MouseEvent.CLICK, showInfo, false, 0, true);			
			control.tabTheme.addEventListener(MouseEvent.CLICK, showThemes, false, 0, true);
			control.tabColor.addEventListener(MouseEvent.CLICK, showColors, false, 0, true);
			control.tabStickers.addEventListener(MouseEvent.CLICK, showStickers, false, 0, true);
			control.tabPreview.addEventListener(MouseEvent.CLICK, showPreview, false, 0, true);
			
			control.tabImage.buttonMode = true;
			control.tabInfo.buttonMode = true;
			control.tabTheme.buttonMode = true;
			control.tabColor.buttonMode = true;
			control.tabStickers.buttonMode = true;
			control.tabPreview.buttonMode = true;
			
			currentControl = null; //reference to the current showing clip in the controls			
				
			zoomSlider = new GenericSlider(control.imageBox.zoomHandle, control.imageBox.zoomTrack);
			zoomSlider.setStart(control.imageBox.zoomHandle.x);
			zoomSlider.setOffset(control.imageBox.x);
			
			rotateSlider = new GenericSlider(control.imageBox.rotateHandle, control.imageBox.rotateTrack);
			rotateSlider.setStart(control.imageBox.rotateHandle.x);
			rotateSlider.setOffset(control.imageBox.x);
			
			featureSlider = new FeatureSlider(control.infoBox.slider, control.infoBox.track, stage);			
			
			s1Uploader = new step1Uploader(); //lib clip
			
			preview = new previewContainer(); //lib clip
			
			initialMoveTimer = new Timer(250, 1);
			continualMoveTimer = new Timer(50);
			
			almostDoneDialog = new almostDone(); //lib clip
		}
		
		
		/**
		 * Called from preloader with the passed in flashVar
		 * @param	id
		 */
		public function setID(id:String):void
		{
			facebookID = id;
		}
		
		
		/**
		 * Called when the user successfully enters the intro data into the form
		 * @param	e
		 */
		private function startBuilder(e:Event):void
		{
			updateUserData();			
			killIntroDialog();			
			introDialog.removeEventListener("userDataEntered", startBuilder);
		}
		
		
		private function updateUserData():void
		{
			userData = introDialog.getData();
			
			if (userData.firstName.charAt(userData.firstName.length - 1) == "s") {
				cardTxt.userName.text = userData.firstName + "' Weekend Warrior Ride";		
			}else {
				cardTxt.userName.text = userData.firstName + "'s Weekend Warrior Ride";
			}
			cardTxt.carName.text = "“" + userData.carName + "\"";
			cardTxt.blackBlock.width = cardTxt.carName.textWidth;
			cardTxt.carModel.autoSize = TextFieldAutoSize.LEFT;
			
			if(userData.carMake != "not listed"){
				cardTxt.carModel.text = userData.carYear + " " + userData.carMake + " " + userData.carModel;
			}else {
				cardTxt.carModel.text = userData.carYear + " " + userData.carModel;
			}
			
			cardTxt.blackBlock2.width = cardTxt.carModel.textWidth + 5;
			cardTxt.blackBlock2.height = cardTxt.carModel.textHeight;
			
			if(userData.restoreTime == "1"){
				cardTxt.restoreTime.text = "Restored in " + userData.restoreTime + " day";
			}else {
				cardTxt.restoreTime.text = "Restored in " + userData.restoreTime + " days";
			}
			cardTxt.restoreTime.y = cardTxt.carModel.y + cardTxt.carModel.textHeight;
		}
		
		
		
		private function killIntroDialog(showCancel:Boolean = false):void
		{
			if(contains(introDialog)){
				removeChild(introDialog);
			}
			
			s1Uploader.alpha = 1;
			
			addChild(s1Uploader);
			s1Uploader.fileName.text = "";
			s1Uploader.y = 60;
			s1Uploader.btnOK.alpha = .36;
			s1Uploader.progressBar.scaleX = 0;
			s1Uploader.btnBrowse.addEventListener(MouseEvent.CLICK, openFileReference, false, 0, true);
			s1Uploader.btnBrowse.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			s1Uploader.btnBrowse.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			s1Uploader.btnBrowse.buttonMode = true;
			
			if (!showCancel) {
				s1Uploader.btnCancel.alpha = 0;
				s1Uploader.btnCancel.mouseEnabled = false;
			}else {
				s1Uploader.btnCancel.alpha = 1;
				s1Uploader.btnCancel.mouseEnabled = true;
				s1Uploader.btnCancel.buttonMode = true;
				s1Uploader.btnCancel.addEventListener(MouseEvent.CLICK, closeS1Uploader, false, 0, true);
			}
		}
		
		private function showS1Glow(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget.redArrow, .5, { alpha:1 } );
		}
		
		private function hideS1Glow(e:MouseEvent):void
		{
			TweenLite.to(e.currentTarget.redArrow, .5, { alpha:0 } );
		}
		
		
		private function openFileReference(e:MouseEvent):void
		{			
			fileRef.browse([new FileFilter("Car Images", "*.jpeg;*.jpg;*.gif;*.png")]);
			fileRef.addEventListener(Event.SELECT, fileSelected, false, 0, true);
		}
		
		
		private function fileSelected(e:Event):void 
		{
			//limit to 2MB = 4 * 1024 * 1024
			if(fileRef.size <= 4194304){
				s1Uploader.btnOK.addEventListener(MouseEvent.CLICK, loadFile, false, 0, true);
				s1Uploader.btnOK.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
				s1Uploader.btnOK.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
				s1Uploader.btnOK.alpha = 1;
				s1Uploader.btnOK.buttonMode = true;
				s1Uploader.fileName.text = fileRef.name;
			}else {
				s1Uploader.errorLimit.alpha = 1;				
				TweenLite.to(s1Uploader.errorLimit, 1, { alpha:0, delay:2 } );
				s1Uploader.fileName.text = "";
				s1Uploader.btnOK.alpha = .36;
				s1Uploader.btnOK.removeEventListener(MouseEvent.CLICK, loadFile);
				s1Uploader.btnOK.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
				s1Uploader.btnOK.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			}
		}
		
		
		private function loadFile(e:MouseEvent):void
		{
			s1Uploader.btnBrowse.removeEventListener(MouseEvent.CLICK, openFileReference);
			s1Uploader.btnBrowse.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			s1Uploader.btnBrowse.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			s1Uploader.btnOK.removeEventListener(MouseEvent.CLICK, loadFile);
			s1Uploader.btnOK.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			s1Uploader.btnOK.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			fileRef.addEventListener(Event.COMPLETE, onFileLoaded, false, 0, true);
			fileRef.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError, false, 0, true);
			fileRef.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			fileRef.load();
		}
		
		private function onFileLoaded(e:Event):void 
		{		
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded, false, 0, true);
			loader.loadBytes(e.target.data);			
		}
		
		
		private function imageLoaded(e:Event):void
		{			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			if(!carContainer.contains(loader)){
				carContainer.addChild(loader);
				loader.x -= loader.width / 2;
				loader.y -= loader.height / 2;
			}
			resetImage();
			
			//initially fit the image to the window
			var targetScaleX:Number = 505 / loader.width;
			
			zoomSlider.setSlider(targetScaleX);
			updateImageScale();
			
			carContainer.addEventListener(MouseEvent.MOUSE_DOWN, startPicDrag, false, 0, true);			
			
			closeS1Uploader();
		}
		private function startPicDrag(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stopPicDrag, false, 0, true);
			carContainer.startDrag();
		}
		private function stopPicDrag(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopPicDrag);
			carContainer.stopDrag();
		}
		private function closeS1Uploader(e:MouseEvent = null):void
		{
			s1Uploader.btnCancel.removeEventListener(MouseEvent.CLICK, closeS1Uploader);
			TweenLite.to(s1Uploader, 1, { alpha:0, onComplete:killS1Uploader } );
		}
		
		private function killS1Uploader():void
		{
			removeChild(s1Uploader);
			
			//shows the first control interface
			showImage();
			
			//show the new dialog
			showAlmostDone(true);
		}
		
		
		
		
		private function onFileLoadError(e:IOErrorEvent):void
		{
			trace("file upload error");
		}
		
		
		private function onProgress(e:ProgressEvent):void
		{
			s1Uploader.progressBar.scaleX = e.bytesLoaded / e.bytesTotal;
		}
		
		
		
		
		
		
		// *******      IMAGE
		//{region "IMAGE"
		private function showImage(e:MouseEvent = null):void
		{
			removeLastControl();
			control.imageBox.alpha = 0;
			TweenLite.to(control.imageBox, .5, { alpha:1 } );
			control.imageBox.y = 60;
			currentControl = control.imageBox;
		
			zoomSlider.addEventListener(GenericSlider.DRAGGING, updateImageScale, false, 0, true);
			rotateSlider.addEventListener(GenericSlider.DRAGGING, updateImageRotation, false, 0, true);
			
			//move buttons
			control.imageBox.btnUp.direction = "up";
			control.imageBox.btnUp.buttonMode = true;
			control.imageBox.btnDown.direction = "down";
			control.imageBox.btnDown.buttonMode = true;
			control.imageBox.btnLeft.direction = "left";
			control.imageBox.btnLeft.buttonMode = true;
			control.imageBox.btnRight.direction = "right";
			control.imageBox.btnRight.buttonMode = true;
			
			control.imageBox.btnUp.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
			control.imageBox.btnDown.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
			control.imageBox.btnLeft.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
			control.imageBox.btnRight.addEventListener(MouseEvent.MOUSE_DOWN, startMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopMoving, false, 0, true);
			
			
			control.imageBox.btnReset.buttonMode = true;
			control.imageBox.btnReset.addEventListener(MouseEvent.CLICK, resetImage, false, 0, true);
			control.imageBox.btnReset.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			control.imageBox.btnReset.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			
			control.imageBox.btnChange.buttonMode = true;
			control.imageBox.btnChange.addEventListener(MouseEvent.CLICK, changeCarImage, false, 0, true);
			control.imageBox.btnChange.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			control.imageBox.btnChange.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			
			control.tabHiliter.alpha = 1;
			control.tabHiliter.x = 8;
			control.tabHiliter.width = 81;
			control.tabArrow.x = 49;
		}
		
		private function editForm(e:MouseEvent):void
		{
			introDialog.alpha = 1;
			introDialog.editMode();
			introDialog.addListeners(); //enables the next button
			introDialog.addEventListener("userDataEntered", removeForm, false, 0, true);
			introDialog.y = 60;
			addChild(introDialog);
		}
		private function removeForm(e:Event):void
		{
			updateUserData();
			introDialog.removeEventListener("userDataEntered", removeForm);
			TweenLite.to(introDialog, 1, { alpha:0, onComplete:killForm } );
		}
		private function killForm():void
		{
			removeChild(introDialog);
		}
		
		private function changeCarImage(e:MouseEvent):void
		{
			killIntroDialog(true);
		}
		
		private function resetImage(e:MouseEvent = null):void
		{
			zoomSlider.resetSlider();
			rotateSlider.resetSlider();
			loader.x = loader.y = 0;
			
			//var targetScaleX:Number = 505 / loader.width;
			
			//zoomSlider.setSlider(targetScaleX);
			//updateImageScale();
		}
		
		private function updateImageScale(e:Event = null):void
		{			
			loader.scaleX = loader.scaleY = 1 + zoomSlider.getNormalizedDelta();
		}
		
		private function updateImageRotation(e:Event):void
		{			
			carContainer.rotation = rotateSlider.getNormalizedDelta() * 180;
		}
		//}
		
		
		/**
		 * Called from mouseDown on any of the move buttons
		 * @param	e
		 */
		private function startMove(e:MouseEvent):void
		{
			var dist:int = 4;
			var dir:String = e.currentTarget.direction;
			switch(dir) {
				case "up":
					loader.y -= dist;
					moveDirection = new Point(0, -3);
					break;
				case "down":
					loader.y += dist;
					moveDirection = new Point(0, 3);
					break;
				case "left":
					loader.x -= dist;
					moveDirection = new Point( -3, 0);
					break;
				case "right":
					loader.x += dist;
					moveDirection = new Point(3, 0);
					break;
			}
			initialMoveTimer.addEventListener(TimerEvent.TIMER, moveImage, false, 0, true);
			initialMoveTimer.start();
		}
		private function moveImage(e:TimerEvent = null):void
		{
			initialMoveTimer.removeEventListener(TimerEvent.TIMER, moveImage);
			initialMoveTimer.reset();
			continualMoveTimer.addEventListener(TimerEvent.TIMER, moveAgain, false, 0, true);
			continualMoveTimer.start();
		}
		private function moveAgain(e:TimerEvent):void
		{
			loader.x += moveDirection.x;
			loader.y += moveDirection.y;
		}
		private function stopMoving(e:MouseEvent):void
		{
			initialMoveTimer.removeEventListener(TimerEvent.TIMER, moveImage);
			initialMoveTimer.reset();			
			continualMoveTimer.reset();
			continualMoveTimer.removeEventListener(TimerEvent.TIMER, moveAgain);
		}
		
		
		
		
		
		
		
		// *******      INFO
		private function i(){}
		private function showInfo(e:MouseEvent):void
		{
			removeLastControl();
			control.infoBox.alpha = 0;
			
			control.infoBox.featureContainer.mask = control.infoBox.featMask;
			
			TweenLite.to(control.infoBox, .5, { alpha:1 } );
			control.infoBox.y = 60;
			currentControl = control.infoBox;
			
			control.infoBox.btnUpdate.addEventListener(MouseEvent.CLICK, updateInfo, false, 0, true);
			control.infoBox.btnUpdate.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			control.infoBox.btnUpdate.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			control.infoBox.btnUpdate.buttonMode = true;
			
			control.infoBox.btnEdit.buttonMode = true;
			control.infoBox.btnEdit.addEventListener(MouseEvent.CLICK, editForm, false, 0, true);
			control.infoBox.btnEdit.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			control.infoBox.btnEdit.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			
			control.infoBox.btnAdd.buttonMode = true;
			control.infoBox.btnAdd.addEventListener(MouseEvent.CLICK, addNewFeature, false, 0, true);
			
			control.tabHiliter.alpha = 1;
			control.tabHiliter.x = 106;
			control.tabHiliter.width = 73;
			control.tabArrow.x = 143;
			
			control.infoBox.newFeature.text = "";
			control.infoBox.newFeature.maxChars = 36;
			
			featureSlider.addEventListener(FeatureSlider.DRAGGING, updateFeaturePositions, false, 0, true);
			
			checkFeatureScroller();
		}
		
		private function updateFeaturePositions(e:Event = null):void
		{
			//control.infoBox.featureContainer.height = 21 * control.infoBox.featureContainer.numChildren;
			featureDelta = Math.max(0, control.infoBox.featureContainer.height - control.infoBox.featMask.height);
			var delta:Number = featureSlider.getNormalizedDelta();
			control.infoBox.featureContainer.y = control.infoBox.featMask.y - (featureDelta * delta);
		}
		
		private function updateInfo(e:Event):void
		{
			if (swearFilter.containsSwear(control.infoBox.description.text)) {				
				showInfoError("No profanity is allowed");
			}else{
				cardTxt.description.text = control.infoBox.description.text;
			}
		}
		
		
		/**
		 * Updates the feature list on the card
		 */
		private function updateCardFeatures():void
		{
			//remove any old features
			while (cardTxt.featureHolder.numChildren) {
				cardTxt.featureHolder.removeChildAt(0);
			}
			
			var vGap:int = 5;
			var curY:int = 0;
			var newFeat:MovieClip;
			var c:int = control.infoBox.featureContainer.numChildren;
			for (var i:int = 0; i < c; i++) {
				switch(curTemplate) {
					case 1:
						newFeat = new featureCardTemp1();
						break;
					case 2:
						newFeat = new featureCardTemp2();
						break;
					case 3:
						newFeat = new featureCardTemp3();
						break;
				}				
				
				newFeat.theText.autoSize = TextFieldAutoSize.LEFT;
				
				newFeat.theText.text = control.infoBox.featureContainer.getChildAt(i).theText.text;
				cardTxt.featureHolder.addChild(newFeat);
				newFeat.y = curY;
				curY += newFeat.theText.textHeight + vGap;
			}
				
		}
		
		private function showInfoError(msg:String):void
		{
			control.infoBox.errorMessage.text = msg;
			control.infoBox.errorMessage.alpha = 1;
			TweenLite.to(control.infoBox.errorMessage, 2, { alpha:0, delay:2 } );
		}
		
		/**
		 * Called from clicking the + button to add a feature
		 * @param	e
		 */
		private function addNewFeature(e:MouseEvent):void
		{
			if (swearFilter.containsSwear(control.infoBox.newFeature.text)) {				
				showInfoError("No profanity is allowed");
				return;
			}
			if (control.infoBox.newFeature.text == "") {
				showInfoError("No feature to add");
				return;
			}
				
			var feat:MovieClip = new feature(); //lib clip
			feat.theText.text = control.infoBox.newFeature.text;
			feat.x = 1;
			feat.y = 21 * control.infoBox.featureContainer.numChildren;
			control.infoBox.featureContainer.addChild(feat);
			
			checkFeatureScroller();
			
			feat.btnDelete.buttonMode = true;
			feat.btnDelete.addEventListener(MouseEvent.CLICK, deleteFeature, false, 0, true);
			
			featureDelta = Math.max(0, control.infoBox.featureContainer.height - control.infoBox.featMask.height);
			
			//clear feature just entered
			control.infoBox.newFeature.text = "";
			
			updateCardFeatures();
		}
		
		private function checkFeatureScroller():void
		{
			if (control.infoBox.featureContainer.numChildren > 4) {
				TweenLite.to(control.infoBox.slider, 1, { alpha:1 } );
				TweenLite.to(control.infoBox.track, 1, { alpha:1 } );
				control.infoBox.slider.mouseEnabled = true;
			}else {
				TweenLite.to(control.infoBox.slider, 1, { alpha:0 } );
				TweenLite.to(control.infoBox.track, 1, { alpha:0 } );
				control.infoBox.slider.mouseEnabled = false;
			}
		}
		
		/**
		 * Deletes a feature item from the lower list of features
		 * @param	e
		 */
		private function deleteFeature(e:MouseEvent):void
		{
			control.infoBox.featureContainer.removeChild(e.currentTarget.parent);
			
			var c:int = control.infoBox.featureContainer.numChildren;
			var curY:int = 0;
			for (var i:int = 0; i < c; i++) {
				control.infoBox.featureContainer.getChildAt(i).y = 21 * i;
			}
			
			
			updateFeaturePositions();
			updateCardFeatures();
			checkFeatureScroller();
		}
		
		
		
		
		
		
		
		// *******       COLORS
		private function j(){}
		private function showColors(e:MouseEvent):void
		{
			removeLastControl();
			initTemplateColors();
			control.colorBox.alpha = 0;
			TweenLite.to(control.colorBox, .5, { alpha:1 } );
			control.colorBox.y = 60;
			currentControl = control.colorBox;
			
			control.tabHiliter.alpha = 1;
			control.tabHiliter.x = 337;
			control.tabHiliter.width = 144;
			control.tabArrow.x = 405;
		}
		
		
		private function initTemplateColors():void
		{
			control.colorBox.c1.myColor = 0x181818;
			control.colorBox.c1.alpha = 0;
			control.colorBox.c1.buttonMode = true;
			control.colorBox.c1.addEventListener(MouseEvent.CLICK, colorClicked, false, 0, true);
			
			control.colorBox.c2.myColor = 0x6b6b6b;
			control.colorBox.c2.alpha = 0;
			control.colorBox.c2.buttonMode = true;
			control.colorBox.c2.addEventListener(MouseEvent.CLICK, colorClicked, false, 0, true);
			
			control.colorBox.c3.myColor = 0xab2627;
			control.colorBox.c3.alpha = 0;
			control.colorBox.c3.buttonMode = true;
			control.colorBox.c3.addEventListener(MouseEvent.CLICK, colorClicked, false, 0, true);
			
			control.colorBox.c4.myColor = 0x153f67;
			control.colorBox.c4.alpha = 0;
			control.colorBox.c4.buttonMode = true;
			control.colorBox.c4.addEventListener(MouseEvent.CLICK, colorClicked, false, 0, true);
			
			//color picker
			control.colorBox.c5.alpha = 0;
			control.colorBox.c5.buttonMode = true;
			control.colorBox.c5.addEventListener(MouseEvent.CLICK, colorPickerClicked, false, 0, true);
		}
		
		private function colorClicked(e:MouseEvent):void
		{
			tintInterface(e.currentTarget.myColor);
		}
		
		private function colorPickerClicked(e:MouseEvent):void
		{
			cardData.draw(theCard, null, null, null, new Rectangle(24, 96, 498, 288)); //draw just the car image into cardData
			addEventListener(Event.ENTER_FRAME, showPickColor, false, 0, true);
			
			Mouse.hide();
			addChild(paintCan);
			paintCan.startDrag(true);
			paintCan.mouseEnabled = false;
			paintCan.mouseChildren = false;
			
			theCard.addEventListener(MouseEvent.CLICK, chooseCustomColor, false, 0, true);
		}
		
		private function showPickColor(e:Event):void
		{			
			currentPickColor = cardData.getPixel(theCard.mouseX, theCard.mouseY);
			tintInterface(currentPickColor);
		}
		
		private function chooseCustomColor(e:MouseEvent):void
		{
			tintInterface(currentPickColor);			
			removeEventListener(Event.ENTER_FRAME, showPickColor);
			theCard.removeEventListener(MouseEvent.CLICK, chooseCustomColor);
			removePaintCan();
		}
		
		private function tintInterface(newTint:Number):void
		{
			TweenLite.to(theCard.colorLayer, .5, { tint:newTint } );
			TweenLite.to(control.colorBox.customColor, .5, { tint:newTint } );
			TweenLite.to(paintCan.theColor, .5, { tint:newTint } );
		}
		
		
		
		
		
		//*******      TEMPLATES
		private function k(){}
		private function showThemes(e:MouseEvent):void
		{
			removeLastControl();
			control.templateBox.alpha = 0;
			TweenLite.to(control.templateBox, .5, { alpha:1 } );
			control.templateBox.y = 60;
			currentControl = control.templateBox;
			
			control.templateBox.t1.addEventListener(MouseEvent.CLICK, showTemplate1, false, 0, true);
			control.templateBox.t1.buttonMode = true;
			control.templateBox.t2.addEventListener(MouseEvent.CLICK, showTemplate2, false, 0, true);
			control.templateBox.t2.buttonMode = true;
			control.templateBox.t3.addEventListener(MouseEvent.CLICK, showTemplate3, false, 0, true);
			control.templateBox.t3.buttonMode = true;
			
			control.tabHiliter.alpha = 1;
			control.tabHiliter.x = 197;
			control.tabHiliter.width = 119;
			control.tabArrow.x = 260;
		}
		
		
		private function showTemplate1(e:MouseEvent = null):void
		{
			control.templateBox.t1.gotoAndStop(2);
			control.templateBox.t2.gotoAndStop(1);
			control.templateBox.t3.gotoAndStop(1);
			swapBorder(1);
		}
		
		
		private function showTemplate2(e:MouseEvent = null):void
		{
			control.templateBox.t2.gotoAndStop(2);
			control.templateBox.t1.gotoAndStop(1);
			control.templateBox.t3.gotoAndStop(1);
			swapBorder(2);
		}
		
		
		private function showTemplate3(e:MouseEvent = null):void
		{
			control.templateBox.t3.gotoAndStop(2);
			control.templateBox.t1.gotoAndStop(1);
			control.templateBox.t2.gotoAndStop(1);
			swapBorder(3);
		}
		
		
		private function swapBorder(whichBorder:int):void
		{
			if(border){
				if(theCard.contains(border)){
					theCard.removeChild(border);
				}
			}
			
			curTemplate = whichBorder;
			
			switch(whichBorder) {
				case 1:
					border = new border1(); //lib clip					
					break;
				case 2:
					border = new border2();
					break;
				case 3:
					border = new border3();
					break;
			}
			
			border.x = 2;
			border.y = 81;
			
			border.theMask.alpha = 0;
			
			border.mouseEnabled = false;
			
			carContainer.mask = border.theMask;
			
			theCard.addChildAt(border, theCard.numChildren - 3);
			
			//make sure the text is always on top
			theCard.setChildIndex(cardTxt, theCard.numChildren - 1);
			
			updateCardFeatures();
		}
		
		
		
		
		
		
		
		// ************** STICKERS
		private function l(){}
		private function showStickers(e:MouseEvent):void
		{
			removeLastControl();
			addStickerHandlers();
			control.stickerBox.alpha = 0;
			TweenLite.to(control.stickerBox, .5, { alpha:1 } );
			control.stickerBox.y = 60;
			currentControl = control.stickerBox;
			
			control.tabHiliter.alpha = 1;
			control.tabHiliter.x = 501;
			control.tabHiliter.width = 137;
			control.tabArrow.x = 572;
		}
		
		private function addStickerHandlers():void
		{
			for (var i:int = 0; i < stickerList.length; i++) {
				stickerList[i].buttonMode = true;
				Bitmap(stickerList[i].getChildAt(0)).smoothing = true;
				stickerList[i].addEventListener(MouseEvent.CLICK, addSticker, false, 0, true);
				stickerList[i].addEventListener(MouseEvent.MOUSE_OVER, expandSticker, false, 0, true);
				stickerList[i].addEventListener(MouseEvent.MOUSE_OUT, contractSticker, false, 0, true);
			}
		}
		
		private function removeStickerHandlers():void
		{
			for (var i:int = 0; i < stickerList.length; i++) {
				stickerList[i].removeEventListener(MouseEvent.CLICK, addSticker);
				stickerList[i].removeEventListener(MouseEvent.MOUSE_OVER, expandSticker);
				stickerList[i].removeEventListener(MouseEvent.MOUSE_OUT, contractSticker);
			}
		}
		
		private function addSticker(e:MouseEvent):void
		{	
			var CD:Class;
			var stick:MovieClip;
			
			//make bad ass bigger = s1_2 in the lib
			if (e.currentTarget.name == "s1") {
				stick = new s1_2();
			}else {
				CD = Class(getDefinitionByName(e.currentTarget.name));
				stick = new CD();
			}			
			
			Bitmap(stick.getChildAt(0)).smoothing = true;
			
			stick.filters = [stickerShadow];
			stickerContainer.addChild(stick);
			
			stick.x = theCard["s" + (stickerNumber % 16)].x; 
			stick.y = theCard["s" + (stickerNumber % 16)].y;
			
			stick.buttonMode = true;
			stick.addEventListener(MouseEvent.MOUSE_DOWN, startStickerDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, endStickerDrag, false, 0, true);			
				
			stickerNumber++;
		}
		
		private function startStickerDrag(e:MouseEvent):void
		{			
			curSticker = MovieClip(e.currentTarget);
			stickerContainer.setChildIndex(curSticker, stickerContainer.numChildren - 1);
			curSticker.startDrag();
		}
		private function endStickerDrag(e:MouseEvent):void
		{
			stopDrag();
			
			var buff:int = 15;
			
			//remove sticker if it's dropped out of the card bounds
			if (curSticker) {
				
				//make sure stickers land on whole pixels
				curSticker.x = Math.floor(curSticker.x);
				curSticker.y = Math.floor(curSticker.y);
				
				if (stickerContainer.contains(curSticker)) {					
					if ((curSticker.x - (curSticker.width / 2) + buff < 0) || (curSticker.x + (curSticker.width / 2) - buff > 720) || (curSticker.y - (curSticker.height / 2) + buff < 0) || (curSticker.y + (curSticker.height / 2) - buff > 570)) {
						stickerContainer.removeChild(curSticker);
						curSticker.removeEventListener(MouseEvent.MOUSE_DOWN, startStickerDrag);
						curSticker = null;
					}
				}
			}			
		}
		
		
		/*
		private function killAnimateSticker():void
		{
			removeChild(animSticker);
			animSticker.scaleX = 1;
			animSticker.scaleY = 1;
			stickerContainer.addChild(animSticker);
			
			animSticker.x = theCard.s1.x; animSticker.y = theCard.s1.y;
			trace(animSticker.x, animSticker.y);
		}*/
		
		
		private function expandSticker(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { scaleX:1.1, scaleY:1.1 } );
		}
		
		private function contractSticker(e:MouseEvent):void
		{			
			TweenLite.to(e.currentTarget, .25, { scaleX:1, scaleY:1 } );
		}
		
		
		
		
		
		
		
		// ***************    PREVIEW
		private function m(){}
		private function showPreview(e:MouseEvent):void
		{
			if (!contains(preview)) {
				addChild(preview);				
			}
			preview.alpha = 1;
			preview.btnClose.redArrow.alpha = 0;
			//preview.y = 60;
			
			preview.progress.alpha = 0;
			preview.progress.mouseEnabled = false;
			preview.progress.mouseChildren = false;
			
			preview.btnClose.buttonMode = true;
			preview.btnSave.buttonMode = true;
			
			preview.btnClose.addEventListener(MouseEvent.CLICK, closePreview, false, 0, true);
			preview.btnClose.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			preview.btnClose.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			
			preview.btnSave.addEventListener(MouseEvent.CLICK, saveCard, false, 0, true);
			preview.btnSave.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			preview.btnSave.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);
			
			//turn smoothing off for all stickers in the card
			var c:int = stickerContainer.numChildren;
			var m:MovieClip;
			for (var i:int = 0; i < c; i++) {
				m = MovieClip(stickerContainer.getChildAt(i));
				Bitmap(m.getChildAt(0)).smoothing = false;
			}
			
			cardData.draw(theCard);
			if(!preview.contains(cardBMP)){
				preview.addChild(cardBMP);
			}
			cardBMP.x = 15;
			cardBMP.y = 92;
			
			showAlmostDone(false);				
		}
		
		
		private function showAlmostDone(begin:Boolean = true):void
		{
			addChild(almostDoneDialog);
			almostDoneDialog.x = 109;			
			if (begin) {
				almostDoneDialog.y = 165;
				almostDoneDialog.beginText.alpha = 1;
				almostDoneDialog.bottomArrow.alpha = 1;
				almostDoneDialog.endText.alpha = 0 ;
				almostDoneDialog.topArrow.alpha = 0;
			}else {
				almostDoneDialog.y = 195;
				almostDoneDialog.beginText.alpha = 0;
				almostDoneDialog.bottomArrow.alpha = 0;
				almostDoneDialog.endText.alpha = 1 ;
				almostDoneDialog.topArrow.alpha = 1;
			}
			
			
			
			almostDoneDialog.btnClose.redArrow.alpha = 0;
			TweenLite.to(almostDoneDialog, .5, { alpha:1 } );
			almostDoneDialog.btnClose.buttonMode = true;
			almostDoneDialog.btnClose.addEventListener(MouseEvent.CLICK, closeAlmostDoneDialog, false, 0, true);
			almostDoneDialog.btnClose.addEventListener(MouseEvent.MOUSE_OVER, showS1Glow, false, 0, true);
			almostDoneDialog.btnClose.addEventListener(MouseEvent.MOUSE_OUT, hideS1Glow, false, 0, true);		
		}
		
		
		private function closeAlmostDoneDialog(e:MouseEvent = null):void
		{
			almostDoneDialog.btnClose.removeEventListener(MouseEvent.CLICK, closeAlmostDoneDialog);
			almostDoneDialog.btnClose.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			almostDoneDialog.btnClose.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			TweenLite.to(almostDoneDialog, 1, { alpha:0, onComplete:killAlmostDoneDialog } );
		}
		
		
		private function killAlmostDoneDialog():void
		{
			if(contains(almostDoneDialog)){
				removeChild(almostDoneDialog);
			}
		}
		
		
		private function closePreview(e:MouseEvent = null):void
		{			
			//turn smoothing on for all stickers in the card
			var c:int = stickerContainer.numChildren;
			var m:MovieClip;
			for (var i:int = 0; i < c; i++) {
				m = MovieClip(stickerContainer.getChildAt(i));
				Bitmap(m.getChildAt(0)).smoothing = true;
			}
			
			
			
			preview.btnClose.removeEventListener(MouseEvent.CLICK, closePreview);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			preview.btnClose.removeEventListener(MouseEvent.CLICK, closePreview);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			closeAlmostDoneDialog();
			TweenLite.to(preview, 1, { alpha:0, onComplete:killPreview } );
		}
		
		
		private function killPreview():void
		{			
			removeChild(preview);
		}
		
		
		private function saveCard(e:MouseEvent):void
		{		
			preview.btnClose.removeEventListener(MouseEvent.CLICK, closePreview);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			preview.btnClose.removeEventListener(MouseEvent.CLICK, closePreview);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			preview.btnClose.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			preview.btnSave.redArrow.alpha = 0;
			closeAlmostDoneDialog();
			
			TweenLite.to(preview.progress, .5, { alpha:1, onComplete:doSave } );
			TweenLite.to(preview.btnClose, .5, { alpha:0 } );
		}
		
		private function doSave():void
		{			
			
			var thumb:BitmapData = new BitmapData(180, 142, false);
			var m:Matrix = new Matrix();
			m.scale(180/theCard.width, 142/theCard.height);
			thumb.draw(theCard, m);
			
			//addChild(new Bitmap(thumb));
			
			var thumbBA:ByteArray = cardImage.getJpeg(thumb, 72);
			var thumbEnc:String = cardImage.getBase64(thumbBA);
			
			var ba:ByteArray = cardImage.getJpeg(cardData, 80);
			var enc:String = cardImage.getBase64(ba);
			
			cardImage.addEventListener(CardImage.DID_NOT_POST, postError, false, 0, true);
			cardImage.addEventListener(CardImage.DID_POST, postSuccess, false, 0, true);
			
			userData.fb_uid = facebookID;
			cardImage.postImage(enc, thumbEnc, userData);
		}
			
		
		private function postError(e:Event):void
		{			
			trace("post failed");
		}
		
		
		private function postSuccess(e:Event):void
		{
			var response:String = cardImage.getResponse();
			navigateToURL(new URLRequest("ShareCard.aspx?id=" + response + "&fullname=" + userData.firstName + "%20" + userData.lastName + "&email=" + userData.email), "_self");
			//closePreview();
		}
		
		
		
		private function removePaintCan():void
		{
			if (paintCan) {
				if (contains(paintCan)) {
					removeChild(paintCan);
					Mouse.show();
				}
			}
		}
		
		private function removeLastControl():void
		{
			removePaintCan();
			
			if (currentControl != null) {
				currentControl.y = 450;
			}
			
			control.infoBox.btnUpdate.removeEventListener(MouseEvent.CLICK, updateInfo);
			control.infoBox.btnUpdate.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			control.infoBox.btnUpdate.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			control.imageBox.btnReset.removeEventListener(MouseEvent.CLICK, resetImage);
			control.imageBox.btnReset.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			control.imageBox.btnReset.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			control.infoBox.btnEdit.removeEventListener(MouseEvent.CLICK, editForm);
			control.infoBox.btnEdit.removeEventListener(MouseEvent.MOUSE_OVER, showS1Glow);
			control.infoBox.btnEdit.removeEventListener(MouseEvent.MOUSE_OUT, hideS1Glow);
			
			featureSlider.removeEventListener(FeatureSlider.DRAGGING, updateFeaturePositions);
			
			removeEventListener(Event.ENTER_FRAME, showPickColor);
			theCard.removeEventListener(MouseEvent.CLICK, chooseCustomColor);
			zoomSlider.removeEventListener(GenericSlider.DRAGGING, updateImageScale);
			//stage.removeEventListener(MouseEvent.MOUSE_UP, endStickerDrag);
			removeStickerHandlers();
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopMoving);
		}
		
		
		
	}	
}