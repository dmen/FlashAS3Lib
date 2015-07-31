/**
 * Used by ComboBox.as
 * Represents one item in the ComboBox
 */

package com.gmrmarketing.utilities.components
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import com.greensock.TweenMax;
	
	
	public class ComboItem extends Sprite
	{		
		public static const CLICKED:String = "itemClicked";//dispatched when the item is clicked
		
		private var theText:TextField;//contains the item.label
		private var textFormat:TextFormat;
		private var item:Object;//object containing label and data keys
		private var w:int;//width and height of the item
		private var h:int;
		private var txtCol:Number; //normal text color
		private var txtOverCol:Number; //text color when mouse over the item
		private var bgCol:Number; //normal background color
		private var bgOverCol:Number; //background color when mouse over the item
		
		
		/**
		 * Constructor - called from ComboBox.addItems()
		 * @param	$item Object with label property, can have data property
		 * @param	$w
		 * @param	$h
		 * @param	$txtCol
		 * @param	$txtOverCol
		 * @param	$bgCol
		 * @param	$bgOverCol	
		 * @param	fs Font size
		 * @param	fr Font Reference
		 * @param	leftMargin Left margin
		 */
		public function ComboItem($item:Object, $w:int, $h:int, $txtCol:Number, $txtOverCol:Number, $bgCol:Number, $bgOverCol:Number, fs:int = 14, fr:Font = null, leftMarg:int = 6 )		
		{
			item = $item;			
			w = $w;
			h = $h;
			txtCol = $txtCol;
			txtOverCol = $txtOverCol;
			bgCol = $bgCol;
			bgOverCol = $bgOverCol;
			theText = new TextField();
			theText.autoSize = TextFieldAutoSize.LEFT;
			theText.antiAliasType = AntiAliasType.ADVANCED;
			theText.selectable = false;
			theText.multiline = false;
			theText.height = h;
			theText.selectable = false;
			
			textFormat = new TextFormat();
			if (fr != null) {
				theText.embedFonts = true;
				textFormat.font = fr.fontName;				
			}
			textFormat.leftMargin = leftMarg;
			textFormat.size = fs;
			
			theText.text = item.label;
			theText.textColor = txtCol;
			theText.setTextFormat(textFormat);
			
			//background with border
			graphics.lineStyle(1, 0x000000, .2);
			graphics.beginFill(bgCol, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			
			addChild(theText);
			//center text vertically in the space
			theText.y = Math.floor((h - theText.textHeight) * .5);
			
			addEventListener(MouseEvent.MOUSE_DOWN, itemClicked);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		
		/**
		 * Returns an object containing the items label and data properties
		 * @return
		 */
		public function getProps():Object
		{			
			return { label:item.label, data:item.data };
		}
		
		
		/**
		 * Shows the highlight on the item before calling sendClick
		 * Called from ComboBox.clicked()
		 * @param	e
		 */
		private function itemClicked(e:MouseEvent):void
		{
			mouseOver();
			TweenMax.delayedCall(.1, sendClick);
		}
		
		
		/**
		 * Called from TweenMax.delayed call to allow the highlighted item to show
		 * the highlight for 1/10 second. This for touch systems when the item is
		 * simply clicked and not moused over first
		 */
		private function sendClick():void
		{
			dispatchEvent(new Event(CLICKED));
		}
		
		
		/**
		 * Changes the bg and text to the over color
		 * @param	e
		 */
		private function mouseOver(e:MouseEvent = null):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x000000, .2);
			graphics.beginFill(bgOverCol, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			theText.textColor = txtOverCol;
		}
		
		
		/**
		 * Changes the bg and text to the normal color
		 * @param	e
		 */
		private function mouseOut(e:MouseEvent):void
		{
			graphics.clear();
			graphics.lineStyle(1, 0x000000, .2);
			graphics.beginFill(bgCol, 1);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
			theText.textColor = txtCol;
		}
		
	}
	
}