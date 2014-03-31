package com.gmrmarketing.jimbeam.boldchoice
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import fl.data.DataProvider;
	import flash.events.IOErrorEvent;	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	
	
	public class Admin extends EventDispatcher 
	{
		public static const ADMIN_CLOSED:String = "adminDialogClosed";
		
		private var clip:MovieClip;
		private var container:DisplayObjectContainer;
		private var numQuestions:int;
		private var numQuestionsTemp:int;
		private var so:SharedObject;
		
		private var soRecap:SharedObject;
		private var items:Array;
		private var curIndex:int;
		private var userData:Array;
		
		private var venues:Array;
		private var venueProvider:DataProvider;
		private var currentVenue:String;
		
		
		
		public function Admin()
		{
			so = SharedObject.getLocal("genericAppData", "/");
			soRecap = SharedObject.getLocal("JBBC_bad_data", "/");
			
			numQuestions = so.data.numQuestions;			
			currentVenue = so.data.venue;			
			
			if (numQuestions == undefined || numQuestions < 3) {				
				numQuestions = 3;
				currentVenue = "Richmond";
				save();
			}
			numQuestionsTemp = numQuestions;
			
			
			venues = new Array();
			venues.push( { label:"Denver" } );
			venues.push( { label:"San Diego" } );
			venues.push( { label:"Tampa" } );
			venues.push( { label:"Louisville" } );
			venues.push( { label:"Indianapolis" } );
			venues.push( { label:"Dallas" } );
			venues.push( { label:"Kansas City" } );
			venues.push( { label:"Richmond" } );
			venues.push( { label:"Charlotte" } );
			venues.push( { label:"St. Louis" } );
			venues.push( { label:"Seattle" } );
			
			venueProvider = new DataProvider(venues);
			
			clip = new the_admin(); //lib clip
		}
		
		
		public function show($container:DisplayObjectContainer = null):void
		{
			if($container != null){
				container = $container;
			}
			clip.alpha = 0;
			if(!container.contains(clip)){
				container.addChild(clip);
			}
			
			clip.venues.dataProvider = venueProvider;
			
			//show the current venue in the dropdown
			for (var i:int = 0; i < venues.length; i++) {
				if (currentVenue == venues[i].label) {
					clip.venues.selectedIndex = i;
					break;
				}
			}
			
			numQuestionsTemp = numQuestions;
			clip.numQuestions.text = String(numQuestions);
			
			clip.btnDown.addEventListener(MouseEvent.MOUSE_DOWN, clickDown, false, 0, true);
			clip.btnUp.addEventListener(MouseEvent.MOUSE_DOWN, clickUp, false, 0, true);
			clip.btnSave.addEventListener(MouseEvent.MOUSE_DOWN, saveData, false, 0, true);
			clip.btnClose.addEventListener(MouseEvent.MOUSE_DOWN, close, false, 0, true);
			
			clip.errMessage.text = "";
			curIndex = -1;
			items = soRecap.data.records; //array of arrays - each sub array contains: venue,email,optin
			if (items == null) {
				items = new Array();
			}
			
			clip.theText.text = "There are " + items.length + " records that need to be uploaded";
			
			if (items.length > 0) {
				clip.btnUpload.alpha = 1;
				clip.btnUpload.addEventListener(MouseEvent.CLICK, beginUpload, false, 0, true);				
			}else {
				clip.btnUpload.alpha = .85;				
			}
			
			clip.btnCancel.addEventListener(MouseEvent.CLICK, cancelPressed, false, 0, true);
			
			TweenMax.to(clip, .5, { alpha:1 } );
		}
		
		
		public function hide():void
		{
			
			if (container) {
				if (container.contains(clip)) {
					clip.venues.close();
					clip.btnDown.removeEventListener(MouseEvent.MOUSE_DOWN, clickDown);
					clip.btnUp.removeEventListener(MouseEvent.MOUSE_DOWN, clickUp);
					clip.btnSave.removeEventListener(MouseEvent.MOUSE_DOWN, saveData);
					clip.btnClose.removeEventListener(MouseEvent.MOUSE_DOWN, close);
					clip.btnCancel.removeEventListener(MouseEvent.CLICK, cancelPressed);
					clip.btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload);
					container.removeChild(clip);
				}
			}
		}
		
		
		public function getNumQuestions():int
		{
			return numQuestions;
		}
		
		
		public function getVenue():String
		{
			return currentVenue;
		}
		
		
		/**
		 * Called by clicking the close button
		 * @param	e
		 */
		private function close(e:MouseEvent):void
		{
			hide();
		}
		
		
		private function beginUpload(e:MouseEvent):void
		{			
			clip.btnUpload.removeEventListener(MouseEvent.CLICK, beginUpload); //disable upload button
			clip.btnUpload.alpha = .85;
			
			curIndex = -1;
			processNextFile();			
		}
		
		
		private function processNextFile():void
		{
			curIndex++;
			clip.theText.text = "Uploading record: " + String(curIndex + 1);
			if (items.length > 0) {
				
				userData = items.shift();//array with venue,email,optin elements
				
				var request:URLRequest = new URLRequest("http://jimbeamboldchoice.thesocialtab.net/Home/Submit");				
				
				var vars:URLVariables = new URLVariables();
				vars.market = userData[0];
				vars.email = userData[1];
				vars.optin = userData[2];
				
				request.data = vars;
				request.method = URLRequestMethod.GET;
				
				var lo:URLLoader = new URLLoader();
				lo.addEventListener(IOErrorEvent.IO_ERROR, sendError, false, 0, true);
				lo.addEventListener(Event.COMPLETE, saveDone, false, 0, true);
				lo.load(request);
			}else {
				finishedProcessing();
			}
		}
		
		
		/**
		 * IOError
		 * @param	e
		 */
		private function sendError(e:IOErrorEvent):void
		{			
			if (String(e.text).indexOf("2032")) {
				clip.errMessage.text = "Error: Check Internet Connection";
			}else{
				clip.errMessage.text = "Error: " + e.text;
			}
			stopProcessing();
		}
		
		
		/**
		 * Pressed cancel upload 
		 * @param	e
		 */
		private function stopProcessing(e:MouseEvent = null):void
		{	
			if(userData != null){
				items.push(userData);				
				so.data.records = items;
				so.flush();
			}
			show();
		}
		
		
		private function cancelPressed(e:MouseEvent):void
		{
			if(userData != null){
				items.push(userData);				
				so.data.records = items;
				so.flush();
			}
			hide();
		}
		
		
		/**
		 * Record upload complete
		 * @param	e
		 */
		private function saveDone(e:Event):void
		{
			if (e.target.data == false) {
				clip.errMessage.text = "An error occured";
				stopProcessing();
			}else{
				processNextFile();
			}
		}
		
		
		/**
		 * Called when all items have been uploaded
		 */
		private function finishedProcessing():void
		{
			userData = null;
			clip.errMessage.text = "Uploading Complete";
			show();
		}
		
		
		private function clickDown(e:MouseEvent):void
		{
			numQuestionsTemp--;
			if (numQuestionsTemp < 3) {
				numQuestionsTemp = 3;
			}
			clip.numQuestions.text = String(numQuestionsTemp);
		}
		
		
		private function clickUp(e:MouseEvent):void
		{
			numQuestionsTemp++;
			if (numQuestionsTemp > 9) {
				numQuestionsTemp = 9;
			}
			clip.numQuestions.text = String(numQuestionsTemp);
		}
		
		
		private function save():void
		{			
			so.data.numQuestions = numQuestions;
			so.data.venue = currentVenue;
			so.flush();
		}
		
		
		/**
		 * Called by clicking the save button
		 * @param	e
		 */
		private function saveData(e:MouseEvent):void
		{			
			currentVenue = clip.venues.selectedItem.label;
			numQuestions = numQuestionsTemp;
			save();
			dispatchEvent(new Event(ADMIN_CLOSED));
		}
	}
	
}