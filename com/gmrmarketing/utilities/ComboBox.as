package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.gmrmarketing.utilities.ComboItem;
	import com.gmrmarketing.utilities.ComboSlider;
	import com.greensock.TweenMax;
	
	
	public class ComboBox extends Sprite
	{	
		public static const CHANGED:String = "selectedItemChanged";//dispatched from clicked() whenever the selected item changes
		
		private var labelContainer:Sprite; //container for top items - label, dropDownToggle, etc.		
		private var label:TextField; //shows the current selection or default
		private var labelFormat:TextFormat;
		private var dropDownToggle:Shape; //the arrow that points down inside the label area
		private var dropContainer:Sprite; //container for the items and the slider
		private var itemContainer:Sprite;//container for the items
		private var slider:ComboSlider;
		private var dropBG:Sprite; //background of drop container - only seen when there are less items than visibleLines
		private var dropContainerHeight:int;//current height of the container - number of items * visibleLineHeight
		private var dropMask:Sprite; //mask for dropContainer
		private var myWidth:int;//full width of the comboBox
		private var myHeight:int;//height of the top label portion
		private var radius:int;//corner radius of the top label portion
		private var toggleSpacePercent:Number;//percentage of space in the top label portion to use for the arrow
		private var fieldWidth:int;//width of lower drop down
		private var visibleLines:int;//number of visible items in the dropDown when it's open
		private var visibleLinesHeight:int; //height of the visible items in the dropDown
		private var labelFontReference:Font;
		private var labelFontSize:int;
		private var itemFontReference:Font;
		private var itemFontSize:int;
		private var selItem:Object; //The selected item - has label and data properties
		private var defaultMessage:String;		
		private var items:Array; //array of ComboItems;
		private var sliderRange:int; //amount of dropDownContainer beyond the visible area - set in addItems()
		private var listColors:Array;
		
		/**
		 * Constructor
		 */
		public function ComboBox()
		{	
			labelContainer = new Sprite();
			dropContainer = new Sprite();
			dropBG = new Sprite();
			dropMask = new Sprite();
			itemContainer = new Sprite();
			label = new TextField();
			label.autoSize = TextFieldAutoSize.LEFT;
			label.antiAliasType = AntiAliasType.ADVANCED;
			labelFormat = new TextFormat();
			
			//add label to container
			labelContainer.addChild(label);
			
			label.defaultTextFormat = labelFormat;
			dropDownToggle = new Shape();
			items = new Array();
			dropContainerHeight = 0;
			slider = new ComboSlider();
			
			setDefaultMessage();
			selItem = { label:"Nothing selected", data: -1 };
		}
		
		
		/**
		 * Sets the default message shown before an item is selected
		 * @param	newDefault
		 */
		public function setDefaultMessage(newDefault:String = "Please Select"):void
		{
			defaultMessage = newDefault;
			label.text = defaultMessage;
			label.setTextFormat(labelFormat);
		}
		
		
		/**
		 * 
		 * @param	w
		 * @param	h
		 * @param	rad
		 * @param	togPer
		 * @param	fSize
		 * @param	fRef
		 */
		public function setLabelProperties(w:int = 100, h:int = 25, rad:int = 0, togPer:Number = 20, fSize:int = 14, fRef:Font = null ):void
		{
			myWidth = w;
			myHeight = h;
			radius = rad;			
			toggleSpacePercent = togPer;
			labelFontSize = fSize;
			labelFontReference = fRef;
			
			if (labelFontReference != null) {
				label.embedFonts = true;
				labelFormat.font = labelFontReference.fontName;
			}
			
			labelFormat.size = labelFontSize;
			label.setTextFormat(labelFormat);
			label.height = myHeight;
			label.selectable = false;
		}

		
		/**
		 * 
		 * @param	labelColor Label text color
		 * @param	borderCol Color of the border around the label portion
		 * @param	bgCol Color of the background in the label portion
		 * 
		 * @param	triangleBorder Border color of the down arrow
		 * @param	triangleFill Fill color of the down arrow
		 * @param	separatorColor Color for the vertical line separting the label and arrow
		 */
		public function setLabelColors(labelColor:Number = 0xffffff, borderCol:Number = 0x222222, bgCol:Number = 0x666666, triangleBorder:Number = 0x222222, triangleFill:Number = 0x777777, separatorColor:Number = 0x333333 ):void
		{
			var g:Graphics;//just a shorthand ref
			
			//labelContainer
			g = labelContainer.graphics;
			g.clear();
			g.lineStyle(1,borderCol, 1, true);
			g.beginFill(bgCol, 1);
			//using .5 pixel here makes the corners smoother
			g.drawRoundRect(0,0, myWidth, myHeight, radius, radius);
			g.endFill();			
			
			//draw a vertical line for the separator between the label and toggle
			var toggleSpace:int = Math.floor(myWidth * (toggleSpacePercent * .01));
			fieldWidth = myWidth - toggleSpace;
			g = labelContainer.graphics;
			g.lineStyle(1, separatorColor, 1);
			g.moveTo(fieldWidth, 6);
			g.lineTo(fieldWidth, myHeight - 6);
			
			//triangle for the toggle - make it 70% of toggleSpace width and 70% of myHeight
			var triWide:int = Math.floor(toggleSpace * .5);
			g = dropDownToggle.graphics;
			g.clear();
			g.lineStyle(1, triangleBorder, 1, true);
			g.beginFill(triangleFill, 1);
			g.moveTo(0, 0);
			g.lineTo(triWide, 0);
			g.lineTo(triWide * .5, Math.floor(myHeight * .5));
			g.lineTo(0, 0);
			g.endFill();			
			
			//add triangle toggle to container
			labelContainer.addChild(dropDownToggle);
			dropDownToggle.x = fieldWidth + Math.floor((toggleSpace - triWide) * .5);
			dropDownToggle.y = 1 + Math.floor((myHeight - dropDownToggle.height) * .5);			
			
			label.x = 6;
			label.y = Math.floor((myHeight - label.textHeight - 2) * .5);
			labelFormat.color = labelColor;
			label.setTextFormat(labelFormat);
		
			if (!contains(dropContainer)) {
				addChild(dropContainer);
			}
			dropContainer.x = 0;
			dropContainer.y = myHeight + 1; //right under the labelContainer
			
			//dropContainer background
			g = dropBG.graphics;
			g.clear();
			g.beginFill(bgCol, 1);
			g.drawRect(0, 0, fieldWidth, visibleLines * visibleLinesHeight);
			g.endFill();
			
			if (!dropContainer.contains(dropBG)) {
				dropContainer.addChild(dropBG);
			}
			
			if (!dropContainer.contains(itemContainer)) {
				dropContainer.addChild(itemContainer);
			}
			
			//slider
			if(!dropContainer.contains(slider)){
				dropContainer.addChild(slider);
			}	
			slider.x = fieldWidth;
			slider.init(myWidth - fieldWidth, visibleLinesHeight * visibleLines);
			
			//Mask
			g = dropMask.graphics;
			g.clear();
			g.beginFill(0x00ff00, 1);
			g.drawRoundRect(0, 0, myWidth, visibleLines * visibleLinesHeight, radius, radius);
			g.endFill();
			
			if (!contains(dropMask)) {
				addChild(dropMask);
			}
			dropMask.x = dropContainer.x;
			dropMask.y = dropContainer.y; //same y as dropContainer
			dropContainer.mask = dropMask;			
			
			if(!contains(labelContainer)){
				addChild(labelContainer);
			}
		}
		
		
		/**
		 * 
		 * @param	vLines
		 * @param	vHeight
		 * @param	fSize
		 * @param	fRef
		 */
		public function setListProperties(vLines:int = 5, vHeight:int = 20,  fSize:int = 14, fRef:Font = null):void
		{			
			visibleLines = vLines;
			visibleLinesHeight = vHeight;
			itemFontSize = fSize;
			itemFontReference = fRef;
			
			labelContainer.addEventListener(MouseEvent.MOUSE_DOWN, toggleDropDown);
		}
		
		
		/**
		 * 
		 * @param	txtCol
		 * @param	txtOverCol
		 * @param	bgColor
		 * @param	bgOverColor
		 */
		public function setListColors(txtCol:Number = 0xffffff, txtOverCol:Number = 0x000000, bgColor:Number = 0x666666, bgOverColor:Number = 0xffffff):void
		{
			listColors = [txtCol, txtOverCol, bgColor, bgOverColor];
		}
		
		
		/**
		 * Adds items to the list
		 * @param	newItems Array of objects with label and data(optional) properties
		 */
		public function addItems(newItems:Array):void
		{
			var curY:int = itemContainer.height;
			
			for (var i:int = 0; i < newItems.length; i++) {
				var ni:ComboItem = new ComboItem(newItems[i], fieldWidth, visibleLinesHeight, listColors[0], listColors[1], listColors[2], listColors[3], itemFontSize, itemFontReference);
				ni.addEventListener(ComboItem.CLICKED, clicked, false, 0, true);
				itemContainer.addChild(ni);
				ni.y = curY;
				curY += visibleLinesHeight;//labelContainer height from init()
				items.push(ni);
			}
			
			//full height minus the visible portion is the range the slider will move the items
			sliderRange = itemContainer.height - (visibleLines * visibleLinesHeight);
			
			close();
		}
		
		
		/**
		 * Gets the currently selected item
		 */
		public function get selectedItem():Object
		{
			return selItem;
		}
		
		
		/**
		 * Gets the number of items in the list
		 */
		public function get length():int
		{
			return items.length;
		}
		
		
		/**
		 * Called whenever an item in the dropDown is clicked
		 * Changes the label text to the selected item's label
		 * Dispatches a CHANGED event
		 * @param	e
		 */
		private function clicked(e:Event):void
		{
			selItem = ComboItem(e.currentTarget).getProps();
			label.text = selItem.label;
			label.setTextFormat(labelFormat);
			close();
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function toggleDropDown(e:MouseEvent):void
		{
			if (dropContainer.y < 0) {
				//closed - open it
				slider.reset();
				itemContainer.y = 0;
				TweenMax.to(dropContainer, .25, { y:myHeight + 1 } );
				//dropContainer.y = myHeight + 1; //right under the labelContainer
				e.stopImmediatePropagation();//stop the event from bubbling to stageClicked()
				if(items.length > visibleLines){
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClicked, false, 0, true);				
					slider.addEventListener(ComboSlider.DRAGGING, updateItems, false, 0, true);
				}
			}else {
				//opened - close it
				slider.removeEventListener(ComboSlider.DRAGGING, updateItems);
				close();
			}
		}
		
		
		private function stageClicked(e:MouseEvent):void
		{			
			if((stage.mouseX < x || stage.mouseX > (x + width)) || (stage.mouseY < y || stage.mouseY > (y + myHeight + (visibleLines * visibleLinesHeight)))){
				e.stopImmediatePropagation();//stop the event from bubbling to anywhere else
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageClicked);
				close();
			}
		}
		
		
		private function close():void
		{			
			dropContainer.y = -dropContainer.height;
		}
		
		
		private function updateItems(e:Event):void
		{
			itemContainer.y =  Math.max(-sliderRange * slider.getPosition(), -(sliderRange - 2));			
		}
		
	}
	
}