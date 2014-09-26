package com.gmrmarketing.utilities
{	
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	
	
	public class ComboBox extends EventDispatcher
	{
		private var container:DisplayObjectContainer;
		private var contentPresenterBorder:Sprite; //the base of the combo that contains the contentPresenter and dropDownToggle
		private var contentPresenter:TextField;
		private var contentPresenterFormat:TextFormat;
		private var dropDownToggle:Shape; //the arrow that points down inside the contentPresenter area
		
		private var data:Array; //array of objects with data and value properties
		private var popup:Sprite; //base container for the drop down items
		private var itemHolder:Sprite; //holder of all items within popup - this scrolls within the mask
		private var textFieldWidth:int; //pixel width of contentPresenter
		private var isOpen:Boolean;
		
		
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
			contentPresenter.text = "Make a selection bitches be cool";
			contentPresenterBorder.addChild(contentPresenter);
			contentPresenter.x = 6;
			contentPresenter.y = (height - contentPresenter.textHeight - 2) * .5;
			textFieldWidth = lineX - 12; //6 on each side
			contentPresenter.width = textFieldWidth;
		}		
		
		
		/**
		 * 
		 * @param	$data Array of objects with label and data properties
		 * @param	itemHeight
		 * @param	numItemsToShow
		 */
		public function setData($data:Array, itemHeight:int = 20, numItemsToShow:int = 5 ):void
		{
			data = $data;
			popup = new Sprite();
			popup.graphics.lineStyle(1, 0x333333, 1);
			popup.graphics.drawRect(0, 0, contentPresenterBorder.width, itemHeight * numItemsToShow);
			
			var popupMask:Shape = new Shape();
			popupMask.graphics.beginFill(0x00FF00, 1);
			popupMask.graphics.drawRect(0, 0 , contentPresenterBorder.width+1, itemHeight * numItemsToShow+1);
			popupMask.graphics.endFill();
			
			itemHolder = new Sprite();
			popup.addChild(itemHolder);
			itemHolder.x = 1;
			itemHolder.y = 1;
			
			var itemHolderMask:Shape = new Shape();			
			itemHolderMask.graphics.beginFill(0x00FF00, 1);
			itemHolderMask.graphics.drawRect(1, 1, contentPresenterBorder.width -2, itemHeight * numItemsToShow - 2);
			itemHolderMask.graphics.endFill();
			
			var itemY:int = 1;
			
			//create indiviual items and place them inside itemHolder
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
				itemText.width = textFieldWidth; //same width as contentPresenter field
				itemHolder.addChild(itemContainer);
				itemContainer.x = 1;
				itemContainer.y = itemY;
				itemY += itemHeight;
			}
			popup.y = 31 - popup.height;//incoming height from init() + n
			itemHolderMask.y = 31;
			popupMask.y = 31;
			
			contentPresenterBorder.addChild(popup);			
			contentPresenterBorder.addChild(itemHolderMask);
			contentPresenterBorder.addChild(popupMask);
			itemHolder.mask = itemHolderMask;
			popup.mask = popupMask;
			
			isOpen = false;
			
			contentPresenter.addEventListener(MouseEvent.MOUSE_DOWN, toggle, false, 0, true);
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
		
		
		public function toggle(e:MouseEvent):void
		{
			if (isOpen) {
				isOpen = false;
				TweenMax.to(popup, 1, { y:31 - popup.height} );
			}else {
				isOpen = true;
				TweenMax.to(popup, 1, { y:31} );
			}
		}
	}
	
}