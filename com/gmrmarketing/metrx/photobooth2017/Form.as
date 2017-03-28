package com.gmrmarketing.metrx.photobooth2017
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.gmrmarketing.utilities.Validator;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Form extends EventDispatcher
	{
		public static const COMPLETE:String = "formComplete";
		public static const HIDDEN:String = "formHidden";
		
		private var clip:MovieClip;
		private var _container:DisplayObjectContainer;
		
		private var kbd:KeyBoard;
		private var tim:TimeoutHelper;
		
		
		public function Form()
		{
			clip = new mcForm();
			
			clip.fname.title.text = "FIRST NAME";
			clip.lname.title.text = "LAST NAME";
			clip.email.title.text = "EMAIL";
			
			tim = TimeoutHelper.getInstance();
			
			kbd = new KeyBoard();
			kbd.loadKeyFile("keyboard.xml"); 
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			_container = c;
		}
		
		
		public function show():void
		{
			if (!_container.contains(clip)){
				_container.addChild(clip);
			}
			
			clip.x = 0;
			clip.tread.x = 1920;
			clip.fname.x = 1920;
			clip.lname.x = 1920;
			clip.email.x = 1920;
			clip.check.x = 1920;
			clip.check.check.visible = false;
			clip.check.addEventListener(MouseEvent.MOUSE_DOWN, toggleCheck, false, 0, true);
			
			clip.fname.theText.text = "";
			clip.lname.theText.text = "";
			clip.email.theText.text = "";
			
			clip.title.alpha = 0;
			
			TweenMax.to(clip.tread, .5, {x:216, ease:Expo.easeOut});
			
			TweenMax.to(clip.fname, .5, {x:868, ease:Expo.easeOut, delay:.3});
			TweenMax.to(clip.lname, .5, {x:868, ease:Expo.easeOut, delay:.4});
			TweenMax.to(clip.email, .5, {x:868, ease:Expo.easeOut, delay:.5});
			TweenMax.to(clip.check, .5, {x:868, ease:Expo.easeOut, delay:.6});
			
			TweenMax.to(clip.title, .5, {alpha:1, delay:.75});
			
			kbd.y = 1100;// 680;
			kbd.x = 280;
			if(!clip.contains(kbd)){
				clip.addChild(kbd);
			}
			kbd.setFocusFields([[clip.fname.theText, 0], [clip.lname.theText, 0], [clip.email.theText, 0]]);
			kbd.addEventListener(KeyBoard.SUBMIT, validate, false, 0, true);
			kbd.addEventListener(KeyBoard.KBD, butClick, false, 0, true);
			clip.stage.focus = clip.fname.theText;
			
			TweenMax.to(kbd, .5, {y:640, ease:Expo.easeOut, delay:.75});
		}
		
		
		private function butClick(e:Event):void
		{
			tim.buttonClicked();
		}
		
		
		public function hide():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, validate);
			kbd.removeEventListener(KeyBoard.KBD, butClick);
			
			TweenMax.to(clip, .5, {x: -1920, onComplete:kill});
		}
		
		public function reset():void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, validate);
			kbd.removeEventListener(KeyBoard.KBD, butClick);
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			if (clip.contains(kbd)){
				clip.removeChild(kbd);
			}
		}
		
		
		public function get data():Object
		{
			return {"fname":clip.fname.theText.text, "lname":clip.lname.theText.text, "email":clip.email.theText.text, "optin":clip.check.check.visible ? true : false};
		}
		
		
		private function kill():void
		{
			dispatchEvent(new Event(HIDDEN));
			
			if (_container.contains(clip)){
				_container.removeChild(clip);
			}
			if (clip.contains(kbd)){
				clip.removeChild(kbd);
			}
		}
		
		
		private function toggleCheck(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.check.check.visible){
				clip.check.check.visible = false;
			}else{
				clip.check.check.visible = true;
			}
		}
		
		
		private function validate(e:Event):void
		{
			if (Validator.isValidEmail(clip.email.theText.text) && clip.fname.theText.text != "" && clip.lname.theText.text != ""){
				dispatchEvent(new Event(COMPLETE));
			}else{
				if (clip.fname.theText.text == ""){
					clip.fname.title.text = "PLEASE ENTER YOUR FIRST NAME";
					clip.fname.title.alpha = 0;
					TweenMax.to(clip.fname.title, .5, {alpha:1, colorTransform:{tint:0xE55F25, tintAmount:1}});					
					TweenMax.to(clip.fname.title, .3, {alpha:0, delay:2, onComplete:showFnameText});
				}else if (clip.lname.theText.text == ""){
					clip.lname.title.text = "PLEASE ENTER YOUR LAST NAME";
					clip.lname.title.alpha = 0;
					TweenMax.to(clip.lname.title, .5, {alpha:1, colorTransform:{tint:0xE55F25, tintAmount:1}});					
					TweenMax.to(clip.lname.title, .3, {alpha:0, delay:2, onComplete:showLnameText});
				}else{
					clip.email.title.text = "PLEASE ENTER A VALID EMAIL";
					clip.email.title.alpha = 0;
					TweenMax.to(clip.email.title, .5, {alpha:1, colorTransform:{tint:0xE55F25, tintAmount:1}});				
					TweenMax.to(clip.email.title, .3, {alpha:0, delay:2, onComplete:showEmailText});
				}
			}
		}
		
		private function showFnameText():void
		{
			clip.fname.title.text = "FIRST NAME";
			TweenMax.to(clip.fname.title, .5, {alpha:1, colorTransform:{tint:0xFFFFFF, tintAmount:1}});
		}
		private function showLnameText():void
		{
			clip.lname.title.text = "LAST NAME";
			TweenMax.to(clip.lname.title, .5, {alpha:1, colorTransform:{tint:0xFFFFFF, tintAmount:1}});
		}
		private function showEmailText():void
		{
			clip.email.title.text = "EMAIL";
			TweenMax.to(clip.email.title, .5, {alpha:1, colorTransform:{tint:0xFFFFFF, tintAmount:1}});
		}
		
	}
	
}