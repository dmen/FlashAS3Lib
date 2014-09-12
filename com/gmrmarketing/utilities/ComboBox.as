package com.gmrmarketing.utilities
{	
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	
	public class ComboBox extends EventDispatcher
	{
		private var container:DisplayObjectContainer;
		private var contentPresenterBorder:Sprite; //the base of the combo that contains the contentPresenter and dropDownToggle
		private var contentPresenter:TextField;
		private var contentPresenterFormat:TextFormat;
		private var dropDownToggle:Shape; //the arrow that points down inside the contentPresenter area
		
		private var data:Array; //array of objects with data and value properties
		private var popup:Sprite; //container for the drop down items
		
		
		public function ComboBox()
		{
			contentPresenterBorder = new Sprite();
			contentPresenter = new TextField();
			contentPresenter.antiAliasType = AntiAliasType.ADVANCED;			
			
			contentPresenterFormat = new TextFormat();
			contentPresenterFormat.size = 14;
			contentPresenter.defaultTextFormat = contentPresenterFormat;
			
			dropDownToggle = new Shape();
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * 
		 * @param	width The width, in pixels, of the component
		 * @param	height The height, in pixels, of the component
		 * @param	radius The corner radius
		 * @param	toggleSpacePercent Percent of the width that the toggle area occupies
		 * @param	fontReference Font reference from the library in case a custom font is needed
		 */
		public function init(width:int, height:int, radius:int = 5, toggleSpacePercent:Number = .2, fontReference:Font = null)
		{
			var g:Graphics;
			
			if (fontReference != null) {
				contentPresenter.embedFonts = true;
				contentPresenterFormat.font = fontReference.fontName;
				contentPresenter.defaultTextFormat = contentPresenterFormat;
			}
			
			//triange for the toggle
			g = dropDownToggle.graphics;
			g.lineStyle(1, 0x000000, 1, true);
			g.beginFill(0xAAAAAA, 1);
			g.moveTo(0, 0);
			g.lineTo(11, 0);
			g.lineTo(5, 10);
			g.lineTo(0, 0);
			g.endFill();
			
			//border background
			g = contentPresenterBorder.graphics;
			g.lineStyle(1, 0x000000, 1, true);
			g.beginFill(0xFFFFFF, 1);
			g.drawRoundRect(0, 0, width, height, radius, radius);
			g.endFill();
			
			//draw a vertical line for the separator between the selection text and toggle
			var toggleSpace:int = Math.round(width * toggleSpacePercent);
			var lineX:int = width - toggleSpace;
			g.lineStyle(1, 0xCECECE, 1);
			g.moveTo(lineX, 6);
			g.lineTo(lineX, height - 6);
			
			//add toggle to border
			contentPresenterBorder.addChild(dropDownToggle);
			dropDownToggle.x = lineX + ((toggleSpace - 12) * .5);
			dropDownToggle.y = (height - 10) * .5;
			
			contentPresenter.textColor = 0x444444;
			contentPresenter.width = lineX - 12; //6 on each side
			contentPresenter.text = "Make a selection bitches be cool";
			contentPresenterBorder.addChild(contentPresenter);
			contentPresenter.x = 6;
			contentPresenter.y = (height - contentPresenter.textHeight - 2) * .5;
		}		
		
		
		/**
		 * 
		 * @param	$data Array of objects with label and data properties
		 */
		public function setData($data:Array, itemHeight:int = 20, numItemsToShow:int = 5 ):void
		{
			data = $data;
			popup = new Sprite();
			popup.graphics.lineStyle(1, 0x888888, 1);
			popup.graphics.drawRect(0, 0, contentPresenterBorder.width, itemHeight * numItemsToShow);		
			
			var itemHolder:Sprite = new Sprite();
			popup.addChild(itemHolder);
			itemHolder.x = 1;
			itemHolder.y = 1;
			
			var popupMask:Shape = new Shape();			
			popupMask.graphics.beginFill(0x00FF00, 1);
			popupMask.graphics.drawRect(1, 1, contentPresenterBorder.width -2, itemHeight * numItemsToShow - 2);
			popupMask.graphics.endFill();
			
			var itemY:int = 1;
			
			for (var i:int = 0; i < data.length; i++) {
				var itemContainer:Sprite = new Sprite();
				var itemText:TextField = new TextField();
				itemText.defaultTextFormat = contentPresenterFormat;
				itemText.text = data[i].label;
				var g:Graphics = itemContainer.graphics;
				g.beginFill(0xAAAAAA, 1);
				g.drawRect(0, 0, contentPresenterBorder.width-2, itemHeight);
				g.endFill();
				itemContainer.addChild(itemText);
				itemText.x = 6;
				itemHolder.addChild(itemContainer);
				itemContainer.x = 1;
				itemContainer.y = itemY;
				itemY += itemHeight;
			}
			popup.y = 31;//incoming height from init() + n
			popupMask.y = 31;
			
			contentPresenterBorder.addChild(popup);			
			contentPresenterBorder.addChild(popupMask);
			itemHolder.mask = popupMask;
		}
		
		
		/**
		 * Displays the component
		 * @param	tx
		 * @param	ty
		 */
		public function show(tx:int = 0, ty:int = 0):void
		{
			if (container) {
				if (!container.contains(contentPresenterBorder)) {
					container.addChild(contentPresenterBorder);
				}
			}
			contentPresenterBorder.x = tx;
			contentPresenterBorder.y = ty;
		}
	}
	
}