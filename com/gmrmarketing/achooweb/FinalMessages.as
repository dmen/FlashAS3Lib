/**
 * In Game Questions
 * 
 * Kleenex Achoo Game
 * 
 * Engine adds Question and waits for event "questionAnswered"
 */

package com.gmrmarketing.achooweb
{ 	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.*
	import flash.utils.getDefinitionByName;
	import flash.system.fscommand;
	import com.gmrmarketing.kiosk.KioskHelper;
	import flash.external.ExternalInterface;
	
	public class FinalMessages extends MovieClip
	{		
		private var gameRef:Sprite
		private var curFrame:uint;
		private var myRoom:String;
		private var totFrames:uint = 6; //number of messages
		private var channel:SoundChannel;
		private var myTimer:Timer;
		
		private var helper:KioskHelper;
		
		/**
		 * Constructor
		 * 
		 * @param	game
		 * @param	room String - bathroom, bedroom, classroom
		 */
		public function FinalMessages(game:Sprite, room:String):void
		{		
			helper = KioskHelper.getInstance();//for logging
									
			curFrame = 1;
			
			gameRef = game;
			myRoom = room;
			
			channel = new SoundChannel();
			
			gameRef.addChild(this);
			
			x = Engine.GAME_WIDTH / 2 - (width / 2);
			y = Engine.GAME_HEIGHT / 2 - (Engine.FINAL_HEIGHTS[1] / 2) - 80;
			
			scaleX = .4;
			scaleY = .4;
			TweenLite.to(this, 1.5, { scaleX:1, scaleY:1, ease:Elastic.easeOut, onComplete:talk } );
			
			//addEventListener(MouseEvent.CLICK, nextMessage);
		}		
		
				
		/**
		 * Removes this object from the game
		 */
		public function removeSelf() : void
		{
			removeEventListener(MouseEvent.CLICK, nextMessage);
			channel.removeEventListener(Event.SOUND_COMPLETE, nextMessage);
			if (gameRef.contains(this)){
				gameRef.removeChild(this);
			}			
		}		
		
		
		
		//------------------ PRIVATE -------------------
		
		
		private function nextMessage(e:Event):void
		{			
			if (curFrame == 1) {
				switch(myRoom)
				{
					case "bathroom":
						curFrame = 2;
						break;
					case "bedroom":
						curFrame = 3;
						break;
					case "classroom":
						curFrame = 4;
						break;
				}				 
			}else {
				if (curFrame < 5) { 
					curFrame = 5;
				}else{
					curFrame++;
				}
			}
			
			if (curFrame > totFrames) {				
				removeSelf();
				dispatchEvent(new Event("finalComplete"));
			}else {
				x = Engine.GAME_WIDTH / 2 - (width / 2);
				y = Engine.GAME_HEIGHT / 2 - (Engine.FINAL_HEIGHTS[curFrame] / 2) - 80;
				scaleX = .4;
				scaleY = .4;
				TweenLite.to(this, 1.5, { scaleX:1, scaleY:1, ease:Elastic.easeOut } );// , onComplete:talk } );
				talk();
				gotoAndStop(curFrame);			
			}
			
		}
		
		
		private function talk()
		{
			if (Engine.USE_VOICE) {
					channel.stop();
					var classRef:Class = getDefinitionByName(myRoom + "Final" + curFrame) as Class;
					var s:Sound = new classRef();
					channel = s.play();
					channel.addEventListener(Event.SOUND_COMPLETE, nextMessage);
				}
		}
		
	} 
}