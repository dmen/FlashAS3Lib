package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	
	public class ComboItem extends Sprite
	{		
		public static const CLICKED:String = "itemClicked";
		
		private var theText:TextField;
		private var textFormat:TextFormat;
		private var item:Object;
		private var w:int;
		private var h:int;
		private var txtCol:Number; //normal text color
		private var txtOverCol:Number; //text color when mouse over the item
		private var bgCol:Number; //normal background color
		private var bgOverCol:Number; //background color when mouse over the item
		
		/**
		 * 
		 * @param	item Contains label and data keys
		 */
		public function ComboItem($item:Object, $w:int, $h:int, $txtCol:Number, $txtOverCol:Number, $bgCol:Number, $bgOverCol:Number, fontReference:Font = null)		
		{
			item = $item;			
			w = $w;
			h = $h;
			txtCol = $txtCol;
			txtOverCol = $txtOverCol;
			bgCol = $bgCol;
			
			theText = new TextField();
			theText.antiAliasType = AntiAliasType.ADVANCED;
			theText.selectable = false;
			theText.multiline = false;
			theText.height = h;
			
			textFormat = new TextFormat();
			textFormat.size = 14;
			theText.defaultTextFormat = textFormat;
			
			theText.text = item.label;
			theText.textColor = 0x000000;
			
			graphics.beginFill(0xAAAAAA, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			
			addChild(theText);
			
			addEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		
		public function getLabel():String
		{
			return item.label;
		}
		
		
		public function getData():Object
		{
			return item.data;
		}
		
		
		private function itemClicked(e:MouseEvent):void
		{
			dispatchEvent(new Event(CLICKED));
		}
		
		
		private function mouseOver(e:MouseEvent):void
		{
			graphics.beginFill(0xCCCCCC, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			theText.textColor = 0xFF0000;
		}
		
		
		private function mouseOut(e:MouseEvent):void
		{
			graphics.beginFill(0xAAAAAA, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			theText.textColor = 0x000000;
		}
		
	}
	
}