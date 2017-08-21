package com.gmrmarketing.katyperry.witness
{
	import flash.events.*;
	import flash.display.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.geom.Matrix;
	import flash.text.TextFormat;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Result extends EventDispatcher
	{
		public static const COMPLETE:String = "resultComplete";
		public static const RETAKE:String = "retakePhoto";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var numpad:KeyBoard;
		private var kbd:KeyBoard;
		private var userNumber:String;
		
		private var spacer8Message:TextFormat;
		private var spacer8Email:TextFormat;
		
		private var photo:BitmapData;
		private var photoScaler:Matrix;
		private var photoHolder:Bitmap;
		
		private var isEmail:Boolean;
		
		private var errorMsg:MovieClip;
		
		private var tim:TimeoutHelper;
		
		
		public function Result()
		{
			clip = new results();
			
			numpad = new KeyBoard();
			kbd = new KeyBoard();
			numpad.x = 1067;
			numpad.y = 340;
			kbd.x = 2000;
			kbd.y = 481;
			
			spacer8Message = new TextFormat(); 
			spacer8Message.letterSpacing = 0; 
			spacer8Message.size = 42; 
			
			spacer8Email = new TextFormat();
			spacer8Email.size = 24; 
			spacer8Email.letterSpacing = 0; 
			
			photo = new BitmapData(654, 654, false, 0x000000);
			
			photoScaler = new Matrix();
			photoScaler.scale(.6055555, .6055555);//654x654
			
			photoHolder = new Bitmap(photo);		
			
			errorMsg = new errorMess();
			errorMsg.x = 574;
			errorMsg.y = 500;
			
			tim = TimeoutHelper.getInstance();
			
			numpad.loadKeyFile("numpad.xml");
			kbd.loadKeyFile("kbd.xml");
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * photo comes in full size at 1080x1080  .592592 scale to 640x640
		 * @param	photo
		 */
		public function show(p:BitmapData):void
		{
			if (!myContainer.contains(clip)){
				myContainer.addChild(clip);
			}
			
			if (!myContainer.contains(photoHolder)){
				myContainer.addChild(photoHolder);
			}
			
			photo.draw(p, photoScaler, null, null, null, true);
			
			isEmail = false;
			
			if(!clip.contains(numpad)){
				clip.addChild(numpad);
			}
			if (!clip.contains(kbd)){
				clip.addChild(kbd);
			}
			
			numpad.x = 1067;
			kbd.x = 2000;			
			
			//setup for text message
			photoHolder.x = 127;
			photoHolder.y = 210;
			clip.authCheck.x = 1067;
			clip.authText.x = 1104;
			clip.emailBG.alpha = 0;			
			clip.authCheck.gotoAndStop(1);			
			
			clip.userInput.text = "000-000-0000";
			clip.userInput.border = false;
			clip.userInput.textColor = 0x000000;
			clip.userInput.height = 64;
			
			clip.userInput.x = 1067;
			clip.userInput.y = 336;
			
			clip.btnSend.x = 1067;
			clip.btnSend.y = 907;
			
			userNumber = "";
			
			numpad.addEventListener(KeyBoard.KBD, numPadPress, false, 0, true);
			kbd.addEventListener(KeyBoard.KBD, kbdPress, false, 0, true);
			
			clip.getYour.x = 1065;			
			clip.btnText.x = 1063;
			clip.btnEmail.x = 1381;
			clip.btnText.gotoAndStop(1);//blue, selected, bg
			clip.btnEmail.gotoAndStop(2);//clear bg
			
			clip.btnText.addEventListener(MouseEvent.MOUSE_DOWN, switchToText, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, switchToEmail, false, 0, true);
			clip.authCheck.addEventListener(MouseEvent.MOUSE_DOWN, toggleAuthCheck, false, 0, true);
			clip.btnSend.addEventListener(MouseEvent.MOUSE_DOWN, sendPressed, false, 0, true);
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePressed, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)){
				myContainer.removeChild(clip);
			}
			if (myContainer.contains(photoHolder)){
				myContainer.removeChild(photoHolder);
			}
			
			if (clip.contains(kbd)){
				clip.removeChild(kbd);
			}
			if (clip.contains(numpad)){
				clip.removeChild(numpad);
			}
			
			numpad.removeEventListener(KeyBoard.KBD, numPadPress);
			kbd.removeEventListener(KeyBoard.KBD, kbdPress);
			
			clip.btnText.removeEventListener(MouseEvent.MOUSE_DOWN, switchToText);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, switchToEmail);
			clip.authCheck.removeEventListener(MouseEvent.MOUSE_DOWN, toggleAuthCheck);
			clip.btnSend.removeEventListener(MouseEvent.MOUSE_DOWN, sendPressed);
			clip.btnRetake.addEventListener(MouseEvent.MOUSE_DOWN, retakePressed);
		}
		
		
		public function get data():Object
		{
			var o:Object = new Object();
			o.isEmail = isEmail;// boolean
			if (!isEmail){
				//phone number - remove dashes for NowPik
				o.num = userNumber.split("-").join("");
			}else{
				o.num = userNumber;//email
			}
			
			o.opt = clip.authCheck.currentFrame == 2 ? true : false;
			
			return o;
		}
		
		
		private function switchToText(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			isEmail = false;
			
			clip.btnText.gotoAndStop(1);//blue, selected, bg
			clip.btnEmail.gotoAndStop(2);//clear bg	
			
			clip.userInput.background = false;
			clip.userInput.text = "000-000-0000";
			//clip.userInput.setTextFormat(spacer8Message);
			clip.userInput.border = false;
			clip.userInput.textColor = 0x000000;
			clip.userInput.height = 64;
			
			TweenMax.to(clip.emailBG, .5, {alpha:0});
			
			TweenMax.to(clip.getYour, .5, {x:1065, ease:Expo.easeOut});
			TweenMax.to(clip.btnText, .5, {x:1063, ease:Expo.easeOut});
			TweenMax.to(clip.btnEmail, .5, {x:1381, ease:Expo.easeOut});
			
			TweenMax.to(clip.userInput, .5, {x:1067, y:336, ease:Expo.easeOut});
			TweenMax.to(clip.btnSend, .5, {x:1067, y:907, ease:Expo.easeOut});
			
			TweenMax.to(clip.authCheck, .5, {x:1067, ease:Expo.easeOut});
			TweenMax.to(clip.authText, .5, {x:1104, ease:Expo.easeOut});			
			
			TweenMax.to(numpad, .5, {x:1067, ease:Expo.easeOut});
			TweenMax.to(kbd, .5, {x:2000, ease:Expo.easeOut});
			
			userNumber = "";
		}
		
		
		private function switchToEmail(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			isEmail = true;
			
			clip.btnText.gotoAndStop(2);//clear bg
			clip.btnEmail.gotoAndStop(1);//blue, selected bg
			
			//clip.userInput.background = true;
			clip.userInput.text = "ENTER YOUR EMAIL ADDRESS";
			clip.userInput.setTextFormat(spacer8Email);
			clip.userInput.textColor = 0xab66b2;
			//clip.userInput.border = true;
			//clip.userInput.borderColor = 0xab66b2;
			//clip.userInput.height = 50;			
			
			TweenMax.to(clip.emailBG, .5, {alpha:1});
			
			TweenMax.to(clip.getYour, .5, {x:856, ease:Expo.easeOut});
			TweenMax.to(clip.btnText, .5, {x:856, ease:Expo.easeOut});
			TweenMax.to(clip.btnEmail, .5, {x:1174, ease:Expo.easeOut});
			
			TweenMax.to(clip.userInput, .5, {x:864, y:360, ease:Expo.easeOut});
			TweenMax.to(clip.btnSend, .5, {x:856, y:825, ease:Expo.easeOut});
			
			TweenMax.to(clip.authCheck, .5, {x:1950, ease:Expo.easeOut});
			TweenMax.to(clip.authText, .5, {x:1950, ease:Expo.easeOut});
			
			TweenMax.to(numpad, .5, {x:2000, ease:Expo.easeOut});
			TweenMax.to(kbd, .5, {x:755, ease:Expo.easeOut});			
			
			userNumber = "";
		}
		
		
		private function toggleAuthCheck(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.authCheck.currentFrame == 1){
				clip.authCheck.gotoAndStop(2);
			}else{
				clip.authCheck.gotoAndStop(1);
			}
		}
		
		
		private function sendPressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			clip.btnSend.fill.alpha = 1;
			TweenMax.to(clip.btnSend.fill, .3, {alpha:0});
			
			var v:Boolean;
			if (isEmail){
				v = Validator.isValidEmail(userNumber);
				if (!v){
					errorMsg.theText.text = "Please enter a valid email address";
				}
			}else{
				v = Validator.isValidPhoneNumber(userNumber);
				if (!v){
					errorMsg.theText.text = "Please enter a valid phone number";
				}
				if (clip.authCheck.currentFrame != 2){
					v = false;
					errorMsg.theText.text = "You must check the consent box";
				}
			}
			
			if(v){
				TweenMax.delayedCall(.3, sendComplete);//give button highlight time to fade out
			}else{				
				myContainer.addChild(errorMsg);				
				errorMsg.alpha = 0;
				TweenMax.to(errorMsg, .5, {alpha:1});
				TweenMax.to(errorMsg, .5, {alpha:0, delay:1, onComplete:hideError});
			}
		}
		
		
		private function sendComplete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function hideError():void
		{
			if (myContainer.contains(errorMsg)){
				myContainer.removeChild(errorMsg);
			}
		}
		
		
		private function retakePressed(e:MouseEvent):void
		{
			tim.buttonClicked();
			dispatchEvent(new Event(RETAKE));
		}
		
		
		private function numPadPress(e:Event):void
		{
			tim.buttonClicked();
			var c:String = numpad.getKey();
			
			if (c == "<<"){
				
				if(userNumber.length > 0){
					//delete the dash and the number... since the dash is auto added
					if (userNumber.length == 5 || userNumber.length == 9 || userNumber.length == 4 || userNumber.length == 8){
						userNumber = userNumber.substr(0, userNumber.length - 2);						
					}else{
						userNumber = userNumber.substr(0, userNumber.length - 1);
					}
				}				
			}else{				
				
				if(userNumber.length < 12){
					if (userNumber.length == 2 || userNumber.length == 6){
						userNumber += c;
						userNumber += "-";
					}else if (userNumber.length == 3 || userNumber.length == 7){
						userNumber += "-";
						userNumber += c;						
					}else{
						userNumber += c;
					}
				}				
			}
			
			if (userNumber == ""){
				clip.userInput.text = "000-000-0000";
			}else{
				clip.userInput.text = userNumber;
			}
			
			clip.userInput.setTextFormat(spacer8Message);			
		}
		
		
		private function kbdPress(e:Event):void
		{
			tim.buttonClicked();
			var c:String = kbd.getKey();
			
			if (c == "<<"){
				if (userNumber.length > 0){
					userNumber = userNumber.substr(0, userNumber.length - 1);
				}
			}else{
				userNumber += c;
			}
			
			if (userNumber == ""){
				clip.userInput.text = "ENTER YOUR EMAIL ADDRESS";
			}else{
				clip.userInput.text = userNumber;
			}
			
			clip.userInput.setTextFormat(spacer8Email);
		}
		
	}
	
}