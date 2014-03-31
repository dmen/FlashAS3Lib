package com.gmrmarketing.bicycle
{
	import flash.display.AVM1Movie;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;	
	import com.greensock.TweenMax;
	import fl.events.ColorPickerEvent;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;	
	import flash.utils.getDefinitionByName;
	import com.gmrmarketing.bicycle.Manipulator;
	import flash.filters.DropShadowFilter;	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;	
	import flash.system.fscommand; //for fullscreen
	import flash.printing.PrintJob;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	import com.gmrmarketing.bicycle.CardImage;
	import com.gmrmarketing.kiosk.KioskHelper;
	import com.gmrmarketing.kiosk.KioskEvent;

	public class Main extends MovieClip
	{		
		private const CARD_CENTER_X:int = 188;
		private const CARD_CENTER_Y:int = 260;
		
		private var defaultColor:Number = 0x333333;
		
		private var manip:Manipulator;
		private var cardMask:theMask; //lib clip
		
		private var hasBorder:Boolean = false; //set to true in borderClicked
		private var hasInitials:Boolean = false;
		
		private var border:MovieClip;
		private var initials:MovieClip;
		
		private var iconShadow:DropShadowFilter;
		
		private var dialog:Dialog; //lib clips
		private var keyboard:Keyboard;
		
		private var files:SWFKitFiles;
		private var cardImage:CardImage;
		
		private var uid:String; //unique ID for the current card
		private var cardWithID:BitmapData; //bitmap data of the card - needed if the print fails
		private var encoded:String; //base 64 encoded jpeg byteArray
		
		private var kioskHelper:KioskHelper;
		private var attractor:Loader;
		
		private var currentBGColor:Number = 0x333333;
		
		
		public function Main()
		{			
			fscommand("fullscreen", "true");
			
			files = new SWFKitFiles();
			cardImage = new CardImage();
			
			manip = new Manipulator();
			dialog = new Dialog();
			keyboard = new Keyboard();
			
			attractor = new Loader();
			attractor.load(new URLRequest("kioskIntroLoop.swf"));
			attractor.contentLoaderInfo.addEventListener(Event.COMPLETE, resetAttractor, false, 0, true);
			
			bgColor.setStyle("swatchWidth", 30); 
			bgColor.setStyle("swatchHeight", 30); 
			bgColor.setStyle("columnCount", 19);
			
			bgColor.addEventListener(ColorPickerEvent.CHANGE, cardBGChanged);
			
			var newColors:Array = [0x000000, 0x000000, 0x003300, 0x006600, 0x009900, 0x00CC00, 0x00ff00, 0x330000, 0x333300, 0x336600,
			0x339900, 0x33cc00, 0x33ff00, 0x660000, 0x663300, 0x666600, 0x669900, 0x66cc00, 0x66ff00, 0x333333, 0x000033, 0x003333, 
			0x006633, 0x009933, 0x00cc33, 0x00ff33, 0x330033, 0x333333, 0x336633, 0x339933, 0x33cc33, 0x33ff33, 0x660033, 0x663333, 0x666633, 
			0x669933, 0x66cc33, 0x66ff33, 0x666666, 0x000066, 0x003366, 0x006666, 0x009966, 0x00cc66, 0x00ff66, 0x330066, 0x333366, 0x336666, 
			0x339966, 0x33cc66, 0x33ff66, 0x660066, 0x663366, 0x666666, 0x669966, 0x66cc66, 0x66ff66, 0x999999, 0x000099, 0x003399, 0x006699, 
			0x009999, 0x00cc99,	0x00ff99, 0x330099, 0x333399, 0x336699, 0x339999, 0x33cc99, 0x33ff99, 0x660099, 0x663399, 0x666699, 0x669999, 
			0x66cc99, 0x66ff99, 0xcccccc, 0x0000cc, 0x0033cc, 0x0066cc, 0x0099cc, 0x00cccc, 0x00ffcc, 0x3300cc, 0x3333cc, 0x3366cc, 0x3399cc, 
			0x33cccc, 0x33ffcc, 0x6600cc, 0x6633cc, 0x6666cc, 0x6699cc, 0x66cccc, 0x66ffcc, 0xffffff, 0x0000ff, 0x0033ff, 0x0066ff, 0x0099ff, 
			0x00ccff, 0x00ffff, 0x3300ff, 0x3333ff, 0x3366ff, 0x3399ff, 0x33ccff, 0x33ffff, 0x6600ff, 0x6633ff, 0x6666ff, 0x6699ff, 0x66ccff, 
			0x66ffff, 0xff0000, 0x990000, 0x993300, 0x996600, 0x999900, 0x99cc00, 0x99ff00, 0xcc0000, 0xcc3300, 0xcc6600, 0xcc9900, 0xcccc00, 
			0xccff00, 0xff0000, 0xff3300, 0xff6600, 0xff9900, 0xffcc00,	0xffff00, 0x00ff00, 0x990033, 0x993333, 0x996633, 0x999933, 0x99cc33, 
			0x99ff33, 0xcc0033, 0xcc3333, 0xcc6633, 0xcc9933, 0xcccc33, 0xccff33, 0xff0033, 0xff3333, 0xff6633, 0xff9933, 0xffcc33, 0xffff33, 
			0x0000ff, 0x990066, 0x993366, 0x996666, 0x999966, 0x99cc66, 0x99ff66, 0xcc0066, 0xcc3366, 0xcc6666, 0xcc9966, 0xcccc66, 0xccff66, 
			0xff0066, 0xff3366, 0xff6666, 0xff9966, 0xffcc66, 0xffff66, 0xffff00, 0x990099, 0x993399, 0x996699, 0x999999, 0x99cc99, 0x99ff99, 
			0xcc0099, 0xcc3399, 0xcc6699, 0xcc9999, 0xcccc99, 0xccff99, 0xff0099, 0xff3399, 0xff6699, 0xff9999, 0xffcc99, 0xffff99, 0x00ffff, 
			0x9900cc, 0x9933cc, 0x9966cc, 0x9999cc, 0x99cccc, 0x99ffcc, 0xcc00cc, 0xcc33cc, 0xcc66cc, 0xcc99cc, 0xcccccc, 0xccffcc, 0xff00cc, 
			0xff33cc, 0xff66cc, 0xff99cc, 0xffcccc, 0xffffcc, 0xff00ff, 0x9900ff, 0x9933ff, 0x9966ff, 0x9999ff, 0x99ccff, 0x99ffff, 0xcc00ff, 
			0xcc33ff, 0xcc66ff, 0xcc99ff, 0xccccff, 0xccffff, 0xff00ff, 0xff33ff, 0xff66ff, 0xff99ff, 0xffccff, 0xffffff];
			
			bgColor.colors = newColors;
						
			iconShadow = new DropShadowFilter(0, 0, 0x000000, 1, 6, 6, 1, 2);
			
			addIcons();
			addBorders();
			addInitials();
			
			kioskHelper = KioskHelper.getInstance();
			kioskHelper.eightCornerInit(stage, "urlr", false , 1360, 768);
			kioskHelper.addEventListener(KioskEvent.EIGHT_CLICKS, quitGame, false, 0, true);
			kioskHelper.attractInit(stage, 90000);
			kioskHelper.addEventListener(KioskEvent.START_ATTRACT, startAttractLoop);
			kioskHelper.attractStart();
			
			borderDelete.addEventListener(MouseEvent.CLICK, removeBorder, false, 0, true);
			
			borderColor1.col = "0xA39161";
			borderColor2.col = "0xFFFFFF";
			borderColor3.col = "0x000000";			
			borderColor1.addEventListener(MouseEvent.CLICK, borderColor, false, 0, true);
			borderColor2.addEventListener(MouseEvent.CLICK, borderColor, false, 0, true);
			borderColor3.addEventListener(MouseEvent.CLICK, borderColor, false, 0, true);
			
			initColor1.col = "0xA39161";
			initColor2.col = "0xFFFFFF";
			initColor3.col = "0x000000";			
			initColor1.addEventListener(MouseEvent.CLICK, initColor, false, 0, true);
			initColor2.addEventListener(MouseEvent.CLICK, initColor, false, 0, true);
			initColor3.addEventListener(MouseEvent.CLICK, initColor, false, 0, true);
			
			stage.addEventListener(MouseEvent.CLICK, hideManipulator, false, 0, true);
			
			//cardMask.x = card.x;
			//cardMask.y = card.y;
			//card.mask = cardMask;
			card.mouseEnabled = false;
			//cardMask.mouseEnabled = false;
			
			btnReset.addEventListener(MouseEvent.CLICK, confirmReset, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, saveAndPrint, false, 0, true);
			editInitials.addEventListener(MouseEvent.CLICK, showKeyboard, false, 0, true);
			
			bgColor.selectedColor = 0x333333;
			
			
		}
		
		
		private function resetAttractor(e:Event = null):void
		{
			MovieClip(attractor.content).gotoAndStop(1);
		}
		
		
		private function startAttractLoop(e:KioskEvent = null):void
		{			
			addChild(attractor);
			MovieClip(attractor.content).play();
			resetConfirmed();
			kioskHelper.attractStop(); //stop listening
			MovieClip(attractor.content).addEventListener(MouseEvent.CLICK, killAttract, false, 0, true);
		}
		
		
		private function killAttract(e:MouseEvent):void
		{
			resetAttractor();
			MovieClip(attractor.content).cancel();//kills the timeout
			removeChild(attractor);
			//begin checking again
			kioskHelper.attractStart();
		}
		
		
		private function quitGame(e:KioskEvent):void
		{
			//trace("quit");
			fscommand("quit");
			//NativeApplication.nativeApplication.exit(); //AIR
		}
		
		
		
		private function addIcons():void
		{
			var icons:Array = new Array("icon_usflag", "icon_canada", "icon_club", "icon_heart", "icon_spade", "icon_diamond",
			"icon_cards", "icon_flames1", "icon_flames2", "icon_flames3", "icon_football", "icon_bball", "icon_soccer",
			"icon_pool", "icon_car1", "icon_car2", "icon_car3", "icon_copter1", "icon_copter2", "icon_copter3",
			"icon_butter1", "icon_butter2", "icon_butter3", "icon_flower1", "icon_flower2", "icon_flower3", "icon_flower4",
			"icon_design1", "icon_design2", "icon_design3");
			
			var startX:int = 54;
			var startY = 325;
			var buffer:int = 6;
			var iconSquare:int = 40;
			
			var loc:Array;
			
			for (var i:int = 0; i < icons.length; i++) {
				var ic:MovieClip = new MovieClip();
				var bg:iconBG = new iconBG();
				bg.width = bg.height = iconSquare;
				ic.addChild(bg);
				 
				var classRef:Class = getDefinitionByName(icons[i]) as Class;
				var instance:MovieClip = new classRef();
				instance.height = instance.width = 30;
				instance.x = instance.y = iconSquare * .5;
				ic.addChild(instance);
				
				loc = gridLoc(i + 1, 10);				
				
				ic.x = startX + ((loc[0] - 1) * (iconSquare + buffer));
				ic.y = startY + ((loc[1] - 1) * (iconSquare + buffer));
				ic.iconRef = classRef;				
				
				ic.filters = [iconShadow];
				addChild(ic);
				ic.addEventListener(MouseEvent.CLICK, iconClicked, false, 0, true);
			}			
		}
		
		
		/**
		 * Adds the border icons
		 */
		private function addBorders():void
		{
			var icons:Array = new Array("icon_border1", "icon_border2", "icon_border3", "icon_border4", "icon_border5");
			var startX:int = 54;
			var startY = 499;
			var buffer:int = 13;
			var iconSquare:int = 80;
			
			for (var i:int = 0; i < icons.length; i++) {
				var ic:MovieClip = new MovieClip();
				var bg:iconBG = new iconBG();
				bg.width = bg.height = iconSquare;
				ic.addChild(bg);
				 
				var classRef:Class = getDefinitionByName(icons[i]) as Class;
				var instance:MovieClip = new classRef();
				instance.height = instance.width = 70;
				instance.x = instance.y = 5;
				ic.addChild(instance);
				
				ic.x = startX;
				ic.y = startY;
				ic.iconRef = icons[i].substring(5); //get rid of icon_
				
				startX += iconSquare + buffer;
				
				ic.filters = [iconShadow];
				addChild(ic);
				
				ic.addEventListener(MouseEvent.CLICK, borderClicked, false, 0, true);
			}
		}
		
		
		
		private function addInitials():void
		{
			var icons:Array = new Array("inits0", "inits1", "inits2", "inits3", "inits4");
			var startX:int = 54;
			var startY = 632;
			var buffer:int = 13;
			var iconSquare:int = 80;
			
			for (var i:int = 0; i < icons.length; i++) {
				var ic:MovieClip = new MovieClip();
				var bg:iconBG = new iconBG();
				bg.width = bg.height = iconSquare;
				ic.addChild(bg);
				 
				var classRef:Class = getDefinitionByName(icons[i]) as Class;
				var instance:MovieClip = new classRef();
				instance.height = instance.width = 70;
				instance.x = instance.y = iconSquare * .5;
				ic.addChild(instance);
				
				ic.x = startX;
				ic.y = startY;
				ic.iconRef = classRef
				
				startX += iconSquare + buffer;
				
				ic.filters = [iconShadow];
				addChild(ic);
				
				ic.addEventListener(MouseEvent.CLICK, initialClicked, false, 0, true);
			}
		
		}
		
		
		
		
		/**
		 * Called by clicking an icon button
		 * Adds the icon to the card - calls bringToFront to insure the newly added icon
		 * comes in behind the border
		 * @param	e
		 */
		private function iconClicked(e:MouseEvent):void
		{
			var newIcon:MovieClip = new e.currentTarget.iconRef();
			card.addChild(newIcon);			
					
			bringToFront(newIcon); //makes sure new icons are added behind the border
			
			newIcon.x = CARD_CENTER_X;
			newIcon.y = CARD_CENTER_Y;
			newIcon.addEventListener(MouseEvent.MOUSE_DOWN, addManipulator, false, 0, true);
		}
		
		
		
		/**
		 * Called by clicking a border button
		 * Adds the specified border to the card
		 * @param	e
		 */
		private function borderClicked(e:MouseEvent):void
		{
			if (hasBorder) {
				removeBorder();
			}
			
			var classRef:Class = getDefinitionByName(e.currentTarget.iconRef) as Class;
			border = new classRef();
			
			//trace("border...", card.numChildren);
			card.addChild(border);
			border.x = 7;
			border.y = 7;
			border.width = 362;
			border.height = 538;
			border.mouseEnabled = false;
			
			hasBorder = true;
		}
		
		
		
		/**
		 * Called by clicking an initials button
		 * @param	e
		 */
		private function initialClicked(e:MouseEvent):void
		{
			if (hasInitials) {
				removeInitials();
			}
					
			initials = new e.currentTarget.iconRef();
			initials.isInitials = true; //used by manipulator when deleting
			card.addChild(initials);
			
			bringToFront(initials); //makes sure new icons are added behind the border
			
			initials.x = CARD_CENTER_X;
			initials.y = CARD_CENTER_Y;
			initials.addEventListener(MouseEvent.MOUSE_DOWN, addManipulator, false, 0, true);
			
			hasInitials = true;
			showKeyboard();
		}
		
		
		
		
		/**
		 * Called by clicking borderDelete button
		 * @param	e
		 */
		private function removeBorder(e:MouseEvent = null):void
		{
			if(border){
				if(card.contains(border)){
					card.removeChild(border);
					hasBorder = false;
				}
			}
		}
		
		
		
		/**
		 * Called by clicking on the border color buttons
		 * @param	e
		 */
		private function borderColor(e:MouseEvent):void
		{
			var newCol:Number = Number(e.currentTarget.col);
			if(border){
				if (card.contains(border)) {
					TweenMax.to(border, 1, { tint:newCol } );
				}
			}
		}
		
		
		
		/**
		 * Called by clicking on the initial color buttons
		 * @param	e
		 */
		private function initColor(e:MouseEvent):void
		{
			var newCol:Number = Number(e.currentTarget.col);
			if(initials){
				if (card.contains(initials)) {
					TweenMax.to(initials.theText, 1, { tint:newCol } );
					if(initials.theBorder){
						TweenMax.to(initials.theBorder, 1, { tint:newCol } );
					}
				}
			}
		}
		
		
		
		/**
		 * Hides the manipulator - called by clicking anywhere except on the manipulator
		 * @param	e
		 */
		private function hideManipulator(e:MouseEvent):void
		{			
			if(e.target == stage || e.target.name == "bg"){
				manip.hide();
			}
		}
		
		
		
		/**
		 * Adds the manipulator object to the icon which allows rotation, scaling and positioning of the object
		 * @param	e
		 */
		private function addManipulator(e:MouseEvent):void
		{
			bringToFront(DisplayObject(e.currentTarget));
			manip.hide();
			manip.setObject(e.currentTarget);
			manip.show();
			manip.addEventListener("killIcon", doKill, false, 0, true);
			manip.addEventListener("killInitials", doKillInitials, false, 0, true);
		}
		
		
		
		private function doKill(e:Event = null):void
		{			
			var theIcon:DisplayObjectContainer = manip.getIcon();
			theIcon.removeEventListener(MouseEvent.CLICK, addManipulator);
			manip.removeEventListener("killIcon", doKill);
			manip.removeEventListener("killInitials", doKillInitials);
			manip.hide();
			manip.nullMyObject();
			card.removeChild(theIcon);
		}
		
		private function doKillInitials(e:Event):void
		{
			hasInitials = false;
			doKill();
		}
		
		
		/**
		 * Called from initialClicked() when a current initials exists in the card
		 * removes the current initials so a new intitials can be added
		 */
		private function removeInitials():void
		{
			if(initials){
				if (card.contains(initials)) {
					manip.removeEventListener("killInitials", doKillInitials);
					
					if (manip.getIcon() == initials){
						manip.hide();
						manip.nullMyObject();
					}
				
					card.removeChild(initials);
					hasInitials = false;
				}
				
			}
		}
		
		/**
		 * Brings the specified child object to the front of the card
		 * but keeps it under the card border object
		 * Called from addManipulator() and iconClicked()
		 * @param	child
		 */
		private function bringToFront(child:DisplayObject):void
		{			
			var ind:int = hasBorder ? card.numChildren - 2 : card.numChildren - 1;
			card.setChildIndex(child, ind);
		}
		
		
		
		/**
		 * Called from clicking a color swatch in the card background color picker component
		 * Uses Tweenmax to tint the cards bg to the specified color
		 * @param	e
		 */
		private function cardBGChanged(e:ColorPickerEvent):void
		{
			currentBGColor = e.color;
			TweenMax.to(card.bg, 1, { tint:currentBGColor } );
		}
		
		
		
		/**
		 * Called by clicking the initials edit button
		 * @param	e
		 */
		private function showKeyboard(e:MouseEvent = null):void
		{
			if (hasInitials) {
				if (!contains(keyboard)) {
					addChild(keyboard);
					keyboard.x = 145;
					keyboard.y = 330;
					keyboard.enable();
					keyboard.addEventListener(Keyboard.INITIALS_ENTERED, kbdSubmit, false, 0, true);
				}
			}
		}
		
		
		/**
		 * Called by pressing the ok key on the keyboard
		 * @param	e
		 */
		private function kbdSubmit(e:Event):void
		{
			var inits:String = keyboard.getInitials();			
			initials.theText.text = inits;
			keyboard.disable();
			removeChild(keyboard);
		}
		
		
		
		/**
		 * Called by clicking the reset button
		 * @param	e
		 */
		private function confirmReset(e:MouseEvent):void
		{
			addChild(dialog);
			dialog.show("OK to reset card to default state?");
			dialog.addEventListener(Dialog.DIALOG_YES, resetConfirmed, false, 0, true);
			dialog.addEventListener(Dialog.DIALOG_NO, closeDialog, false, 0, true); 
		}
		
		
		/**
		 * Called by clicking yes in the reset confirmation dialog
		 * @param	e
		 */
		private function resetConfirmed(e:Event = null):void
		{
			manip.hide();
			manip.nullMyObject();
			if(contains(dialog)){
				removeChild(dialog);
			}
			dialog.removeEventListener(Dialog.DIALOG_YES, resetConfirmed);
			dialog.removeEventListener(Dialog.DIALOG_NO, closeDialog); 
			removeBorder();
			removeInitials();
			
			var l:int = card.numChildren - 1;
			for (var i:int = l; i > 0; i--) {
				var c:DisplayObject = card.getChildAt(i);
				if (c != card.bg && c != card.cmask) {
					card.removeChild(c);
				}
			}
			
			if (contains(keyboard)) {
				keyboard.disable();
				removeChild(keyboard);
			}
			
			TweenMax.to(card.bg, 1, { tint:defaultColor } ); //original bg color
			bgColor.selectedColor = defaultColor; //set swatch color in colorPicker
		}
		
		
		
		/**
		 * called by clicking no in the reset confirmation dialog
		 * @param	e
		 */
		private function closeDialog(e:Event = null):void
		{
			btnSave.addEventListener(MouseEvent.CLICK, saveAndPrint, false, 0, true);
			dialog.removeEventListener(Dialog.DIALOG_YES, resetConfirmed);
			dialog.removeEventListener(Dialog.DIALOG_NO, closeDialog);
			if(contains(dialog)){
				removeChild(dialog);
			}
		}
		private function closeThanksDialog(e:Event = null):void
		{
			btnSave.addEventListener(MouseEvent.CLICK, saveAndPrint, false, 0, true);
			dialog.removeEventListener(Dialog.DIALOG_NO, closeThanksDialog);
			startAttractLoop();
		}
		
		
		/**
		 * Called by clicking the save and print button
		 * @param	e
		 */
		private function saveAndPrint(e:MouseEvent = null):void
		{
			//disable print button so it can't be clicked multiple times
			btnSave.removeEventListener(MouseEvent.CLICK, saveAndPrint);
			
			manip.hide();
			
			uid = getUniqueID();
			var bmpd:BitmapData = cardImage.cardBitmap(card);			
			
			encoded = cardImage.getBase64(cardImage.getJpeg(bmpd));
			cardImage.postImage(encoded, uid);
			cardImage.addEventListener(CardImage.DID_POST, uploadSuccessful, false, 0, true);
			cardImage.addEventListener(CardImage.DID_NOT_POST, uploadFailed, false, 0, true);
			
			cardWithID = cardImage.addID(bmpd, uid);			
			doPrint(); //prints cardWithID
		}
		
		
		
		private function doPrint():void
		{	
			closeDialog();
			
			var printClip:MovieClip = new MovieClip();
			
			//HP Photosmart A646: 288,432
			var wht:BitmapData = new BitmapData(288, 432, false, 0xFFFFFF); //white rect at full page size
			
			printClip.addChild(new Bitmap(wht));
			
			var card:Bitmap = new Bitmap(cardWithID);
			card.width = 175;
			card.scaleY = card.scaleX;
			
			//add a slightly larger bg colored image to get full bleed color
			/*
			var bgBmpD:BitmapData = new BitmapData(card.width + 20, card.height + 20, false, currentBGColor);
			var bgBmp:Bitmap = new Bitmap(bgBmpD);
			printClip.addChild(bgBmp);
			bgBmp.x = 46;
			bgBmp.y = 85;	
			*/
			
			printClip.addChild(card);
			card.x = 56; //margins to place card inside perforated area
			card.y = 95;
			
			//add bitmaps to cover the curved portion from the mask
			var topBar:BitmapData = new BitmapData(card.width + 20, 12, false, currentBGColor);
			var top:Bitmap = new Bitmap(topBar);
			printClip.addChild(top);
			top.x = 46;
			top.y = 85;
			
			var botBar:BitmapData = new BitmapData(card.width + 20, 12, false, currentBGColor);
			var bot:Bitmap = new Bitmap(botBar);
			printClip.addChild(bot);
			bot.x = 46;
			bot.y = 85 + card.height + 8;
			
			var leftBar:BitmapData = new BitmapData(12, card.height + 20, false, currentBGColor);
			var l:Bitmap = new Bitmap(leftBar);
			printClip.addChild(l);
			l.x = 46; l.y = 85;
			
			var rightBar:BitmapData = new BitmapData(12, card.height + 20, false, currentBGColor);
			var r:Bitmap = new Bitmap(rightBar);
			printClip.addChild(r);
			r.x = 54 + card.width; r.y = 85;
			
			var printJob:PrintJob = new PrintJob();
			
			if (printJob.start()) {
				
				//use this trace to get the printers proper page size
				//only works after printJob.start() is called
				//trace(printJob.pageWidth, printJob.pageHeight);
				var ok:int = 0;
				try{
					printJob.addPage(printClip);
					ok = 1;
					
				}catch (e:Error) {
					ok = 0;
					printFailed();
				}
				
				if (ok == 1) {
					printJob.send();
					thanksDialog();
				}else {
					printFailed();
				}
				
			}else {
				printFailed();
			}
		}
		
		
		/**
		 * Called if an error is thrown in doPrint()
		 */
		private function printFailed():void
		{
			addChild(dialog);
			dialog.show("A printing error occured.\nPlease check the printer.\nPress Yes to print again, or No to cancel.");
			dialog.addEventListener(Dialog.DIALOG_YES, doPrint, false, 0, true);
			dialog.addEventListener(Dialog.DIALOG_NO, closeDialog, false, 0, true); 
		}
		
		
		private function uploadSuccessful(e:Event):void
		{
			//trace("upload good");
		}
		
		
		private function uploadFailed(e:Event):void
		{
			//trace("upload failed");
			files.saveFile(encoded, uid);
		}
		
		
		private function thanksDialog():void
		{			
			if(!contains(dialog)){
				addChild(dialog);
			}			
			
			dialog.show("Your card is printing.\nFollow the instructions on the card to download your custom design online and save up to $5 when you have your design printed on a full deck of cards.", "", "OK", uid);
			dialog.addEventListener(Dialog.DIALOG_NO, closeThanksDialog, false, 0, true); 
		}
		
		
		
		/**
		 * Returns a unique alpha numeric id string
		 * @return
		 */
		private function getUniqueID():String
		{
			var charArray:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

			var d:Date = new Date(2010, 4, 3); //may 1st
			var e:Date = new Date();
			var m:String = String(e.valueOf() - d.valueOf()); 

			var curIndex:int = 0;
			var numArray:Array = new Array();

			while(curIndex < m.length){
				numArray.push(parseInt(m.substr(curIndex, 2)));
				curIndex += 2;
			}

			var fin:String = "";
			for(var i:int = 0; i < numArray.length; i++){
				var cur:int = numArray[i];
				if(cur < charArray.length){
					fin += charArray.charAt(cur);
				}else{
					fin += String(cur);
				}
			}
			
			return fin;
		}
		
		
		
		/**
		 * Returns column,row in array
		 * @param	index
		 * @param	perRow
		 * @return
		 */
		private function gridLoc(index:Number, perRow:Number):Array
        {
            return new Array(index % perRow == 0 ? perRow : index % perRow, Math.ceil(index / perRow));
        }
		
	}
	
}