/**
  Customizable on-screen keyboard
  
  usage:
	 
  import com.dmennenoh.keyboard.KeyBoard;
  
  var kbd:KeyBoard = new KeyBoard();
  kbd.addEventListener(KeyBoard.KEYFILE_LOADED, init, false, 0, true);
  kbd.loadKeyFile("basicKeyboard.xml"); or kbd.setKeyFile(xmlData);
  
  function init(e:Event):void{
    addChild(kbd);
    kbd.setFocusFields([theText]);
  }
  
  
  NOTES: Use Input text fields, instead of dynamic, to be able to display the text cursor.
  If publishing to AIR - use FULL_SCREEN_INTERACTIVE instead of just FULL_SCREEN or the 
  text cursor will be inconsistent
  
  Updates:
	  6/26/14
	  Made the Shift key stay highlighted, after being pressed, until a second key
	  is pressed.
	  
	  12/10/14
	  Modified draw() to allow keys to have individual font colors. In the XML file when type is flat or linear
	  the key will use the fontColor attribute to color the key text.
	  
	  6/15
	  allowed nudgex,nudgey in the individual key data - not incorporated into editor yet
	  
	  TODO: Need to update Editor to write the fontColor attribute
 */

package com.dmennenoh.keyboard
{
	import com.dmennenoh.keyboard.Key;
	import flash.display.*;	
	import flash.events.*;	
	import flash.net.*;	
	import flash.text.*;
	import flash.geom.*;	
	import flash.utils.*;	
	
	
	public class KeyBoard extends Sprite
	{
		public static const KBD:String = "KBD_KEY_PRESSED"; //Dispatched anytime any key is pressed
		public static const SUBMIT:String = "SUBMIT_PRESSED"; //Special - dispatched only when a key with the value Submit or Send is pressed
		public static const KEYFILE_LOADED:String = "keyFileLoaded"; //Dispatched when keyFileLoaded() is called, ie when loadKeyFile() is used
		
		private const IS_ANDROID:Boolean = false; //if true hacks are employed to deselect the text fields...
		
		private var keyContainer:Sprite;//container for all the Key objects
		private var bgContainer:Sprite; //container for the background shape
		private var keyFile:XML; //passed in keyboard XML file
		private var keys:XMLList; //list of keys derived from the xml - corresponds to keyFile.keyboard.keys.key - populated in setKeyFile()
		private var setup:XMLList; //list of setup data from the xml - populated in setKeyFile()
		private var targetField:TextField; //the textfield being typed into
		private var keyboardShifted:Boolean; //true if Shift is on
		
		private var numbers:Array;//for checking restrict
		private var focusFields:Array; //array of fields to keep focus on - set in setFocusFields()		
		private var focusLengths:Array; //array of max ield lengths
		private var focusTimer:Timer; //calls autoFocus every 100ms
		
		private var num:int; //just a predefined int for use in for loops
		private var keyboardFont:Font; //Font object for using embedded fonts
		private var lastChar:String; //String value of the last key pressed
		private var lastCharShifted:String; //String shifted value of the last key pressed
		private var lastCharUnshifted:String; //String of the keys unshifted value - set in keypress()
		private var keyIndex:int; //index in the key list of the last key pressed - set in keypress()
		private var enabled:Boolean; //true if the kbd is enabled - true by default - checked in keypress()
		
		private var lastKey:Key; //reference to the last Key object pressed
		
		
		/**
		 * Constructor
		 */
		public function KeyBoard()
		{
			numbers = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9");
			focusTimer = new Timer(100);
			focusTimer.addEventListener(TimerEvent.TIMER, autoFocus, false, 0, true);
			keyContainer = new Sprite();
			bgContainer = new Sprite();			
			enabled = true;
			lastChar = "";
			keyIndex = 0;
		}
		
		
		/**
		 * Loads a keyboard definition xml file
		 * 
		 * @param	fileName
		 */
		public function loadKeyFile(fileName:String):void
		{
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, xmlLoaded, false, 0, true);
			try{
				l.load(new URLRequest(fileName));
			}catch (e:Error) {
				trace("error:", e.message);
			}
		}		
		
		
		/**
		 * Sets the XML file used to draw the keyboard
		 * populates the keys and setup xmlLists
		 * 
		 * @param	$keyFile XML keyboard file
		 */
		public function setKeyFile($keyFile:XML):void
		{	
			keyFile = $keyFile;			
			keyboardShifted = false;
			keys = keyFile.keyboard.keys.key;
			setup = keyFile.keyboard.setup;
			var kbdFontClass:Class = getDefinitionByName(setup.font.@name) as Class;
			keyboardFont = new kbdFontClass() as Font;
			draw();
		}				
		
		
		/**
		 * Returns the XML set in setKeyFile()
		 * @return
		 */
		public function getKeyFile():XML
		{			
			return keyFile;
		}
		
		
		/**
		 * Sets the list of fields that can be edited
		 * Turns on focus checking
		 * 
		 * @param	fields Array of arrays - sub arrays are [fieldReference, maxChars]
		 */
		public function setFocusFields(fields:Array):void
		{
			focusFields = [];
			for (var i:int = 0; i < fields.length; i++){
				focusFields.push(fields[i][0]);
				TextField(fields[i][0]).maxChars = fields[i][1];
				TextField(fields[i][0]).addEventListener(MouseEvent.MOUSE_DOWN, focusChanged, false, 0, true);
			}
			targetField = focusFields[0];
			/*
			if(stage){
				stage.focus = targetField;
			}
			*/
			focusTimer.start();//calls autoFocus()
		}
		
		
		/**
		 * Switches the focus to the field pressed by the user
		 * @param	e
		 */		
		private function focusChanged(e:MouseEvent):void
		{
			var t:TextField = TextField(e.currentTarget);
			var curInd:int = focusFields.indexOf(t);			
			targetField = focusFields[curInd];
			t.stage.focus = targetField;
		}
		
		
		public function setFocus(ind:int):void
		{	
			targetField = focusFields[ind];			
			stage.focus = targetField;			
		}
		
		
		/**
		 * Shows the keyboard sprite and starts the focus timer
		 */
		public function show():void
		{			
			if (parent) {
				if (!parent.contains(this)) {					
					parent.addChild(this);
				}
			}
			focusTimer.start();
		}
		
		
		/**
		 * Hides the keyboard sprite and stops the focus timer
		 */
		public function hide():void
		{			
			if (parent) {
				if (parent.contains(this)) {
					parent.removeChild(this);
				}
			}
			focusTimer.stop();
		}		
		
		
		/**
		 * Returns the string of the last key pressed
		 * Dependent on the shift value
		 * lastChar is set in keypress()
		 * @return String lastChar
		 */
		public function getKey():String
		{
			return lastChar;
		}
		
		
		/**
		 * Returns the last key pressed normal (unshifted) value
		 * regardless of the state of the Shift key
		 * @return
		 */
		public function getUnshiftedKey():String
		{
			return lastCharUnshifted;
		}
		
		
		/**
		 * Returns the last key pressed shifted value
		 * set in keypress()
		 * @return String shift value
		 */
		public function getShiftKey():String
		{
			return lastCharShifted;
		}
		
		
		/**
		 * Returns the index in the xml list of keys
		 * set in keypress()
		 * @return int
		 */
		public function getKeyIndex():int
		{
			return keyIndex;
		}
		
		
		public function enableKeyboard():void
		{
			enabled = true;
		}
		
		
		public function disableKeyboard():void
		{
			enabled = false;
		}
		
		
		/**
		 * Called when the keyboard file is loaded
		 * ie - if loadKeyFile() is used 
		 * @param	e Event.COMPLETE
		 */
		private function xmlLoaded(e:Event):void
		{
			setKeyFile(new XML(e.target.data));
			dispatchEvent(new Event(KEYFILE_LOADED));			
		}
		
		
		/**
		 * Checks to see if the stage.focus is in the list of focusFields
		 * If not - stageFocus is set to the last targetField
		 * If stage.focus is in the list of fields and it's different from that
		 * last targetField then targetField is set to stage.focus
		 * @param	e
		 */		
		private function autoFocus(e:TimerEvent):void
		{
			if(stage){
				if (focusFields.indexOf(stage.focus) == -1) {
					stage.focus = targetField;
				}else {
					if (stage.focus != targetField) {
						targetField = TextField(stage.focus);
					}
				}
				
				//hack for android
				if(IS_ANDROID){
					if (targetField.selectionEndIndex != targetField.selectionBeginIndex) {
						targetField.setSelection(targetField.selectionEndIndex, targetField.selectionEndIndex);
					}
				}
			}
		}		
		
		
		private function tabToNextField():void
		{
			var curInd:int = focusFields.indexOf(targetField);
			curInd++;
			if (curInd >= focusFields.length) {
				curInd = 0;
			}
			targetField = focusFields[curInd];
			stage.focus = targetField;
		}
		
		
		/**
		 * Called by listener on each Key object created in draw()
		 * Gets the keys value and places the text into the targetField text field
		 * 
		 * @param	e Key.KEYPRESS Event
		 */
		private function keypress(e:Event):void
		{	
			var i:int;
			
			if (enabled) {
				
				if (lastKey) {
					if (lastKey.value == "Shift") {
						lastKey.unHighlight();
						if (Key(e.currentTarget).value == "Shift") {
							//user pressed Shift, then Shift again
							Key(e.currentTarget).unHighlight();
							lastKey = null;
							keyboardShifted = false;
							num = keyContainer.numChildren;
							for (i = 0; i < num; i++) {
								Key(keyContainer.getChildAt(i)).toggleShift(keyboardShifted);
							}
							return;
						}
					}
				}
				lastKey = Key(e.currentTarget);
				
				//hack for android
				if(stage && IS_ANDROID){
					if (targetField.selectionEndIndex != targetField.selectionBeginIndex) {
						targetField.setSelection(targetField.selectionEndIndex, targetField.selectionEndIndex);
					}
				}
				
				//call getters in the Key object
				lastChar = e.currentTarget.value; //current key value depending on Shift
				lastCharUnshifted = e.currentTarget.unshiftedValue;//key value
				lastCharShifted = e.currentTarget.shiftValue;//key shift value
				keyIndex = e.currentTarget.index;//keys index in the xmllist of keys
				
				//Check for special chars
				if ((lastChar.toLowerCase() == "backspace" || lastChar.toLowerCase() == "back") && targetField) {
					var bo:Boolean = targetField.selectionBeginIndex == 1 ? true : false;
					num = targetField.selectionBeginIndex == targetField.selectionEndIndex ? targetField.selectionBeginIndex - 1 : targetField.selectionBeginIndex;
					targetField.replaceText(num, targetField.selectionEndIndex, '');
					//targetField.setSelection(targetField.selectionEndIndex, targetField.selectionEndIndex);
					//trace("bs", targetField.selectionBeginIndex, targetField.selectionEndIndex, bo);
					if (bo) {
						stage.focus = targetField;
						targetField.setSelection(0,0);
					}				
				}else if (lastChar == "Shift") {
					keyboardShifted = !keyboardShifted;
					num = keyContainer.numChildren;
					for (i = 0; i < num; i++) {
						Key(keyContainer.getChildAt(i)).toggleShift(keyboardShifted);
					}
				}else if (lastChar == "Caps") {
					num = keyContainer.numChildren;
					for (i = 0; i < num; i++) {
						Key(keyContainer.getChildAt(i)).toggleCaps();
					}
				}else if (lastChar == "Enter" && targetField) {
					if(targetField.multiline){
						targetField.appendText("\n");
					}else {
						tabToNextField();
					}
				}else if (lastChar.toLowerCase() == "submit" || lastChar.toLowerCase() == "send") {
					dispatchEvent(new Event(SUBMIT));
				}else {
					if (targetField) {					
						if (targetField.restrict == null) {
							//any char can go in the field
							if(targetField.length < targetField.maxChars || targetField.maxChars == 0){
								targetField.replaceText(targetField.selectionBeginIndex, targetField.selectionEndIndex, lastChar);
							}
						}else {
							//targetField.restrict is not null - check for numbers and - only - for zip/phone etc.							
							if (targetField.restrict.substr(0, 1) == "-") {
								
								if (numbers.indexOf(lastChar) != -1 || lastChar == "-") {
									if(targetField.length < targetField.maxChars || targetField.maxChars == 0){
										targetField.replaceText(targetField.selectionBeginIndex, targetField.selectionEndIndex, lastChar);
									}
								}
								
							}else {
								//restrict is just 0-9
								if (numbers.indexOf(lastChar) != -1) {
									if(targetField.length < targetField.maxChars || targetField.maxChars == 0){
										targetField.replaceText(targetField.selectionBeginIndex, targetField.selectionEndIndex, lastChar);
									}
								}
							}
							
						}
						if(keyboardShifted){
							keyboardShifted = false;
							num = keyContainer.numChildren;
							for (var j:int = 0; j < num; j++) {
								Key(keyContainer.getChildAt(j)).toggleShift(keyboardShifted);
							}
						}
					}
					//autoTab?
					if (targetField.length == targetField.maxChars) {
						tabToNextField();
					}
				}
				//targetField.setSelection(targetField.selectionEndIndex, targetField.selectionEndIndex);				
				dispatchEvent(new Event(KBD));
				
			}//enabled
		}
		
		
		/**
		 * Draws the keyboard into the keyContainer sprite
		 * Draws the background into the bgContainer sprite
		 */
		private function draw():void
		{
			while (keyContainer.numChildren) {
				keyContainer.removeChildAt(0);
			}	
			while (bgContainer.numChildren) {
				bgContainer.removeChildAt(0);
			}
			bgContainer.graphics.clear();
			
			var thisKey:XML;
			num = keys.length();
			for (var i:int = 0; i < num; i++) {
				var a:Key;
				
				thisKey = keys[i];
				if(thisKey.@type != undefined) {
					//this key has unique color data - use it instead of the defaults
					if (thisKey.@nudgex != undefined) {
						a = new Key(i, thisKey.@val, thisKey.@shiftval, thisKey.@showshiftval, parseInt(thisKey.@w), parseInt(thisKey.@h), parseInt(setup.keybackground.@r), setup.keybackground.@borderWidth, setup.keybackground.@borderColor, setup.highlight.@color, setup.highlight.@startAlpha, thisKey.@type, thisKey.@gradienttype, thisKey.@color1, thisKey.@color2, parseInt(setup.font.@size), setup.font.@color, keyboardFont, thisKey.@nudgex, thisKey.@nudgey, setup.keyTextNudge.@shiftX, setup.keyTextNudge.@shiftY);
					}else{
						a = new Key(i, thisKey.@val, thisKey.@shiftval, thisKey.@showshiftval, parseInt(thisKey.@w), parseInt(thisKey.@h), parseInt(setup.keybackground.@r), setup.keybackground.@borderWidth, setup.keybackground.@borderColor, setup.highlight.@color, setup.highlight.@startAlpha, thisKey.@type, thisKey.@gradienttype, thisKey.@color1, thisKey.@color2, parseInt(setup.font.@size), setup.font.@color, keyboardFont, setup.keyTextNudge.@x, setup.keyTextNudge.@y, setup.keyTextNudge.@shiftX, setup.keyTextNudge.@shiftY);
					}
				}else{
					a = new Key(i, thisKey.@val, thisKey.@shiftval, thisKey.@showshiftval, parseInt(thisKey.@w), parseInt(thisKey.@h), parseInt(setup.keybackground.@r), setup.keybackground.@borderWidth, setup.keybackground.@borderColor, setup.highlight.@color, setup.highlight.@startAlpha, setup.keybackground.@type, setup.keybackground.@gradienttype, setup.keybackground.@color1, setup.keybackground.@color2, parseInt(setup.font.@size), setup.font.@color, keyboardFont, setup.keyTextNudge.@x, setup.keyTextNudge.@y, setup.keyTextNudge.@shiftX, setup.keyTextNudge.@shiftY);
				}
				keyContainer.addChild(a);
				a.x = parseInt(thisKey.@x); 
				a.y = parseInt(thisKey.@y);
				a.addEventListener(Key.KEYPRESS, keypress, false, 0, true);
			}
			
			//draw bg
			bgContainer.graphics.lineStyle(setup.mainbackground.@borderWidth, setup.mainbackground.@borderColor, 1, true);
			if (setup.mainbackground.@type == "gradient") {
				var matr:Matrix = new Matrix();
				if (setup.mainbackground.@gradienttype == "tight") {
					matr.createGradientBox(keyContainer.width, keyContainer.height * .5, 1.5707, 0, 0);//rotated 90 in radians
				}else{
					matr.createGradientBox(keyContainer.width, keyContainer.height, 1.5707, 0, 0);//rotated 90 in radians
				}				
				bgContainer.graphics.beginGradientFill(GradientType.LINEAR, [setup.mainbackground.@color1, setup.mainbackground.@color2], [1, 1], [0, 255], matr);
			} else {
				bgContainer.graphics.beginFill(setup.mainbackground.@color1, 1);
			}
			bgContainer.graphics.drawRoundRect(0, 0, setup.mainbackground.@w, setup.mainbackground.@h, setup.mainbackground.@r, setup.mainbackground.@r);
			bgContainer.graphics.endFill();
			
			addChild(bgContainer);
			addChild(keyContainer);
		}
	}	
}