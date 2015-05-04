/**
 * AutoTab
 * Controls autoTabbing in text fields
 
   usage:
	import com.gmrmarketing.utilities.AutoTab;

	var autoTab:AutoTab = new AutoTab();
	autoTab.add(field1, 2, 0x222222);
	autoTab.add(field2, 2, 0x222222);
	autoTab.add(field1, 4, 0x000000);
 */
package com.gmrmarketing.utilities
{
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	
	public class AutoTab
	{
		private var fieldList:Array;
		private var dataList:Array;
		
		
		public function AutoTab()
		{
			fieldList = [];
			dataList = [];
		}
		
		
		/**
		 * Adds a new field - tab order is determined by the order in which the fields are added
		 * The field's default text and default font color should already be present in the field
		 * @param	field
		 * @param	maxLength Max number of characters in the field - once max is reached focus will advance to the next field - set to 0 for no limit
		 * @param	textColor Color to change the text to once the default text is removed
		 */
		public function add(field:TextField, maxLength:int, textColor:Number = 0x000000):void
		{			
			field.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			field.addEventListener(FocusEvent.FOCUS_IN, clearDefault);
			field.addEventListener(FocusEvent.FOCUS_OUT, restoreDefault);
			field.maxChars = maxLength;
			
			fieldList.push(field);			
			dataList.push({maxLength:maxLength, defaultText:field.text, defaultColor:Number(field.getTextFormat().color), normalColor:textColor});
		}
		
		
		/**
		 * Called whenever a key is released in the field
		 * @param	e KeyboardEvent
		 */
		private function keyUp(e:KeyboardEvent):void
		{
			var t:TextField = TextField(e.currentTarget);
			var i:int = fieldList.indexOf(t);
			
			if (e.keyCode == 9) {//9 is tab
				t.setSelection(0, t.length);
				
			}else if(e.keyCode != 16){//16 is shift
				
				if (t.length == dataList[i].maxLength) {
					i++;
					if (i >= dataList.length) {
						i = 0;
					}
					t.stage.focus = fieldList[i];
					fieldList[i].setSelection(0, fieldList[i].length);
				}
			}
		}
		
		
		/**
		 * Called on TAB or Mouse into the field
		 * Clears the field if the text in the field is the default text
		 * @param	e FocusEvent FOCUS_IN
		 */
		private function clearDefault(e:FocusEvent):void
		{		
			var t:TextField = TextField(e.currentTarget);
			var i:int = fieldList.indexOf(t);
			
			var userFormat:TextFormat = new TextFormat();
			
			if (t.text == dataList[i].defaultText) {
				t.text = "";		
				userFormat.color = dataList[i].normalColor;
				t.defaultTextFormat = userFormat;
			}
		}
		
		
		/**
		 * Called on TAB or Mouse out of the field
		 * Restores the default text and font color if the field is empty
		 * @param	e FocusEvent FOCUS_OUT
		 */
		private function restoreDefault(e:FocusEvent):void
		{
			var t:TextField = TextField(e.currentTarget);
			var i:int = fieldList.indexOf(t);
			
			var userFormat:TextFormat = new TextFormat();
			
			if (t.text == "") {
				t.text = dataList[i].defaultText;
				userFormat.color = dataList[i].defaultColor;
				t.setTextFormat(userFormat);
			}
		}
		
	}
	
}