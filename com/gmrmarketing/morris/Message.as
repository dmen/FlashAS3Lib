/**
 * In Game Queue of Expanding and Fading Messages
 * 
 * Instantiated by Engine
 * 
 * Linked to message library clip that contains a text field - theText
 *
 */

package com.gmrmarketing.morris
{ 
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;	
	
	import gs.TweenLite;
	import gs.easing.*
	
	
	public class Message extends Sprite
	{		
		
		private var messages:Array;
		private var isTweening:Boolean;
		
		
		/**
		 * Constructor
		 */
		public function Message():void
		{
			messages = new Array();
			isTweening = false;
		}
		
		
		/**
		 * Pushes a new message onto the message queue
		 * calls tweenMessage if isTweening is false - ie the queue is empty
		 * 
		 * @param	mess String message to show
		 */
		public function show(mess:String, clearQueue:Boolean = false, dispatchEvent:Boolean = false )
		{		
			if (clearQueue) {
				messages = new Array();
			}
			messages.push([mess, dispatchEvent]);
			if (!isTweening) {
				tweenMessage();
			}
		}
		
		
		/**
		 * Animates the queue of messages until it is empty
		 */
		private function tweenMessage()
		{			
			TweenLite.killTweensOf(this);
			y = -1000;
			if (messages.length > 0) {
				x = Engine.GAME_WIDTH / 2;			
				y = Engine.GAME_HEIGHT / 2;
				var aMessage = messages.shift()
				theText.text = aMessage[0];				
				scaleX = 0;
				scaleY = 0;
				alpha = 1;
				if (aMessage[1]) {
					TweenLite.to(this, 1.25, {scaleX:1.3, scaleY:1.3} );
					TweenLite.to(this, .75, { alpha:0,  delay:.5, overwrite:0, onComplete:doDispatch } );
				}else {
					TweenLite.to(this, 1.25, {scaleX:1.3, scaleY:1.3} );
					TweenLite.to(this, .75, { alpha:0,  delay:.5, overwrite:0, onComplete:tweenMessage } )
				}
				isTweening = true;
			}else {
				isTweening = false;
			}
		}
		
		private function doDispatch()
		{
			dispatchEvent(new Event("messageComplete"));
			tweenMessage();
		}
	} 
}