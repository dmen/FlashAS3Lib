package com.gmrmarketing.nfl.wineapp
{
	import flash.display.*;
	import com.gmrmarketing.utilities.components.ComboBox;	
	import flash.events.*;
	import flash.net.SharedObject;
	
	
	public class ConfigDialog extends EventDispatcher 
	{
		public static const COMPLETE:String = "CONFIGCOMPLETE";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		private var white1Combo:ComboBox;
		private var white2Combo:ComboBox;
		private var white3Combo:ComboBox;
		
		private var red1Combo:ComboBox;
		private var red2Combo:ComboBox;
		private var red3Combo:ComboBox;
		
		private var so:SharedObject;		
		
		
		public function ConfigDialog()
		{
			so = SharedObject.getLocal("nflWineAppData");
			
			clip = new mcConfigWine();
			
			white1Combo = new ComboBox();
			white1Combo.x = 630;
			white1Combo.y = 720;
			
			white2Combo = new ComboBox();
			white2Combo.x = 1135;
			white2Combo.y = 720;
			
			white3Combo = new ComboBox();
			white3Combo.x = 1640;
			white3Combo.y = 720;
			
			red1Combo = new ComboBox();
			red1Combo.x = 630;
			red1Combo.y = 1040;
			
			red2Combo = new ComboBox();
			red2Combo.x = 1135;
			red2Combo.y = 1040;	
			
			red3Combo = new ComboBox();
			red3Combo.x = 1640;
			red3Combo.y = 1040;	
			
			var d:Object = { };
			d.labelSize = 25;
			d.itemSize = 22;
			d.visibleItems = 5;
			d.whiteBG = 0x555555;
			d.redBG = 0xaa4444;
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			white1Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			white1Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			white1Combo.setLabelColors(0xbbbbbb,d.whiteBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			white1Combo.setListColors(0xcccccc, 0x333333, d.whiteBG, 0xaaaaaa);
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			white2Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			white2Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			white2Combo.setLabelColors(0xbbbbbb,d.whiteBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			white2Combo.setListColors(0xcccccc, 0x333333, d.whiteBG, 0xaaaaaa);
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			white3Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			white3Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			white3Combo.setLabelColors(0xbbbbbb,d.whiteBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			white3Combo.setListColors(0xcccccc,0x333333,d.whiteBG,0xaaaaaa);
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			red1Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			red1Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			red1Combo.setLabelColors(0xbbbbbb,d.redBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			red1Combo.setListColors(0xcccccc, 0x333333, d.redBG, 0xaaaaaa);
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			red2Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			red2Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			red2Combo.setLabelColors(0xbbbbbb,d.redBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			red2Combo.setListColors(0xcccccc, 0x333333, d.redBG, 0xaaaaaa);
			
			//width, height, corner radius, toggle percent, fontSize, fontReference, leftMargin
			red3Combo.setLabelProperties(480, 50, 10, 12, d.labelSize, new endZone(), 12);			
			//numVisibleItems, itemHeight, sliderPercentWidth, fontSize, fontReference, leftMargin
			red3Combo.setListProperties(d.visibleItems, 38, 10, d.itemSize, new endZone(), 14);			
			//labelTextColor, bgColor, borderColor, arrowBorderColor, arrowFillColor, separatorLineColor
			red3Combo.setLabelColors(0xbbbbbb,d.redBG,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			//itemTextColor, itemHighlightColor, bgColor, bgHighlightColor
			red3Combo.setListColors(0xcccccc,0x333333,d.redBG,0xaaaaaa);
			
			clip.addChild(white1Combo);
			clip.addChild(white2Combo);
			clip.addChild(white3Combo);
			
			clip.addChild(red1Combo);
			clip.addChild(red2Combo);
			clip.addChild(red3Combo);			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * returns an array of item objects {label, data}
		 * @param	category
		 * @return
		 */
		public function selectedWines(category:String):Array
		{
			var ret:Array = [];
			if (category == "White") {
				ret.push(so.data.white1, so.data.white2, so.data.white3);
			}else {
				ret.push(so.data.red1, so.data.red2, so.data.red3);
			}
			
			return ret;
		}
		
		
		public function setData(whites:Array, reds:Array):void
		{
			var whiteData:Array = [];
			for (i = 0; i < whites.length; i++) {
				whiteData.push( { label:whites[i].id + " - " + whites[i].vintage + " " + whites[i].variety, data:whites[i].id } );
			}
			
			var redData:Array = [];
			for (var i:int = 0; i < reds.length; i++) {
				redData.push( { label:reds[i].id + " - " + reds[i].vintage + " " + reds[i].variety, data:reds[i].id } );
			}
						
			white1Combo.addItems(whiteData);
			white2Combo.addItems(whiteData);
			white3Combo.addItems(whiteData);
			
			red1Combo.addItems(redData);
			red2Combo.addItems(redData);
			red3Combo.addItems(redData);			
		}		
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}			
			
			if (so.data.white1 != null) {
				white1Combo.selectedItem = so.data.white1;
			}
			if (so.data.white2 != null) {
				white2Combo.selectedItem = so.data.white2;
			}
			if (so.data.white3 != null) {
				white3Combo.selectedItem = so.data.white3;
			}
			
			if (so.data.red1 != null) {
				red1Combo.selectedItem = so.data.red1;
			}
			if (so.data.red2 != null) {
				red2Combo.selectedItem = so.data.red2;
			}
			if (so.data.red3 != null) {
				red3Combo.selectedItem = so.data.red3;
			}
			
			clip.btnCancel.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, doSave, false, 0, true);
		}
		
		
		public function hide(e:MouseEvent = null):void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			
			clip.btnCancel.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
			clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, doSave);
			dispatchEvent(new Event(COMPLETE));
		}		
		
		
		private function doSave(e:MouseEvent):void
		{
			so.data.white1 = white1Combo.selectedItem;
			so.data.white2 = white2Combo.selectedItem;
			so.data.white3 = white3Combo.selectedItem;
			
			so.data.red1 = red1Combo.selectedItem;
			so.data.red2 = red2Combo.selectedItem;
			so.data.red3 = red3Combo.selectedItem;
			
			so.flush();
			
			hide();
		}		
		
	}
	
}