/**
 * Manages the interests selector for the Map
 * Dispatches CHANGED any time a selection changes
 * call the interests getter to retrieve the list of selected categories/interests
 * used by Map.as
 */
package com.gmrmarketing.empirestate.ilny
{
	import flash.events.*;
	import flash.display.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	
	public class Interests extends EventDispatcher 
	{
		public static const CHANGED:String = "interestChanged";
		private var clip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var selectedInterest:String;//one at a time
		//private var selectedInterests:Array;
		private var tim:TimeoutHelper;
		
		
		public function Interests()
		{
			clip = new mcInterests();
			tim = TimeoutHelper.getInstance();
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
			
			//selectedInterests = [];
			selectedInterest = "";
			
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
		
		
		public function hide():void
		{
			if (myContainer.contains(clip)) {
				myContainer.removeChild(clip);
			}
			clip.btnMust.removeEventListener(MouseEvent.MOUSE_DOWN, mustSelected);
			clip.btnHistorical.removeEventListener(MouseEvent.MOUSE_DOWN, historicalSelected);
			clip.btnCultural.removeEventListener(MouseEvent.MOUSE_DOWN, culturalSelected);
			clip.btnParks.removeEventListener(MouseEvent.MOUSE_DOWN, parksSelected);
			clip.btnWineries.removeEventListener(MouseEvent.MOUSE_DOWN, wineriesSelected);
			clip.btnFamily.removeEventListener(MouseEvent.MOUSE_DOWN, familySelected);
		}
		
		/**
		 * Returns the array of selected interests:
			Must See, History, Art & Culture, Wineries, Breweries, Parks and Beaches, Family Fun
		 */
			/*
		public function get interests():Array
		{
			return selectedInterests;
		}
		*/
		public function get interest():String
		{
			return selectedInterest;
		}
		

		private function mustSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redMust.alpha == 1) {
				TweenMax.to(clip.redMust, .3, { alpha:0 } );
				TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redMust, .3, { alpha:1 } );
				TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "Must See";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redHistorical, .3, { alpha:0 } );				
			TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redCultural, .3, { alpha:0 } );
			TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redParks, .3, { alpha:0 } );
			TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redWineries, .3, { alpha:0 } );
			TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redFamily, .3, { alpha:0 } );
			TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
		
		private function historicalSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redHistorical.alpha == 1) {
				TweenMax.to(clip.redHistorical, .3, { alpha:0 } );
				TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redHistorical, .3, { alpha:1 } );
				TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "History";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redMust, .3, { alpha:0 } );				
			TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redCultural, .3, { alpha:0 } );
			TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redParks, .3, { alpha:0 } );
			TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redWineries, .3, { alpha:0 } );
			TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redFamily, .3, { alpha:0 } );
			TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
		
		private function culturalSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redCultural.alpha == 1) {
				TweenMax.to(clip.redCultural, .3, { alpha:0 } );
				TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redCultural, .3, { alpha:1 } );
				TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "Art & Culture";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redMust, .3, { alpha:0 } );				
			TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redHistorical, .3, { alpha:0 } );
			TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redParks, .3, { alpha:0 } );
			TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redWineries, .3, { alpha:0 } );
			TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redFamily, .3, { alpha:0 } );
			TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
		
		private function parksSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redParks.alpha == 1) {
				TweenMax.to(clip.redParks, .3, { alpha:0 } );
				TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redParks, .3, { alpha:1 } );
				TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "Parks and Beaches";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redMust, .3, { alpha:0 } );				
			TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redHistorical, .3, { alpha:0 } );
			TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redCultural, .3, { alpha:0 } );
			TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redWineries, .3, { alpha:0 } );
			TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redFamily, .3, { alpha:0 } );
			TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
		
		private function wineriesSelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redWineries.alpha == 1) {
				TweenMax.to(clip.redWineries, .3, { alpha:0 } );
				TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redWineries, .3, { alpha:1 } );
				TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "Wineries and Breweries";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redMust, .3, { alpha:0 } );				
			TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redHistorical, .3, { alpha:0 } );
			TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redCultural, .3, { alpha:0 } );
			TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redParks, .3, { alpha:0 } );
			TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redFamily, .3, { alpha:0 } );
			TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
		
		
		private function familySelected(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			if (clip.redFamily.alpha == 1) {
				TweenMax.to(clip.redFamily, .3, { alpha:0 } );
				TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:0 }} );
				selectedInterest = "";
			}else {
				TweenMax.to(clip.redFamily, .3, { alpha:1 } );
				TweenMax.to(clip.checkFamily, .25, { colorMatrixFilter: { saturation:1 }} );
				selectedInterest = "Family Fun";
			}
			
			//turn off other buttons
			TweenMax.to(clip.redMust, .3, { alpha:0 } );				
			TweenMax.to(clip.checkMust, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redHistorical, .3, { alpha:0 } );
			TweenMax.to(clip.checkHistorical, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redCultural, .3, { alpha:0 } );
			TweenMax.to(clip.checkCultural, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redParks, .3, { alpha:0 } );
			TweenMax.to(clip.checkParks, .25, { colorMatrixFilter: { saturation:0 }} );
			
			TweenMax.to(clip.redWineries, .3, { alpha:0 } );
			TweenMax.to(clip.checkWineries, .25, { colorMatrixFilter: { saturation:0 }} );
			
			dispatchEvent(new Event(CHANGED));
		}
			
		
	}
	
}