/**
 * In Game Queue of Expanding and Fading Messages
 * 
 * Instantiated by Engine
 * 
 * Linked to message library clip that contains a text field - theText
 *
 */

package com.gmrmarketing.achoo
{ 
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;	
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*
	
	
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
		public function show(mess:String)
		{			
			messages.push(mess);
			if(!isTweening){
				tweenMessage();
			}
		}
		
		
		/**
		 * Animates the queue of messages until it is empty
		 */
		private function tweenMessage()
		{		
			y = -1000;
			if (messages.length > 0) {
				x = Engine.GAME_WIDTH / 2;			
				y = Engine.GAME_HEIGHT / 2;
				theText.text = messages.shift();				
				scaleX = 0;
				scaleY = 0;
				alpha = 1;
				TweenLite.to(this, 1.5, { alpha:0, scaleX:1.5, scaleY:1.5, onComplete:tweenMessage } );
				isTweening = true;
			}else {
				isTweening = false;
			}
		}
	} 
}