package com.gmrmarketing.humana.recipes
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.Validator;
	import com.greensock.TweenMax;
	import com.dmennenoh.keyboard.KeyBoard;
	
	public class Email extends EventDispatcher
	{
		public static const CANCELED:String = "emailCanceled";
		public static const SEND:String = "emailSend";
		
		private var recipe:XML;
		private var imageURL:String = "http://digimedia.gmrmarketing.com/HumanaVitalityRecipe/";		
		private var emailURL:String = "https://sendgrid.com/api/mail.send.json?"; 
		
		private var kbd:KeyBoard;
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		
		
		public function Email()
		{
			clip = new mcEmail();//dialog for entering email
			kbd = new KeyBoard();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function show():void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
				
				//container.addChild(kbd);
				kbd.addEventListener(KeyBoard.KEYFILE_LOADED, initKbd, false, 0, true);
				kbd.loadKeyFile("humana_keyboard.xml");
			}
			
			clip.alpha = 1;
			clip.btnCancel.theText.text = "Cancel";
			clip.btnEmail.theText.text = "Email";
			clip.theEmail.text = "";
			clip.theError.theText.text = "";
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, cancelClicked, false, 0, true);
			clip.btnEmail.addEventListener(MouseEvent.MOUSE_DOWN, emailClicked, false, 0, true);
			container.stage.addEventListener(KeyboardEvent.KEY_DOWN, checkEnter, false, 0, true);
			container.stage.focus = clip.theEmail;
		}
		
		private function initKbd(e:Event):void
		{
			kbd.removeEventListener(KeyBoard.KEYFILE_LOADED, initKbd);
			container.addChild(kbd);
			kbd.y = 650;
			kbd.setFocusFields([clip.theEmail]);
			kbd.addEventListener(KeyBoard.SUBMIT, submitKeyboard, false, 0, true);
			kbd.enableKeyboard();
		}
		
		public function hide(fade:Boolean = false):void
		{
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, cancelClicked);
			clip.btnEmail.removeEventListener(MouseEvent.MOUSE_DOWN, emailClicked);
			container.stage.removeEventListener(KeyboardEvent.KEY_DOWN, checkEnter);
			kbd.removeEventListener(KeyBoard.SUBMIT, submitKeyboard);
			kbd.disableKeyboard();
			
			if (fade) {
				clip.theError.theText.text = "Thanks! Your recipe will be sent shortly.";
				TweenMax.to(clip, 2, { alpha:0, delay:3, onComplete:hide } );
			}else{
				if (container.contains(clip)) {
					container.removeChild(clip);
					container.removeChild(kbd);
				}
			}
		}
		
		private function submitKeyboard(e:Event):void
		{
			emailClicked();
		}
		private function cancelClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(CANCELED));
		}
		
		private function checkEnter(e:KeyboardEvent):void
		{
			if (e.charCode == 13) {
				emailClicked();
			}
		}
		
		private function emailClicked(e:MouseEvent = null):void
		{
			if (Validator.isValidEmail(clip.theEmail.text)) {
				dispatchEvent(new Event(SEND));
			}else {
				clip.theError.theText.text = "Please enter a valid email";
				clip.theError.alpha = 0;
				TweenMax.to(clip.theError, .5, { alpha:1, onComplete:fadeError } );
			}
		}
		
		
		private function fadeError():void
		{
			TweenMax.to(clip.theError, 1, { alpha:0, delay:3 } );
		}
		
		
		public function sendEmail($recipe:XML):void
		{
			recipe = $recipe;
			
			var s:String = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\"><html><head><meta http-equiv=\"content-type\" content=\"text/html; charset=UTF-8\"/><title></title></head><body><table width='800' style='background-color:#e3e1e2;' border='0'>";
			s += "<tr><td><img valign='bottom' width='800' height='109' src='" + imageURL + "header_email.jpg'/></td></tr>";
			s += "<tr><td><img valign='top' width='800' height='355' src='" + imageURL + recipe.detailImage + "'/></td></tr>";
			
			s += "<tr>";
			s += "<td style='padding-left:10px; padding-right:10px;'><span style='font-family: Tahoma, Arial, sans-serif; font-size: 18px; color: #333333;'>" + recipe.title + "</span><br/>";
			
			s += "<span style='font-family: Tahoma, Arial, sans-serif; font-size: 12px; color: #333333;'>Recipe courtesy of: " + recipe.courtesyOf + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Serves: " + recipe.numberOfServings + "</span></td></tr><tr><td style='padding-left:10px; padding-right:10px;'>";
			
			s += "<br/><p style='font-family: Tahoma, Arial, sans-serif; font-size: 13; color: #333333;'>" + recipe.description + "</p>";
			s += "<img align='right' src='" + imageURL + "hline.jpg'/><br/><img align='right' src='" + imageURL + "ingredients.jpg'/>";
			
			s += "<ul style='font-family: Tahoma, Arial, sans-serif; font-size: 13; color: #333333;'>";
			
			var list:XMLList = recipe.ingredients.item;
			for (var i:int = 0; i < list.length(); i++) {					
					s += "<li>" + list[i] + "</li>";
			}
			
			s += "</ul><img align='right' src='" + imageURL + "hline.jpg'/><br/><img align='right' src='" + imageURL + "directions.jpg'/>";
			
			s += "<ol style='font-family: Tahoma, Arial, sans-serif; font-size: 13; color: #333333;'>";
			
			list = recipe.directions.item;			
			for (i = 0; i < list.length(); i++) {
				s += "<li>" + list[i] + "</li>";
			}
			
			s += "</ol><img align='right' src='" + imageURL + "hline.jpg'/><br/><img align='right' src='" + imageURL + "nutrition.jpg'/>";
			
			s += "<ul style='font-family: Tahoma, Arial, sans-serif; font-size: 13; color: #333333;'>";
			
			list = recipe.nutrition.item;
			for (i = 0; i < list.length(); i++) {
				s += "<li>" + list[i] + "</li>";
			}
			
			s += "</ul></td></tr></table></body></html>";
			
			//s = escape(s);
			
			var em:String = clip.theEmail.text;//"dmennenoh@gmrmarketing.com";//
			
			//emailURL += em + "&html=" + s;			
			
			var request:URLRequest = new URLRequest(emailURL);
			var vars:URLVariables = new URLVariables();
			vars.api_user = "gmrappdevelopers";
			vars.api_key = "n0s0upf0ru";
			vars.subject = "Humana Vitality Recipe";
			vars.from = "VitalityHealthyFood@gmrmarketing.com";
			vars.to = em;
			vars.html = s;
			
			request.data = vars;
					
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);
		}
		
		
		private function dataError(e:IOErrorEvent):void
		{
			
		}
		
		private function dataPosted(e:Event):void
		{
			trace("done");
		}
		
	}
	
}