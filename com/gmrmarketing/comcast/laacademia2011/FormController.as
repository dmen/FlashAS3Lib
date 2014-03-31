package com.gmrmarketing.comcast.laacademia2011
{
	import com.gmrmarketing.utilities.GenMessageEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import com.gmrmarketing.utilities.OSKeyboard;
	import com.gmrmarketing.utilities.KbdEvent;
	import flash.events.*;
	import com.greensock.TweenLite;
	import com.blurredistinction.validators.EmailValidator;
	import com.gmrmarketing.utilities.GenErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.utils.Timer;
	
	//import flash.filesystem.*;
	import com.gmrmarketing.bicycle.SWFKitFiles;
	
	
	
	public class FormController extends EventDispatcher
	{
		public static const FORM_SUBMITTED:String = "formGood";
		public static const FORM_CANCELLED:String = "formCancelled";
		public static const FORM_TIMEDOUT:String = "noActivityInForm";
		
		private var kbd:OSKeyboard;
		private var form:MovieClip;
		private var blocker:MovieClip;		
		private var formContainer:DisplayObjectContainer;
		
		private var fieldList:Array;
		private var curTab:int;
		
		private var cursorCounter:int;
		
		//if true the next char will be upper case
		private var shiftFlag:Boolean = true;
		
		private var emVal:EmailValidator;
		
		private var lang:String = "english";
		
		private var privacy:MovieClip;
		
		private var swfKit:SWFKitFiles;
		
		private var timeoutTimer:Timer;
		
		//for loading the privacy policy text files
		private var pLoader:URLLoader;		
		
		
		
		
		public function FormController($formContainer:DisplayObjectContainer)
		{
			formContainer = $formContainer;
			
			pLoader = new URLLoader();
			pLoader.addEventListener(Event.COMPLETE, policyLoaded, false, 0, true);
			
			timeoutTimer = new Timer(45000, 1);
			timeoutTimer.addEventListener(TimerEvent.TIMER, formTimedOut, false, 0, true);
			
			swfKit = new SWFKitFiles();
			
			emVal = new EmailValidator();			
			
			blocker = new formBlocker(); //lib clip - black box for graying out the bg
			
			kbd = new OSKeyboard();
			kbd.addEventListener(KbdEvent.KEY_CLICK, keyClicked, false, 0, true);
			kbd.x = 408;
			kbd.y = 635;
		}
		
		
		
		public function init($lang:String = "english"):void
		{	
			lang = $lang;
			
			if(form){
				if (formContainer.contains(form)) {
					formContainer.removeChild(form);					
				}
			}
			
			if(lang == "spanish"){
				form = new formSpanish(); //lib clip
			}else {
				form = new formEnglish(); //lib clip
			}
			
			form.x = 460;
			form.y = 84;
			
			//field names and max chars in the form
			fieldList = new Array();
			fieldList.push([form.firstName, 20], [form.lastName, 25], [form.theAddress, 35]);
			fieldList.push([form.theAddress2, 35], [form.theCity, 15], [form.theState, 2]);
			fieldList.push([form.theZip, 5], [form.thePhone, 12],[form.theEmail, 35]);
		}
		
		
		
		/**
		 * Returns the zip code so it can be checked against the list supplied by comcast
		 * @return
		 */
		public function getZipCode():String
		{
			return form.theZip.text;
		}
		
		
		
		/**
		 * Called from ScratchOff.formSubmitted()
		 */
		public function saveUserData(fName:String):void
		{
			var o:Array = new Array();		
			
			o.push("<firstname>" + form.firstName.text + "</firstname>");
			o.push("<lastname>" + form.lastName.text + "</lastname>");
			o.push("<address>" + form.theAddress.text + "</address>");
			o.push("<address2>" + form.theAddress2.text + "</address2>");
			o.push("<city>" + form.theCity.text + "</city>");
			o.push("<state>" + form.theState.text + "</state>");
			o.push("<zip>" + form.theZip.text + "</zip>");
			o.push("<phone>" + form.thePhone.text + "</phone>");
			
			var type:String = "home";
			if (form.checkCell.currentFrame == 2) {
				type = "cell";
			}
			o.push("<phoneType>" + type + "</phoneType>");
			
			o.push("<email>" + form.theEmail.text + "</email>");
			
			var sub:String = "no";
			if (form.checkYes.currentFrame == 2) {
				sub = "yes";
			}
			o.push("<currentSubscriber>" + sub + "</currentSubscriber>");
			
			var yn:String = "no";
			if (form.checkMail.currentFrame == 2) {
				yn = "yes";
			}
			o.push("<furtherCommUSMail>" + yn + "</furtherCommUSMail>");
			
			yn = "no";
			if (form.checkEmail.currentFrame == 2) {
				yn = "yes";
			}
			o.push("<furtherCommEMail>" + yn + "</furtherCommEMail>");
			
			yn = "no";
			if (form.checkPhone.currentFrame == 2) {
				yn = "yes";
			}
			o.push("<furtherCommPhone>" + yn + "</furtherCommPhone>");
			
			
			o.push("<language>" + lang + "</language>");
			
			swfKit.saveFormData(fName, o);
		}
		
		
		
		public function showForm():void
		{
			clearForm();
			
			curTab = 0;
			
			kbd.alpha = 0;
			form.alpha = 0;
			blocker.alpha = .69;
			
			formContainer.addChild(blocker);			
			formContainer.addChild(kbd);
			formContainer.addChild(form);
			
			TweenLite.to(form, .5, { alpha:1 } );
			TweenLite.to(kbd, .5, { alpha:1 } );
		
			form.insertion.addEventListener(Event.ENTER_FRAME, flashCursor, false, 0, true);			
			cursorCounter = 0;
			
			form.insertion.x = fieldList[curTab][0].x + fieldList[curTab][0].textWidth + 2;
			form.insertion.y = fieldList[curTab][0].y + 3;
			
			for (var i:int = 0; i < fieldList.length; i++){
				fieldList[i][0].addEventListener(MouseEvent.CLICK, fieldTapped, false, 0, true);
			}
			
			//init radio buttons
			form.checkHome.addEventListener(MouseEvent.CLICK, toggleCell, false, 0, true);
			form.checkCell.addEventListener(MouseEvent.CLICK, toggleCell, false, 0, true);
			
			form.checkYes.addEventListener(MouseEvent.CLICK, toggleYes, false, 0, true);
			form.checkNo.addEventListener(MouseEvent.CLICK, toggleYes, false, 0, true);
			
			form.checkMail.addEventListener(MouseEvent.CLICK, toggleComm, false, 0, true);
			form.checkEmail.addEventListener(MouseEvent.CLICK, toggleComm, false, 0, true);
			form.checkPhone.addEventListener(MouseEvent.CLICK, toggleComm, false, 0, true);
			
			form.checkConfirm.addEventListener(MouseEvent.CLICK, toggleConfirm, false, 0, true);
			
			//privacy
			form.btnPrivacy.addEventListener(MouseEvent.CLICK, showPrivacy, false, 0, true);
			
			timeoutTimer.start();
		}
		
		
		
		private function formTimedOut(e:TimerEvent):void
		{
			timeoutTimer.reset();
			dispatchEvent(new Event(FORM_TIMEDOUT));
		}
		
		
		
		private function showPrivacy(e:MouseEvent):void
		{
			if (lang == "english") {
				privacy = new privacyEnglish(); //lib clip
				pLoader.load(new URLRequest("privacy_en.txt"));
			}else {
				privacy = new privacySpanish();
				pLoader.load(new URLRequest("privacy_sp.txt"));
			}
			privacy.alpha = 0;
			form.addChild(privacy);
			
			kbd.deactivateKeys();
			
			TweenLite.to(privacy, 1, { alpha:1 } );
			privacy.btnOK.addEventListener(MouseEvent.CLICK, hidePrivacy, false, 0, true);
			timeoutTimer.reset();
		}
		
		private function policyLoaded(e:Event):void
		{
			privacy.tf.htmlText = "<font size='14'>" + pLoader.data + "</font>";			
		}
		
		private function hidePrivacy(e:MouseEvent):void
		{
			privacy.btnOK.removeEventListener(MouseEvent.CLICK, hidePrivacy);
			kbd.activateKeys();
			TweenLite.to(privacy, .5, { alpha:0, onComplete:killPrivacy } );
		}
		
		private function killPrivacy():void
		{
			form.removeChild(privacy);
			privacy = null;
			timeoutTimer.start();
		}
		
		
		public function hideForm():void
		{
			form.checkHome.removeEventListener(MouseEvent.CLICK, toggleCell);
			form.checkCell.removeEventListener(MouseEvent.CLICK, toggleCell);
			
			form.checkYes.removeEventListener(MouseEvent.CLICK, toggleYes);
			form.checkNo.removeEventListener(MouseEvent.CLICK, toggleYes);
			
			form.checkMail.removeEventListener(MouseEvent.CLICK, toggleComm);
			form.checkEmail.removeEventListener(MouseEvent.CLICK, toggleComm);
			form.checkPhone.removeEventListener(MouseEvent.CLICK, toggleComm);			
			
			form.insertion.removeEventListener(Event.ENTER_FRAME, flashCursor);
			
			TweenLite.to(kbd, .5, { alpha:0 } );
			TweenLite.to(form, .5, { alpha:0 } );
			TweenLite.to(blocker, 1.5, { alpha:0, onComplete:removeBlocker } );
			
			for (var i:int = 0; i < fieldList.length; i++){
				fieldList[i][0].removeEventListener(MouseEvent.CLICK, fieldTapped);
			}
			
			form.btnPrivacy.removeEventListener(MouseEvent.CLICK, showPrivacy);
		}
		
		
		
		private function removeBlocker():void
		{			
			formContainer.removeChild(kbd);
			formContainer.removeChild(form);
			formContainer.removeChild(blocker);
		}
		
		
		
		private function toggleCell(e:MouseEvent):void
		{
			if (e.currentTarget == form.checkHome) {
				form.checkHome.gotoAndStop(2);
				form.checkCell.gotoAndStop(1);
			}else {
				form.checkHome.gotoAndStop(1);
				form.checkCell.gotoAndStop(2);
			}
		}

		
		
		private function toggleYes(e:MouseEvent):void
		{
			if (e.currentTarget == form.checkYes) {
				form.checkYes.gotoAndStop(2);
				form.checkNo.gotoAndStop(1);
			}else {
				form.checkYes.gotoAndStop(1);
				form.checkNo.gotoAndStop(2);
			}
		}		
	
		
		
		private function toggleComm(e:MouseEvent):void
		{
			if (e.currentTarget == form.checkMail) {
				if (form.checkMail.currentFrame == 1) {
					form.checkMail.gotoAndStop(2);
				}else {
					form.checkMail.gotoAndStop(1);
				}
			}
			if (e.currentTarget == form.checkEmail) {
				if (form.checkEmail.currentFrame == 1) {
					form.checkEmail.gotoAndStop(2);
				}else {
					form.checkEmail.gotoAndStop(1);
				}
			}
			if (e.currentTarget == form.checkPhone) {
				if (form.checkPhone.currentFrame == 1) {
					form.checkPhone.gotoAndStop(2);
				}else {
					form.checkPhone.gotoAndStop(1);
				}
			}
		}
		
		
		
		private function toggleConfirm(e:MouseEvent):void
		{
			if (form.checkConfirm.currentFrame == 1) {
				form.checkConfirm.gotoAndStop(2);
			}else {
				form.checkConfirm.gotoAndStop(1);
			}
		}
		
		
		
		private function flashCursor(e:Event):void
		{
			cursorCounter++;
			if (cursorCounter % 15 == 0) {
				if (form.insertion.alpha < 1) {
					form.insertion.alpha = 1;					
				}else {
					form.insertion.alpha = 0;					
				}
			}
		}
		
		
		
		private function fieldTapped(e:MouseEvent):void
		{
			for (var i:int = 0; i < fieldList.length; i++){
				if (e.currentTarget == fieldList[i][0]) {
					curTab = i;
					
					form.insertion.x = fieldList[curTab][0].x + fieldList[curTab][0].textWidth + 2;
					form.insertion.y = fieldList[curTab][0].y + 3;
					
					break;
				}
			}
			shiftFlag = true; //set to true for first char of new line
		}
		
		
		
		/**
		 * Called by listener whenever a key on the OSKeyboard is clicked
		 * @param	e
		 */
		private function keyClicked(e:KbdEvent):void
		{
			var input:String = e.char;
			
			timeoutTimer.reset();
			
			if (input == "tab") {
				curTab++;				
				if (curTab >= fieldList.length) {
					curTab = 0;
				}
				shiftFlag = true; //set to true for first char of new line
				
			}else if (input == "backspace") {
				//backspace
				if(fieldList[curTab][0].text.length > 0){
					fieldList[curTab][0].text = fieldList[curTab][0].text.substr(0, fieldList[curTab][0].text.length - 1);
				}				
				
			}else if (input == "submit") {
				if (checkFields()) {					
					dispatchEvent(new Event(FORM_SUBMITTED)); //calls formSubmitted() in ScratchOff
				}
			
			}else if (input == "cancel") {
				dispatchEvent(new Event(FORM_CANCELLED));
				
			}else {
				var code:Number = input.charCodeAt(0);
				
				//if space, or we're in the state field, next char will be upper case - 
				if (code == 32 || curTab == 5) { shiftFlag = true; }
				
				if (shiftFlag && code >= 97 && code <= 122) {
					code -= 32;
					shiftFlag = false;					
					input = String.fromCharCode(code);
				}					
				
				if (fieldList[curTab][0].text.length < fieldList[curTab][1]) {
					if (curTab == 5) {
						//only allow upper case chars in state
						if (code > 64 && code < 91) {							
							fieldList[curTab][0].appendText(input);
						}
					}else if (curTab == 6) {
						//only allow numbers in zip field
						if (code > 47 && code < 58) {							
							fieldList[curTab][0].appendText(input);
						}
					}else if (curTab == 7) {
						//only allow numbers and - in phone field
						if ((code > 47 && code < 58) || code == 45) {							
							fieldList[curTab][0].appendText(input);
						}
					}else{
						fieldList[curTab][0].appendText(input);
					}
				}				
				
			}
			
			form.insertion.x = fieldList[curTab][0].x + fieldList[curTab][0].textWidth + 2;
			form.insertion.y = fieldList[curTab][0].y + 3;
			
			timeoutTimer.start();
		}
		
		
		
		/**
		 * Called from keyClicked() when the submit button is pressed
		 * 
		 * @return
		 */
		private function checkFields():Boolean
		{
			if (form.firstName.text == "" || form.lastName.text == "") {
				if(lang == "english"){
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Please provide a first and last name."));
				}else {
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Por favor suministre su nombre y apellido."));
				}
				return false;
			}
			if(form.theEmail.text != ""){
				if (!emVal.validate(form.theEmail.text)) {
					if(lang == "english"){
						dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Please provide a valid email address."));
					}else {
						dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Por favor suministre su dirección de correo electrónico."));
					}
					return false;
				}
			}
			if (form.theZip.text.length != 5) {
				if(lang == "english"){
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Please provide a valid zip code."));
				}else {
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Por favor suministre su código postal."));
				}
				return false;
			}
			if (form.checkConfirm.currentFrame != 2) {
				if(lang == "english"){
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "You must accept the privacy acknowledgment."));
				}else {
					dispatchEvent(new GenMessageEvent(GenMessageEvent.GENERAL_MESSAGE, "Usted debe aceptar las políticas de privacidad."));
				}
				return false;
			}
			
			return true;
		}
		
		
		
		/**
		 * Clears form and sets defaults for check boxes
		 * called from showForm()
		 */
		private function clearForm(e:Event = null):void
		{
			for (var i:int = 0; i < fieldList.length; i++) {
				fieldList[i][0].text = "";
			}
			
			form.checkHome.gotoAndStop(2);
			form.checkCell.gotoAndStop(1);
			
			form.checkYes.gotoAndStop(2);
			form.checkNo.gotoAndStop(1);
			
			form.checkMail.gotoAndStop(1);
			form.checkEmail.gotoAndStop(1);
			form.checkPhone.gotoAndStop(1);
			
			form.checkConfirm.gotoAndStop(1);
		}
		
		
	}
	
}