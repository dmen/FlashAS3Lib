/**
 * iOS Style spinner selector
 * Typically used for choosing birthdates and such.
 * 
 * Requires a library clip with the linkage spinChoice 
 * containing a dynamic text field with an instance name of: theText
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
 * 
 * 
 * used by:AgeGate
 */

package com.gmrmarketing.miller.gifphotobooth
{	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.gmrmarketing.utilities.TimeoutHelper;
	
	public class Spinner
	{
		private const CENTER_Y:Number = 125; //vertical center of the spinner
		private const CHOICE_TEXT_FIELD_HEIGHT:int = 50; //height of each choice in the list
		
		private var myChoices:Array;
		private var spinner:MovieClip;
		private var choicesContainer:Sprite;//contains instances of spinChoice
		private var myContainer:DisplayObjectContainer; //user specified container for the spinner
		private var offsetY:Number;
		private var choicesOffset:Number;		
		private var lastMousePos:Number;//used for calculating mouseDelta
		private var mouseDelta:Number;	//the between frame mouse speed	
		private var target:Sprite;		
		
		private var tim:TimeoutHelper;
		
		
		public function Spinner():void
		{
			
			choicesContainer = new Sprite();
			spinner = new spinClip();
			tim = TimeoutHelper.getInstance();
			
			//places choiceContainer above the spinners background
			spinner.addChildAt(choicesContainer, 1);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * Sets the choices available in the spinner window
		 * adds each item to the choicesContainer
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
				ch.x = 18;//dependent on the spinClip asset
				ch.y = i * CHOICE_TEXT_FIELD_HEIGHT;
				//ch.cacheAsBitmap = true;
				choicesContainer.addChild(ch);			
			}
			//choicesContainer.cacheAsBitmap = true;
			//spinner.theMask.cacheAsBitmap = true;
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
		public function show(xLoc:int = 0, yLoc:int = 0):void
		{
			spinner.x = xLoc;
			spinner.y = yLoc;
			
			if (!myContainer.contains(spinner)) {
				myContainer.addChild(spinner);
			}
			spinner.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag, false, 0, true);
		}
		
		
		/**
		 * Hides the spinner
		 */
		public function hide():void
		{
			if(myContainer){
				if(myContainer.contains(spinner)){
					myContainer.removeChild(spinner);
				}
			}
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
		
		
		/**
		 * Sets the spinner to the indicated choice
		 * @param	choice
		 */
		public function setStringChoice(choice:String):void
		{
			var ind:int = myChoices.indexOf(choice);
			
			if (ind != -1) {
				choicesContainer.y = CENTER_Y - (ind * CHOICE_TEXT_FIELD_HEIGHT) - (CHOICE_TEXT_FIELD_HEIGHT * .5);
			}
		}
		
		
		/**
		 * Called on MouseDown on the Spinner
		 * @param	e
		 */
		private function beginDrag(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			mouseDelta = 0;
			lastMousePos = myContainer.mouseY;
			offsetY = myContainer.mouseY;
			choicesOffset = choicesContainer.y;
			
			myContainer.addEventListener(Event.ENTER_FRAME, mouseMove, false, 0, true);			
			myContainer.stage.addEventListener(MouseEvent.MOUSE_UP, endDrag, false, 0, true);
		}
		
		
		/**
		 * Called by enter_frame
		 * Calculates mouse delta for use in endDrag()
		 * @param	e
		 */
		private function mouseMove(e:Event):void
		{
			choicesContainer.y = myContainer.mouseY - offsetY + choicesOffset;			
			checkPos();			
			mouseDelta = myContainer.mouseY - lastMousePos;//per frame mouse speed
			lastMousePos = myContainer.mouseY;
		}
		
		
		/**
		 * Called when the mouse is released
		 * Scrolls the list to the nearest choice
		 * @param	e
		 */
		private function endDrag(e:MouseEvent):void
		{
			tim.buttonClicked();
			
			myContainer.removeEventListener(Event.ENTER_FRAME, mouseMove);
			myContainer.stage.removeEventListener(MouseEvent.MOUSE_UP, endDrag);
			
			var scrollDist:Number = Math.round((choicesContainer.y + (mouseDelta * 10)) / CHOICE_TEXT_FIELD_HEIGHT) * CHOICE_TEXT_FIELD_HEIGHT;
			TweenMax.to(choicesContainer, 1, { y:scrollDist, onUpdate:checkPos } );	
			
			mouseDelta = 0;
		}
		
		
		public function cursorMove(moveUp:Boolean):void
		{
			var scrollTo:Number;
			if (moveUp){				
				scrollTo = Math.round((choicesContainer.y + 50) / CHOICE_TEXT_FIELD_HEIGHT) * CHOICE_TEXT_FIELD_HEIGHT;				
				TweenMax.to(choicesContainer, 1, { y:scrollTo, onUpdate:checkPos } );	
			}else{
				scrollTo = Math.round((choicesContainer.y - 50) / CHOICE_TEXT_FIELD_HEIGHT) * CHOICE_TEXT_FIELD_HEIGHT;				
				TweenMax.to(choicesContainer, 1, { y:scrollTo, onUpdate:checkPos } );	
			}
		}
		
		
		/**
		 * Limits dragging the vertical extents of the spinner past the midpoint marker
		 */
		private function checkPos():void
		{	
			var theY:int;
			
			if (choicesContainer.y + (CHOICE_TEXT_FIELD_HEIGHT * myChoices.length) < CENTER_Y + (CHOICE_TEXT_FIELD_HEIGHT * .5)) {
				theY = CENTER_Y - (CHOICE_TEXT_FIELD_HEIGHT * myChoices.length) + (CHOICE_TEXT_FIELD_HEIGHT * .5);
				TweenMax.killTweensOf(choicesContainer);
				TweenMax.to(choicesContainer, .5, { y:theY } );
				//choicesContainer.y = theY;
			}
			
			if (choicesContainer.y > CENTER_Y - (CHOICE_TEXT_FIELD_HEIGHT * .5)) {
				theY = CENTER_Y - (CHOICE_TEXT_FIELD_HEIGHT * .5);
				TweenMax.killTweensOf(choicesContainer);
				TweenMax.to(choicesContainer, .5, { y:theY } );
				//choicesContainer.y = theY;
			}
		}
	}
	
}