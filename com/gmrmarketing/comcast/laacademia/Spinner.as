package com.gmrmarketing.comcast.laacademia
{	
	import flash.display.StageDisplayState;
	
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
	
	import com.gmrmarketing.kiosk.KioskHelper;
	import com.gmrmarketing.kiosk.KioskEvent;
	
	
	
	public class Spinner extends MovieClip
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
		private var pointer:thePointer; //lib clip
		
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
		
		
		private var offset:Number;
		private var initAngle:Number;
		private var initTime:int;
		//private var perFrame:Number;
		private var lastDragTime:int;
		
		private var lastPegNumber:int;
		private var soundPeg:int;
		
		private var waitToReboundCounter:int = 0;
		
		private var dialog:theDialog; //lib clip		
		
		private var totalRotation:Number; //accumulated rotation - used to know if the spinner made a complete revolution
		
		private var clickSound:click = new click(); //peg click sound
		
		private var particles:Array;
		private var particleTimer:Timer;
		private var particleContainer:Sprite;
	
		private var timeoutTimer:Timer;
		
		private var normalFriction:Number;
		private var pointerFriction:Number;
		
		private var pegAngles:Array;
		private var textAngles:Array;
		
		private var language:String;
		//private var intText:introText; //lib clip - touch screen text at very start
		
		private var did360:Boolean = false;
		private var icon:MovieClip = new MovieClip(); //tv.net,phone icon in the congrats dialog box - uses dialogShadow
		
		
		
		/**
		 * CONSTRUCTOR
		 */
		public function Spinner()
		{
			mySpinner = new Sprite();
			
			dialog = new theDialog(); //lib clip
			dialog.x = 238;
			dialog.y = 156;
			
			xmlLoader = new URLLoader();
			imageLoader = new Loader();
			logoLoader = new Loader();
			
			//intText = new introText();
			//intText.x = 206;
			//intText.y = 297;
			
			spinnerShadow = new DropShadowFilter(8, 45, 0x000000, .8, 8, 8, 1, 2, false, false, false);
			prizeShadow = new DropShadowFilter(0, 0, 0x000000, .8, 5, 5, 1, 2, false, false, false);
			handShadow = new DropShadowFilter(6, 45, 0x000000, .8, 8, 8, 1, 2, false, false, false);
			dialogShadow = new DropShadowFilter(0, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			winTextShadow = new DropShadowFilter(0, 0, 0x000000, .8, 6, 6, 1, 2, false, false, false);
			
			timeoutTimer = new Timer(15000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, pokeFinger, false, 0, true);
			
			xmlLoader.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			xmlLoader.load(new URLRequest("spinner_config.xml"));
		}
		
		
		public function setLanguage(l:String):void
		{
			language = l;
		}
		
		
		private function configLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, configLoaded);			
			config = new XML(e.target.data);
			
			normalFriction = parseFloat(config.normalFriction);
			pointerFriction = parseFloat(config.pointerFriction);
			
			if (config.showMousePointer == "false") {
				Mouse.hide();
			}
			
			bgLoaded();
			//load background image
			//bgImage = new Loader();
			//bgImage.load(new URLRequest(config.backgroundImage));
			//bgImage.contentLoaderInfo.addEventListener(Event.COMPLETE, bgLoaded, false, 0, true);
		}
	
		
		private function bgLoaded(e:Event = null):void
		{
			/*
			var bit:Bitmap = e.target.content;
			if(bit != null){
				bit.smoothing = true;
			}
			
			addChild(bgImage);
			bgImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, bgLoaded);			
			*/
			
			//load spinner
			imageLoader.load(new URLRequest(config.spinnerImage));
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, spinnerLoaded, false, 0, true);
		}
		
		
		
		private function spinnerLoaded(e:Event):void
		{
			imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, spinnerLoaded);
			
			//load dialog image
			//dialogLoader = new Loader();
			//dialogLoader.load(new URLRequest(config.dialogImage));
			//dialogLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, dialogLoaded, false, 0, true);
			
			//load center logo
			if(config.spinnerCenter != ""){
				logoLoader = new Loader();
				logoLoader.load(new URLRequest(config.spinnerCenter));
				logoLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, logoLoaded, false, 0, true);
			}
			
			//smooth spinner
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
			spinnerPress.width = spinnerPress.height = imageLoader.width;
			spinnerPress.alpha = 0;
			spinnerPress.x = -spinnerRadius;
			spinnerPress.y = -spinnerRadius;
			
			pointer = new thePointer(); //lib clip	
			pointer.x = parseInt(config.pointerLocation.@x);
			pointer.y = parseInt(config.pointerLocation.@y);
			
			//collision detection kit init
			cList = new CollisionList(pointer.fingBottom);
			cList.alphaThreshold = 0;
			
			computeAngles();
			addPegs();
			//addTextFields();			
			
			mySpinner.addChild(spinnerPress);
			
			addChild(mySpinner);
			mySpinner.x = parseInt(config.spinnerImage.@xLoc);
			mySpinner.y = parseInt(config.spinnerImage.@yLoc);
			
			addChild(pointer);
			if(config.handShadow == "true"){
				pointer.filters = [handShadow];
			}
			
			dragListen();	
		}
		
		
		private function quitGame(e:KioskEvent):void
		{
			//fscommand("quit");			
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
		
		
		/*
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
			dialText.theText.autoSize = TextFieldAutoSize.LEFT;
			dialog.addChild(dialText); //library clip
			dialText.x = 10;
			if (config.winTextShadow == "true") {
				dialText.filters = [winTextShadow];
			}	
			
			dialog.x = Math.floor((stage.stageWidth - dialog.width) * .5);
			dialog.y = Math.floor((stage.stageHeight - dialog.height) * .5);
		}
		*/
		
		
		//private function showDialog(message:String, col:Number = 0xFFFFFF):void
		private function showDialog(theIcon:String, col:Number = 0xFFFFFF):void
		{		
			if (dialog.contains(icon)) {
				dialog.removeChild(icon);
			}
			
			switch(theIcon) {
				case "tv":
					icon = new icon_tv();
					icon.y = 172;
					break;
				case "phone":
					icon = new icon_phone();
					icon.y = 172;
					break;
				case "net":
					icon = new icon_net();
					icon.y = 172;
					break;
				case "all":
					icon = new icon_all();
					icon.y = 214;
					break;
			}
			dialog.addChild(icon);
			icon.x = 491;
			
			
			dialog.alpha = 0;
			dialog.startButton.alpha = 0;
			addChild(dialog);			
			dialog.theText.autoSize = TextFieldAutoSize.LEFT;
			
			if(did360){
				if(language == "en"){
					dialog.theText.text = "Congratulations you've won";
					dialog.theCategory.text = "Category:";
				}else {
					dialog.theText.text = "Felicidades, ¡ganaste!";
					dialog.theCategory.text = "Categoría:";
				}
			}else {
				dialog.theCategory.text = "";
				if(language == "en"){					
					dialog.theText.htmlText = "The wheel did not make a complete turn.<br/>Please try again.";
				}else {
					dialog.theText.htmlText = "No se completo una<br/>revolucion de ruleta<br/>Por favor intente de nuevo.";
				}
			}
			
			//dialText.y = Math.floor((dialogLoader.height - dialText.theText.textHeight) * .5);
			
					
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
		 * Computes the angles, in radians, for the pegs and text fields
		 * based on the slice data in the xml
		 */
		private function computeAngles():void
		{
			pegAngles = new Array();
			pegAngles.push(0);
			textAngles = new Array();
			
			var slices:XMLList = config.prizes.slice;
			var numSlices:int = slices.length();		
			
			var curAng:Number = 0;			
			var accum:Number = 0;			
			
			for (var i:int = 0; i < numSlices; i++) {				
				curAng = parseInt(slices[i].@angle) / (180 / Math.PI); //radians				
				accum += curAng;				
				
				pegAngles.push(accum);
			}
			
			for (i = 1; i < pegAngles.length; i++) {
				var diff:Number = pegAngles[i] - pegAngles[i - 1];
				var half:Number = diff * .5;
				textAngles.push(half + pegAngles[i - 1]);
			}
			pegAngles.shift(); //remove the 0
		}
		
		
		/**
		 * Adds 'pegs' around the perimiter of the spinner
		 * Each peg is added to the collision list for checking against while rotating
		 */
		private function addPegs():void
		{
			var slices:XMLList = config.prizes.slice;
			
			for (var i:int = 0; i < pegAngles.length; i++) {				
				
				var pegLoc:Point = new Point(Math.cos(pegAngles[i]) * spinnerRadius, Math.sin(pegAngles[i]) * spinnerRadius);
				var aPeg:peg = new peg(); //lib clip
				aPeg.index = i + 1;				
				mySpinner.addChild(aPeg);
				aPeg.alpha = .01;
				aPeg.x = pegLoc.x;
				aPeg.y = pegLoc.y;
				cList.addItem(aPeg); //add each peg to collision list - checked in pegCheck()
			}
		}
		
		
		
		/**
		 * Adds the prize text to the spinner		 
		 */
		private function addTextFields():void
		{	
			prizes = config.prizes;			
			
			var edgeBuffer:int = parseInt(config.prizes.@textEdgeBuffer);
			
			for (var i:int = 0; i < textAngles.length; i++) {
				
				var tFormat:TextFormat = new TextFormat();
				tFormat.color = Number("0x" + prizes.slice[i].prizeText.@color);
				
				var tLoc:Point = new Point(Math.cos(textAngles[i]) * (spinnerRadius - edgeBuffer), Math.sin(textAngles[i]) * (spinnerRadius - edgeBuffer));
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
				
				aField.rotation = (textAngles[i] * (180 / Math.PI)) - 180; //degrees
				aField.rotation += parseInt(prizes.slice[i].prizeText.@addAngle);
				
				if(config.prizeTextShadow == "true"){
					aField.filters = [prizeShadow];
				}
				mySpinner.addChild(aField);				
				
			}
		}
		
		
		/**
		 * Called by clicking on the spinner donut - outside portion of spinner
		 * @param	e
		 */
		private function startDragRotation(e:MouseEvent):void
		{
			//hide intro text
			/*
			if (contains(intText)) {
				TweenMax.to(intText, 1, { alpha:0, onComplete:removeIntroText } );				
			}			
			*/
			
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
		 * Called by TweenMax once the text has faded out
		 */
		/*
		private function removeIntroText():void
		{
			removeChild(intText);
		}
		*/
		
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
				//if (lastPegNumber == 7) {
					//prizeSlice = lastPegNumber - 1;//  parseInt(config.numberOfSlices);
				//}else{
					prizeSlice = lastPegNumber - 1;
				//}
			}else {
				if (lastPegNumber == 7) {
					prizeSlice = 0;
				}else{
					prizeSlice = lastPegNumber;
				}
			}		
			
			//trace(rotationPerFrame, Math.abs(rotationPerFrame));
			if (Math.abs(rotationPerFrame) < .03) {
				removeEventListener(Event.ENTER_FRAME, doRotate);
				if(totalRotation > 360){
					did360 = true;
					showDialog(config.prizes.slice[prizeSlice].icon, Number("0x" + config.prizes.slice[prizeSlice - 1].winText.@color));
					//showDialog(config.prizes.slice[prizeSlice - 1].winText, Number("0x" + config.prizes.slice[prizeSlice - 1].winText.@color));
				}else {	
					did360 = false;
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
					//trace(lastPegNumber);
					
					/*
					if (lastPegNumber != soundPeg) {
						//var chan:SoundChannel = clickSound.play();
						soundPeg = lastPegNumber;
					}
					*/
					
					if(colArray[0].angle > 0){
						TweenMax.to(pointer, .2, { rotation:pointer.rotation + 6 } );
					}else {
						TweenMax.to(pointer, .2, { rotation:pointer.rotation - 6 } );
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
			
			TweenMax.to(mySpinner, 2, { rotation:0, ease:Bounce.easeOut, onComplete:spinDone } );
			TweenMax.to(pointer, .25, { rotation: 0 } );
		}
		
		
		private function spinDone():void
		{			
			if (did360) {
				//dragListen();
				dispatchEvent(new Event("continueButtonClicked"));
			}else {
				dragListen();
			}
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
		 * Called from spinnerLoaded()
		 */
		private function dragListen():void
		{
			//trace("dragListen");
			
			if (!contains(dialog)) {
				//trace("addingDialog");
				addChild(dialog);
			}
			dialog.alpha = 0;
			if (dialog.contains(icon)) { dialog.removeChild(icon); }
			dialog.startButton.alpha = 1;
			
			dialog.theText.autoSize = TextFieldAutoSize.LEFT;
			
			if (language == "en") {
				dialog.theText.text = "Touch your finger anywhere on the prize wheel and drag it to spin";
				dialog.startButton.theText.text = "START GAME";
			}else {
				dialog.theText.text = "Toca cualquier parte de la ruleta de premios con tu dedo y arrástrala para hacerla girar";
				dialog.startButton.theText.text = "INICIAR JUEGO";
			}
			dialog.theCategory.text = "";
			TweenMax.to(dialog, 1, { alpha:1 } );
			
			/**
			//show intro text
			if (!contains(intText)) {
				addChild(intText);
			}
			intText.alpha = 0;
			TweenMax.to(intText, 1, { alpha:1 } );
			
			if (language == "en") {
				intText.theText.text = "Touch your finger anywhere on the prize wheel and drag it to spin";
			}else {
				intText.theText.text = "Toca cualquier parte de la ruleta de premios con tu dedo y arrástrala para hacerla girar";
			}
			*/
			dialog.startButton.addEventListener(MouseEvent.CLICK, beginGame, false, 0, true);
		}
		
		private function beginGame(e:MouseEvent):void
		{
			hideDialog();
			
			dialog.startButton.removeEventListener(MouseEvent.CLICK, beginGame);
			
			spinnerPress.addEventListener(MouseEvent.MOUSE_DOWN, startDragRotation);
			stage.addEventListener(MouseEvent.MOUSE_UP, endDragRotation);
			
			timeoutTimer.reset();
			timeoutTimer.start();
		}
		
		
		public function stopGame():void
		{
			TweenMax.killAll();
			timeoutTimer.reset();
			removeEventListener(Event.ENTER_FRAME, doRotate);
		}
		
	}
	
}

