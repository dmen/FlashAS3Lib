/**
 * In Game Queue of Expanding and Fading Messages
 * 
 * Kleenex Achoo Game
 */

package com.gmrmarketing.achooweb
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
		
		public function Message():void
		{
			messages = new Array();
			isTweening = false;
		}
		
		
		public function show(mess:String)
		{			
			messages.push(mess);
			if(!isTweening){
				tweenMessage();
			}
		}
		
		
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