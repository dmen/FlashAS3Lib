/**
 * Contains the list of venues, and the stamps that go with each
 * Uses a shared object to store the selected venue
 * Calls the tracking service to update stats
 */
package com.sagecollective.corona.atp
{	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import fl.data.DataProvider; 
	import com.greensock.TweenMax;
	

	public class Stats extends EventDispatcher
	{	
		public static const STATS_CLOSED:String = "statsClosed";
		
		private var theSO:SharedObject;		
		
		private var theVenues:Array;
		private var loader:URLLoader;
		private var eventProvider:DataProvider;
		
		private var container:DisplayObjectContainer;
		private var admin:MovieClip;		
		
		private var selectedVenue:String;
		private var selectedStamp:String;
		private var link1:String;
		private var link2:String;
		
		
		public function Stats($container:DisplayObjectContainer)
		{
			container = $container;
			admin = new the_admin(); //lib clip
			
			theSO = SharedObject.getLocal("coronaATPData", "/");
			selectedVenue = theSO.data.venue;
			selectedStamp = theSO.data.stamp;
			link1 = theSO.data.link1;
			link2 = theSO.data.link2;
			
			if (selectedVenue == null) {
				clearData();
			}	
			
			//label is what shows in the dropdown
			//data is stamp name in the library
			//link1 and 2 appear in the facebook post
			theVenues = new Array();			
			theVenues.push( { label:"Atlanta", data:"stamp_atlanta", link1:"www.atlantatennischampionships.com", link2:"www.facebook.com/ATChampionships" } );
			theVenues.push( { label:"Cincinnati", data:"stamp_cincinnati", link1:"www.cincytennis.com", link2:"www.facebook.com/cincytennis" } );
			theVenues.push( { label:"Washington DC", data:"stamp_dc", link1:"www.leggmasontennisclassic.com", link2:"www.facebook.com/dcatptennis" } );
			theVenues.push( { label:"Delray Beach", data:"stamp_delray", link1:"www.yellowtennisball.com", link2:"http://www.facebook.com/delraybeachITCfans" } );			
			theVenues.push( { label:"Indian Wells", data:"stamp_indianwells", link1:"www.bnpparibasopen.com", link2:"www.facebook.com/BNPPARIBASOPEN" } );
			theVenues.push( { label:"Key Biscayne", data:"stamp_keybiscayne", link1:"www.sonyericssonopen.com", link2:"www.facebook.com/SonyEricssonOpen" } );			
			theVenues.push( { label:"Memphis", data:"stamp_memphis", link1:"www.memphistennis.com", link2:"http://www.facebook.com/memphistennis" } );			
			theVenues.push( { label:"Newport", data:"stamp_newport", link1:"www.tennisfame.com/atp-tournament", link2:"www.facebook.com/HallofFameTennisChamps" } );		
			theVenues.push( { label:"Winston", data:"stamp_winston", link1:"www.winstonsalemopen.com", link2:"www.facebook.com/WinstonSalemOpen" } );
			
			eventProvider = new DataProvider(theVenues);
		}
		
		
		/**
		 * Calls the tracking webservice to update the data
		 * @param	type String, the type of data to update: started, printed, shared, emailed
		 */
		public function updateData(type:String):void
		{			
			var request:URLRequest = new URLRequest("https://coronaatp.thesocialtab.net/Home/Track");
				
			var vars:URLVariables = new URLVariables();
			vars.venue = selectedVenue;
			vars.email = "";
			vars.type = type;			
			
			request.data = vars;			
			request.method = URLRequestMethod.POST;
			
			var lo:URLLoader = new URLLoader();
			lo.addEventListener(IOErrorEvent.IO_ERROR, dataError, false, 0, true);
			lo.addEventListener(Event.COMPLETE, dataPosted, false, 0, true);
			lo.load(request);			
		}
		
		
		public function getVenue():String
		{
			return selectedVenue;
		}
		
		public function getStamp():String
		{
			return selectedStamp;
		}
		
		public function getLinks():Array 
		{
			return new Array(link1, link2);
		}
		
		/**
		 * Shows the admin interface on screen
		 */
		public function show():void
		{
			if(!container.contains(admin)){
				container.addChild(admin);
			}
			
			admin.theEvents.dataProvider = eventProvider; //populate dropdown			
			admin.btnExit.addEventListener(MouseEvent.MOUSE_DOWN, hide, false, 0, true);
			
			admin.currentEvent.text = selectedVenue;			
			admin.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveSelectedVenue, false, 0, true);
		}
		
		/**
		 * dateError and dataPosted do nothing... no alerts on an error
		 * @param	e
		 */
		private function dataError(e:IOErrorEvent):void{}		
		private function dataPosted(e:Event):void{}
		
		/**
		 * Called by pressing Exit button
		 * @param	e
		 */
		private function hide(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
			if (container.contains(admin)) {
				container.removeChild(admin);
				admin.btnExit.removeEventListener(MouseEvent.MOUSE_DOWN, hide);
				admin.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveSelectedVenue);
				
				dispatchEvent(new Event(STATS_CLOSED));
			}
		}
		
		
		/**
		 * Called by pressing the Save button by the event dropdown
		 * @param	e
		 */
		private function saveSelectedVenue(e:MouseEvent):void
		{
			selectedVenue = admin.theEvents.selectedItem.label;
			selectedStamp = admin.theEvents.selectedItem.data;
			link1 = admin.theEvents.selectedItem.link1;
			link2 = admin.theEvents.selectedItem.link2;
			
			showMessage("Data capture now using newly selected venue");
			admin.currentEvent.text = selectedVenue;
			
			saveData();
		}
		
		
		private function showMessage(message:String):void
		{
			admin.theMessage.alpha = 1;
			admin.theMessage.text = message;
			TweenMax.to(admin.theMessage, 2, { alpha:0, delay:10 } );
		}	
		
	
		public function saveData():void
		{			
			theSO.data.venue = selectedVenue;
			theSO.data.stamp = selectedStamp;
			theSO.data.link1 = link1;
			theSO.data.link2 = link2;
			
			theSO.flush();
		}
	
		
		public function clearData():void
		{
			selectedVenue = "no venue selected";
			selectedStamp = "";
			link1 = "";
			link2 = "";
			
			theSO.data.venue = selectedVenue;
			theSO.data.stamp = selectedStamp;
			theSO.data.link1 = link1;
			theSO.data.link2 = link2;
			
			theSO.flush();
		}
	}	
}