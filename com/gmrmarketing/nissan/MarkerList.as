/**
 * This is the list of both marker objects on the map
 * and the list of markers and mileages on the left side
 */

package com.gmrmarketing.nissan
{	
	import com.google.maps.Map;
	import com.google.maps.overlays.Marker;
	import com.google.maps.overlays.MarkerOptions;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import com.greensock.TweenMax;
	import com.google.maps.MapMouseEvent;
	
	
	public class MarkerList extends EventDispatcher
	{
		public static const MARKER_DROPPED:String = "mapMarkerWasDropped";
		public static const MARKER_DELETE:String = "markerBeingDeleted";	
		public static const ALL_MARKER_DELETE:String = "allMarkersBeingDeleted";
		public static const ONLY_HOME_MARKERS_REMAIN:String = "onlyHomeMarkersRemain";
		
		private var container:DisplayObjectContainer;
		private var markers:Array; //the actual markers on the map		
		
		private var routeItems:Array; //the list of routes on the left side
		private var map:Map;
		private var colors:Array;
		private var labels:Array;
		
		private var deleteIndex:int;
		private var batteries:Array;
		
		
		
		
		/**
		 * Constructor
		 * 
		 * @param	$container Display object container that marker list items are displayed in
		 * @param	$map Reference to the map instance - used for adding the markers
		 */
		public function MarkerList($container:DisplayObjectContainer, $map:Map)
		{
			container = $container;
			map = $map;
			
			colors = new Array( { iconColor:0x7bc143, fontColor:0x000000 }, { iconColor:0x00b6dd, fontColor:0x000000 }
			,{iconColor:0xe64097, fontColor:0x000000 }, { iconColor:0x522e91, fontColor:0xffffff }
			,{iconColor:0xff6e2e, fontColor:0x000000 }, {iconColor:0x002d6a, fontColor:0xffffff }
			,{ iconColor:0x299d19, fontColor:0x000000 }, { iconColor:0x73ffcf, fontColor:0x000000 }
			,{ iconColor:0xffbc2b, fontColor:0x000000 }, { iconColor:0x819d65, fontColor:0x000000 }
			,{ iconColor:0xaf51ff, fontColor:0x000000 }, { iconColor:0x004576, fontColor:0xffffff }
			,{ iconColor:0x4176ff, fontColor:0xffffff }, { iconColor:0xdea9ff, fontColor:0x000000 }
			,{iconColor:0xe64097, fontColor:0x000000 }, { iconColor:0x522e91, fontColor:0xffffff }
			,{iconColor:0xff6e2e, fontColor:0x000000 }, {iconColor:0x002d6a, fontColor:0xffffff }
			,{ iconColor:0x299d19, fontColor:0x000000 }, { iconColor:0x73ffcf, fontColor:0x000000 }
			,{ iconColor:0xffbc2b, fontColor:0x000000 }, { iconColor:0x819d65, fontColor:0x000000 }
			,{ iconColor:0xaf51ff, fontColor:0x000000 }, { iconColor:0x004576, fontColor:0xffffff }
			,{ iconColor:0x4176ff, fontColor:0xffffff }, { iconColor:0xdea9ff, fontColor:0x000000 });
			
			labels = new Array("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z");
			
			markers = new Array();			
			routeItems = new Array();
			batteries = new Array();
		}
		
		
		
		/**
		 * Removes the markers from map and removes the
		 * left side items
		 */
		public function clearMarkers():void
		{
			var p:Marker;
			while (markers.length) {
				p = markers.splice(0, 1)[0];
				map.removeOverlay(p);
				p = null;
			}
			markers = new Array();			
			
			var i:markerItem;
			while (routeItems.length) {
				i = routeItems.splice(0, 1)[0];
				container.removeChild(i);
				i = null;
			}
			routeItems = new Array();
			
			clearBatteries();
			
		}
		
		
		
		private function clearBatteries():void
		{
			//clear any batteries in the list
			var b:battery2;
			while (batteries.length) {
				b = batteries.splice(0, 1)[0];
				container.removeChild(b);				
				b = null;
			}
			batteries = new Array();
		}
		
		
		
		/**
		 * Returns array of marker objects
		 * Uses concat to pass a copy of the array - since arrays are passed by reference
		 * this keeps the array intact in case any changes are made to it by the calling method
		 * 
		 * @return Copy of the markers array
		 */
		public function getMarkers():Array
		{
			return markers.concat();
		}
		
		
		
		public function getColors():Array
		{
			return colors;
		}
		
		
		
		/**
		 * Returns the number of markers currently on the map
		 * @return Integer number of markers
		 */
		public function numberOfMarkers():int
		{
			return markers.length;
		}
		
		
		
		/**
		 * Returns true if there are labels that can still be used
		 * @return
		 */
		public function canAddMarker():Boolean
		{
			return markers.length < labels.length;
		}
		
		
		
		/**
		 * Called from Leaf once the routes have been calculated
		 * Updates the text in the list of marker items with the distances list
		 * 
		 * @param	distances Array of distances from the DirectionsList
		 */
		public function updateItems(distances:Array):void
		{
			//trace("markerList.updateItems()");
			var i:int;
			//clear any batteries currently showing
			clearBatteries();
			
			//respace the marker list
			for (i = 0; i < routeItems.length; i++){
				routeItems[i].y = i * 35;
			}
			
			var tot:int = 100;			
			routeItems[0].theDistance.text = "0"; //home
			
			for (i = 0; i < distances.length; i++) {				
				
				routeItems[i + 1].theDistance.text = distances[i];
			
				tot -= distances[i];				
				
				if (tot < 0) {
					while (tot < 0) {						
						tot += 100;
					}					
					//bat = new battery(); //lib clip
					var bat:battery2 = new battery2(); //lib clip
					//bat.scaleX = bat.scaleY = .75;
					//bat.x = 420;
					bat.x = 0; //same x as marker items
					//bat.y = (154 + ((i + 1) * 35)) - (bat.height * .5) + 1;
					bat.y = routeItems[i].y + 35; // 154 + ((i + 1) * 35);
					container.addChild(bat);
					batteries.push(bat);
					moveMarkerItemsDown(i + 1);
				}
			}			
		}
		
		
		
		/**
		 * Called from updateItems() above - moves the items down 35 pixels whenever a battery
		 * is added to the list
		 * 
		 * @param	ind Index of the first item to move
		 */
		private function moveMarkerItemsDown(ind:int):void
		{
			for (var i:int = ind; i < routeItems.length; i++) {
				routeItems[i].y += 35;
			}
		}
		
	
		
		
		/**
		 * Adds a Google maps marker at the map center
		 * Called by Leaf - markerButtonClicked() whenever one of the marker menu buttons is clicked
		 */
		public function addMarker(markerName:String):void
		{
			var ic:MovieClip = new customIcon(); //library clip
			ic.buttonMode = true;
			ic.theName = markerName; //for testing... unused in the app
			ic.beenDropped = false; //add a beenDropped flag to the custom icon - this is used to move any non-dropped
			//markers if the map is moved - set to true in markerDropped()
			
			var icLabel:String = labels[markers.length];
			ic.theText.text = icLabel;
			ic.theText.mouseEnabled = false;
			
			TweenMax.to(ic.fill, 0, { tint:colors[markers.length].iconColor } );
			TweenMax.to(ic.shadLayer, 0, { dropShadowFilter: { color:0x000000, alpha:1, blurX:6, blurY:6, distance:0, angle:0, quality:2} } );
			TweenMax.to(ic.theText, 0, { tint:colors[markers.length].fontColor } );
			
			var markerOptions:MarkerOptions = new MarkerOptions( { icon:ic, iconOffset:new Point( -16, -37), draggable:true, hasShadow:false } );
			
			var marker:Marker = new Marker(map.getCenter(), markerOptions);
			
			marker.addEventListener(MapMouseEvent.DRAG_END, markerDropped, false, 0, true);
			//marker.buttonMode = true;
			
			map.addOverlay(marker);
			
			//adds a marker item to the left side - the list of makers with distances
			var item:markerItem = new markerItem();
			item.markerIndex = markers.length;
			item.theLabel.text = markerName;
			item.theMarker.theText.text = icLabel;
			item.btnDelete.addEventListener(MouseEvent.CLICK, deleteMarkerClicked, false, 0, true);
			item.btnDelete.buttonMode = true;
			TweenMax.to(item.theMarker.fill, 0, { tint:colors[markers.length].iconColor } );
			TweenMax.to(item.theMarker.theText, 0, { tint:colors[markers.length].fontColor } );
			item.x = 0; //343;
			item.y = (markers.length + batteries.length) * 35;
			
			container.addChild(item);
			
			markers.push(marker);
			
			//check for looping route - ie duplicate the home marker if this is the first marker
			//added to the list
			if (routeItems.length == 0) {
				routeItems.push(item);
				item = new markerItem();
				item.theLabel.text = "home";
				item.theMarker.theText.text = "A";
				item.btnDelete.addEventListener(MouseEvent.CLICK, deleteMarkerClicked, false, 0, true);
				item.btnDelete.buttonMode = true;
				TweenMax.to(item.theMarker.fill, 0, { tint:colors[0].iconColor } );
				TweenMax.to(item.theMarker.theText, 0, { tint:colors[0].fontColor } );
				item.markerIndex = 0;
				item.x = 0;
				item.y = 35;
				container.addChild(item);
				routeItems.push(item);
			}else {
				//remove the final home from the list
				var lastItem:markerItem = routeItems.pop();
				container.removeChild(lastItem);
				//push the newly created one
				routeItems.push(item);
				//now push the last home back
				routeItems.push(lastItem);
				//and position it
				lastItem.y = item.y + 35;
				container.addChild(lastItem);
			}
		}
		
		
		
		/**
		 * Listened for by the main Leaf class - which calls DirectionsList.updateDirections() when received
		 * Sets the markers custom icon, beenDropped property to true - this is used bu getNotDropped() that
		 * returns the list of not yet placed markers
		 * 
		 * @param	e
		 */
		private function markerDropped(e:MapMouseEvent):void
		{
			e.feature.getOptions().icon.beenDropped = true;			
			dispatchEvent(new Event(MARKER_DROPPED));
		}
		
		
		
		/**
		 * Returns an array of marker objects that have not yet been placed by the user - ie markers
		 * that are placed by the app at map center - and not yet positioned - these markers move with the
		 * map if it is moved
		 * 
		 * @return Array of not yet dropped markers - or an empty array
		 */
		public function getNotDropped():Array
		{
			var b:Array = new Array();
			for (var i:int = 0; i < markers.length; i++) {
				if (markers[i].getOptions().icon.beenDropped == false) {
					b.push(markers[i]);
				}
			}
			return b;
		}
		
		
		
		/**
		 * Called when a delete marker button is clicked
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function deleteMarkerClicked(e:MouseEvent):void
		{
			deleteIndex = e.currentTarget.parent.markerIndex;
			
			if (deleteIndex == 0) {
				//deleting home marker... so remove all
				dispatchEvent(new Event(ALL_MARKER_DELETE));
			}else {
				//deleting a normal marker
				dispatchEvent(new Event(MARKER_DELETE));
			}
		}
		
		
		
		/**
		 * Returns the index of the marker being deleted
		 * calculated in deleteMarkerClicked
		 * 
		 * @return Integer - deleteIndex
		 */
		public function getDeleteIndex():int
		{
			return deleteIndex;
		}
		
		
		
		/**
		 * Called from Leaf when one of the marker item delete buttons is clicked
		 * Removes the item from the list, and map, and then reorders the icons in the
		 * list and on the map so they're labels and colors are in the right order
		 * 
		 * @param	index Integer index of the marker to delete
		 */
		public function deleteMarker(index:int):void
		{
			clearBatteries();
			
			var delMarker:Marker = markers.splice(index, 1)[0];
			map.removeOverlay(delMarker);
			
			var delItem:markerItem = routeItems.splice(index, 1)[0];
			container.removeChild(delItem);
			
			for (var i:int = 1; i < routeItems.length - 1; i++) {
				var item:markerItem = routeItems[i];
				item.y = i * 35;
				item.theMarker.theText.text = labels[i];
				item.markerIndex = i;
				TweenMax.to(item.theMarker.fill, 0, { tint:colors[i].iconColor } );
				TweenMax.to(item.theMarker.theText, 0, { tint:colors[i].fontColor } );
				
				//relabel and color the map markers
				var mark:Marker = markers[i];
				var ic:MovieClip = MovieClip(mark.getOptions().icon);
				ic.theText.text = labels[i];
				TweenMax.to(ic.fill, 0, { tint:colors[i].iconColor } );
				TweenMax.to(ic.theText, 0, { tint:colors[i].fontColor } );
			}
			
			//move the final home up
			routeItems[routeItems.length - 1].y = (routeItems.length - 1) * 35;
			//if theres just the two home icons remaining set the last homes dist to 0
			if (routeItems.length == 2) {
				
				routeItems[1].theDistance.text = "0";
				dispatchEvent(new Event(ONLY_HOME_MARKERS_REMAIN));
			}
		}
		
	}
	
}