package com.gmrmarketing.sap.levisstadium.avatar.testing
{	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.utils.Timer;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	import com.gmrmarketing.utilities.Validator;
	
	public class Registration extends EventDispatcher
	{
		public static const REG_COMPLETE:String = "registrationComplete";
		public static const RESET:String = "registrationReset";
		
		private var regEmail:MovieClip;
		private var regConfirm:MovieClip;
		private var regFull:MovieClip;
		private var regThanks:MovieClip;
		private var container:DisplayObjectContainer;
		private var fullSize:BitmapData; //full size user image
		private var prev:Bitmap; //preview that shows in thanks
		
		private var kbd:KeyBoard;
		private var tim:TimeoutHelper;
		
		private var step:int; //for drawing animated circle loader
		private var loaderSprite:Sprite;
		
		private var ims:ImageService;
		private var userID:int; //id from web service
		
		
		public function Registration()
		{
			regEmail = new mcRegEmail();
			regConfirm = new mcRegConfirm();
			regFull = new mcRegFull();
			regThanks = new mcRegThanks();
			loaderSprite = new Sprite();
			
			tim = TimeoutHelper.getInstance();
			
			ims = new ImageService();
			ims.setServiceURL("http://sap49ersapi.thesocialtab.net/Api/Registrant/SubmitAvatar");
			ims.setSaveFolder("levis_avatar/"); //folder on the desktop - will be created
			
			kbd = new KeyBoard();			
			kbd.loadKeyFile("keyboard.xml");
			kbd.x = 475;
			kbd.y = 730;
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		//prev bmp is 257x319
		//full size incoming is 716 x 891		
		public function show(previewImage:BitmapData):void
		{
			fullSize = previewImage;
			
			var prevBmd:BitmapData = new BitmapData(257, 319);
			var m:Matrix = new Matrix();
			m.scale(0.3589385474860335, 0.3589385474860335); 
			prevBmd.draw(previewImage, m, null, null, null, true);
			
			prev = new Bitmap(prevBmd);
			prev.x = 830;
			prev.y = 500;
			
			//remove
			if (container.contains(regConfirm)) {
				container.removeChild(regConfirm);
			}
			if (container.contains(regFull)) {
				container.removeChild(regFull);
			}
			if (container.contains(regThanks)) {
				container.removeChild(regThanks);
			}
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
			//add
			if (!container.contains(regEmail)) {
				container.addChild(regEmail);
			}
			regEmail.alpha = 0;
			regEmail.theEmail.text = "";
			regEmail.errorText.alpha = 0;
			regEmail.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, emailSubmit, false, 0, true);
			regEmail.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			container.addChild(kbd);
			kbd.setFocusFields([regEmail.theEmail]);
			kbd.y = 900;
			kbd.alpha = 0;
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.SUBMIT, emailSubmit, false, 0, true);			
			
			TweenMax.to(regEmail, 1, { alpha:1 } );
			TweenMax.to(kbd, 1, { alpha:1, y:730, delay:1, ease:Back.easeOut } );
		}
		
		
		public function hide():void
		{
			if (container.contains(regConfirm)) {
				container.removeChild(regConfirm);
			}
			if (container.contains(regFull)) {
				container.removeChild(regFull);
			}
			if (container.contains(regThanks)) {
				container.removeChild(regThanks);
			}
			if (container.contains(regEmail)) {
				container.removeChild(regEmail);
			}
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
			regEmail.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, emailSubmit);
			regFull.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit);
			
			regEmail.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regFull.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regConfirm.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regThanks.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			
			kbd.removeEventListener(KeyBoard.KBD, keyPressed);
			kbd.removeEventListener(KeyBoard.SUBMIT, emailSubmit);
			kbd.removeEventListener(KeyBoard.SUBMIT, fullRegSubmit);
		}
		
		
		//called whenever a key on the keyboard is pressed
		private function keyPressed(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		private function regReset(e:MouseEvent):void
		{
			dispatchEvent(new Event(RESET));
		}
		
		
		/**
		 * Called when submit is pressed in the initial email dialog
		 * @param	e
		 */
		private function emailSubmit(e:*):void
		{
			var em:String = regEmail.theEmail.text;
			tim.buttonClicked();
			
			if(Validator.isValidEmail(em)){
			
				regEmail.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, emailSubmit);
				kbd.removeEventListener(KeyBoard.SUBMIT, emailSubmit);
				
				showLoader();
				
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var req:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/Registrant/GetRegistrantByEmail");
				req.method = URLRequestMethod.GET;			
				req.requestHeaders.push(hdr);			
				
				var vars:URLVariables = new URLVariables();
				vars.email = em;
				
				req.data = vars;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, emailCheckError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, emailCheckComplete, false, 0, true);
				lo.load(req);	
				
			}else {
				regEmail.errorText.alpha = 1;
				regEmail.errorText.theText.text = "Please enter a valid email address";
				TweenMax.to(regEmail.errorText, 2, { alpha:0, delay:2 } );
			}
		}
		
		
		private function emailCheckError(e:IOErrorEvent):void
		{
			trace("IOError:",e.toString());
		}
		
		
		private function emailCheckComplete(e:Event):void
		{
			hideLoader();
			var json:Object = JSON.parse(e.currentTarget.data);
			if (json.Id != undefined) {
				//user was found in the database
				userID = json.Id;
				showConfirmation(json.FirstName + " " + json.LastName, json.Email);
			}else {
				//not found
				showFull();
			}
		}
		
		
		
		private function showConfirmation(name:String, em:String):void
		{
			if (container.contains(regEmail)) {
				container.removeChild(regEmail);
			}
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
			if (container.contains(regThanks)) {
				container.removeChild(regThanks);
			}
			if (!container.contains(regConfirm)) {
				container.addChild(regConfirm);
			}
			
			regConfirm.alpha = 0;
			regConfirm.theName.text = name;
			regConfirm.theEmail.text = em;
			
			regConfirm.btnYes.addEventListener(MouseEvent.MOUSE_DOWN, confirmYes, false, 0, true);
			regConfirm.btnNo.addEventListener(MouseEvent.MOUSE_DOWN, confirmNo, false, 0, true);
			regConfirm.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			TweenMax.to(regConfirm, 1, { alpha:1 } );
		}
		
		
		private function confirmYes(e:MouseEvent):void
		{
			tim.buttonClicked();
			regConfirm.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, confirmYes);
			regConfirm.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, confirmNo);
			regConfirm.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			showThanks();
		}
		
		
		private function confirmNo(e:MouseEvent):void
		{
			tim.buttonClicked();
			regConfirm.btnYes.removeEventListener(MouseEvent.MOUSE_DOWN, confirmYes);
			regConfirm.btnNo.removeEventListener(MouseEvent.MOUSE_DOWN, confirmNo);
			regConfirm.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			showFull(true);
		}
		
		
		private function showFull(blankEmail:Boolean = false):void
		{
			if (container.contains(regEmail)) {
				container.removeChild(regEmail);
			}
			
			if (!container.contains(regFull)) {
				container.addChild(regFull);
			}
			regFull.errorText.alpha = 1;
			regFull.alpha = 0;
			regFull.theFname.text = "";
			regFull.theLname.text = "";
			if (blankEmail) {
				regFull.theEmail.text = "";//user answered 'no' this isn't me... odd
			}else{
				regFull.theEmail.text = regEmail.theEmail.text; //pre-pop with what was entered in email dialog
			}
			
			regFull.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit, false, 0, true);
			regFull.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			if(!container.contains(kbd)){
				container.addChild(kbd);				
			}else {
				//contains - remove and add to move it to top
				container.removeChild(kbd);
				container.addChild(kbd);
			}
			kbd.y = 900;
			kbd.alpha = 0;
			
			TweenMax.to(regFull, 1, { alpha:1 } );
			TweenMax.to(kbd, 1, { alpha:1, y:730, delay:1, ease:Back.easeOut } );
			
			kbd.setFocusFields([regFull.theFname, regFull.theLname, regFull.theEmail]);			
			kbd.addEventListener(KeyBoard.SUBMIT, fullRegSubmit, false, 0, true);
		}
		
		
		private function fullRegSubmit(e:*):void
		{
			tim.buttonClicked();
			
			if (regFull.theFname.text == "" || regFull.theLname.text == "") {
				
				regFull.errorText.alpha = 1;
				regFull.errorText.theText.text = "Please enter a first and last name";
				TweenMax.to(regFull.errorText, 2, { alpha:0, delay:2 } );
				
			}else{
			
				showLoader();
			
				//user was not found - submit their data for registration
				regFull.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit);
				kbd.removeEventListener(KeyBoard.SUBMIT, fullRegSubmit);
				
				var js:String = JSON.stringify( { FirstName:regFull.theFname.text, LastName:regFull.theLname.text, Email:regFull.theEmail.text } );
				
				var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
				var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var req:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/Registrant/Register");
				req.method = URLRequestMethod.POST;
				req.requestHeaders.push(hdr);
				req.requestHeaders.push(hdr2);
				req.data = js;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(Event.COMPLETE, regDataSubmitted, false, 0, true);
				lo.addEventListener(IOErrorEvent.IO_ERROR, regDataSubmitError, false, 0, true);
				lo.load(req);
			}
		}
		
		
		private function regDataSubmitted(e:Event):void
		{
			hideLoader();
			var json:Object = JSON.parse(e.currentTarget.data);
			userID = json.Id;
			
			showThanks();
		}
		
		
		private function regDataSubmitError(e:IOErrorEvent):void
		{
			
		}
		
		
		private function showThanks():void
		{
			tim.buttonClicked();
			
			if (container.contains(regConfirm)) {
				container.removeChild(regConfirm);
			}
			if (container.contains(regFull)) {
				container.removeChild(regFull);
			}			
			if (container.contains(regEmail)) {
				container.removeChild(regEmail);
			}
			if (container.contains(kbd)) {
				container.removeChild(kbd);
			}
			if (!container.contains(regThanks)) {
				container.addChild(regThanks);
			}		
			
			if (!regThanks.contains(prev)) {
				regThanks.addChild(prev);
			}
			
			regThanks.alpha = 0;
			TweenMax.to(regThanks, 1, { alpha:1, onComplete:sendToIMS } );			
		}
		
		//*/called once thanks is showing
		private function sendToIMS():void
		{
			regThanks.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			ims.addEventListener(ImageService.ADDED, complete, false, 0, true);
			ims.addToQueue(fullSize, userID);
			
		}
		
		
		private function complete(e:Event):void
		{
			dispatchEvent(new Event(REG_COMPLETE));
		}
		
		
		
		//Spinning loader graphic
		private function showLoader():void
		{
			if (container.contains(loaderSprite)) {
				container.removeChild(loaderSprite);
			}
			container.addChild(loaderSprite);
			loaderSprite.graphics.clear();
			step = 0;
			container.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
		}
		
		
		private function hideLoader():void
		{
			step = 0;
			container.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			if (container.contains(loaderSprite)) {
				container.removeChild(loaderSprite);
			}
		}
		
		
		private function onEnterFrame(e:Event):void
		{           
			step += 20;	
			if (step >= 360) {
				step = 0;
			}
			draw_arc(1210, 370, 30, 0, step, 0xE5b227);			
        }		
		
		
		private function draw_arc(center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineColor:Number, lineAlpha:Number = 1):void
		{
			loaderSprite.graphics.clear();
			loaderSprite.graphics.lineStyle(10, lineColor, lineAlpha, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:int = (angle_to) - (angle_from);
			var steps:int = angle_diff * 1;//1 is precision... use higher numbers for more.
			var angle:int = angle_from;
			var px:Number = center_x + radius * Math.cos((angle-90) * 0.0174532925);//sub 90 here and below to rotate the arc to start at 12oclock
			var py:Number = center_y + radius * Math.sin((angle-90) * 0.0174532925);

			loaderSprite.graphics.moveTo(px, py);

			for (var i:int = 1; i <= steps; i++) {
				angle = angle_from + angle_diff / steps * i;
				loaderSprite.graphics.lineTo(center_x + radius * Math.cos((angle-90) * 0.0174532925), center_y + radius * Math.sin((angle-90) * 0.0174532925));
			}
		}
		
	}
	
}