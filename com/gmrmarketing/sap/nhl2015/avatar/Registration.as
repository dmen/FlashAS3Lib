package com.gmrmarketing.sap.nhl2015.avatar
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
		public static const REG_LOG:String = "registrationLogEntry";
		private var degToRad:Number = 0.0174532925; //PI / 180
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
		private var logMessage:String;
		
		private var timeout:Timer;
		private var notMe:Boolean = false; //if true user entered an email, and said 'no this is not me'
		
		//loaders so they can be canceled if a network timeout occurs
		private var emailLoader:URLLoader;
		private var fullRegLoader:URLLoader;
		
		private var willSend:Boolean; //returned as WillSendEmail from GetRegistrantByEmail service - if true thanks dialog changes
		
		
		public function Registration()
		{
			regEmail = new mcRegEmail();
			regConfirm = new mcRegConfirm();
			regFull = new mcRegFull();
			regThanks = new mcRegThanks();
			loaderSprite = new Sprite();
			
			tim = TimeoutHelper.getInstance();
			timeout = new Timer(10000, 1);
			
			ims = new ImageService();
			ims.setServiceURL("http://sap49ersapi.thesocialtab.net/Api/NHL/SubmitAvatar");
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
			regEmail.btnClose2.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			container.addChild(kbd);
			kbd.setFocusFields([regEmail.theEmail]);
			kbd.y = 900;
			kbd.alpha = 0;
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);
			kbd.addEventListener(KeyBoard.SUBMIT, emailSubmit, false, 0, true);
			
			timeout.addEventListener(TimerEvent.TIMER, networkTimeoutEmail);
			
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
			
			hideLoader();
			
			regEmail.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, emailSubmit);
			regFull.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit);
			
			regEmail.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regEmail.btnClose2.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regFull.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
			regFull.btnClose2.removeEventListener(MouseEvent.MOUSE_DOWN, regReset);
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
		
		
		public function getLogMessage():String
		{
			return logMessage;
		}
		
		/**
		 * Called when submit is pressed in the initial email dialog
		 * @param	e
		 */
		private function emailSubmit(e:*):void
		{
			var em:String = regEmail.theEmail.text;
			tim.buttonClicked();
			
			willSend = false;
			
			notMe = false;//true if user presses not me in confirmation dialog
			
			if(Validator.isValidEmail(em)){
			
				regEmail.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, emailSubmit);
				kbd.removeEventListener(KeyBoard.SUBMIT, emailSubmit);
				
				showLoader();
				
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var req:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/NHL/GetRegistrantByEmail");
				req.method = URLRequestMethod.GET;			
				req.requestHeaders.push(hdr);			
				
				var vars:URLVariables = new URLVariables();
				vars.email = em;
				
				req.data = vars;
				
				timeout.reset();
				timeout.start(); //will call networkTimeoutEmail() in 10 sec if not stopped
				
				emailLoader = new URLLoader();
				emailLoader.addEventListener(IOErrorEvent.IO_ERROR, emailCheckError, false, 0, true);
				emailLoader.addEventListener(Event.COMPLETE, emailCheckComplete, false, 0, true);
				emailLoader.load(req);	
				
			}else {
				regEmail.errorText.alpha = 1;
				regEmail.errorText.theText.text = "Please enter a valid email address";
				TweenMax.to(regEmail.errorText, 2, { alpha:0, delay:2 } );
			}
		}
		
		
		private function emailCheckError(e:IOErrorEvent):void
		{
			timeout.reset(); //stop networkTimeout() from being called
			hideLoader();
			logMessage = "Registration.emailCheckError - userID set to -1    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));
			userID = -1;
			showFull();
		}
		
		
		private function networkTimeoutEmail(e:TimerEvent):void
		{			
			hideLoader();
			emailLoader.close();//prevent complete or error from being called
			logMessage = "Registration.networkTimeout - userID set to -1    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));
			userID = -1;
			showFull();
		}
		
		
		private function emailCheckComplete(e:Event):void
		{
			timeout.reset(); //stop networkTimeout() from being called
			hideLoader();
			var json:Object = JSON.parse(e.currentTarget.data);
			if (json.Id != undefined) {
				//user was found in the database
				userID = json.Id;
				willSend = json.WillSendEmail;
				
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
			if (container.contains(regFull)) {
				container.removeChild(regFull);
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
			notMe = true;
			showFull();
		}
		
		
		/**
		 * Called if the user was not found in the database where userID is still undefined
		 * Or if a network error occured checking email - in that case userID is set to -1
		 * @param	blankEmail
		 */
		private function showFull():void
		{
			hideLoader();
			timeout.removeEventListener(TimerEvent.TIMER, networkTimeoutEmail);
			
			if (container.contains(regEmail)) {
				container.removeChild(regEmail);
			}
			
			if (container.contains(regConfirm)) {
				container.removeChild(regConfirm);
			}
			
			if (!container.contains(regFull)) {
				container.addChild(regFull);
			}
			regFull.errorText.alpha = 1;
			regFull.alpha = 0;			
			
			regFull.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit, false, 0, true);
			regFull.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			regFull.btnClose2.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
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
			
			regFull.theFname.text = "";
			regFull.theLname.text = "";
			
			if (notMe) {
				regFull.theEmail.text = "";//user answered 'no' this isn't me
			}else{
				regFull.theEmail.text = regEmail.theEmail.text; //pre-pop with what was entered in email dialog
			}			
		}
		
		
		/**
		 * wildcard event so KeyBoard.SUBMIT event or MouseEvent works
		 * @param	e
		 */
		private function fullRegSubmit(e:*):void
		{
			
			tim.buttonClicked();
			
			if (regFull.theFname.text == "" || regFull.theLname.text == "") {
				
				regFull.errorText.alpha = 1;
				regFull.errorText.theText.text = "Please enter a first and last name";
				TweenMax.to(regFull.errorText, 2, { alpha:0, delay:2 } );
				
			}else if (!Validator.isValidEmail(regFull.theEmail.text)) {
				
				regFull.errorText.alpha = 1;
				regFull.errorText.theText.text = "Please enter a valid email address";
				TweenMax.to(regFull.errorText, 2, { alpha:0, delay:2 } );			
			}else{
			
				showLoader();
			
				//user was not found - submit their data for registration
				//regFull.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit);
				regFull.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, fullRegSubmit);
				kbd.removeEventListener(KeyBoard.SUBMIT, fullRegSubmit);
				
				//full reg email check
				var hdr:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
				var req:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/NHL/GetRegistrantByEmail");
				req.method = URLRequestMethod.GET;			
				req.requestHeaders.push(hdr);			
				
				var vars:URLVariables = new URLVariables();
				vars.email = regFull.theEmail.text;
				
				req.data = vars;
				
				timeout.addEventListener(TimerEvent.TIMER, fullRegNetworkTimeoutEmail);
				timeout.reset();
				timeout.start();
				
				emailLoader = new URLLoader();
				emailLoader.addEventListener(IOErrorEvent.IO_ERROR, fullRegEmailCheckError, false, 0, true);
				emailLoader.addEventListener(Event.COMPLETE, fullRegEmailCheckComplete, false, 0, true);
				emailLoader.load(req);	
			}
		}		
		
		
		private function fullRegEmailCheckError(e:IOErrorEvent):void
		{
			timeout.reset(); //stop fullRegNetworkTimeoutEmail() from being called			
			logMessage = "Registration.fullRegEmailCheckError - regThisUser()    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));			
			regThisUser();
		}
		
		
		private function fullRegNetworkTimeoutEmail(e:TimerEvent):void
		{	
			emailLoader.close();//prevent complete or error from being called
			logMessage = "Registration.fullRegNetworkTimeoutEmail calling regThisUser()    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));
			regThisUser();
		}
		
		
		private function fullRegEmailCheckComplete(e:Event):void
		{
			timeout.reset(); //stop fullRegNetworkTimeoutEmail() from being called			
			var json:Object = JSON.parse(e.currentTarget.data);//WillSendEmail
			if (json.Id != undefined) {
				//user was found in the database
				showConfirmation(json.FirstName + " " + json.LastName, json.Email);
			}else {
				//not found - submit full reg form
				regThisUser();
			}
		}
		
		
		private function regThisUser():void
		{
			var js:String = JSON.stringify( { FirstName:regFull.theFname.text, LastName:regFull.theLname.text, Email:regFull.theEmail.text } );
			
			var hdr:URLRequestHeader = new URLRequestHeader("Content-type", "application/json");
			var hdr2:URLRequestHeader = new URLRequestHeader("Accept", "application/json");
			var req:URLRequest = new URLRequest("http://sap49ersapi.thesocialtab.net/Api/NHL/Register");
			req.method = URLRequestMethod.POST;
			req.requestHeaders.push(hdr);
			req.requestHeaders.push(hdr2);
			req.data = js;
			
			timeout.addEventListener(TimerEvent.TIMER, networkTimeoutFullReg);
			timeout.reset();
			timeout.start();
			
			fullRegLoader = new URLLoader();
			fullRegLoader.addEventListener(Event.COMPLETE, regDataSubmitted, false, 0, true);
			fullRegLoader.addEventListener(IOErrorEvent.IO_ERROR, regDataSubmitError, false, 0, true);
			fullRegLoader.load(req);
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
			logMessage = "Registration.regDataSubmitError - userID set to -1    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));
			userID = -1;
			showThanks();			
		}
		
		
		private function networkTimeoutFullReg(e:TimerEvent):void
		{
			fullRegLoader.close();//prevent complete or error from being called
			logMessage = "Registration.networkTimeoutFullReg - userID set to -1    Error: " + e.toString();
			dispatchEvent(new Event(REG_LOG));
			userID = -1;
			showThanks();
		}
		
		
		/**
		 * Shows the thanks dialog
		 * Calls image service
		 */
		private function showThanks():void
		{
			timeout.reset(); //stop networkTimeout() from being called
			timeout.removeEventListener(TimerEvent.TIMER, networkTimeoutFullReg);
			hideLoader();
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
			
			//preview card image
			if (!regThanks.contains(prev)) {
				regThanks.addChild(prev);
			}
			
			if (willSend) {
				regThanks.theText.text = "Your Hockey Character has been added\nto your personalized fan page."
			}else{
				regThanks.theText.text = "Your email and hockey character has been sent!";
			}
			
			regThanks.alpha = 0;
			
			TweenMax.to(regThanks, 1, { alpha:1 } );
			TweenMax.delayedCall(5, sendToIMS);
		}
		
		
		//called once thanks is showing
		private function sendToIMS():void
		{
			regThanks.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, regReset, false, 0, true);
			
			ims.addEventListener(ImageService.ADDED, complete, false, 0, true);
			if(userID != -1){
				ims.addToQueue(fullSize, userID);	
			}else {
				//userID = -1 - error submitting data - network down... or something
				ims.addToQueue(fullSize, userID, regFull.theFname.text, regFull.theLname.text, regFull.theEmail.text);
			}
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
			draw_arc(loaderSprite.graphics, 1210, 370, 30, 0, step, 5, 0xE5b227);			
        }		
		
		
		private function draw_arc(g:Graphics, center_x:int, center_y:int, radius:int, angle_from:int, angle_to:int, lineThickness:Number, lineColor:Number, alph:Number = 1):void
		{
			g.clear();
			//g.lineStyle(1, lineColor, alph, false, LineScaleMode.NORMAL, CapsStyle.NONE);
			
			var angle_diff:Number = (angle_to) - (angle_from);
			var steps:int = angle_diff * 2; // 2 is precision... use higher numbers for more.
			var angle:Number = angle_from;
			
			var halfT:Number = lineThickness / 2; // Half thickness used to determine inner and outer points
			var innerRad:Number = radius - halfT; // Inner radius
			var outerRad:Number = radius + halfT; // Outer radius
			
			var px_inner:Number = getX(angle, innerRad, center_x); //sub 90 here and below to rotate the arc to start at 12oclock
			var py_inner:Number = getY(angle, innerRad, center_y); 
			
			if(angle_diff > 0){
				g.beginFill(lineColor, alph);
				g.moveTo(px_inner, py_inner);
				
				var i:int;
			
				// drawing the inner arc
				for (i = 1; i <= steps; i++) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, innerRad, center_x), getY(angle, innerRad, center_y));
				}
				
				// drawing the outer arc
				for (i = steps; i >= 0; i--) {
								angle = angle_from + angle_diff / steps * i;
								g.lineTo( getX(angle, outerRad, center_x), getY(angle, outerRad, center_y));
				}
				
				g.lineTo(px_inner, py_inner);
				g.endFill();
			}
		}
		
		private function getX(angle:Number, radius:Number, center_x:Number):Number
		{
			return Math.cos((angle-90) * degToRad) * radius + center_x;
		}
		
		
		private function getY(angle:Number, radius:Number, center_y:Number):Number
		{
			return Math.sin((angle-90) * degToRad) * radius + center_y;
		}
		
	}
	
}