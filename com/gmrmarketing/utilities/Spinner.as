/**
 * iOS Style spinner selector
 * Typically used for choosing birthdates and such.
 * 
 * useage:
 *	var a:Spinner = new Spinner();
 * 
 *	a.setChoices(["Spring","Summer","Fall","Winter"]); //array of choices to show in spinner window
 * 
 *	a.showSpinner(this,100,100); //container, x, y
 * 
 * Example Spinner Setup in:
 * fs01\IT\GMRdigital\FlashClasses\FlashSource\AgeGateSpinner.fla
 */

package com.gmrmarketing.utilities
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	
	public class Spinner
	{
		private const CENTER_Y:Number = 59; //vertical center of the spinner - ie where the marker is
		private const CHOICE_TEXT_FIELD_HEIGHT:int = 25; //height of each choice in the list - with any buffer
		
		private var myChoices:Array;
		private var spinner:MovieClip;
		private var choicesContainer:Sprite;//contains the text fields for the array of choices
		private var container:DisplayObjectContainer; //user specified container for the spinner
		private var offsetY:Number;
		private var choicesOffset:Number;		
		private var lastMousePos:Number;
		private var mouseDelta:Number;		
		private var target:Sprite;
		
		
		
		public function Spinner():void
		{
			choicesContainer = new Sprite();
			spinner = new spinClip();
			//places the choices container above the spinners background
			spinner.addChildAt(choicesContainer, 1);				
		}
		
		
		/**
		 * Sets the choices available in the spinner window
		 * @param	choices Array of Strings
		 */
		public function setChoices(choices:Array):void
		{
			myChoices = choices;
			
			for (var i:int = 0; i < choices.length; i++) {
				//library text clip - be sure the field's antialiasing type is Animation and not Readability
				//must contain a dynamic text field with an instance name of theText
				var ch:MovieClip = new spinChoice();
				ch.theText.text = choices[i];
				ch.x = 24;
				ch.y = i * CHOICE_TEXT_FIELD_HEIGHT;
				choicesContainer.addChild(ch);			
			}
			choicesContainer.mask = spinner.theMask;			
		}
		
		
		/**
		 * Resets the spinner to the original position
		 */
		public function reset():void
		{
			choicesContainer.y = 0;
		}
		
		
		/**
		 * Shows the spinner in the specified container and location
		 * Call with parameters initially to set the container and location
		 * Call with no parameters after calling hide() to just show again where it was
		 * @param	$container
		 * @param	xLoc
		 * @param	yLoc
		 */
		public function show($container:DisplayObjectContainer = null, xLoc:int = 0, yLoc:int = 0):void
		{
			if($container != null){
				container = $container;
				spinner.x = xLoc;
				spinner.y = yLoc;
			}
			container.addChild(spinner);			
			enable();
		}
		
		
		/**
		 * Hides the spinner
		 */
		public function hide():void
		{
			if(container.contains(spinner)){
				container.removeChild(spinner);
			}
			disable();
		}
		
		
		/**
		 * Enables the spinner
		 */
		public function enable():void
		{
			spinner.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
		}
		
		
		/**
		 * Disables the spinner
		 */
		public function disable():void
		{
			spinner.removeEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
		}		
		
		
		/**
		 * Returns the string of the chosen item
		 * @return String choice
		 */
		public function getStringChoice():String
		{
			var delta:Number = CENTER_Y - choicesContainer.y;
			var ind:int = Math.floor(delta / CHOICE_TEXT_FIELD_HEIGHT);
			return String(myChoices[ind]);
		}
		
		
		/**
		 * Returns the index in the choices array of the chosen item
		 * @return int array index
		 */
		public function getIndexChoice():int
		{
			var delta:Number = CENTER_Y - choicesContainer.y;
			var ind:int = Math.floor(delta / CHOICE_TEXT_FIELD_HEIGHT);
			return ind;
		}
		
		
		
		
		
		
		// PRIVATE
		
		/**
		 * Called on MouseDown
		 * @param	e
		 */
		private function beginDrag(e:MouseEvent):void
		{			
			//target is the choices container (Sprite) in the clicked on spinner
			target = Sprite(MovieClip(e.currentTarget).getChildAt(1));
			
			lastMousePos = container.mouseY;
			offsetY = container.mouseY;
			choicesOffset = target.y;
			target.addEventListener(Event.ENTER_FRAME, mouseMove, false, 0, true);			
			target.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		/**
		 * Called by enter_frame
		 * Calculates mouse delta for use in endDrag()
		 * @param	e
		 */
		private function mouseMove(e:Event):void
		{			
			target.y = container.mouseY - offsetY + choicesOffset;			
			checkPos();			
			mouseDelta = container.mouseY - lastMousePos;
			lastMousePos = container.mouseY;
		}
		
		
		/**
		 * Called when the mouse is released
		 * Scrolls the list to the nearest choice
		 * @param	e
		 */
		private function endDrag(e:MouseEvent):void
		{	
			if (target != null) {
				target.removeEventListener(Event.ENTER_FRAME, mouseMove);
				target.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
				var scrollDist:Number = Math.round((target.y + (mouseDelta * 8)) / CHOICE_TEXT_FIELD_HEIGHT) * CHOICE_TEXT_FIELD_HEIGHT;			
				TweenMax.to(target, 1, { y:scrollDist, onUpdate:checkPos } );			
			}
		}
		
		
		/**
		 * Limits dragging the vertical extents of the spinner past the midpoint marker
		 */
		private function checkPos():void
		{			
			if (target.y + target.height < CENTER_Y + 10) {
				target.y = CENTER_Y - target.height + 10;
				TweenMax.killTweensOf(target);
			}
			
			if (target.y > CENTER_Y - 10) {
				target.y = CENTER_Y - 10;
				TweenMax.killTweensOf(target);
			}
		}
	}
	
}