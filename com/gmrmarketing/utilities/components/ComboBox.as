/**
 * ComboBox component
 * 
 * Usage - Defaults:
	import com.gmrmarketing.utilities.components.ComboBox;
	
	var a:ComboBox = new ComboBox();
	a.useDefaults();
	
	a.addItems([{label:"Kaden", data:1},{label:"Kian", data:2},{label:"Momma", data:3}]);
	a.addEventListener(ComboBox.CHANGED, comboSelected, false, 0, true);
	addChild(a);
	
	function comboSelected(e:Event):void
	{
		var item:Object = a.selectedItem;
		trace(item.label, item.data);
	}	
	
	To customize the component, don't call useDefaults() and instead:
	
	//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
	a.setLabelProperties(400, 60, 20, 18, 36, new treb(),12);
	//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
	a.setListProperties(6, 36, 10, 18, new treb(), 14);
	//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
	a.setLabelColors(0xbbbbbb,0x666666,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
	//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
	a.setListColors(0xcccccc,0x333333,0x666666,0xaaaaaa);

 */
package com.gmrmarketing.utilities.components
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.text.*;
	import com.gmrmarketing.utilities.components.ComboItem;
	import com.gmrmarketing.utilities.components.ComboSlider;
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
		private var slider:ComboSlider;//the vertical slider used to scroll the item list
		private var dropBG:Sprite; //background of drop container - only seen when there are less items than visibleLines
		private var dropContainerHeight:int;//current height of the container - number of items * visibleLineHeight
		private var dropMask:Sprite; //mask for dropContainer
		private var myWidth:int;//full width of the comboBox
		private var myHeight:int;//height of the top label portion
		private var radius:int;//corner radius of the top label portion
		private var toggleSpace:Number;//space in the top label portion to use for the arrow
		private var fieldWidth:int;//width of lower drop down
		private var visibleLines:int;//number of visible items in the dropDown when it's open
		private var visibleLinesHeight:int; //height of the visible items in the dropDown
		private var listMargin:int; //left margin for list items - set in setListProperties()
		private var labelFontReference:Font;
		private var labelFontSize:int;
		private var itemFontReference:Font;
		private var itemFontSize:int;
		private var selItem:Object; //The selected item - has label and data properties
		private var items:Array; //array of ComboItems;
		private var sliderRange:int; //amount of dropDownContainer beyond the visible area - set/updated in addItems()
		private var listColors:Array;
		
		
		/**
		 * Constructor
		 */
		public function ComboBox()
		{	
			labelContainer = new Sprite();
			
			//add an inner shadow
			labelContainer.filters = [new DropShadowFilter(0, 0, 0, 1, 3, 3, 1, 2, true)];
			
			dropContainer = new Sprite();
			
			//add an inner shadow
			dropContainer.filters = [new DropShadowFilter(0, 0, 0, 1, 3, 3, 1, 2, true)];
			
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
		}
		
		
		/**
		 * Sets the default message shown before an item is selected
		 * @param	newDefault
		 */
		public function setDefaultMessage(newDefault:String = "Please Select"):void
		{
			label.text = newDefault;
			label.setTextFormat(labelFormat);
			selItem = { label:newDefault, data: -1 };
		}
		
		
		/**
		 * Shorthand to set defaults for everything
		 */
		public function useDefaults():void
		{
			setLabelProperties();
			setListProperties();
			setLabelColors();
			setListColors();
		}
		
		
		/**
		 * 
		 * @param	w		full width of the comboBox
		 * @param	h		height of the top label portion
		 * @param	rad		corner radius - this is used in the item list as well
		 * @param	togPer	percentage of width to use for arrow
		 * @param	fSize	label font size
		 * @param	fRef	font reference
		 * @param	lMarg	left margin
		 */
		public function setLabelProperties(w:int = 140, h:int = 25, rad:int = 0, togPer:Number = 15, fSize:int = 14, fRef:Font = null, lMarg:int = 7 ):void
		{
			myWidth = w;
			myHeight = h;
			radius = rad;
			labelFontSize = fSize;
			labelFontReference = fRef;
			
			if (labelFontReference != null) {
				label.embedFonts = true;
				labelFormat.font = labelFontReference.fontName;
			}
			
			toggleSpace = myWidth * (togPer * .01);
			fieldWidth = myWidth - toggleSpace;
			
			labelFormat.leftMargin = lMarg;
			labelFormat.size = labelFontSize;
			label.setTextFormat(labelFormat);
			label.height = myHeight;
			label.selectable = false;
		}

				
		/**
		 * 
		 * @param	vLines	number of lines visible in the list
		 * @param	vHeight	height of each list item
		 * @param	sliPer	percentage of width to use for slider
		 * @param	fSize	item font size
		 * @param	fRef	font reference
		 * @param	lMarg	left margin for items in the list
		 */
		public function setListProperties(vLines:int = 5, vHeight:int = 20,  sliPer:int = 15, fSize:int = 13, fRef:Font = null, lMarg:int = 6):void
		{			
			visibleLines = vLines;
			visibleLinesHeight = vHeight;
			itemFontSize = fSize;
			itemFontReference = fRef;
			listMargin = lMarg;
			
			//slider
			if(!dropContainer.contains(slider)){
				dropContainer.addChild(slider);
			}
			//var fw:int = fieldWidth;
			var slideSpace:Number = myWidth * (sliPer * .01);
			if (slideSpace < toggleSpace) {
				fieldWidth = myWidth - slideSpace;
			}
			slider.x = fieldWidth;	
			slider.init(myWidth - fieldWidth, visibleLinesHeight * visibleLines);
			
			labelContainer.addEventListener(MouseEvent.MOUSE_DOWN, toggleDropDown);
		}
		
		
		/**
		 * 
		 * @param	labelColor Label text color
		 * 
		 * @param	bgCol Color of the background in the label portion
		 * @param	borderCol Color of the border around the label portion
		 * 
		 * @param	triangleBorder Border color of the down arrow
		 * @param	triangleFill Fill color of the down arrow
		 * 
		 * @param	separatorColor Color for the vertical line separting the label and arrow
		 */
		public function setLabelColors(labelColor:Number = 0xffffff, bgCol:Number = 0x666666, borderCol:Number = 0x222222, triangleBorder:Number = 0x333333, triangleFill:Number = 0x888888, separatorColor:Number = 0x444444 ):void
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
			var lineHeight:int = Math.floor(myHeight * .65);//line is 65% of height
			var lineTop:int = Math.floor((myHeight - lineHeight) * .5);			
			var lineX:int = myWidth - toggleSpace;
			
			g = labelContainer.graphics;
			g.lineStyle(1, separatorColor, 1);
			g.moveTo(lineX, lineTop);
			g.lineTo(lineX, lineTop + lineHeight);
			
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
			dropDownToggle.x = lineX + Math.floor((toggleSpace - triWide) * .5);
			dropDownToggle.y = 1 + Math.floor((myHeight - dropDownToggle.height) * .5);			
			
			label.y = Math.floor((myHeight - label.textHeight - 2) * .5);
			labelFormat.color = labelColor;
			label.setTextFormat(labelFormat);
		
			if (!contains(dropContainer)) {
				addChild(dropContainer);
			}
			dropContainer.x = 0;
			dropContainer.y = myHeight + 3; //right under the labelContainer
			
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
		 * @param	txtCol
		 * @param	txtOverCol
		 * @param	bgColor
		 * @param	bgOverColor
		 * @param	trackColor
		 * @param	slideColor
		 */
		public function setListColors(txtCol:Number = 0xffffff, txtOverCol:Number = 0x000000, bgColor:Number = 0x666666, bgOverColor:Number = 0xcccccc, trackColor:Number = 0x333333, slideColor:Number = 0x777777):void
		{
			listColors = [txtCol, txtOverCol, bgColor, bgOverColor];
			slider.colors(trackColor, slideColor);			
		}
		
		
		/**
		 * Adds items to the list
		 * @param	newItems Array of objects with label and other optional properties
		 */
		public function addItems(newItems:Array):void
		{
			var curY:int = itemContainer.height;
			
			for (var i:int = 0; i < newItems.length; i++) {				
				var ni:ComboItem = new ComboItem(newItems[i], fieldWidth, visibleLinesHeight, listColors[0], listColors[1], listColors[2], listColors[3], itemFontSize, itemFontReference, listMargin);
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
				TweenMax.to(dropContainer, .25, { y:myHeight + 3 } );
				//dropContainer.y = myHeight + 1; //right under the labelContainer
				e.stopImmediatePropagation();//stop the event from bubbling to stageClicked()
				if(items.length > visibleLines){
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageClicked, false, 0, true);				
					slider.addEventListener(ComboSlider.DRAGGING, updateItems, false, 0, true);
				}else {
					slider.ghost();
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