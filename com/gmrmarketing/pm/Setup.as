/**
 * Linkage class for setup clip in the library
 */

package com.gmrmarketing.pm
{
	import flash.display.MovieClip;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.system.fscommand;
	
	public class Setup extends MovieClip
	{		
		private var xmlLoader:URLLoader;
		private var setupXML:XML;
		private var css:String = "h1 { color:#ff0000; font-size: 14;}";
		private var ss:StyleSheet;
		private var currentBrand:XMLList;
		private var theBrand:String;
		private var requirements:XML;
		private var benefits:XML;
		
		
		public function Setup()
		{
			ss = new StyleSheet();
			ss.parseCSS(css);
			
			xmlLoader = new URLLoader();			
			
			var facilityProvider:DataProvider = new DataProvider();
			facilityProvider.addItem({label:"Adult Only Facility (AOF)", data:"aof"});
			facilityProvider.addItem( { label:"Partial Adult Only Facility (PAOF)", data:"paof" } );
			comboFacility.dataProvider = facilityProvider;
			
			xmlLoader.addEventListener(Event.COMPLETE, setupLoaded); 
			xmlLoader.load(new URLRequest("setup.xml"));
		}
		
		
		
		/**
		 * Called when setup.xml is done loading
		 * populates the markets dropdown
		 * loads venues.xml
		 * 
		 * @param	e
		 */
		private function setupLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, setupLoaded);
			setupXML = new XML(e.target.data);			
			
			var markets:DataProvider = new DataProvider();
			var marketList:XMLList = setupXML.markets.market;
			for each (var market:XML in marketList)  {
				markets.addItem( { label:market.@id, data:market.brands } );
			}
			comboMarket.dataProvider = markets;
			comboMarket.rowCount = 10;
			
			xmlLoader.addEventListener(Event.COMPLETE, venuesLoaded); 
			xmlLoader.load(new URLRequest("venues.xml"));
		}
		
		
		
		/**
		 * Called when venues.xml is done loading
		 * populates the venues dropdown
		 * loads requirements.xml
		 * 
		 * @param	e
		 */
		private function venuesLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, venuesLoaded);
			var venuesXML = new XML(e.target.data);
			
			var venues:DataProvider = new DataProvider();			
			
			var venueList:XMLList = venuesXML.venue;
			
			for each (var venue:XML in venueList)  {
				venues.addItem( { label:venue.type, data:venue.file } );
			}
			comboVenue.dataProvider = venues;
			comboVenue.rowCount = 6;
			
			//load requirements
			xmlLoader.addEventListener(Event.COMPLETE, requirementsLoaded); 
			xmlLoader.load(new URLRequest("requirements.xml"));			
		}
		
		
		/**
		 * Called when requirements.xml is done loading
		 * loads benefits.xml
		 * @param	e
		 */
		private function requirementsLoaded(e:Event):void
		{			
			xmlLoader.removeEventListener(Event.COMPLETE, requirementsLoaded);
			requirements = new XML(e.target.data);
			
			//load benefits
			xmlLoader.addEventListener(Event.COMPLETE, benefitsLoaded); 
			xmlLoader.load(new URLRequest("benefits.xml"));
		}
		
		
		/**
		 * Called when benefits.xml is done loading
		 * Final XML listener - all XML files loaded
		 * enables the combos and calls marketChanged() to 
		 * show the initial setup data
		 * 
		 * @param	e
		 */
		private function benefitsLoaded(e:Event):void
		{
			xmlLoader.removeEventListener(Event.COMPLETE, benefitsLoaded);
			benefits = new XML(e.target.data);
			
			enableCombos();
			marketChanged();
		}
			
		
		/**
		 * Called when the market dropdown is changed
		 * populates the brands dropdown based on the selected market
		 * 
		 * @param	e
		 */
		private function marketChanged(e:Event = null):void
		{			
			var theBrands:Array = String(comboMarket.selectedItem.data).split(",");			
			var brands:DataProvider = new DataProvider();			
			
			for (var i:int = 0; i < theBrands.length; i++) {				
				var aBrand:XMLList = setupXML.brand.(@id == theBrands[i]);			
				brands.addItem( { label:aBrand.@display, data:aBrand.@name } );
			}
			
			comboBrand.dataProvider = brands;
			comboBrand.rowCount = 6;
			comboBrand.selectedIndex = 0;			
			
			displaySetupData();
		}
		
		
		
		private function printPressed(e:MouseEvent):void
		{
			var theFile:String = comboFacility.selectedItem.data + "_sell_sheet.exe";
			fscommand("exec", theFile);
		}
		
		
		/**
		 * Called from benefitsLoaded() when all xml has finished loading
		 */
		private function enableCombos():void
		{
			
			comboFacility.addEventListener(Event.CHANGE, displaySetupData, false, 0, true);
			comboBrand.addEventListener(Event.CHANGE, displaySetupData, false, 0, true);
			comboVenue.addEventListener(Event.CHANGE, displaySetupData, false, 0, true);
			comboMarket.addEventListener(Event.CHANGE, marketChanged, false, 0, true);
		
			comboFacility.selectedIndex = 0;
			comboBrand.selectedIndex = 0;
			comboVenue.selectedIndex = 0;
			comboMarket.selectedIndex = 0;
		}
		
		
		/**
		 * Dispatches a beginPresentation event to the Main class
		 * 
		 * @param	e
		 */
		private function beginPressed(e:MouseEvent):void
		{
			dispatchEvent(new Event("beginPresentation"));			
		}
		
		
		
		/**
		 * Displays the setup text
		 * Called whenever one of the combo boxes on the setup screen is changed
		 * Called initially from venuesLoaded() to display the default selection data
		 * 
		 * @param	e CHANGED Event
		 */
		private function displaySetupData(e:Event = null):void
		{			
			var output:String;
			
			theBrand = comboBrand.selectedItem.data;
			
			if(theBrand == "Marlboro" || theBrand == "Marlboro with Snus" || theBrand == "Marlboro w/o Buck a Pack"){
				output = "<b>Program:</b><br/><ul><li>" + comboBrand.selectedItem.label + "</li></ul><br/><br/>";
				
				currentBrand = setupXML.brand.(@name == theBrand);
				
				var selFacility:String = comboFacility.selectedItem.data; //aof or paof
				
				output += "<b>Features:</b><br/>";
				var feats:XMLList;
				if(selFacility == "aof"){
					feats = currentBrand.features.feature;
				}else {
					feats = currentBrand.features.feature.(@type == "paof" || @type == "both")
				}			
				
				output += "<ul>";
				for each (var feat:XML in feats)  {
				 output += "<li>" + feat + "</li>";
				}
				output += "</ul><br/><br/>";
				
				output += "<b>Venue Type:</b><br/><ul><li>" + comboVenue.selectedItem.label + "</li></ul><br/><br/>";		
				
				output += "<b>Requirements:</b><br/>";
				var reqs:XMLList;
				if(selFacility == "aof"){
					reqs = requirements.requirement;
				}else {
					reqs = requirements.requirement.(@type == "paof" || @type == "both");
				}
				
				output += "<ul>";
				for each (var req:XML in reqs)  {
				 output += "<li>" + req + "</li>";
				}
				output += "</ul><br/><br/>";
				
				output += "<b>Benefits:</b><br/>";
				var bens:XMLList = benefits.benefit.(@brand == theBrand).benefitGroup;			
				output += "<ul>";
				for each (var ben:XML in bens)  {
				 output += "<li>" + ben.@id + "</li>";
				}
				output += "</ul>";				
				
				//enable presentation buttons
				btnBegin.buttonMode = true;
				btnBegin.addEventListener(MouseEvent.CLICK, beginPressed, false, 0, true);
				btnPrint.buttonMode = true;
				btnPrint.addEventListener(MouseEvent.CLICK, printPressed, false, 0, true);
				btnBegin.alpha = 1;
				btnPrint.alpha = 1;
			}else {
				
				output = "<br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>                                                             COMING SOON";
				//disable presentation buttons
				btnBegin.buttonMode = false;
				btnBegin.removeEventListener(MouseEvent.CLICK, beginPressed);
				btnPrint.buttonMode = false;
				btnPrint.removeEventListener(MouseEvent.CLICK, printPressed);
				btnBegin.alpha = .1;
				btnPrint.alpha = .1;
			}
			
			theText.htmlText = output;
		}
		
		
		public function getXML():XMLList
		{
			return currentBrand;
		}
		
		
		public function getBrand():String
		{
			return theBrand;
		}
		
		
		public function getVenue():String
		{
			return comboVenue.selectedItem.label;
		}
		
		
		public function getVenueFile():String
		{
			return comboVenue.selectedItem.data;
		}
		
		
		public function getFacilityType():String
		{
			return comboFacility.selectedItem.data;
		}
	}
	
}