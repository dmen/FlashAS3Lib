package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.gmrmarketing.utilities.ComboItem;
	
	
	public class ComboBox extends Sprite
	{	
		private var labelContainer:Sprite; //container for top items - label, dropDownToggle, etc.		
		private var label:TextField; //shows the current selection or default
		private var labelFormat:TextFormat;
		private var dropDownToggle:Shape; //the arrow that points down inside the label area
		private var dropContainer:Sprite; //container for the combo items
		private var dropMask:Sprite; //mask for dropContainer
		private var myWidth:int;
		private var myHeight:int;
		private var radius:int;
		private var toggleSpacePercent:Number;
		private var fieldWidth:int;
		private var visibleLines:int;
		private var fontReference:Font;
		
		private var defaultMessage:String;
		
		private var items:Array; //array of ComboItems;
		
		
		public function ComboBox()
		{
			labelContainer = new Sprite();
			dropContainer = new Sprite();
			dropMask = new Sprite();
			label = new TextField();
			label.antiAliasType = AntiAliasType.ADVANCED;
			labelFormat = new TextFormat();
			labelFormat.size = 14;
			label.defaultTextFormat = labelFormat;
			dropDownToggle = new Shape();
			items = new Array();
			
			init();//defaults
		}
		
		
		public function init(width:int = 100, height:int = 25, $radius:int = 0, $toggleSpacePercent:Number = 21, $visibleLines:int = 5, $fontReference:Font = null):void
		{
			myWidth = width;
			myHeight = height;
			radius = $radius;
			toggleSpacePercent = $toggleSpacePercent;
			visibleLines = $visibleLines;
			fontReference = $fontReference;
			
			label.height = myHeight;
			label.selectable = false;
			
			if (fontReference != null) {
				label.embedFonts = true;
				labelFormat.font = fontReference.fontName;
				label.defaultTextFormat = labelFormat;
			}
			
			setDefaultMessage();//Please Select
			setColors(); //defaults
		}
		
		
		public function setColors(labelColor:Number = 0x333333, borderCol:Number = 0x444444, bgCol:Number = 0xEEEEEE, triangleBorder:Number = 0x444444, triangleFill:Number = 0xAAAAAA, separatorColor:Number = 0xBBBBBB ):void
		{
			var g:Graphics;//just a shorthand ref
			
			//labelContainer
			g = labelContainer.graphics;
			g.clear();
			g.lineStyle(1,borderCol, 1, true);
			g.beginFill(bgCol, 1);
			g.drawRoundRect(0, 0, myWidth, myHeight, radius, radius);
			g.endFill();
			
			//triangle for the toggle			
			g = dropDownToggle.graphics;
			g.clear();
			g.lineStyle(1, triangleBorder, 1, true);
			g.beginFill(triangleFill, 1);
			g.moveTo(0, 0);
			g.lineTo(11, 0);
			g.lineTo(5, 10);
			g.lineTo(0, 0);
			g.endFill();
			
			//draw a vertical line for the separator between the label and toggle
			var toggleSpace:int = Math.floor(myWidth * (toggleSpacePercent * .01));
			fieldWidth = myWidth - toggleSpace;
			g = labelContainer.graphics;
			g.lineStyle(1, separatorColor, 1);
			g.moveTo(fieldWidth, 6);
			g.lineTo(fieldWidth, myHeight - 6);
			
			//add triangle toggle to container
			labelContainer.addChild(dropDownToggle);
			dropDownToggle.x = Math.floor(fieldWidth + ((toggleSpace - 12) * .5)) + 1;//+1 at end because it always seems left a pixel...
			dropDownToggle.y = Math.floor((myHeight - 10) * .5);
			
			//add label to container
			labelContainer.addChild(label);
			label.x = 6;
			label.y = Math.floor((myHeight - label.textHeight - 2) * .5);
			
			labelFormat.color = labelColor;
			
			if (!labelContainer.contains(dropContainer)) {
				labelContainer.addChild(dropContainer);
			}
			dropContainer.x = 0;
			dropContainer.y = myHeight + 1; //right under the labelContainer
			
			//Mask
			g = dropMask.graphics;
			g.clear();
			g.beginFill(0x00ff00, 1);
			g.drawRect(0, 0, fieldWidth, visibleLines * myHeight);
			g.endFill();
			
			if (!labelContainer.contains(dropMask)) {
				labelContainer.addChild(dropMask);
			}
			dropMask.x = dropContainer.x;
			dropMask.y = dropContainer.y; //same y as dropContainer
			dropContainer.mask = dropMask;
			
			if(!contains(labelContainer)){
				addChild(labelContainer);
			}
		}		
		
		
		public function setDefaultMessage(newDefault:String = "Please Select"):void
		{
			defaultMessage = newDefault;
			label.text = defaultMessage;
		}
		
		
		/**
		 * 
		 * @param	newItems Array of objects with label and data properties
		 */
		public function addItems(newItems:Array):void
		{
			var curY:int = dropContainer.height;
			
			for (var i:int = 0; i < newItems.length; i++) {
				var ni:ComboItem = new ComboItem(newItems[i], fieldWidth, myHeight, 0x000000, 0x333333, 0xcccccc, 0xeeeeee, fontReference);
				dropContainer.addChild(ni);
				ni.y = curY;
				curY += myHeight;//labelContainer height from init()
			}
		}
		
	}
	
}