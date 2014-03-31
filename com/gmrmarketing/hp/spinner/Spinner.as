package com.gmrmarketing.hp.spinner
{
	import flash.filters.GlowFilter;
	import flash.display.StageDisplayState;
	import flash.desktop.NativeApplication;
	import flash.display.Screen;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.filters.DropShadowFilter;
	import flash.filters.BlurFilter;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	import flash.text.TextField;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import com.coreyoneil.collision.CollisionList;
	
	import flash.system.fscommand;
	import flash.ui.Mouse;
	
	import com.gmrmarketing.Particle;
	import com.sitedaniel.text.LoadFont;
	
	import com.gmrmarketing.kiosk.KioskHelper;
	import com.gmrmarketing.kiosk.KioskEvent;
	
	import com.gmrmarketing.hp.spinner.DefaultConfig; //the default XML - call static getConfig() to retrieve
	import com.gmrmarketing.utilities.AIRXML;
	
	
	public class Spinner extends Sprite
	{
		private var kioskHelper:KioskHelper;
		
		private var xmlLoader:URLLoader;
		private var config:XML;
		private var prizes:XMLList;
		
		private var bgImage:Loader;
		private var imageLoader:Loader;
		private var dialogLoader:Loader;
		private var logoLoader:Loader;
		
		private var mySpinner:Sprite;
		private var pointer:theHand; //lib clip
		
		private var initPoint:Point;
		//private var initTime:Number;
		private var spinStarted:Boolean = false;
		
		private var pegs:Array;
		private var rotationDirection:int;
		
		private var targetRotation:Number;
		private var rotationPerFrame:Number;
		private var degreesPerSlice:Number;
		
		private var cList:CollisionList;
		
		private var stopCheckingCollisionCounter:int = 0;
		
		private var spinnerRadius:Number; //set to 1/2 width of loader spinner image
		private var spinnerPress:MovieClip;
		
		private var spinnerShadow:DropShadowFilter;
		private var prizeShadow:DropShadowFilter;
		private var handShadow:DropShadowFilter;
		private var dialogShadow:DropShadowFilter;
		private var winTextShadow:DropShadowFilter;
		private var sparkle:GlowFilter;
		
		private var offset:Number;
		private var initAngle:Number;
		private var initTime:int;
		//private var perFrame:Number;
		private var lastDragTime:int;
		
		private var lastPegNumber:int;
		private var soundPeg:int;
		
		private var waitToReboundCounter:int = 0;
		
		private var dialog:Sprite; //container for the dialog box
		private var dialText:MovieClip; //lib clip
		
		private var totalRotation:Number; //accumulated rotation - used to know if the spinner made a complete revolution
		
		private var clickSound:click = new click(); //peg click sound
		
		private var particles:Array;
		private var particleTimer:Timer;
		private var particleContainer:Sprite;
		
		private var fontLoader:LoadFont; //used to load in the font defined in the fontPackage tag in the xml
		private var myFont:Font; //overall app font - set in fontLoaded
		
		private var timeoutTimer:Timer;
		
		private var normalFriction:Number;
		private var pointerFriction:Number;
		
		private var airXML:AIRXML = new AIRXML();
		private var configDialog:xmlConfigDialog; //lib clip
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Spinner()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;			
			
			kioskHelper = KioskHelper.getInstance();
			
			fontLoader = new LoadFont();
			
			mySpinner = new Sprite();
			dialog = new Sprite();
			
			configDialog = new xmlConfigDialog(); //lib clip
			
			particles = new Array();
			particleContainer = new Sprite();
			
			imageLoader = new Loader();
			logoLoader = new Loader();		
			
			spinnerShadow = new DropShadowFilter(8, 45, 0x000000, .8, 8, 8, 1, 2, false, false, false);
			prizeShadow = new DropShadowFilter(0, 0, 0x000000, .8, 5, 5, 1, 2, false, false, false);
			handShadow = new DropShadowFilter(6, 45, 0x000000, .8, 8, 8, 1, 2, false, false, false);
			dialogShadow = new DropShadowFilter(0, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			winTextShadow = new DropShadowFilter(0, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			sparkle = new GlowFilter(0xFFFFFF, 1, 6, 6, 5, 2, false, false);
			
			timeoutTimer = new Timer(15000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, pokeFinger, false, 0, true);
			
			particleTimer = new Timer(100);
			particleTimer.addEventListener(TimerEvent.TIMER, emitter, false, 0, true);				
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkConfig, false, 0, true);
			
			getConfig();
		}
		
		
		private function getConfig():void
		{
			airXML.addEventListener(AIRXML.NOT_FOUND, useDefaultXML, false, 0, true);
			airXML.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			airXML.readXML();
		}
		
		private function configLoaded(e:Event):void
		{
			airXML.removeEventListener(Event.COMPLETE, configLoaded);			
			config = airXML.getXML();
			gotConfig();
		}
		
		
		private function useDefaultXML(e:Event):void
		{
			airXML.removeEventListener(AIRXML.NOT_FOUND, useDefaultXML);
			config = DefaultConfig.getConfig();
			gotConfig();
		}
		
		
		private function gotConfig():void
		{
			normalFriction = parseFloat(config.normalFriction);
			pointerFriction = parseFloat(config.pointerFriction);
			
			if (config.showMousePointer == "false") {
				Mouse.hide();
			}
			
			//load font package
			fontLoader.load(config.fontPackage);
			fontLoader.addEventListener(Event.COMPLETE, fontLoaded, false, 0, true);
		}
		
		
		private function checkConfig(e:KeyboardEvent):void
		{
			//Ctrl-Alt-C opens config dialog
			if (e.ctrlKey && e.altKey && e.keyCode == 67) {
				if (!contains(configDialog)) {
					addChild(configDialog);					
					configDialog.x = 10;
					configDialog.y = 10;
					configDialog.btnSave.addEventListener(MouseEvent.CLICK, saveConfig, false, 0, true);
					configDialog.btnClose.addEventListener(MouseEvent.CLICK, configClose, false, 0, true);
					Mouse.show();
					populateConfig();
				}
			}
		}
		
		
		private function populateConfig():void
		{		
			configDialog.bgimage.text = config.backgroundImage;
			configDialog.spinimage.text = config.spinnerImage;
			configDialog.centerimage.text = config.spinnerCenter;
			configDialog.dialogimage.text = config.dialogImage;
			configDialog.nfriction.text = config.normalFriction;
			configDialog.pfriction.text = config.pointerFriction;
			configDialog.dialogalpha.text = config.dialogAlpha;
			configDialog.spinx.text = config.spinnerImage.@xLoc;
			configDialog.spiny.text = config.spinnerImage.@yLoc;
			configDialog.pointx.text = config.pointerLocation.@x;
			configDialog.pointy.text = config.pointerLocation.@y;
			configDialog.fontpackage.text = config.fontPackage;
			configDialog.fontleading.text = config.fontPackage.@leading;
			
			configDialog.incompletetext.text = config.incompleteTurn;
			configDialog.incompletetextcolor.text = config.incompleteTurn.@color;
			
			configDialog.bgparticles.selected = config.bgParticles == "true";
			configDialog.showpointer.selected = config.showMousePointer == "true";
			configDialog.spinshadow.selected = config.spinnerShadow == "true";
			configDialog.pointshadow.selected = config.handShadow == "true";
			configDialog.prizeshadow.selected = config.prizeTextShadow == "true";
			configDialog.dialogshadow.selected = config.dialogShadow == "true";
			configDialog.wintextshadow.selected = config.winTextShadow == "true";			
		
			configDialog.numslices.text = config.numberOfSlices;
			configDialog.edgebuffer.text = config.prizes.@textEdgeBuffer;
			
			//clear fields
			var i:int;
			for (i = 1; i < 13; i++) {
				configDialog["twoline" + i].selected = false;
				configDialog["angle" + i].text = "";
				configDialog["slicecolor" + i].text = "";
				configDialog["wincolor" + i].text = "";
				configDialog["slicetext" + i].text = "";
				configDialog["wintext" + i].text = "";
			}
			
			var prizeList:XMLList = config.prizes.slice;
			for (i = 0; i < prizeList.length(); i++) {
				configDialog["twoline" + (i + 1)].selected = prizeList[i].prizeText.@twoLine == "yes";
				configDialog["angle" + (i + 1)].text = prizeList[i].prizeText.@addAngle;
				configDialog["slicecolor" + (i + 1)].text = prizeList[i].prizeText.@color;
				configDialog["wincolor" + (i + 1)].text = prizeList[i].winText.@color;
				configDialog["slicetext" + (i + 1)].text = prizeList[i].prizeText;
				configDialog["wintext" + (i + 1)].text = prizeList[i].winText;
			}
			
		}
		
		
		private function configClose(e:MouseEvent = null):void
		{
			if (contains(configDialog)) {
				removeChild(configDialog);
			}
		}
		
		
		private function saveConfig(e:MouseEvent = null):void
		{
			config.backgroundImage = configDialog.bgimage.text;
			config.spinnerImage = configDialog.spinimage.text;
			config.spinnerCenter = configDialog.centerimage.text;
			config.dialogImage = configDialog.dialogimage.text;
			config.normalFriction = configDialog.nfriction.text;
			config.pointerFriction = configDialog.pfriction.text;
			config.dialogAlpha = configDialog.dialogalpha.text;
			config.spinnerImage.@xLoc = configDialog.spinx.text;
			config.spinnerImage.@yLoc = configDialog.spiny.text;
			config.pointerLocation.@x = configDialog.pointx.text;
			config.pointerLocation.@y = configDialog.pointy.text;
			config.fontPackage = configDialog.fontpackage.text;
			config.fontPackage.@leading = configDialog.fontleading.text;
			config.incompleteTurn = configDialog.incompletetext.text;
			config.incompleteTurn.@color = configDialog.incompletetextcolor.text;
			
			config.bgParticles = configDialog.bgparticles.selected ? "true" : "false";
			config.showMousePointer = configDialog.showpointer.selected ? "true" : "false";
			config.spinnerShadow = configDialog.spinshadow.selected ? "true" : "false";
			config.handShadow = configDialog.pointshadow.selected ? "true" : "false";
			config.prizeTextShadow = configDialog.prizeshadow.selected ? "true" : "false";
			config.dialogShadow = configDialog.dialogshadow.selected ? "true" : "false";
			config.winTextShadow = configDialog.wintextshadow.selected ? "true" : "false";
			
			config.numberOfSlices = configDialog.numslices.text;
			config.prizes.@textEdgeBuffer = configDialog.edgebuffer.text;
			
			//slices	
			for (var i:int = 0; i < 12; i++) {
				config.prizes.slice[i].prizeText.@twoLine = configDialog["twoline" + (i + 1)].selected ? "yes" : "no";
				config.prizes.slice[i].prizeText.@addAngle = configDialog["angle" + (i + 1)].text;
				config.prizes.slice[i].prizeText.@color = configDialog["slicecolor" + (i + 1)].text;
				config.prizes.slice[i].winText.@color = configDialog["wincolor" + (i + 1)].text;
				config.prizes.slice[i].prizeText = configDialog["slicetext" + (i + 1)].text;
				config.prizes.slice[i].winText = configDialog["wintext" + (i + 1)].text;
			}
		
			airXML.addEventListener(AIRXML.SAVED, configWasSaved, false, 0, true);
			airXML.writeXML(config);
		}
		
		private function configWasSaved(e:Event):void
		{			
			configClose();
			getConfig(); //reload to show changes
		}
		
		private function fontLoaded(e:Event):void
		{
			fontLoader.removeEventListener(Event.COMPLETE, fontLoaded);			
			myFont = fontLoader.getFont();
			
			//load background
			bgImage = new Loader();
			bgImage.load(new URLRequest(config.backgroundImage));
			bgImage.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaded, false, 0, true);
		}
		
		
		
		private function bgLoaded(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			addChild(bgImage);
			bgImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, bgLoaded);
			
			if(config.bgParticles == "true"){
				addChild(particleContainer);
				particleTimer.start(); //start calling emitter();
			}
			
			//load spinner
			imageLoader.load(new URLRequest(config.spinnerImage));
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, spinnerLoaded, false, 0, true);
		}
		
		
		
		private function spinnerLoaded(e:Event):void
		{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, spinnerLoaded);
			
			//load dialog image
			dialogLoader = new Loader();
			dialogLoader.load(new URLRequest(config.dialogImage));
			dialogLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dialogLoaded, false, 0, true);
			
			//load center logo
			if(config.spinnerCenter != ""){
				logoLoader = new Loader();
				logoLoader.load(new URLRequest(config.spinnerCenter));
				logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaded, false, 0, true);
			}
			
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			spinnerRadius = imageLoader.width * .5;			
			
			mySpinner.addChild(imageLoader);
			if(config.spinnerShadow == "true"){
				imageLoader.filters = [spinnerShadow];
			}
			imageLoader.x = -spinnerRadius;
			imageLoader.y = -spinnerRadius;
			
			spinnerPress = new pressDonut(); //lib clip
			
			spinnerPress.alpha = 0;
			spinnerPress.x = -spinnerRadius;
			spinnerPress.y = -spinnerRadius;
			
			pointer = new theHand();			
			pointer.x = parseInt(config.pointerLocation.@x);
			pointer.y = parseInt(config.pointerLocation.@y);
			
			cList = new CollisionList(pointer.fingBottom);
			cList.alphaThreshold = 0;
			
			addPegs(parseInt(config.numberOfSlices));
			addTextFields(parseInt(config.numberOfSlices));			
			
			mySpinner.addChild(spinnerPress);
			
			addChild(mySpinner);
			mySpinner.x = parseInt(config.spinnerImage.@xLoc);
			mySpinner.y = parseInt(config.spinnerImage.@yLoc);
			
			addChild(pointer);
			if(config.handShadow == "true"){
				pointer.filters = [handShadow];
			}		
			
			kioskHelper.eightCornerInit(stage, "ur", false , 1360, 768);
			kioskHelper.addEventListener(KioskEvent.EIGHT_CLICKS, quitGame, false, 0, true);
			
			dragListen();	
		}
		
		private function quitGame(e:KioskEvent):void
		{
			//fscommand("quit");
			NativeApplication.nativeApplication.exit(); //AIR
		}
		
		private function logoLoaded(e:Event):void
		{
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			logoLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, logoLoaded);
			addChild(logoLoader);
			logoLoader.filters = [dialogShadow];
			logoLoader.x = mySpinner.x - (logoLoader.width * .5);
			logoLoader.y = mySpinner.y - (logoLoader.height * .5);
		}
		
		
		
		private function dialogLoaded(e:Event):void
		{
			dialogLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, dialogLoaded);
			dialog.addChild(dialogLoader);
			if (config.dialogShadow == "true") {
				dialog.filters = [dialogShadow];
			}
			dialText = new dialogText(); //lib clip
			dialText.theText.text = "";	
			dialText.theText.width = dialog.width - 20;
			dialog.addChild(dialText); //library clip
			dialText.x = 10;
			if (config.winTextShadow == "true") {
				dialText.filters = [winTextShadow];
			}
			
			var screenBounds:Rectangle = stage.nativeWindow.bounds; //AIR
			trace(Screen.screens);
			
			dialog.x = Math.floor((screenBounds.width - dialog.width) * .5);
			dialog.y = Math.floor((screenBounds.height - dialog.height) * .5);
		}
		
		
		
		private function showDialog(message:String, col:Number = 0xFFFFFF):void
		{			
			addChild(dialog);			
			
			var tFormat:TextFormat = new TextFormat();
			tFormat.color = col;
			tFormat.font = myFont.fontName;
			tFormat.leading = parseInt(config.fontPackage.leading);
			dialText.theText.autoSize = TextFieldAutoSize.LEFT;
			dialText.theText.htmlText = message;
			dialText.theText.setTextFormat(tFormat);
			dialText.y = Math.floor((dialogLoader.height - dialText.theText.textHeight) * .5);
			dialog.alpha = 0;			
			TweenMax.to(dialog, .5, { alpha:parseFloat(config.dialogAlpha)} );
		}
		
		
		
		private function hideDialog(e:MouseEvent = null):void		
		{
			if(contains(dialog)){
				TweenMax.to(dialog, 1, { alpha:0, onComplete:removeDialog } );
			}
		}
		
		
		
		private function removeDialog():void
		{
			removeChild(dialog);
		}
		
		
		
		/**
		 * Adds 'pegs' around the perimiter of the spinner
		 * Each peg is added to the collision list for checking against while rotating
		 * 
		 * @param	numSlices
		 */
		private function addPegs(numSlices:int):void
		{
			//angle per slice in radians
			var anglePerSlice:Number = (2 * Math.PI) / numSlices;
			for (var i:int = 0; i < numSlices; i++) {
				var curAng:Number = i * anglePerSlice;
				var pegLoc:Point = new Point(Math.cos(curAng) * spinnerRadius, Math.sin(curAng) * spinnerRadius);
				var aPeg:peg = new peg(); //lib clip
				aPeg.index = i + 1;
				mySpinner.addChild(aPeg);
				aPeg.alpha = .01;
				aPeg.x = pegLoc.x;
				aPeg.y = pegLoc.y;
				cList.addItem(aPeg);
			}
		}
		
		
		
		/**
		 * Adds the prize text to the spinner
		 * @param	numSlices
		 */
		private function addTextFields(numSlices:int):void
		{
			prizes = config.prizes;
			//angle per slice in radians
			var radiansPerSlice:Number = (2 * Math.PI) / numSlices;
			var startAngle:Number = radiansPerSlice / 2; //half way into first slice
			var textAngle:Number = startAngle * (180 / Math.PI); //start angle in degrees
			degreesPerSlice = radiansPerSlice * (180 / Math.PI);
			
			var edgeBuffer:int = parseInt(config.prizes.@textEdgeBuffer);
			for (var i:int = 0; i < numSlices; i++) {
				
				var tFormat:TextFormat = new TextFormat();
				tFormat.color = Number("0x" + prizes.slice[i].prizeText.@color);
				tFormat.font = myFont.fontName;
				tFormat.leading = parseInt(config.fontPackage.leading);
				
				var curAng:Number = startAngle + (i * radiansPerSlice);
				var tLoc:Point = new Point(Math.cos(curAng) * (spinnerRadius - edgeBuffer), Math.sin(curAng) * (spinnerRadius - edgeBuffer));
				var aField:MovieClip;
				if(prizes.slice[i].prizeText.@twoLine == "yes"){
					aField = new tField2(); //lib clip
				}else {
					aField = new tField(); //lib clip
				}
				aField.theText.htmlText = prizes.slice[i].prizeText;
				aField.theText.setTextFormat(tFormat);
				aField.x = tLoc.x;
				aField.y = tLoc.y;
				aField.rotation = textAngle - 180;
				aField.rotation += parseInt(prizes.slice[i].prizeText.@addAngle);
				textAngle += degreesPerSlice;
				if(config.prizeTextShadow == "true"){
					aField.filters = [prizeShadow];
				}
				mySpinner.addChild(aField);
			}
		}
		
		
		
		private function emitter(e:TimerEvent):void
		{	
			var p:Particle = new Particle(new Point(Math.random() * stage.stageWidth, Math.random() * stage.stageHeight));
			p.filters = [sparkle];
			particles.push(p);
			p.addEventListener("killParticle", killPart, false, 0, true);
			particleContainer.addChild(p);			
		}
		
		
		
		private function killPart(e:Event):void
		{
			var t:int = particles.indexOf(e.target);
			particles[t].filters = [];
			particles[t].removeEventListener("killParticle", killPart);
			particleContainer.removeChild(particles[t]);
			particles.splice(t, 1);
		}
		
		
		
		/**
		 * Called by clicking on the spinner donut - outside portion of spinner
		 * @param	e
		 */
		private function startDragRotation(e:MouseEvent):void
		{
			timeoutTimer.stop();
			TweenMax.killTweensOf(pointer);
			TweenMax.to(pointer, .5, { x:parseInt(config.pointerLocation.@x) } );
			
			initTime = getTimer();
			var position:Number = Math.atan2(mouseY - mySpinner.y, mouseX - mySpinner.x);	
			var angle:Number = (position / Math.PI) * 180;
			initAngle = mySpinner.rotation;
			offset = mySpinner.rotation - angle;
			addEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);			
		}
		
		
		
		/**
		 * Called on enter frame as the spinner is dragged
		 * @param	e
		 */
		private function updateDragRotation(e:Event):void
		{
			lastDragTime = getTimer();
			var position:Number = Math.atan2(mouseY - mySpinner.y, mouseX - mySpinner.x);	
			mySpinner.rotation = (position / Math.PI) * 180 + offset;
		}
		
		
		
		/**
		 * Called on mouse up when spinner is dragging
		 * @param	e
		 */
		private function endDragRotation(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, updateDragRotation);
			var curTime:int = getTimer();
			var dLastDragTime = curTime - lastDragTime;
			var dAngle:Number = mySpinner.rotation - initAngle;	
			var dTime:int = curTime - initTime;
			if (dLastDragTime == 0) dLastDragTime = 1;
			rotationPerFrame = 40  * dAngle / dLastDragTime;	
			
			totalRotation = 0; //accumulated rotation - used to tell if wheel spins around at least once
			
			if(rotationPerFrame != 0 && !isNaN(rotationPerFrame)){
				addEventListener(Event.ENTER_FRAME, doRotate, false, 0, true);
				spinnerPress.removeEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
				stage.removeEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			}
		}
		
		
		
		/**
		 * Called by EnterFrame event
		 * @param	e
		 */
		private function doRotate(e:Event):void
		{
			mySpinner.rotation += rotationPerFrame;
			totalRotation += Math.abs(rotationPerFrame);
			
			pegCheck();
			
			var prizeSlice:int;
			
			if (rotationPerFrame > 0) {
				if (lastPegNumber == 1) {
					prizeSlice = parseInt(config.numberOfSlices);
				}else{
					prizeSlice = lastPegNumber - 1;
				}
			}else {
				prizeSlice = lastPegNumber;
			}		
			
			//trace(rotationPerFrame, Math.abs(rotationPerFrame));
			if (Math.abs(rotationPerFrame) < .03) {
				removeEventListener(Event.ENTER_FRAME, doRotate);
				if(totalRotation > 360){
					showDialog(config.prizes.slice[prizeSlice - 1].winText, Number("0x" + config.prizes.slice[prizeSlice - 1].winText.@color));
				}else {					
					showDialog(config.incompleteTurn, Number("0x" + config.incompleteTurn.@color));					
				}				
				
				stage.addEventListener(MouseEvent.CLICK, playAgain, false, 0, true);
			}
			
		}
		
		
		
		/**
		 * Called from doRotate
		 * Checks for collisions of the pegs against the pointer
		 */
		private function pegCheck():void
		{			
			var friction:Number = normalFriction;
			//stop collision cheking for n frames, if rotation is very small - to prevent spinner getting stuck in hand
			//when it's reversed for going to slow and bumping the pointer
			if(stopCheckingCollisionCounter == 0){
				//returns an array of objects - each object has properties:object1, object2, angle, overlapping
				var colArray:Array = cList.checkCollisions();
				
				if (colArray.length) {
					
					lastPegNumber = colArray[0].object1.index;
					
					if (lastPegNumber != soundPeg) {
						//var chan:SoundChannel = clickSound.play();
						soundPeg = lastPegNumber;
					}
					
					if(colArray[0].angle > 0){
						TweenMax.to(pointer, .2, { rotation:pointer.rotation + 3 } );
					}else {
						TweenMax.to(pointer, .2, { rotation:pointer.rotation - 3 } );
					}
					friction = pointerFriction;
					
					//if the speed is low when a peg hits, reverse the direction and stop checking
					//collisions to prevent getting stuck
					if (Math.abs(rotationPerFrame) < .4) {
						rotationPerFrame *= -1;
						stopCheckingCollisionCounter = 1;
					}
					
					waitToReboundCounter = 0;
					
				}else {
					//no collisions - colList is empty
					waitToReboundCounter++;
					if(waitToReboundCounter == 5){
						TweenMax.to(pointer, .3, { rotation:0 } );
					}
				}
			}else {
				stopCheckingCollisionCounter++;
				if (stopCheckingCollisionCounter == 60) {
					stopCheckingCollisionCounter = 0;
				}
			}
			
			//slow down a little quicker at end
			if (rotationPerFrame < .01 && friction != pointerFriction) { friction -= .02; }
			
			rotationPerFrame *= friction;
		}
		
	
		
		private function playAgain(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.CLICK, playAgain);
			
			hideDialog();
			
			TweenMax.to(mySpinner, 2, { rotation:0, ease:Bounce.easeOut, onComplete:dragListen } );
			TweenMax.to(pointer, .25, { rotation: 0 } );
		}
		
		/**
		 * Called from timeout timer
		 * @param	e
		 */
		private function pokeFinger(e:TimerEvent = null):void
		{
			TweenMax.to(pointer, .25, { x:"-50", delay:3, onComplete:pokeAgain});
		}
		private function pokeAgain():void
		{
			TweenMax.to(pointer, .25, { x:"50", onComplete:pokeFinger});
		}
		
		/**
		 * Called from spinnerLoaded() and playAgain()
		 */
		private function dragListen():void
		{
			spinnerPress.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			
			timeoutTimer.reset();
			timeoutTimer.start();
		}
		
	}
	
}

