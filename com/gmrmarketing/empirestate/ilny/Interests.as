/**
 * Manages the interests selector for the Map
 * Dispatches CHANGED any time a selection changes
 * call the interests getter to retrieve the list of selected items
 * used by Map.as
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Interests extends EventDispatcher 
	{
		public static const CHANGED:String = "interestChanged";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var selectedInterests:Array;
		
		public function Interests()
		{
			clip = new mcInterests();
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
			
			selectedInterests = [];
			
			clip.x = -clip.width;
			clip.y = 224;//bottom aligned
			clip.select.y = 147;//below mask
			TweenMax.to(clip, .4, { x:0 } );
			TweenMax.to(clip.select, .4, { y:84, delay:.5, ease:Back.easeOut } );
			
			clip.redMust.alpha = 0;
			clip.redHistorical.alpha = 0;
			clip.redCultural.alpha = 0;
			clip.redParks.alpha = 0;
			clip.redWineries.alpha = 0;
			clip.redFamily.alpha = 0;
			
			//turn checks gray
			TweenMax.to(clip.checkMust, 0, { colorMatrixFilter:{ saturation:0 }} );
			TweenMax.to(clip.checkHistorical, 0, { colorMatrixFilter:{ saturation:0 }} );
			TweenMax.to(clip.checkCultural, 0, { colorMatrixFilter:{ saturation:0 }} );
			TweenMax.to(clip.checkParks, 0, { colorMatrixFilter:{ saturation:0 }} );
			TweenMax.to(clip.checkWineries, 0, { colorMatrixFilter:{ saturation:0 }} );
			TweenMax.to(clip.checkFamily, 0, { colorMatrixFilter: { saturation:0 }} );
			
			clip.btnMust.addEventListener(MouseEvent.MOUSE_DOWN, mustSelected);
			clip.btnHistorical.addEventListener(MouseEvent.MOUSE_DOWN, historicalSelected);
			clip.btnCultural.addEventListener(MouseEvent.MOUSE_DOWN, culturalSelected);
			clip.btnParks.addEventListener(MouseEvent.MOUSE_DOWN, parksSelected);
			clip.btnWineries.addEventListener(MouseEvent.MOUSE_DOWN, wineriesSelected);
			clip.btnFamily.addEventListener(MouseEvent.MOUSE_DOWN, familySelected);
		}		
		
		
		/**
		 * Returns the array of selected interests:
			Must See, History, Art & Culture, Wineries, Breweries, Parks and Beaches, Family Fun
		 */
		public function get interests():Array
		{
			return selectedInterests;
		}
		
		
		private function mustSelected(e:MouseEvent):void
		{
			if (clip.redMust.alpha == 1) {
				if (selectedInterests.indexOf("Must See") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("Must See"), 1);
				}
				TweenMax.to(clip.redMust, .3, { alpha:0 } );
				TweenMax.to(clip.checkMust, .25, { colorMatrixFilter:{ saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("Must See") == -1) {
					selectedInterests.push("Must See");
				}
				TweenMax.to(clip.redMust, .3, { alpha:1 } );
				TweenMax.to(clip.checkMust, .25, { colorMatrixFilter:{ saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function historicalSelected(e:MouseEvent):void
		{
			if (clip.redHistorical.alpha == 1) {
				if (selectedInterests.indexOf("History") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("History"), 1);
				}
				TweenMax.to(clip.redHistorical, .3, { alpha:0 } );				
				TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter:{ saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("History") == -1) {
					selectedInterests.push("History");
				}
				TweenMax.to(clip.redHistorical, .3, { alpha:1 } );
				TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter:{ saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function culturalSelected(e:MouseEvent):void
		{
			if (clip.redCultural.alpha == 1) {
				if (selectedInterests.indexOf("Art & Culture") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("Art & Culture"), 1);
				}
				TweenMax.to(clip.redCultural, .3, { alpha:0 } );
				TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter:{ saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("Art & Culture") == -1) {
					selectedInterests.push("Art & Culture");
				}
				TweenMax.to(clip.redCultural, .3, { alpha:1 } );
				TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter:{ saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function parksSelected(e:MouseEvent):void
		{
			if (clip.redParks.alpha == 1) {
				if (selectedInterests.indexOf("Parks and Beaches") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("Parks and Beaches"), 1);
				}
				TweenMax.to(clip.redParks, .3, { alpha:0 } );
				TweenMax.to(clip.checkParks, .25, { colorMatrixFilter:{ saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("Parks and Beaches") == -1) {
					selectedInterests.push("Parks and Beaches");
				}
				TweenMax.to(clip.redParks, .3, { alpha:1 } );
				TweenMax.to(clip.checkParks, .25, { colorMatrixFilter:{ saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function wineriesSelected(e:MouseEvent):void
		{
			if (clip.redWineries.alpha == 1) {
				if (selectedInterests.indexOf("Wineries") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("Wineries"), 1);
					selectedInterests.splice(selectedInterests.indexOf("Breweries"), 1);
				}
				TweenMax.to(clip.redWineries, .3, { alpha:0 } );
				TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter:{ saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("Wineries") == -1) {
					selectedInterests.push("Wineries");
					selectedInterests.push("Breweries");
				}
				TweenMax.to(clip.redWineries, .3, { alpha:1 } );
				TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter:{ saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function familySelected(e:MouseEvent):void
		{
			if (clip.redFamily.alpha == 1) {
				if (selectedInterests.indexOf("Family Fun") != -1) {
					selectedInterests.splice(selectedInterests.indexOf("Family Fun"), 1);
				}
				TweenMax.to(clip.redFamily, .3, { alpha:0 } );
				TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			}else {
				if (selectedInterests.indexOf("Family Fun") == -1) {
					selectedInterests.push("Family Fun");
				}
				TweenMax.to(clip.redFamily, .3, { alpha:1 } );
				TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:1 }} );
			}
			dispatchEvent(new Event(CHANGED));
		}		
		
	}
	
}