package com.gmrmarketing.nissan.canada.ridedrive2013
{
	import flash.display.*;	
	import flash.events.*;	
	import com.greensock.TweenMax;	
	
	public class PinEntry extends EventDispatcher
	{
		public static const PIN_ENTERED:String = "pinEntered";
		public static const PIN_CLOSED:String = "pinClosed";
		public static const PIN_SHOWING:String = "pinShowing";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var numString:String;
		private var lang:String;
		
		
		public function PinEntry()
		{
			lang = "en"; //default
			clip = new mcNumPad();
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		public function setLanguage($lang:String):void
		{
			lang = $lang;
			if (lang == "en") {
				clip.please.gotoAndStop(1);
			}else {
				clip.please.gotoAndStop(2);
			}
		}
		
		public function show():void
		{
			numString = "xxxxx";
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			clip.alpha = 0;
			clip.prior.alpha = 0;//text at top
			clip.please.alpha = 1;
			
			clip.theText.text = numString;
			
			clip.btn1.addEventListener(MouseEvent.MOUSE_DOWN, p1, false, 0, true);
			clip.btn2.addEventListener(MouseEvent.MOUSE_DOWN, p2, false, 0, true);
			clip.btn3.addEventListener(MouseEvent.MOUSE_DOWN, p3, false, 0, true);
			clip.btn4.addEventListener(MouseEvent.MOUSE_DOWN, p4, false, 0, true);
			clip.btn5.addEventListener(MouseEvent.MOUSE_DOWN, p5, false, 0, true);
			clip.btn6.addEventListener(MouseEvent.MOUSE_DOWN, p6, false, 0, true);
			clip.btn7.addEventListener(MouseEvent.MOUSE_DOWN, p7, false, 0, true);
			clip.btn8.addEventListener(MouseEvent.MOUSE_DOWN, p8, false, 0, true);
			clip.btn9.addEventListener(MouseEvent.MOUSE_DOWN, p9, false, 0, true);
			clip.btn0.addEventListener(MouseEvent.MOUSE_DOWN, p0, false, 0, true);
			clip.btnBack.addEventListener(MouseEvent.MOUSE_DOWN, pBack, false, 0, true);
			clip.btnSubmit.addEventListener(MouseEvent.MOUSE_DOWN, pSubmit, false, 0, true);			
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, pClose, false, 0, true);
			
			if (lang == "en") {
				clip.please.gotoAndStop(1);
			}else {
				clip.please.gotoAndStop(2);
			}
			
			TweenMax.to(clip, .5, { alpha:1, onComplete:showing } );
		}
		
		private function showing():void
		{
			dispatchEvent(new Event(PIN_SHOWING));
		}
		
		public function hide():void
		{
			clip.btn1.removeEventListener(MouseEvent.MOUSE_DOWN, p1);
			clip.btn2.removeEventListener(MouseEvent.MOUSE_DOWN, p2);
			clip.btn3.removeEventListener(MouseEvent.MOUSE_DOWN, p3);
			clip.btn4.removeEventListener(MouseEvent.MOUSE_DOWN, p4);
			clip.btn5.removeEventListener(MouseEvent.MOUSE_DOWN, p5);
			clip.btn6.removeEventListener(MouseEvent.MOUSE_DOWN, p6);
			clip.btn7.removeEventListener(MouseEvent.MOUSE_DOWN, p7);
			clip.btn8.removeEventListener(MouseEvent.MOUSE_DOWN, p8);
			clip.btn9.removeEventListener(MouseEvent.MOUSE_DOWN, p9);
			clip.btn0.removeEventListener(MouseEvent.MOUSE_DOWN, p0);
			clip.btnBack.removeEventListener(MouseEvent.MOUSE_DOWN, pBack);
			clip.btnSubmit.removeEventListener(MouseEvent.MOUSE_DOWN, pSubmit);
			clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, pClose);
			
			if (container.contains(clip)) {
				container.removeChild(clip);
			}	
		}
		
		
		public function getPin():String 
		{
			return numString;
		}
		
		
		public function idExists():void
		{
			clip.prior.alpha = 1;
			clip.please.alpha = 0;
			TweenMax.to(clip.prior, 1, { alpha:0, delay:2, onComplete:showPlease } );
		}
		
		
		private function showPlease():void
		{
			clip.please.alpha = 1;
			clip.theText.text = "xxxxx";
			numString = "xxxxx";
		}
		
		
		private function p1(e:MouseEvent):void
		{
			clip.btn1.alpha = 1;
			TweenMax.to(clip.btn1, .25, { alpha:0 } );
			addChar("1");
		}		
		
		private function p2(e:MouseEvent):void
		{
			clip.btn2.alpha = 1;
			TweenMax.to(clip.btn2, .25, { alpha:0 } );
			addChar("2");
		}
		
		private function p3(e:MouseEvent):void
		{
			clip.btn3.alpha = 1;
			TweenMax.to(clip.btn3, .25, { alpha:0 } );
			addChar("3");
		}
		
		private function p4(e:MouseEvent):void
		{
			clip.btn4.alpha = 1;
			TweenMax.to(clip.btn4, .25, { alpha:0 } );
			addChar("4");
		}
		
		private function p5(e:MouseEvent):void
		{
			clip.btn5.alpha = 1;
			TweenMax.to(clip.btn5, .25, { alpha:0 } );
			addChar("5");
		}
		
		private function p6(e:MouseEvent):void
		{
			clip.btn6.alpha = 1;
			TweenMax.to(clip.btn6, .25, { alpha:0 } );
			addChar("6");
		}
		
		private function p7(e:MouseEvent):void
		{
			clip.btn7.alpha = 1;
			TweenMax.to(clip.btn7, .25, { alpha:0 } );
			addChar("7");
		}
		
		private function p8(e:MouseEvent):void
		{
			clip.btn8.alpha = 1;
			TweenMax.to(clip.btn8, .25, { alpha:0 } );
			addChar("8");
		}
		
		private function p9(e:MouseEvent):void
		{
			clip.btn9.alpha = 1;
			TweenMax.to(clip.btn9, .25, { alpha:0 } );
			addChar("9");
		}
		
		private function p0(e:MouseEvent):void
		{
			clip.btn0.alpha = 1;
			TweenMax.to(clip.btn0, .25, { alpha:0 } );
			addChar("0");
		}
		
		private function pBack(e:MouseEvent):void
		{
			clip.btnBack.alpha = 1;
			TweenMax.to(clip.btnBack, .25, { alpha:0 } );
			addChar("Back");
		}
		
		private function pSubmit(e:MouseEvent):void
		{
			clip.btnSubmit.alpha = 1;
			TweenMax.to(clip.btnSubmit, .25, { alpha:0, onComplete:addChar, onCompleteParams:["Submit"] } );
			//addChar("Submit");
		}
		
		private function pClose(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			dispatchEvent(new Event(PIN_CLOSED));
		}		
		
		private function addChar(char:String):void
		{
			if (numString == "xxxxx") {
				if(char != "Back" && char != "Submit"){
					numString = char;
				}
			}else {
				if (char == "Back") {
					if (numString.length > 0) {
						numString = numString.substr(0, numString.length - 1);
						if (numString.length == 0) {
							numString = "xxxxx";
						}
					}else {
						numString = "xxxxx";
					}
				}else if (char == "Submit") {
					if(numString.length == 5){
						dispatchEvent(new Event(PIN_ENTERED));
					}
				}else{
					if(numString.length < 5){
						numString += char;
					}
				}
			}
			clip.theText.text = numString;
		}
	}
	
}