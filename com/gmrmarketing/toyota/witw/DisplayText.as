/**
 * Single text box on the social wall
 * Instantiated by Social.as
 */
package com.gmrmarketing.toyota.witw
{
	import flash.display.*;
	import flash.events.*;	
	import com.greensock.TweenMax;
	import flash.text.*;
	
	
	public class DisplayText extends Sprite
	{
		private var myTexts:Array;
		private var currentIndex:int;
		private var userField:TextField;
		private var userFormat:TextFormat;
		private var messageField:TextField;
		private var messageFormat:TextFormat;		
		private var originalUserSize:int;
		private var originalMessageSize:int;
		
		/**
		 * 
		 * @param	$x xLoc on stage
		 * @param	$y yLoc on stage
		 * @param	w text box width
		 * @param	h text box height
		 * @param	borderColor text box edge color
		 * @param	fillColor text box fill color
		 */
		public function DisplayText($x:int, $y:int, w:int, h:int, borderColor:Number, fillColor:Number):void
		{
			x = $x;
			y = $y;
			
			var g:Graphics = graphics;
			g.lineStyle(2, borderColor);
			g.beginFill(fillColor, 1);
			g.drawRect(0, 0, w, h);
			g.endFill();			
			
			var userFont:Font = new helvNeueBold();	
			var messageFont:Font = new helvNeue();//arial unicode...
			
			userFormat = new TextFormat();						
			userFormat.font = userFont.fontName;
			
			messageFormat = new TextFormat();			
			messageFormat.font = messageFont.fontName;
			
			if (fillColor == 0xFFFFFF) {
				userFormat.color = 0x38393A;//gray text if bg is white
				messageFormat.color = 0x58595B;
				//if(h == 245){
					userFormat.size = 19;
					originalUserSize = 19;					
					messageFormat.size = 18;
					originalMessageSize = 18;
					messageFormat.leading = -1.4;
				//}else {
					//userFormat.size = 18;
					//originalUserSize = 18;					
					//messageFormat.size = 16;
					//messageFormat.leading = -2;
				//}
			}else {
				userFormat.color = 0xFFFFFF;
				userFormat.size = 26;
				originalUserSize = 26;
				messageFormat.color = 0xFFFFFF;
				messageFormat.size = 22;
				originalMessageSize = 22;
				messageFormat.leading = -1.4;
			}
			
			userField = new TextField();
			userField.defaultTextFormat = userFormat;
			userField.embedFonts = true;
			userField.antiAliasType = AntiAliasType.ADVANCED;
			//userField.autoSize = TextFieldAutoSize.LEFT;
			userField.x = 7;
			userField.y = 5;
			userField.width = w - 10;
			userField.height = h - 10;
			userField.autoSize = TextFieldAutoSize.LEFT;
			
			messageField = new TextField();
			messageField.defaultTextFormat = messageFormat;
			messageField.embedFonts = true;
			messageField.antiAliasType = AntiAliasType.ADVANCED;
			messageField.gridFitType = GridFitType.SUBPIXEL;
			//messageField.autoSize = TextFieldAutoSize.LEFT;
			messageField.x = 7;
			if(originalUserSize < 26){
				messageField.y = 28;
			}else {
				messageField.y = 32;
			}
			messageField.width = w - 12;
			messageField.height = h - 25;
			messageField.wordWrap = true;
			
			addChild(userField);
			addChild(messageField);
			
			myTexts = [];
			currentIndex = 0;
			alpha = 0;
		}
		
		
		/**
		 * adds an object with message,user properties
		 * @param	o
		 */
		public function addText(o:Object):void
		{
			myTexts.push(o);
		}
		
		
		public function hide():void
		{
			TweenMax.to(this, 1, { alpha:0, delay:Math.random(), onComplete:reset } );
		}
		
		
		private function reset():void
		{
			myTexts = [];
			currentIndex = 0;
		}
		
		
		public function transition(readTime:int = 5):void
		{			
			TweenMax.delayedCall(readTime, doTransition);
		}		
		
		
		public function doTransition():void
		{
			//alpha = 0;
			var o:Object = myTexts[currentIndex];
			
			//reduce author font size so it fits - one line only
			userField.text = "@" + o.user;
			userFormat.size = originalUserSize;
			userField.setTextFormat(userFormat);
			while (userField.textWidth > width - 15) {				
				 userFormat.size = int(userFormat.size) - 1;
				 userField.setTextFormat(userFormat);
			}
			
			messageField.text = o.message;
			//reduce to fit - to a min of 4 font sizes smaller
			messageFormat.size = originalMessageSize;
			messageField.setTextFormat(messageFormat);
			var startSize:int = originalMessageSize;
			var smallest:int = startSize - 4;
			while (messageField.textHeight > messageField.height-5 && startSize >= smallest) {
				startSize--;				
				messageFormat.size = startSize;
				messageField.setTextFormat(messageFormat);	
			}
			//if it still doesn't fit add an ellipsis
			while (messageField.textHeight > messageField.height - 5) {
				messageField.text = messageField.text.slice(0, -4) + "...";
			}
			//number of seconds @ 1.5 words per second
			var readTime:Number = Math.max(4, messageField.text.match(/[^\s]+/g).length / 1.5);
			
			currentIndex++;
			if (currentIndex >= myTexts.length) {
				currentIndex = 0;
			}
			
			messageField.alpha = 0;
			userField.alpha = 0;
			if(alpha == 0){
				TweenMax.to(this, 1, { alpha:1 } );
			}
			TweenMax.to(userField, .5, { alpha:1, delay:.2 } );
			TweenMax.to(messageField, .5, { alpha:1, delay:.3, onComplete:transition, onCompleteParams:[readTime] } );			
		}
		
	}
	
}