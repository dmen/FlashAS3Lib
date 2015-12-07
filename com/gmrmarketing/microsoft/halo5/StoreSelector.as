package com.gmrmarketing.microsoft.halo5
{
	import flash.events.*;
	import flash.display.*;
	import com.gmrmarketing.utilities.components.ComboBox;	
	

	public class StoreSelector extends EventDispatcher
	{
		public static const COMPLETE:String = "storeSelected";
		
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var cb:ComboBox;
		private var myData:Object;
		
		
		public function StoreSelector()
		{
			clip = new mcStoreList();
			
			myData = { };
			
			cb = new ComboBox();			
			cb.setLabelProperties(500, 40, 0, 15, 22, new calibri(), 7);
			cb.setListProperties(20, 38, 15, 22, new calibri(), 6);
			cb.setLabelColors();
			cb.setListColors();			
			cb.x = 800;
			cb.y = 400;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show(store:String = ""):void
		{
			if (myContainer) {
				if (!myContainer.contains(clip)) {
					myContainer.addChild(clip);
				}
			}
			clip.theStore.text = store;
			clip.btnChoose.visible = false;
		}
		
		
		/**
		 * array of objects with id,label,value keys (label=value)
		 * @param	items
		 */
		public function showList(items:Array):void
		{
			/*
			for (var i:int = 0; i < items.length; i++) {
				trace("a.push({\"id\":" + items[i].id + ", \"label\":\"" + items[i].label + "\", \"value\":\"" + items[i].value + "\"});");
			}
			*/
			clip.theText.text = ""; //erase default downloading text
			
			cb.addItems(items);
			cb.addEventListener(ComboBox.CHANGED, comboSelected, false, 0, true);			
			clip.addChild(cb);
			
			clip.btnChoose.visible = true;
			clip.btnChoose.addEventListener(MouseEvent.MOUSE_DOWN, chooseStore, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (myContainer) {
				if (myContainer.contains(clip)) {
					myContainer.removeChild(clip);
				}
			}
			cb.removeEventListener(ComboBox.CHANGED, comboSelected);
			clip.btnChoose.removeEventListener(MouseEvent.MOUSE_DOWN, chooseStore);
		}
		
		
		public function get data():Object
		{
			return myData;
		}
		
		
		private function comboSelected(e:Event):void
		{
			myData = cb.selectedItem;
			clip.theStore.text = myData.label;
		}
		
		
		private function chooseStore(e:MouseEvent):void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
	}
	
}