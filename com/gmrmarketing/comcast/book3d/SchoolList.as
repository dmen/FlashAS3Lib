package com.gmrmarketing.comcast.book3d
{
	import flash.events.*;
	import flash.display.*;
	import flash.net.*;
	import com.gmrmarketing.utilities.components.ComboBox;

	public class SchoolList extends EventDispatcher
	{
		public static const COMPLETE:String = "listDownloadComplete";
		public static const SELECTED:String = "schoolSelected";
		
		private var myContainer:DisplayObjectContainer;
		private var clip:MovieClip;
		
		private var so:SharedObject;
		private var univList:Array;
		private var selectedSchool:Object;
		private var combo:ComboBox;
		
		
		public function SchoolList()
		{	
			clip = new mcUnivList();
			
			combo = new ComboBox();
			//width, height, corner radius, toggle percent, fsize, font, left margin
			combo.setLabelProperties(600, 60, 12, 10, 22, new arial(), 8);
			//# v lines, vheight, slider percent, font size, font ref, left margin
			combo.setListProperties(20, 25, 10, 18, new arial(), 8);
			combo.setLabelColors(0xbbbbbb,0x666666,0xdddddd,0xaaaaaa,0xdddddd,0xaaaaaa);
			combo.setListColors(0xcccccc, 0x333333, 0x666666, 0xaaaaaa);
			combo.setDefaultMessage("Please Select University");
			
			so = SharedObject.getLocal("universityList", "/");			
			
			var req:URLRequest = new URLRequest("http://comcastuniversityshellgame.thesocialtab.net/Service/GetSchools");		
			
			req.requestHeaders.push(new URLRequestHeader("Accept", "application/json"));
			req.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, listError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, listComplete, false, 0, true);
			lo.load(req);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(clip)) {
				myContainer.addChild(clip);
			}
			if (!clip.contains(combo)) {
				clip.addChild(combo);
			}
			combo.x = 50;
			combo.y = 125;
			combo.addItems(univList);
			if (so.data.selected != null) {
				combo.setDefaultMessage(so.data.selected.label);
				selectedSchool = { label:so.data.selected.label, data:so.data.selected.data };
			}
			combo.addEventListener(ComboBox.CHANGED, selectionUpdated, false, 0, true);			
			clip.btnSelect.addEventListener(MouseEvent.MOUSE_DOWN, schoolSelected, false, 0, true);
		}
		
		
		public function hide():void
		{
			if (clip.contains(combo)) {
				clip.removeChild(combo);
			}
			combo.removeEventListener(ComboBox.CHANGED, selectionUpdated);
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
		}
		
		
		/**
		 * returns an object with label and data properties
		 */
		public function get selected():Object
		{
			return selectedSchool;
		}
		
		
		private function selectionUpdated(e:Event):void
		{
			selectedSchool = combo.selectedItem;
			so.data.selected = selectedSchool;
			so.flush();
		}
			
		
		/**
		 * called if an error occurs calling the web service
		 * @param	e
		 */
		private function listError(e:IOErrorEvent):void
		{
			univList = so.data.list;
			selectedSchool = so.data.selected;
			
			if (univList == null) {
				univList = [];
				selectedSchool = { label:"", data:0 };
			}
			
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		private function listComplete(e:Event):void
		{
			var js:Object = JSON.parse(e.currentTarget.data);//array of objects with ID and School keys
			
			univList = [];
			for (var i:int = 0; i < js.length; i++) {
				univList.push( { label:js[i].School, data:js[i].ID } );
			}
			
			so.data.list = univList;
			so.flush();
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * Called when select location button is pressed
		 * @param	e
		 */
		private function schoolSelected(e:MouseEvent):void
		{
			clip.btnSelect.removeEventListener(MouseEvent.MOUSE_DOWN, schoolSelected);
			dispatchEvent(new Event(SELECTED));
		}
	}
	
}