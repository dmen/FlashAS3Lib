/**
 * AIR Keyboard Editor
 */

package com.dmennenoh.keyboard
{
	import flash.display.*;
	import flash.events.*;
	import com.dmennenoh.keyboard.KeyBoard;
	import com.dmennenoh.keyboard.FileUtils;
	
	
	public class Editor extends MovieClip
	{
		private var keyboardContainer:Sprite;
		private var kbd:KeyBoard;
		private var keyFile:XML;
		private var curKeyVal:String;
		private var curShiftVal:String;
		private var curKeyIndex:int;		
		private var file:FileUtils;
		private var kbdBG:Sprite; //colored background behind the kbd
		
		public function Editor()
		{					
			file = new FileUtils();
			file.addEventListener(FileUtils.FILE_OPENED, newXMLOpened, false, 0, true);
			
			kbd = new KeyBoard();
			
			kbdBG = new Sprite();
			kbdBG.graphics.beginFill(0xCCCCCC, 1);
			kbdBG.graphics.drawRect(0, 0, 1280, 400);
			kbdBG.graphics.endFill();
			addChild(kbdBG);
			kbdBG.y = 31;
			
			keyboardContainer = new Sprite();
			keyboardContainer.addChild(kbd);
			keyboardContainer.x = 40;
			keyboardContainer.y = 40;
			addChild(keyboardContainer);
			keyboardContainer.addEventListener(MouseEvent.MOUSE_DOWN, startKBDDrag, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopKBDDrag, false, 0, true);
			
			kbd.addEventListener(KeyBoard.KBD, keyPressed, false, 0, true);			
			btnOpen.addEventListener(MouseEvent.CLICK, openXML, false, 0, true);
			kbdBGColor.addEventListener(Event.CHANGE, kbdBGColorColorChanged, false, 0, true);
			kbdBGColor.selectedColor = 0xCCCCCC;
		}
		
		
		/**
		 * Called from newXMLOpened()
		 * Adds button/component listeners and populates the UI with the XML data
		 */
		private function init():void
		{			
			//add listeners
			btnSet.addEventListener(MouseEvent.CLICK, setKeyValue, false, 0, true);			
			bgWidth.addEventListener(Event.CHANGE, bgSizeChanged, false, 0, true);
			bgHeight.addEventListener(Event.CHANGE, bgSizeChanged, false, 0, true);
			bgColor1.addEventListener(Event.CHANGE, setBGColor, false, 0, true);
			bgColor2.addEventListener(Event.CHANGE, setBGColor, false, 0, true);
			bgCornerRadius.addEventListener(Event.CHANGE, bgCornerRadiusChanged, false, 0, true);
			btnAddKey.addEventListener(MouseEvent.CLICK, addNewKey, false, 0, true);
			btnDeleteKey.addEventListener(MouseEvent.CLICK, deleteKey, false, 0, true);
			btnSave.addEventListener(MouseEvent.CLICK, saveXML, false, 0, true);
			keyWidth.addEventListener(Event.CHANGE, keyWidthChanged, false, 0, true);
			keyHeight.addEventListener(Event.CHANGE, keyHeightChanged, false, 0, true);
			keyStroke.addEventListener(Event.CHANGE, keyStrokeChanged, false, 0, true);
			keyStrokeColor.addEventListener(Event.CHANGE, keyStrokeColorChanged, false, 0, true);
			keyColor1.addEventListener(Event.CHANGE, keyColorChanged, false, 0, true);
			keyColor2.addEventListener(Event.CHANGE, keyColorChanged, false, 0, true);
			keyType.addEventListener(Event.CHANGE, keyTypeChanged, false, 0, true);
			keyGradientType.addEventListener(Event.CHANGE, keyGradientTypeChanged, false, 0, true);
			bgStroke.addEventListener(Event.CHANGE, bgStrokeChanged, false, 0, true);
			bgStrokeColor.addEventListener(Event.CHANGE, bgStrokeColorChanged, false, 0, true);
			keyX.addEventListener(Event.CHANGE, keyPosChanged, false, 0, true);
			keyY.addEventListener(Event.CHANGE, keyPosChanged, false, 0, true);
			fontColor.addEventListener(Event.CHANGE, fontColorChanged, false, 0, true);
			fontSize.addEventListener(Event.CHANGE, fontSizeChanged, false, 0, true);
			bgType.addEventListener(Event.CHANGE, bgTypeChanged, false, 0, true);
			bgGradientType.addEventListener(Event.CHANGE, bgGradientTypeChanged, false, 0, true);
			keyCornerRadius.addEventListener(Event.CHANGE, keyCornerRadiusChanged, false, 0, true);
			nudgeX.addEventListener(Event.CHANGE, nudgeChanged, false, 0, true);
			nudgeY.addEventListener(Event.CHANGE, nudgeChanged, false, 0, true);
			nudgeShiftX.addEventListener(Event.CHANGE, nudgeChanged, false, 0, true);
			nudgeShiftY.addEventListener(Event.CHANGE, nudgeChanged, false, 0, true);
			highlightColor.addEventListener(Event.CHANGE, highlightColorChanged, false, 0, true);
			showShift.addEventListener(Event.CHANGE, showShiftChanged, false, 0, true);
			indKeyColor.addEventListener(Event.CHANGE, indKeyColorChanged, false, 0, true);
			indKeyColor1.addEventListener(Event.CHANGE, indKeyColorChanged, false, 0, true);
			indKeyColor2.addEventListener(Event.CHANGE, indKeyColorChanged, false, 0, true);
			indKeyType.addEventListener(Event.CHANGE, indKeyColorChanged, false, 0, true);
			indKeyGradientType.addEventListener(Event.CHANGE, indKeyColorChanged, false, 0, true);			
			
			//populate fields
			fontSize.value = keyFile.keyboard.setup.font.@size;
			bgWidth.value = keyFile.keyboard.setup.mainbackground.@w;
			bgHeight.value = keyFile.keyboard.setup.mainbackground.@h;
			bgStroke.value = keyFile.keyboard.setup.mainbackground.@borderWidth;
			keyStroke.value = keyFile.keyboard.setup.keybackground.@borderWidth;
			bgCornerRadius.value = keyFile.keyboard.setup.mainbackground.@r;
			keyCornerRadius.value = keyFile.keyboard.setup.keybackground.@r;
			bgColor1.selectedColor = parseInt(keyFile.keyboard.setup.mainbackground.@color1);
			bgColor2.selectedColor = parseInt(keyFile.keyboard.setup.mainbackground.@color2);
			keyColor1.selectedColor = parseInt(keyFile.keyboard.setup.keybackground.@color1);
			keyColor2.selectedColor = parseInt(keyFile.keyboard.setup.keybackground.@color2);
			keyStrokeColor.selectedColor = parseInt(keyFile.keyboard.setup.keybackground.@borderColor);
			bgStrokeColor.selectedColor = parseInt(keyFile.keyboard.setup.mainbackground.@borderColor);
			fontColor.selectedColor = parseInt(keyFile.keyboard.setup.font.@color);
			highlightColor.selectedColor = parseInt(keyFile.keyboard.setup.highlight.@color);
			nudgeX.value = keyFile.keyboard.setup.keyTextNudge.@x;
			nudgeY.value = keyFile.keyboard.setup.keyTextNudge.@y;
			nudgeShiftX.value = keyFile.keyboard.setup.keyTextNudge.@shiftX;
			nudgeShiftY.value = keyFile.keyboard.setup.keyTextNudge.@shiftY;
			keyType.selectedIndex = keyFile.keyboard.setup.keybackground.@type == "flat" ? 0 : 1;
			keyGradientType.selectedIndex = keyFile.keyboard.setup.keybackground.@gradienttype == "smooth" ? 0 : 1;
			bgType.selectedIndex = keyFile.keyboard.setup.mainbackground.@type == "flat" ? 0 : 1;
			bgGradientType.selectedIndex = keyFile.keyboard.setup.mainbackground.@gradienttype == "smooth" ? 0 : 1;
		}
		
		
		/**
		 * Callback from Keyboard key pressed
		 * @param	e Event KeyBoard.KBD
		 */
		private function keyPressed(e:Event):void
		{
			curKeyVal = kbd.getUnshiftedKey();
			curShiftVal = kbd.getShiftKey();
			curKeyIndex = kbd.getKeyIndex(); //index of the key being edited
			
			keyValue.text = curKeyVal;
			keyShiftValue.text = curShiftVal;
			keyWidth.value = keyFile.keyboard.keys.key[curKeyIndex].@w;
			keyHeight.value = keyFile.keyboard.keys.key[curKeyIndex].@h;
			keyX.value = keyFile.keyboard.keys.key[curKeyIndex].@x;
			keyY.value = keyFile.keyboard.keys.key[curKeyIndex].@y;
			showShift.selected = keyFile.keyboard.keys.key[curKeyIndex].@showshiftval == "true" ? true : false;
			indKeyColor.selected = keyFile.keyboard.keys.key[curKeyIndex].@color1 == undefined ? false : true;
			indKeyColor1.selectedColor = parseInt(keyFile.keyboard.keys.key[curKeyIndex].@color1);
			indKeyColor2.selectedColor = parseInt(keyFile.keyboard.keys.key[curKeyIndex].@color2);
			indKeyType.selectedIndex = keyFile.keyboard.keys.key[curKeyIndex].@type == "flat" ? 0 : 1;
			indKeyGradientType.selectedIndex = keyFile.keyboard.keys.key[curKeyIndex].@gradienttype == "smooth" ? 0 : 1;
		}
		
		
		private function setKeyValue(e:MouseEvent):void
		{			
			keyFile.keyboard.keys.key[curKeyIndex].@val = keyValue.text;
			keyFile.keyboard.keys.key[curKeyIndex].@shiftval = keyShiftValue.text;		
			kbd.setKeyFile(keyFile);
		}
		
		
		private function addNewKey(e:MouseEvent):void
		{
			keyFile.keyboard.keys.key += <key w="50" h="50" r="8" val="q" shiftval="Q" showshiftval="false" x="0" y="0"></key>
			kbd.setKeyFile(keyFile);
		}
		
		
		private function deleteKey(e:MouseEvent):void
		{
			delete keyFile.keyboard.keys.key[curKeyIndex];
			kbd.setKeyFile(keyFile);
		}
		
		
		private function bgSizeChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@w = bgWidth.value;
			keyFile.keyboard.setup.mainbackground.@h = bgHeight.value;
			kbd.setKeyFile(keyFile);
		}
		
		
		private function setBGColor(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@color1 = "0x" + bgColor1.hexValue;	
			keyFile.keyboard.setup.mainbackground.@color2 = "0x" + bgColor2.hexValue;	
			kbd.setKeyFile(keyFile);
		}
		
		private function bgCornerRadiusChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@r = bgCornerRadius.value;
			kbd.setKeyFile(keyFile);
		}
		
		
		/**
		 * Called by clicking the Open button
		 * @param	e MouseEvent.CLICK 
		 */
		private function openXML(e:MouseEvent):void
		{			
			file.open();
		}
		
		
		/**
		 * Callback from FileUtils.fileSelected()
		 * called when new xml file is opened
		 * @param	e
		 */
		private function newXMLOpened(e:Event):void
		{
			keyFile = file.getFile();
			init();//adds listeners and populates UI
			kbd.setKeyFile(keyFile);			
		}
		
		/**
		 * Called by clicking the Save button
		 * @param	e
		 */
		private function saveXML(e:MouseEvent):void
		{			
			file.save(keyFile);
		}
		
		private function keyWidthChanged(e:Event):void
		{
			keyFile.keyboard.keys.key[curKeyIndex].@w = keyWidth.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyHeightChanged(e:Event):void
		{
			keyFile.keyboard.keys.key[curKeyIndex].@h = keyHeight.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyStrokeChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@borderWidth = keyStroke.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyStrokeColorChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@borderColor = "0x" + keyStrokeColor.hexValue;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyColorChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@color1 = "0x" + keyColor1.hexValue;
			keyFile.keyboard.setup.keybackground.@color2 = "0x" + keyColor2.hexValue;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyCornerRadiusChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@r = keyCornerRadius.value;
			kbd.setKeyFile(keyFile);			
		}
		
		private function bgStrokeChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@borderWidth = bgStroke.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function bgStrokeColorChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@borderColor = "0x" + bgStrokeColor.hexValue;
			kbd.setKeyFile(keyFile);
		}
		 
		private function keyPosChanged(e:Event):void
		{
			keyFile.keyboard.keys.key[curKeyIndex].@x = keyX.value;
			keyFile.keyboard.keys.key[curKeyIndex].@y = keyY.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function fontColorChanged(e:Event):void
		{
			keyFile.keyboard.setup.font.@color = "0x" + fontColor.hexValue;
			kbd.setKeyFile(keyFile);
		}
		
		private function fontSizeChanged(e:Event):void
		{
			keyFile.keyboard.setup.font.@size = fontSize.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function bgTypeChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@type = bgType.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function bgGradientTypeChanged(e:Event):void
		{
			keyFile.keyboard.setup.mainbackground.@gradienttype = bgGradientType.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function nudgeChanged(e:Event):void
		{
			keyFile.keyboard.setup.keyTextNudge.@x = nudgeX.value;
			keyFile.keyboard.setup.keyTextNudge.@y = nudgeY.value;
			keyFile.keyboard.setup.keyTextNudge.@shiftX = nudgeShiftX.value;
			keyFile.keyboard.setup.keyTextNudge.@shiftY = nudgeShiftY.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyTypeChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@type = keyType.value;
			kbd.setKeyFile(keyFile);
		}
		
		private function keyGradientTypeChanged(e:Event):void
		{
			keyFile.keyboard.setup.keybackground.@gradienttype = keyGradientType.value;
			kbd.setKeyFile(keyFile);
		}
		
		
		private function highlightColorChanged(e:Event):void
		{
			keyFile.keyboard.setup.highlight.@color = "0x" + highlightColor.hexValue;
			kbd.setKeyFile(keyFile);
		}
		
		
		private function showShiftChanged(e:Event):void
		{
			keyFile.keyboard.keys.key[curKeyIndex].@showshiftval = showShift.selected == true ? "true" : "false";
			kbd.setKeyFile(keyFile);
		}
		
		
		private function indKeyColorChanged(e:Event):void
		{
			if (indKeyColor.selected) {
				keyFile.keyboard.keys.key[curKeyIndex].@type = indKeyType.value;
				keyFile.keyboard.keys.key[curKeyIndex].@gradienttype = indKeyGradientType.value;
				keyFile.keyboard.keys.key[curKeyIndex].@color1 = "0x" + indKeyColor1.hexValue
				keyFile.keyboard.keys.key[curKeyIndex].@color2 = "0x" + indKeyColor2.hexValue;
			}else {				
				delete keyFile.keyboard.keys.key[curKeyIndex].@type[0];
				delete keyFile.keyboard.keys.key[curKeyIndex].@gradienttype[0];
				delete keyFile.keyboard.keys.key[curKeyIndex].@color1[0];
				delete keyFile.keyboard.keys.key[curKeyIndex].@color1[0];
			}
			kbd.setKeyFile(keyFile);
		}
		
		
		private function startKBDDrag(e:MouseEvent):void
		{
			keyboardContainer.startDrag();
		}
		
		
		private function stopKBDDrag(e:MouseEvent):void
		{
			stopDrag();
		}
		
		
		private function kbdBGColorColorChanged(e:Event):void
		{			
			kbdBG.graphics.clear();
			kbdBG.graphics.beginFill(kbdBGColor.selectedColor, 1);
			kbdBG.graphics.drawRect(0, 0, 1280, 400);
			kbdBG.graphics.endFill();
		}
	}
	
}