/**
 * Represents the list of menu buttons on the left side - the buttons
 * that add markers to the map
 */

package com.gmrmarketing.nissan
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import com.greensock.TweenMax;
	

	public class MarkerButtons extends EventDispatcher
	{
		public static const M_CLICK:String = "markerButtonClicked";
		
		private var theButtons:Array;
		private var buttonObjects:Array;
		private var xStart:int = 43;
		private var yStart:int = 270;
		private var yBuffer:int = 3;
		private var lastClick:String = ""; //btn text of the last clicked button
		private var highlightColor:int = 0xFFF216;
		private var fillColor:int = 0x042E3F;
		private var bgAlpha:Number = .56;
		private var gasButton:markerButtonGAS;
		
		
		
		public function MarkerButtons()
		{
			theButtons = new Array("home", "work", "school", "gym", "practice", "shopping", "entertainment", "restaurant", "recreation");
			buttonObjects = new Array();
		}
		
		
		
		/**
		 * Builds the menu buttons in the specified container
		 * 
		 * @param	container
		 */
		public function buildButtons(container:DisplayObjectContainer):void
		{
			for (var i:int = 0; i < theButtons.length; i++) {
				var aButton:markerButton = new markerButton();
				aButton.x = xStart;
				aButton.y = yStart;
				aButton.theText.text = theButtons[i];
				aButton.theBG.alpha = bgAlpha;
				
				yStart += aButton.height + yBuffer;
				container.addChild(aButton);
				buttonObjects.push(aButton);				
			}
			
			//add the new gas station 'button'
			gasButton = new markerButtonGAS();
			gasButton.x = xStart;
			gasButton.y = yStart;
			gasButton.theBG.alpha = bgAlpha;
			container.addChild(gasButton);
			
			enableButtons();
		}
		
		
		public function enableButtons():void
		{
			var l:int = buttonObjects.length;
			for (var i:int = 0; i < l; i++) {
				buttonObjects[i].addEventListener(MouseEvent.CLICK, btnClicked, false, 0, true);
				buttonObjects[i].alpha = 1;
			}
			gasButton.alpha = .5;
		}
		
		
		public function enableHomeButton():void
		{
			buttonObjects[0].addEventListener(MouseEvent.CLICK, btnClicked, false, 0, true);
			buttonObjects[0].alpha = 1;
		}
		
		
		public function disableHomeButton():void
		{
			buttonObjects[0].removeEventListener(MouseEvent.CLICK, btnClicked);
			buttonObjects[0].alpha = .5;
		}
		
		
		public function disableButtons():void
		{
			var l:int = buttonObjects.length;
			for (var i:int = 0; i < l; i++) {
				buttonObjects[i].removeEventListener(MouseEvent.CLICK, btnClicked);
				buttonObjects[i].alpha = .5;
			}
			gasButton.alpha = .5;
		}
		
		
		/**
		 * Returns the text - button label - of the last clicked on button
		 * @return
		 */
		public function getClicked():String
		{
			return lastClick;
		}
		
		
		
		/**
		 * Called when a button is clicked
		 * Dispatches an M_CLICK event
		 * 
		 * @param	e CLICK MouseEvent
		 */
		private function btnClicked(e:MouseEvent):void
		{
			lastClick = e.currentTarget.theText.text;
			if (lastClick == "home") {
				enableButtons();
				disableHomeButton();
			}
			
			dispatchEvent(new Event(M_CLICK));			
			
			TweenMax.to(e.currentTarget.theBG, 0, { tint:highlightColor, alpha:1 } );
			TweenMax.to(e.currentTarget.theBG, .4, { tint:fillColor, alpha:bgAlpha, delay:.1 } );
		}
	}	
}