/**
 * Venue Selector at very start of app
 * Only shows one time when the app first loads
 * 
 * loaded by main into venueSel
 * linked to tool_venueSelector clip in the library
 */
package com.gmrmarketing.smartcar
{
	import away3d.events.MouseEvent3D;
	import fl.data.DataProvider;
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.net.URLRequest;
	
	
	public class VenueSelector extends MovieClip
	{		
		public static const VENUE_SELECTED:String = "theVenueWasSelected";			
		
		private var loader:URLLoader;
		private var selVenue:String; //selected venue
		private var venueID:String; //selected venue's id from the xml
		
		private var listProvider:DataProvider;
		
		
		public function VenueSelector()
		{
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, fileLoaded, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, fileNotFound, false, 0, true);
			
			try{
				loader.load(new URLRequest(StaticData.VENUE_URL));
			}catch (e:Error) {
				
			}
			
			btnContinue.alpha = .3; //grayed out until list has loaded
			
			addEventListener(Event.REMOVED_FROM_STAGE, cleanUp, false, 0, true);
		}		
		
		public function showRecapData(n:int):void
		{
			netText.text = "There are " + String(n) + " files that need to be uploaded. Please run the recap app when this machine has an internet connection.";
		}
		
		private function fileLoaded(e:Event):void
		{			
			parseXML(new XML(e.target.data));
		}
		
		
		private function fileNotFound(e:IOErrorEvent):void
		{
			theText.text = "An error occured retrieving the venue list. Using hardcoded data. This machine may not be connected to the internet.";
			parseXML(getHardcodedXML());
		}		
		
		
		private function parseXML(xml:XML):void
		{
			listProvider = new DataProvider();
			
			var itList:XMLList = xml.event;
		
			var item:Object
			for (var i:int = 0; i < itList.length(); i++ ) {
				
				item = new Object();
				
				item.label = itList[i].name;
				item.id = itList[i].id;
				item.location = itList[i].location;
				item.startDate = itList[i].startDate;
				item.endDate = itList[i].endDate;
				
				listProvider.addItem( item );
			}				
		
			theVenue.dataProvider = listProvider;
			theVenue.selectedIndex = 0;
			venueSelected();
			theVenue.addEventListener(Event.CHANGE, venueSelected, false, 0, true);
			
			btnContinue.alpha = 1;
			btnContinue.addEventListener(MouseEvent.CLICK, doContinue, false, 0, true);
		}
		
		
		
		/**
		 * Called when the dropdown changes
		 * @param	e Event.CHANGE
		 */
		private function venueSelected(e:Event = null):void
		{			
			selVenue = theVenue.selectedItem.label;
			venueID = theVenue.selectedItem.id;			
		}
		
		/**
		 * Called when continue is pressed
		 * Listened for by Main
		 * Calls venSelected() in Main
		 * @param MouseEvent.CLICK
		 */
		private function doContinue(e:MouseEvent):void
		{
			dispatchEvent(new Event(VENUE_SELECTED));
		}
		
		public function getVenueName():String
		{
			return selVenue;
		}
		
		
		public function getVenueID():String
		{
			return venueID;
		}
		
		
		/** 
		 * Called when the object is removed from the display list
		 * @param	e Event.REMOVED_FROM_STAGE
		 */
		private function cleanUp(e:Event):void
		{			
			removeEventListener(Event.REMOVED_FROM_STAGE, cleanUp);
			theVenue.removeEventListener(Event.CHANGE, venueSelected);
			btnContinue.removeEventListener(MouseEvent.CLICK, doContinue);
			loader.removeEventListener(Event.COMPLETE, fileLoaded);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, fileNotFound);
		}
		
		
		private function getHardcodedXML():XML
		{
			var a:XML = <events><event><id>41238P</id><name>US Open</name><location>NYC</location><startDate>2011-08-25T00:00:00</startDate><endDate>2011-09-13T00:00:00</endDate></event><event><id>41239P</id><name>Fashion Week</name><location>NYC</location><startDate>2011-09-07T00:00:00</startDate><endDate>2011-09-16T00:00:00</endDate></event><event><id>41240P</id><name>Gen Art Fresh Faces NY</name><location>NYC</location><startDate>2011-09-09T00:00:00</startDate><endDate>2011-09-09T00:00:00</endDate></event><event><id>41241P</id><name>Gen Art Fresh Faces LA</name><location>LA</location><startDate>2011-10-17T00:00:00</startDate><endDate>2011-10-19T00:00:00</endDate></event><event><id>41242P</id><name>FFF Festival</name><location>NYC</location><startDate>2011-11-02T00:00:00</startDate><endDate>2011-11-07T00:00:00</endDate></event><event><id>41243P</id><name>Gen Art ArtBasel</name><location>Miami</location><startDate>2011-11-30T00:00:00</startDate><endDate>2011-12-06T00:00:00</endDate></event></events>;
			return a;
		}
	}
	
}