package com.gmrmarketing.chevron.namePlate
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.*;
	import flash.ui.Mouse;
	import flash.display.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.CornerQuit;
	import flash.desktop.NativeApplication;
	
	
	public class Main extends MovieClip
	{
		private const TEXT_POS:int = 900; //vertical position the text is centered on
		private var kbd:KeyBoard;
		private var whichOne:int; //chalkboard - 2 is whiteboard
		private var cq:CornerQuit;
		private var cq2:CornerQuit;
		private var cornerContainer:Sprite;
		private var tf:TextFormat;
		private	var tf2:TextFormat;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();
			
			cornerContainer = new Sprite();
			addChild(cornerContainer);
			
			cq = new CornerQuit();
			cq2 = new CornerQuit();
			
			cq.addEventListener(CornerQuit.CORNER_QUIT, swapBG);
			cq2.addEventListener(CornerQuit.CORNER_QUIT, quitApp);
			
			cq.init(cornerContainer, "lr");
			cq2.init(cornerContainer, "ll");
			
			kbd = new KeyBoard();
			kbd.loadKeyFile("keyboard.xml");
			
			inputText.inputText.text = "";
			inputText.alpha = 0;
			
			whichOne = 2;
			
			bg.addEventListener(MouseEvent.MOUSE_DOWN, showKeyboard, false, 0, true);
			
			tf = theText.getTextFormat();//chalk
			tf2 = theText2.getTextFormat();//modern
			tf.leading = 0;
			tf2.leading = 0;	
			
			theText.mouseEnabled = false;
			theText2.mouseEnabled = false;
			
			swapBG();
		}
		
		
		private function swapBG(e:Event = null):void
		{
			if (whichOne == 2) {
				whichOne = 1;	//chalkboard
			}else {
				whichOne = 2; //whiteboard
			}
			
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			kbd.disableKeyboard();
			
			TweenMax.to(kbd, .5, { alpha:0, onComplete:reListenForKBD } );
			TweenMax.to(inputText, .5, { alpha:0 } );
			
			if (whichOne == 1) {
				bg.gotoAndStop(1);
				theText.text = "ENTER NAME";
				theText.visible = true;
				theText2.visible = false;
				theText.autoSize = TextFieldAutoSize.CENTER;
				tf.size = 64;
				theText.setTextFormat(tf);
			}else {
				bg.gotoAndStop(2);
				theText2.text = "ENTER NAME";
				theText2.visible = true;
				theText.visible = false;
				theText2.autoSize = TextFieldAutoSize.CENTER;
				tf2.size = 64;
				theText2.setTextFormat(tf2);
			}
		}
		
		
		private function showKeyboard(e:MouseEvent):void
		{
			bg.removeEventListener(MouseEvent.MOUSE_DOWN, showKeyboard);
			
			inputText.inputText.text = "";
			inputText.visible = true;
			
			kbd.enableKeyboard();
			addChild(kbd);
			kbd.x = 60;
			kbd.y = 655;
			kbd.scaleX = 1.25;
			kbd.scaleY = 1.6;
			kbd.setFocusFields([[inputText.inputText, 26]]);
			kbd.addEventListener(KeyBoard.SUBMIT, submitPressed, false, 0, true);
			
			TweenMax.to(kbd, .5, { alpha:1 } );
			TweenMax.to(inputText, .5, { alpha:1 } );
			
			if(whichOne == 1){
				TweenMax.to(theText, .5, { alpha:0 } );
			}else {
				TweenMax.to(theText2, .5, { alpha:0 } );
			}
		}		
		
		
		private function submitPressed(e:Event):void
		{
			kbd.removeEventListener(KeyBoard.SUBMIT, submitPressed);
			kbd.disableKeyboard();
			
			var s:String = String(inputText.inputText.text).toUpperCase();
			var topSpace:Number;
			var pixelSize:Number;//actual pixel size of the scaled font			
			var verticalSpace:int = 828; //only use the bottom 830 pixels
			var startVerticalSpaceAt:int = 450; //the Y where verticalSpace begins
			
			if (whichOne == 1) {
				
				theText.text = s;
				
				tf.size = 64;//default - fits full alphabet
				theText.setTextFormat(tf);

				while(theText.textWidth < 1750){	
					 tf.size = int(tf.size) + 1;
					 if (tf.size > 500) {
						tf.size = 500;
						theText.setTextFormat(tf);
						break;
					 }
					 theText.setTextFormat(tf);
				}				
				
				//.76 * font size = pixel size
				pixelSize = Math.round(.685 * int(tf.size));
				if (tf.size > 250) {
					topSpace = .35 * int(tf.size);
				}
				else {
					topSpace = .4 * int(tf.size);
				}
				
				theText.y = (startVerticalSpaceAt + ((verticalSpace - pixelSize) * .5)) - topSpace;
				trace(tf.size, pixelSize, topSpace, theText.y);
				
				TweenMax.to(kbd, .5, { alpha:0 } );
				TweenMax.to(inputText, .5, { alpha:0 } );
				TweenMax.to(theText, .5, { alpha:1, onComplete:reListenForKBD } );
				
			}else {				
				
				theText2.text = s;	
				
				tf2.size = 64;//default - fits full alphabet
				theText2.setTextFormat(tf2);

				while(theText2.textWidth < 1750){	
					 tf2.size = int(tf2.size) + 1;
					 if (tf2.size > 500) {
						tf2.size = 500;
						theText2.setTextFormat(tf2);
						break;
					 }
					 theText2.setTextFormat(tf2);
				}				
				
				//.694 * font size = pixel size
				pixelSize = Math.round(.694 * int(tf2.size));
				if (tf2.size > 250) {
					topSpace = .1 * int(tf2.size);
				}else {
					topSpace = .135 * int(tf2.size);
				}
				
				trace(tf2.size, pixelSize, topSpace);
				
				theText2.y = (startVerticalSpaceAt + ((verticalSpace - pixelSize) * .5)) - topSpace;
				trace(tf2.size, pixelSize, topSpace, theText2.y);
				
				TweenMax.to(kbd, .5, { alpha:0 } );
				TweenMax.to(inputText, .5, { alpha:0 } );
				TweenMax.to(theText2, .5, { alpha:1, onComplete:reListenForKBD } );
			}
		}
		
		
		private function reListenForKBD():void
		{
			inputText.visible = false;
			kbd.y = 1300;
			bg.addEventListener(MouseEvent.MOUSE_DOWN, showKeyboard, false, 0, true);
		}	
		
		
		private function quitApp(e:Event):void
		{
			NativeApplication.nativeApplication.exit();
		}
			
	}
	
}