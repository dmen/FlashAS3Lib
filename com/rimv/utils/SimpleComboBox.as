package com.rimv.utils
{
	/**
   @author    	RimV 
				www.mymedia-art.com
   @class     	SimpleComboBox with roll over effect
   @package   	Utilities
	*/
   
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import gs.TweenMax;
	import gs.easing.*;
	import com.rimv.utils.SimpleComboBoxEvent;
	
   public class SimpleComboBox extends MovieClip
   {
	   // align = left / right / center	   
	   private var align:String = "left";
	   private var itemDistance:Number = 5;
	   private var selected:Number = 0;
	   private var topClip:MovieClip;
	   private var w0, y0:Number;
	   private var maxWidth;
	   
	   // menu align
	   public function get menuAlign():String
	   {
		   return align;
	   }
	   
	   public function set menuAlign(align:String):void
	   {
		  this.align = align;
	   }
	   
	   // menu item distance
	   public function get menuItemDistance():Number
	   {
		   return itemDistance;
	   }
	   
	   public function set menuItemDistance(itemDistance:Number):void
	   {
		  this.itemDistance = itemDistance;
	   }
	   
	   // misc var
	   private var TOTAL:Number = 0;
	   private var items = [];
	   private var visibleStatus:Boolean = false;
	   
	   // Constructor
	   public function SimpleComboBox()
	   {
			buttonMode = true;
			display.visible = false;
			maxWidth = 0;
	   }
	   
	   // Add menu item
	   public function addMenuItem(text:String):void
	   {
		   items[TOTAL] = new menuItem();
		   items[TOTAL].index = TOTAL;
		   items[TOTAL].mouseChildren = false;
		   items[TOTAL].boxText.autoSize = TextFieldAutoSize.LEFT; 
		   items[TOTAL].boxText.text = text;
		   items[TOTAL].backgroundOver.width = items[TOTAL].background.width = items[TOTAL].boxText.width + 10;
		   maxWidth = (maxWidth < items[TOTAL].width) ? items[TOTAL].width : maxWidth;
		   addChild(items[TOTAL]);
		   topClip = items[0];
		   w0 = items[0].width;
		   y0 = items[0].y;
		   if (TOTAL != 0)  items[TOTAL].visible = false;
		   items[TOTAL].margin.width = items[TOTAL].backgroundOver.width;
		   items[TOTAL].margin.height = 22 + itemDistance;
		   items[TOTAL].y = TOTAL * items[TOTAL].margin.height;
		   // Rollover // Roll out interactive
		   items[TOTAL].addEventListener(MouseEvent.ROLL_OVER, itemOver);
		   items[TOTAL].addEventListener(MouseEvent.ROLL_OUT, itemOut);
		   items[TOTAL].addEventListener(MouseEvent.CLICK, itemClick);
		   TOTAL++;
	   }
	   
	   public function alignItem(align:String):void
	   {
		   var i:Number;
		   switch (align) 
		   {
			   case "center": 	for (i = 0; i < TOTAL; i++) items[i].x = (maxWidth - items[i].width) * .5;
								break;
			   case "right": 	for (i = 0; i < TOTAL; i++) items[i].x = (maxWidth - items[i].width);
								break;
		   }
	   }
	   
	   // Roll Over / Out
	   private function itemOver(e:MouseEvent):void
	   {
		   TweenMax.to(e.currentTarget.backgroundOver, 0.5, { alpha:1, ease:Quint.easeOut } ); 
			for (var i:Number = 0; i < TOTAL; i++) 
				if (i != selected)
					items[i].visible = true;
		   dispatchEvent(new SimpleComboBoxEvent(SimpleComboBoxEvent.ON_OVER, (e.target.index )));
	   }
	   
	   private function itemOut(e:MouseEvent):void
	   {
		   TweenMax.to(e.target.backgroundOver, 2, { alpha:0, ease:Quint.easeOut } );
			for (var i:Number = 0; i < TOTAL; i++) 
				if (i != selected)
					items[i].visible = false;
		   dispatchEvent(new SimpleComboBoxEvent(SimpleComboBoxEvent.ON_OUT, (e.target.index)));
	   }
	   
	   private function itemClick(e:MouseEvent):void
	   {
		   if (e.target.index != selected)
		    {
				selected = e.target.index;
				topClip.y = e.target.y;
				e.target.y = y0;
				topClip = e.target as MovieClip;
				dispatchEvent(new SimpleComboBoxEvent(SimpleComboBoxEvent.ON_CLICK, (e.target.index)));
		    }
			else
			{
				dispatchEvent(new SimpleComboBoxEvent(SimpleComboBoxEvent.ON_CLICK, -1));
			}
	   }
	   
	   // methods
	   public function hideMenuItem():void
	   {
		   for (var i:Number = 0; i < TOTAL; i++) 
			if (i != selected)
				items[i].visible = false;
			else
				items[i].visible = true;
		   //visibleStatus = false;
	   }
	   
	   public function showMenuItem():void
	   {
		   for (var i:Number = 1; i < TOTAL; i++) items[i].visible = true;
   		   //visibleStatus = true;

	   }
	   
   }
	
}