/**
 * Key object for the com.dmennenoh.keyboard.KeyBoard class
 * KeyBoard instantiates Key objects as needed
 */
package com.dmennenoh.keyboard
{	
	import flash.display.*;	
	import flash.events.*;	
	import flash.text.*;	
	import flash.geom.Matrix;
	import com.greensock.TweenLite; //used for fading the highlight out
	
	
	public class Key extends Sprite
	{
		public static const KEYPRESS:String = "keyWasPressed";
		
		private var listIndex:int; //this keys index in the xml list of keys
		private var val:String; //keys normal value
		private var shiftVal:String;//keys shifted value
		private var shifted:Boolean;//true if shift has been pressed
		private var capsLocked:Boolean; //true if caps lock is on
		private var field:TextField;//text field to display keys normal value
		private var shiftedField:TextField;//text field to display keys shifted value
		private var showShifted:Boolean;//if true the keys shifted value is shown at upper left, with the normal value under it
		private var fieldFormat:TextFormat;//formatter for the fields
		
		private var bg:Shape; //shape for the background
		private var highlight:Shape; //shape for the highlight
		private var highlightAlpha:Number;//beginning alpha for the highlight shape
		private var fontClass:Class; //for embedded font
		
		
		/**
		 * Constructor - called by KeyBoard.draw()
		 * 
		 * @param 	ind int - they keys index in the xml list of keys
		 * @param	v String - the Key's normal value
		 * @param	sv String - the Key's shifted value
		 * @param	ssv String - Show Shifted Value - if "true" the shifted value is shown at upper left
		 * @param	w int - Key width
		 * @param	h int - Key height
		 * @param	r int - Key corner radius
		 * @param	borW int - Key border width
		 * @param	borCol Number - Key border color
		 * @param	hiCol Number - Key highlight color
		 * @param	hiAlpha Number - Start alpha for the highlight
		 * @param	bgType String - "flat" or "gradient"
		 * @param	gradType String - Gradient type - "smooth" or "tight"
		 * @param	bgCol1 Number - Background color number 1 - only color used if bgType is flat
		 * @param	bgCol2 Number - Background color number 2 - used if bgType is gradient
		 * @param	fontSize int - Size of the Key font
		 * @param	fontColor Number - Color of the key font
		 * @param	kbdFont String - Embedded font name in the library
		 * @param 	nudgeX int - moves the key text an additional amount
		 * @param 	nudgeY int - moves the key text an additional amount
		 */
		public function Key(ind:int, v:String, sv:String, ssv:String, w:int, h:int, r:int, borW:int, borCol:Number,  hiCol:Number, hiAlpha:Number, bgType:String, gradType:String, bgCol1:Number, bgCol2:Number, fontSize:int, fontColor:Number, kbdFont:Font, nudgeX:int, nudgeY:int, nudgeShiftX:int, nudgeShiftY:int)
		{
			listIndex = ind;
			
			shifted = false;
			
			showShifted = ssv == "true" ? true : false;
	 
			bg = new Shape();
			highlight = new Shape();
			
			var borAlpha:Number = borW == 0 ? 0 : 1;
			
			bg.graphics.lineStyle(borW, borCol, borAlpha, true);
			if (bgType == "gradient") {
				var matr:Matrix = new Matrix();
				if(gradType == "tight"){
					matr.createGradientBox(w, h * .5, 1.5707, 0, 0);
				}else {
					matr.createGradientBox(w, h, 1.5707, 0, 0);
				}
				bg.graphics.beginGradientFill(GradientType.LINEAR, [bgCol1, bgCol2], [1, 1], [0, 255], matr);
			} else {
				bg.graphics.beginFill(bgCol1, 1);
			}
			bg.graphics.drawRoundRect(0, 0, w, h, r, r);
			bg.graphics.endFill();
			
			highlightAlpha = hiAlpha;
			highlight.graphics.beginFill(hiCol, hiAlpha);
			highlight.graphics.drawRoundRect(0, 0, w, h, r, r);
			highlight.graphics.endFill();
			
			fieldFormat = new TextFormat();			
			fieldFormat.font = kbdFont.fontName;
			fieldFormat.color = fontColor;
			fieldFormat.size = fontSize;
			
			field = new TextField();
			shiftedField = new TextField();
			field.selectable = false;
			shiftedField.selectable = false;
			field.antiAliasType = AntiAliasType.ADVANCED;
			shiftedField.antiAliasType = AntiAliasType.ADVANCED;
			field.autoSize = TextFieldAutoSize.LEFT;
			shiftedField.autoSize = TextFieldAutoSize.LEFT;
			field.embedFonts = true;
			shiftedField.embedFonts = true;
			field.defaultTextFormat = fieldFormat;
			shiftedField.defaultTextFormat = fieldFormat;
			
			field.x = 3 + nudgeX;
			field.y = nudgeY;
			
			shiftedField.x = 3 + nudgeX;
			shiftedField.y = nudgeY;
			
			field.width = w - 6;
			shiftedField.width = w - 6;
			val = v;
			shiftVal = sv;
			field.text = val;
			shiftedField.text = sv;
			
			addChild(bg);	
			addChild(highlight);
			addChild(field);
			
			if (showShifted) {
				addChild(shiftedField);
				//place normal field at bottom when showShifted is true
				field.x += nudgeShiftX;
				field.y += nudgeShiftY;
				//shiftedField.x = 3 + nudgeShiftX;
				//shiftedField.y = nudgeShiftY;
			}			
			
			highlight.alpha = 0;
			
			capsLocked = false;
			
			addEventListener(MouseEvent.MOUSE_DOWN, keyPressed, false, 0, true);
		}		
		
		
		/**
		 * Returns the keys value or shift value
		 * @return String the keys value depending on the shift state
		 */
		public function get value():String
		{			
			if (shifted || capsLocked) {
				return shiftVal;
			}else{
				return val;
			}
		}
				
		/**
		 * Returns the keys value
		 * @return String keys unshifted value
		 */
		public function get unshiftedValue():String
		{
			return val;
		}
		
		/**
		 * Returns the index in the xml key list
		 * @return int 
		 */
		public function get index():int
		{
			return listIndex;
		}
		
		
		/**
		 * Gets the keys shifted value regardless of the shift state
		 * @return String shifted value
		 */
		public function get shiftValue():String
		{
			return shiftVal;
		}
		
		
		/**
		 * Sets the shifted flag
		 * Shows the shifted text in the key if showShifted is false 
		 * (if showShifted is true the shifted text is already showing at upper left)
		 * @param	shift
		 */
		public function toggleShift(shift:Boolean):void
		{
			shifted = shift;
			field.defaultTextFormat = fieldFormat;	
			if ((shifted && !showShifted) || capsLocked) {
				field.text = shiftVal;				
			}else {
				field.text = val;
			}
		}
		
		
		/**
		 * Dispatches a KEYPRESS event whenever a key is pressed
		 * Shows the highlight and fades it out
		 * @param	e
		 */
		private function keyPressed(e:MouseEvent):void
		{			
			highlight.alpha = highlightAlpha;
			if(val != "Shift"){
				TweenLite.to(highlight, .5, { alpha:0 } );
			}
			dispatchEvent(new Event(KEYPRESS));
		}
		public function unHighlight():void
		{
			TweenLite.to(highlight, .5, { alpha:0 } );
		}
		
		/**
		 * Toggles the capsLocked flag for any alpha keys (a - z)
		 */
		public function toggleCaps():void
		{
			if (isAlpha()) {
				capsLocked = !capsLocked;
				if(capsLocked){
					field.text = shiftVal;
				}else {
					field.text = val;
				}
			}
		}
		
		
		/**
		 * returns true if the keys value is an alpha value (a - z)
		 * @return
		 */
		private function isAlpha():Boolean
		{
			var cc:int = val.charCodeAt(0);
			if (cc >= 97 && cc <= 122 && val.length == 1) {
				return true;
			}
			return false;
		}

	}
	
}