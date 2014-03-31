package com.gmrmarketing.nissan
{
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapMouseEvent;
	import com.google.maps.MapType;
	import com.google.maps.InfoWindowOptions;
	import com.google.maps.LatLngBounds;
	import com.google.maps.MapMoveEvent;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import com.google.maps.interfaces.IPolyline;
	import com.google.maps.services.*;
	import com.google.maps.overlays.*;
	import com.google.maps.styles.*;
	import com.google.maps.controls.MapTypeControl;
	import com.google.maps.controls.ZoomControl;
	import com.google.maps.controls.PositionControl;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	import flash.system.Security;
	
	import com.gmrmarketing.googlemaps.GeoCoder;
	import com.gmrmarketing.utilities.XMLLoader;
	import com.gmrmarketing.nissan.MarkerButtons_web;
	import com.gmrmarketing.nissan.MarkerList;
	import com.gmrmarketing.nissan.DirectionsList;
	import com.gmrmarketing.nissan.CustomZoomControl;
	import com.gmrmarketing.nissan.ZipDialog_web;
	import com.gmrmarketing.nissan.RestartDialog_web;
	import com.gmrmarketing.nissan.HundredMileCircle;
	import com.gmrmarketing.nissan.RechargingStations;
	
	import com.greensock.TweenMax;
	
	import flash.display.LoaderInfo; //for flashVars
	
	
	
	public class Leaf_web extends MovieClip
	{
		private var map:Map;	
		
		private var geoCoder:GeoCoder;
		
		private var config:XMLLoader;
		private var currZip:String; //current zip code from config, or entered by user
		
		private var markerButtons:MarkerButtons_web;
		private var markerList:MarkerList;
		private var directions:DirectionsList;
		
		private var routeContainer:Sprite;
		private var routeContainerMask:Sprite;
		private var slideRatio:Number;
		private var slideStart:int;
		
		private var restartButton:baseButton;
		private var zipButton:baseButton;
		private var oneHundredMilesButton:baseButton;
		private var zoomMarkersButton:baseButton;
		
		private var zipDialog:ZipDialog_web;
		private var restartDialog:RestartDialog_web;
		private var bigCircle:HundredMileCircle;
		
		private var mapCenter:LatLng;
		
		private var customZoom:CustomZoomControl;
		
		private var helpDialog:help; //lib clip
		private var helpButton:baseButton;
		
		private var theKey:String; //flash var google maps API Key
		
		private var rechargeList:RechargingStations;
		
		
		
		
		public function Leaf_web()
		{
			//needed to allow free maps API key to work over HTTPS - otherwise need a premier key
			Security.allowInsecureDomain("maps.googleapis.com");
			
			theKey = loaderInfo.parameters.key; //;//
			theKey = "ABQIAAAAEmsJFo7jmBpA2NUE9158PxRc-kLq9bfpYNf1dBV-Ngqqg-qolhQzUyTWtgX3MhyjQd6XpSnnsDV0Fw";
			
			markerButtons = new MarkerButtons_web();
			markerButtons.buildButtons(this);
			markerButtons.addEventListener(MarkerButtons.M_CLICK, markerButtonClicked, false, 0, true);
			
			//only show home button initially
			markerButtons.disableButtons();
			markerButtons.enableHomeButton(); 
			
			//buttons at lower left of map
			restartButton = new baseButton();
			restartButton.theText.text = "restart";
			restartButton.x = 430;
			restartButton.y = 6;
			addChild(restartButton);
			restartButton.addEventListener(MouseEvent.CLICK, showRestartDialog, false, 0, true);
			restartButton.buttonMode = true;
			restartButton.mouseChildren = false;
			
			zipButton = new baseButton();
			zipButton.theText.text = "zip code";
			zipButton.x = 506;
			zipButton.y = 6;
			addChild(zipButton);
			zipButton.addEventListener(MouseEvent.CLICK, showZipDialog, false, 0, true);
			zipButton.buttonMode = true;
			zipButton.mouseChildren = false;
			
			oneHundredMilesButton = new baseButton();
			oneHundredMilesButton.theText.text = "100 miles";
			oneHundredMilesButton.x = 582;
			oneHundredMilesButton.y = 6;
			addChild(oneHundredMilesButton);
			oneHundredMilesButton.addEventListener(MouseEvent.CLICK, hundredMilesClicked, false, 0, true);
			oneHundredMilesButton.buttonMode = true;
			oneHundredMilesButton.mouseChildren = false;
			
			zoomMarkersButton = new baseButton();
			zoomMarkersButton.theText.text = "show route";
			zoomMarkersButton.x = 658;
			zoomMarkersButton.y = 6;
			addChild(zoomMarkersButton);
			zoomMarkersButton.addEventListener(MouseEvent.CLICK, zoomAllMarkers, false, 0, true);
			zoomMarkersButton.buttonMode = true;
			zoomMarkersButton.mouseChildren = false;
			
			helpButton = new baseButton();
			helpButton.theText.text = "help";
			helpButton.x = 734;
			helpButton.y = 6;
			addChild(helpButton);
			helpButton.addEventListener(MouseEvent.CLICK, showHelp, false, 0, true);
			helpButton.buttonMode = true;
			helpButton.mouseChildren = false;
			
			//new zip dialog
			zipDialog = new ZipDialog_web(this);
			zipDialog.addEventListener(ZipDialog_web.ZIP_CLICK, zipOkClicked, false, 0, true);
			
			//new restart dialog
			restartDialog = new RestartDialog_web(this);
			
			helpDialog = new help();
			helpDialog.x = 524;
			helpDialog.y = 50;
			helpDialog.btnOK.addEventListener(MouseEvent.CLICK, closeHelp, false, 0, true);
			helpDialog.btnOK.buttonMode = true;
			
			map = new Map();			
			map.key = theKey; //from FlashVar
			map.sensor = "false";
			map.setSize(new Point(490, 506));
			map.x = 410;
			map.y = 0;
			map.addEventListener(MapEvent.MAP_READY, onMapReady);			
			map.addEventListener(MapMouseEvent.DOUBLE_CLICK, mapViewChanged, false, 0, true);
			map.addEventListener(MapMouseEvent.DRAG_END, mapViewChanged, false, 0, true);
			
			
			//map.addControl(new MapTypeControl()); //map,satellite,hybrid,terrain
			customZoom = new CustomZoomControl();
			customZoom.addEventListener(CustomZoomControl.DID_ZOOM, mapViewChanged, false, 0, true);
			map.addControl(customZoom); //zoom +,- and slider
			
			//map.addControl(new PositionControl()); //pan control

			addChildAt(map, 0);
			
			routeContainer = new Sprite();			
			addChild(routeContainer);
			routeContainer.x = 211;
			routeContainer.y = 109;
			markerList = new MarkerList(routeContainer, map);
			markerList.addEventListener(MarkerList.MARKER_DROPPED, updateDirections, false, 0, true);
			markerList.addEventListener(MarkerList.MARKER_DELETE, deleteMarker, false, 0, true);
			markerList.addEventListener(MarkerList.ALL_MARKER_DELETE, deleteAllMarkers, false, 0, true);
			markerList.addEventListener(MarkerList.ONLY_HOME_MARKERS_REMAIN, resetMileage, false, 0, true);
			
			routeContainerMask = new Sprite();
			routeContainerMask.graphics.beginFill(0x000000);
			routeContainerMask.graphics.drawRect(0, 0, 178, 387);
			routeContainerMask.x = 211;
			routeContainerMask.y = 109;
			addChild(routeContainerMask);
			routeContainer.mask = routeContainerMask;			
			
			//scroll bar			
			slideStart = slide.y;
			
			directions = new DirectionsList(map);
			directions.addEventListener(DirectionsList.DONE_CALCULATING, directionsFinished, false, 0, true);
			directions.addEventListener(DirectionsList.DIRECTIONS_ERROR, directionsError, false, 0, true);
			
			//100 mile circle
			bigCircle = new HundredMileCircle(map);			
			
			
		}

		
		/**
		 * Called when the Google API is ready
		 * Loads the config file to get the initial zip code
		 * 
		 * @param	e MAP_READY Google Map Event
		 */
		private function onMapReady(e:Event):void
		{			
			map.removeEventListener(MapEvent.MAP_READY, onMapReady);
			
			geoCoder = new GeoCoder();	
			
			config = new XMLLoader();
			config.load("config.xml");
			config.addEventListener(Event.COMPLETE, configLoaded, false, 0, true);
			config.addEventListener(IOErrorEvent.IO_ERROR, configError, false, 0, true);
			
			map.addEventListener(MouseEvent.MOUSE_WHEEL, wheelZoom, false, 0, true);
			
			stage.focus = map;
			//show zip dialog by default
			showZipDialog();
		}

		
		
		/**
		 * Called on successful load of the config.xml file
		 * sets the map center to the zip from the file
		 * 
		 * @param	e COMPLETE event
		 */
		private function configLoaded(e:Event):void
		{			
			var b:XML = config.getXML();
			changeZip(b.mapcenter);
			
			rechargeList = new RechargingStations(map, true);
		}
		
		
		
		/**
		 * Called if there's an error loading the config.xml file
		 * Defaults the zip code to new berlin, wi
		 * 
		 * @param	e ERROR event
		 */
		private function configError(e:Event):void
		{			
			changeZip("53151");
			
			rechargeList = new RechargingStations(map, true);
		}
		
		
		
		/**
		 * Called when the mouse wheel is turned
		 * Called by listener attached to map
		 * 
		 * @param	e
		 */
		private function wheelZoom(e:MouseEvent):void
		{			
			var mPoint:Point = new Point(map.mouseX, map.mouseY);
			var lat:LatLng = map.fromViewportToLatLng(mPoint);			
			
			if (e.delta < 0) {
				map.zoomOut(lat);
			}else {
				map.zoomIn(lat);
			}
			
			rechargeList.showMarkers();
		}
		
		
		
		/**
		 * Called when the OK button in the zip dialog is clicked
		 * Changes the current zip to the zip entered in the dialog
		 * @param	e
		 */
		private function zipOkClicked(e:Event):void
		{
			var newZip:String = zipDialog.getZip();
			if (newZip != "") {
				changeZip(newZip);
			}
		}
		
		
		
		/**
		 * Called when the OK button in the restart dialog is clicked
		 * @param	e
		 */
		private function restartOkClicked(e:Event):void
		{
			restartDialog.removeEventListener(RestartDialog_web.OK_CLICK, restartOkClicked);
			restartDialog.removeEventListener(RestartDialog_web.CANCEL_CLICK, restartCancelClicked);
			changeZip(currZip);
			showZipDialog();
		}
		
		
		private function restartCancelClicked(e:Event = null):void
		{
			restartDialog.removeEventListener(RestartDialog_web.OK_CLICK, restartOkClicked);
			restartDialog.removeEventListener(RestartDialog_web.CANCEL_CLICK, restartCancelClicked);
		}
		
		private function deleteHomeOkClicked(e:Event):void
		{
			restartDialog.removeEventListener(RestartDialog_web.OK_CLICK, deleteHomeOkClicked);
			restartDialog.removeEventListener(RestartDialog_web.CANCEL_CLICK, deleteHomeCancelClicked);
			clearMap();
		}
		
		private function deleteHomeCancelClicked(e:Event = null):void
		{
			restartDialog.removeEventListener(RestartDialog_web.OK_CLICK, deleteHomeOkClicked);
			restartDialog.removeEventListener(RestartDialog_web.CANCEL_CLICK, deleteHomeCancelClicked);
		}
		
		/**
		 * Removes any event listeners on the restart dialog
		 */
		private function clearRestart():void
		{
			restartCancelClicked();
			deleteHomeCancelClicked();
		}
		
		
		
		/**
		 * Changes the current zip to the new zip
		 * Calls gotZip with the geoCoded zip when complete
		 * 
		 * @param	newZip
		 */
		private function changeZip(newZip:String):void
		{
			clearMap();			
			currZip = newZip;
			geoCoder.getGeoCode(currZip);
			geoCoder.addEventListener(GeoCoder.LOC_COMPLETE, gotZip, false, 0, true);
		}
		
		
		
		private function clearMap():void
		{
			//clear all markers and routes when a new zip is entered			
			directions.clearCurrentRoute();
			markerList.clearMarkers();
			bigCircle.clearCircle();
			
			//updates the 100 miles text
			directionsFinished();
			
			//enables the marker buttons
			markerButtons.disableButtons();
			markerButtons.enableHomeButton();
			
			showZipDialog();
			
			//hide the max markers text
			TweenMax.to(maxText, .5, { alpha:0 } );
		}
		
		
		
		/**
		 * Called from listener on the geoCoder - changes the map
		 * center to the new zip code
		 * 
		 * @param	e
		 */
		private function gotZip(e:Event):void
		{
			map.setCenter(new LatLng(geoCoder.getLat(), geoCoder.getLng()), 12);
		}
		
		
		
		/**
		 * Called whenever one of the marker menu buttons is clicked
		 * Sends the string name of the maker from the menu
		 * ie - home, dinner, etc.
		 * 
		 * @param	e
		 */
		private function markerButtonClicked(e:Event):void
		{		
			if (markerList.canAddMarker()) {
				markerList.addMarker(markerButtons.getClicked());
				checkScroller(true);
			}else {
				markerButtons.disableButtons();
				restartDialog.show("Maximum number of markers has been added to the map.", "ok");
				clearRestart();
				TweenMax.to(maxText, .5, { alpha:1 } );
			}
			
		}
		
		
		
		/**
		 * Called whenever a marker is dropped - ie moved
		 * called from deleteMarker when a marker is deleted
		 * Calls the calculateRoute() method inside directions
		 * passing the current list of markers
		 * 
		 * @param	e MARKER_DROPPED event
		 */
		private function updateDirections(e:Event = null):void
		{
			var curMarkers:Array = markerList.getMarkers();		
			
			if (bigCircle.isCircleShowing()) {				
				bigCircle.drawCircle(Marker(curMarkers[0]).getLatLng());
			}
			
			//calculate route modifies the passed in markers array...
			directions.calculateRoute(curMarkers, markerList.getColors());
		}
		
		
		
		/**
		 * Called by listener when a marker delete is clicked in the MarkerList
		 * @param	e
		 */
		private function deleteMarker(e:Event):void
		{
			var deleteIndex:int = markerList.getDeleteIndex();
			markerList.deleteMarker(deleteIndex);
			markerButtons.enableButtons();
			markerButtons.disableHomeButton();
			TweenMax.to(maxText, .5, { alpha:0 } );
			updateDirections();
			checkScroller(false); //false - item was deleted
		}
		
		
		
		/**
		 * Called by listener when the home marker delete button is clicked
		 * @param	e
		 */
		private function deleteAllMarkers(e:Event):void
		{
			restartDialog.addEventListener(RestartDialog_web.OK_CLICK, deleteHomeOkClicked, false, 0, true);
			restartDialog.addEventListener(RestartDialog_web.CANCEL_CLICK, deleteHomeCancelClicked, false, 0, true);
			restartDialog.show("Removing the home marker will erase all markers and routes. Click OK to confirm.");
		}
		
		
		
		/**
		 * Called by listener when the routes between markers are done calculating
		 * ie when directionsList.calculateRoute is done and a DONE_CALCULATING event is dispatched
		 * Note - no event is dispatched is the passed in list of markers is empty
		 * 
		 * Called by clearMap() to reset the 100 miles text
		 * 
		 * @param	e DONE_CALCULATING event
		 */
		private function directionsFinished(e:Event = null):void
		{
			var distances:Array = directions.getDistances();			
			
			var tot:int = 100;			
			for (var i:int = 0; i < distances.length; i++) {
				tot -= distances[i];				
				while (tot < 0) {
					//recharge - add 100 miles
					tot += 100;	
				}
			}
			
			mileage.milesRemaining.text = String(tot);
			mileage.staticText.x = mileage.milesRemaining.textWidth + 7;
			
			var tw:Number = mileage.milesRemaining.textWidth + 114; //111 is text width + 8 for buffer
			
			mileage.x = Math.floor(20 + ((207 - tw) * .5));
			
			//update the list of markers on the left with the new distances			
			if(distances.length){
				markerList.updateItems(distances);
			}
			
			checkScroller(false);
		}
		
		
		/**
		 * Called when all but the two home markers have been deleted
		 * Called by listener when a ONLY_HOME_MARKERS_REMAIN event is dispatched from markerList
		 * @param	e
		 */
		private function resetMileage(e:Event):void
		{
			mileage.milesRemaining.text = "100";
			mileage.staticText.x = mileage.milesRemaining.textWidth + 7;
			
			var tw:Number = mileage.milesRemaining.textWidth + 114; //111 is text width + 8 for buffer
			
			mileage.x = Math.floor(20 + ((207 - tw) * .5));
		}
		
		
		/**
		 * Called from clicking the zip button at map bottom
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function showZipDialog(e:MouseEvent = null):void
		{
			zipDialog.show();
		}
		
		
		private function directionsError(e:Event):void
		{
			var char:String = String.fromCharCode(65 + directions.getErrorLocation());
			restartDialog.show("There was a problem calculating the route. Please check the placement of marker " + char, "ok");
			
		}
		
		
		/**
		 * Called when the restart button is clicked
		 * @param	e
		 */
		private function showRestartDialog(e:MouseEvent):void
		{
			restartDialog.addEventListener(RestartDialog_web.OK_CLICK, restartOkClicked, false, 0, true);
			restartDialog.addEventListener(RestartDialog_web.CANCEL_CLICK, restartCancelClicked, false, 0, true);
			restartDialog.show("Click OK to restart. All markers and routes will be deleted.");
		}
	
		
		
		/**
		 * Called by the zoom route button at map bottom
		 * Zooms the map to show the full collection of markers added
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function zoomAllMarkers(e:MouseEvent):void
		{
			var markers:Array = markerList.getMarkers();
			
			if(markers.length > 1){
				var latlngbounds:LatLngBounds = new LatLngBounds( );
				for ( var i = 0; i < markers.length; i++ ){
					latlngbounds.extend( markers[i].getLatLng() );
				}
				map.setCenter( latlngbounds.getCenter( ), map.getBoundsZoomLevel( latlngbounds ) );
			}
			
			//if only home marker has been added just center on it
			if (markers.length == 1) {
				map.setCenter( markers[0].getLatLng(), 12 );
			}
		}
		
		
		
		/**
		 * Called by listener when the map view is changed either by double clicking to
		 * zoom in or by dragging the map to a new location
		 * Or by clicking the zoom + - buttons
		 * 
		 * Gets the list of unmoved markers and moves them to map center
		 * 
		 * @param	e MapMoveEvent or CustomZoomControl event
		 */
		private function mapViewChanged(e:* = null):void
		{
			mapCenter = map.getCenter(); //LatLng object
			var markersToMove:Array = markerList.getNotDropped();
			
			for (var i:int = 0; i < markersToMove.length; i++) {
				markersToMove[i].setLatLng(mapCenter);
			}
			
			rechargeList.showMarkers();
		}
		
		
		
		/**
		 * Draws the big 100 mile diameter circle at the specified location
		 * map center if no marker is on the map, or the location of the first marker
		 * 
		 * @param	e
		 */
		private function hundredMilesClicked(e:MouseEvent):void
		{			
			var curMarkers:Array = markerList.getMarkers();
			if (curMarkers.length > 0) {
				bigCircle.drawCircle(Marker(curMarkers[0]).getLatLng());
			}else{
				bigCircle.drawCircle(map.getCenter());
			}
			map.setCenter(bigCircle.getCircleLoc(), bigCircle.getZoomBounds());
			//map.setZoom(bigCircle.getZoomBounds());				
		}
		
		
		
		/**
		 * Called when a mouseDown is received on the slider
		 * 
		 * @param	e MOUSE_DOWN MouseEvent
		 */
		private function beginSlideDrag(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging, false, 0, true);
			addEventListener(Event.ENTER_FRAME, updateListPosition, false, 0, true);
			slide.startDrag(false, new Rectangle(track.x, track.y + 1, 0, track.height - 16));
		}
		
		
		
		/**
		 * Called during a startDrag whenever the mouse is released
		 * stops the slider dragging
		 * 
		 * @param	e MOUSE_UP MouseEvent
		 */
		private function stopDragging(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
			removeEventListener(Event.ENTER_FRAME, updateListPosition);
			stopDrag();
		}
		
		
		
		/**
		 * Called by Enter frame while the slider is being dragged
		 * updates the list of markers based on the slider position
		 * 
		 * @param	e ENTER_FRAME Event
		 */
		private function updateListPosition(e:Event = null):void
		{
			var totalSlidePixels:int = track.height - 17;
			slideRatio = (routeContainer.height - routeContainerMask.height) / totalSlidePixels;
			
			var delta:int = slide.y - slideStart;
			var moveAmount:Number = delta * slideRatio;			
			routeContainer.y = routeContainerMask.y - moveAmount;
		}
		
		
		
		/**
		 * Called when the track is clicked on - moves the slider
		 * to the click position and then updates the list
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function trackClicked(e:MouseEvent):void
		{
			var sPos:int = e.stageY;
			sPos = Math.max(track.y + 1, sPos);
			sPos = Math.min(sPos, track.y + track.height - 16);
			slide.y = sPos;
			updateListPosition();
		}
		
		
		
		/**
		 * Called from markerButtonClicked() whenever a new marker is added to the list
		 * enables or disables the scroll bar
		 */
		private function checkScroller(itemWasAdded:Boolean):void
		{
			if (routeContainer.height > routeContainerMask.height) {				
				//enable scroller
				slide.alpha = 1;
				track.alpha = .6;
				slide.addEventListener(MouseEvent.MOUSE_DOWN, beginSlideDrag, false, 0, true);
				track.addEventListener(MouseEvent.CLICK, trackClicked, false, 0, true);
				if(itemWasAdded){
					slide.y = track.y + track.height - 16; //put slider at bottom to show new entry
				}
				updateListPosition();
			}else {
				//disable scroll
				slide.alpha = .24;
				track.alpha = .14;
				slide.removeEventListener(MouseEvent.MOUSE_DOWN, beginSlideDrag);
				track.removeEventListener(MouseEvent.CLICK, trackClicked);
				//reset slide and list position
				slide.y = slideStart;
				routeContainer.y = 109;
			}
		}
		
		
		private function showHelp(e:MouseEvent):void
		{
			if (!contains(helpDialog)) {
				addChild(helpDialog);
				helpDialog.alpha = 0;
				TweenMax.to(helpDialog, .5, { alpha:1 } );
			}
		}
		
		private function closeHelp(e:MouseEvent):void
		{
			removeChild(helpDialog);
		}
		
	}
	
}