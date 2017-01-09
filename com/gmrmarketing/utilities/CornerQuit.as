/**
 * Places one or two hidden click areas on the screen
 * in a user defined corner
 * 
 * A CORNER_QUIT event will be dispatched if the area
 * is clicked four times in succession. If two click areas
 * are present then the event will be dispatched if both corners
 * are clicked four times with 3 seconds max time between corners.
 * 
 * 
 * USAGE:
 * 
 * Pass true in the constructor if you want to see the rect(s) for debugging.
 * The rect(s) are drawn in bright yellow when turned on.
 * 
 * var cq:CornerQuit = new CornerQuit(debug:Boolean = false);
 * 
 * Corner strings are two chars: ul, ur, ll, lr
 * 
 * for one corner:
 * cq.init(this, "ul");
 * 
 * for two corners:
 * cq.init(this, "ullr");
 * 
 * Listen for CornerQuit.CORNER_QUIT to know when to quit the application
 * 
 * cq.addEventListener(CornerQuit.CORNER_QUIT, quitApplication, false, 0, true);
 * 
 * Whenever you want to be sure the corner(s) are on top of anything else issue:
 * 
 * cq.moveToTop();
 * 
 * 
 * Quitting:
 * Flash Player:
 * 
 * import flash.system.fscommand;
 * fscommand("quit");
 * 
 * AIR:
 * import flash.desktop.NativeApplication;
 * NativeApplication.nativeApplication.exit();
 * 
 * SWFKit:
 * ExternalInterface.call("quit");
* in swfkit:
 * function quit()
{
	var mw = getMainWnd();
	mw.close();
}
 * 
 */

 
package com.gmrmarketing.utilities
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class CornerQuit extends EventDispatcher
	{
		public static const CORNER_QUIT:String = "kioskCornerQuit";
		
		private const CLICK_BUFFER:uint = 500; //max time between mouse clicks on a corner
		private const CORNER_BUFFER:int = 3000; //max time between the two eight click corners
		
		private var debug:int; //set in constructor - if true corners will be drawn in yellow instead of being hidden
		
		private var container:DisplayObjectContainer; //set in init - displayObjectContainer to draw in
		private var hitArea:Sprite; //corner one
		private var hitArea2:Sprite; //corner two
		
		private var clickArray:Array; //array containing two click arrays - one for each corner
		
		private var eightClicks:Boolean = false; //if true you need to click in two corners
		private var lastCornerTime:Number;
		private var lastCornerTime2:Number;
		
		private var singleClick:Boolean;
		
		
		
		/**
		 * CONSTRUCTOR
		 * Will draw yellow rects if debug is true
		 * @param	$debug
		 */
		public function CornerQuit($debug:Boolean = false) 
		{
			debug = $debug == false ? 0 : 1;
			singleClick = false;
		}		
		
		
		/**
		 * removes the corners from the container
		 */
		public function hide():void
		{
			if(hitArea){
				if (container.contains(hitArea)) {
					container.removeChild(hitArea);
				}
			}
			if(hitArea2){
				if (container.contains(hitArea2)) {
					container.removeChild(hitArea2);
				}
			}
		}
		
		/**
		 * Initializes the click rectangles
		 * 
		 * @param	$container DisplayObjectContainer that click areas are placed into
		 * @param	position Optional - two or four chars: ul, ur, ll, lr, ullr, ulll, etc.
		 */
		public function init($container:DisplayObjectContainer, position:String = "ul"):void
		{
			container = $container;
			
			resetArray();			
			
			hitArea = new Sprite();
			hitArea.graphics.beginFill(0xFFFF00, debug);
			hitArea.graphics.drawRect(0, 0, 150, 150);
			hitArea.addEventListener(MouseEvent.CLICK, cornerClick);			
			
			container.addChild(hitArea);
			
			var pos1:String = position.substr(0, 2);
			var pos2:String = "";
			
			if (position.length == 4) {
				hitArea2 = new Sprite();
				hitArea2.graphics.beginFill(0xFFFF00, debug);
				hitArea2.graphics.drawRect(0, 0, 150, 150);
				hitArea2.addEventListener(MouseEvent.CLICK, cornerClick2);
			
				container.addChild(hitArea2);
				pos2 = position.substr(2, 2);
				if (pos2 == pos1) { 
					throw new Error("Click corners must be different.");					
				}
				eightClicks = true;
			}			
			
			switch(pos1) {
				case "ul":
					hitArea.x = 0;
					hitArea.y = 0;
					break;
				case "ur":
					hitArea.x = container.stage.stageWidth - 150;
					hitArea.y = 0;
					break;
				case "ll":
					hitArea.x = 0;
					hitArea.y = container.stage.stageHeight - 150;					
					break;
				case "lr":
					hitArea.x = container.stage.stageWidth - 150;
					hitArea.y = container.stage.stageHeight - 150;
					break;
			}
			
			switch(pos2) {
				case "ul":
					hitArea2.x = 0;
					hitArea2.y = 0;
					break;
				case "ur":
					hitArea2.x =  container.stage.stageWidth - 150;
					hitArea2.y = 0;
					break;
				case "ll":
					hitArea2.x = 0;
					hitArea2.y = container.stage.stageHeight - 150;
					break;
				case "lr":				
					hitArea2.x =  container.stage.stageWidth - 150;
					hitArea2.y = container.stage.stageHeight - 150;
					break;
			}			
		}		
		
		
		/**
		 * Moves the click spots to the top of the container
		 * Call this whenever you need to be sure the click spots are above any other content,
		 * and therefore clickable
		 */
		public function moveToTop():void
		{			
			if (container) {				
				if(hitArea){
					if (container.contains(hitArea)) {
						container.setChildIndex(hitArea, container.numChildren - 1);						
					}else {
						container.addChild(hitArea);
					}
				}
				if(hitArea2){
					if (container.contains(hitArea2)) {
						container.setChildIndex(hitArea2, container.numChildren - 1);						
					}else {
						container.addChild(hitArea2);
					}					
				}
			}
		}		
		
		
		/**
		 * Moves a hit spot to a custom point
		 * 
		 * @param	whichArea integer 1 or 2
		 * @param	loc Point
		 */
		public function customLoc(whichArea:int, loc:Point):void
		{
			if (whichArea == 1) {
				hitArea.x = loc.x;
				hitArea.y = loc.y;
			}
			if (whichArea == 2) {
				hitArea2.x = loc.x;
				hitArea2.y = loc.y;
			}
		}		
		
		
		/**
		 * Resets the clickArray to two empty arrays
		 */
		private function resetArray():void
		{
			clickArray = new Array(new Array(), new Array());	
		}
		
		
		/**
		 * Call this to have the hit spot dispatch a CORNER_QUIT event
		 * on a single tap instead of the default four
		 */
		public function setSingleClick():void
		{
			singleClick = true;
		}
		
		
		/**
		 * Called whenever hitArea is clicked
		 * @param	e CLICK
		 */
		private function cornerClick(e:MouseEvent):void
		{			
			if (singleClick) {
				dispatchEvent(new Event(CORNER_QUIT));
				resetArray();
			}else{
				var curTime = getTimer();
				
				if (clickArray[0].length == 0) {
					clickArray[0].push(curTime);			
				}else {
					var elapsed = curTime - clickArray[0][clickArray[0].length - 1];
					if (elapsed < CLICK_BUFFER) {
						clickArray[0].push(curTime);
						if (clickArray[0].length == 4) {
							lastCornerTime = curTime;
						}
					}else {
						resetArray();
						clickArray[0].push(curTime);
					}
				}
				
				checkClicks();
			}
		}		
		
		
		/**
		 * Called whenever hitArea2 is clicked
		 * @param	e CLICK
		 */
		private function cornerClick2(e:MouseEvent):void
		{				
			var curTime = getTimer();
			
			if (clickArray[1].length == 0) {
				clickArray[1].push(curTime);			
			}else {
				var elapsed = curTime - clickArray[1][clickArray[1].length - 1];
				if (elapsed < CLICK_BUFFER) {
					clickArray[1].push(curTime);
					if (clickArray[1].length == 4) {
						lastCornerTime2 = curTime;
					}
				}else {
					resetArray();
					clickArray[1].push(curTime);
				}
			}
			
			checkClicks();
		}		
		
		
		/**
		 * Called from the click handlers - checks the arrays and dispatches
		 * a corner_quit event if the conditions are met
		 */
		private function checkClicks():void
		{			
			if (eightClicks) {
				if (clickArray[0].length == 4 && clickArray[1].length == 4) {
					if(Math.abs(lastCornerTime - lastCornerTime2) < CORNER_BUFFER){
						dispatchEvent(new Event(CORNER_QUIT));						
					}
					resetArray();
				}
			}else {
				//four clicks
				if (clickArray[0].length == 4 ) {
					dispatchEvent(new Event(CORNER_QUIT));
					resetArray();
				}
			}
		}		
	
	}
	
}