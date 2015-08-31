/**
 * Use by Main
 */


package com.gmrmarketing.humana.rockandroll
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import com.greensock.TweenMax;
	
	
	public class Message extends EventDispatcher
	{
		public static const MESSAGE_DISPLAYED:String = "messageComplete";
		
		private var clip:MovieClip;		
		private var container:DisplayObjectContainer;
		private var messages:Array;
		private var curMessage:int;
		private var messageTimer:Timer;
		
		/**
		 * 
		 * @param	message Object from MessageQueue.getMessage() with keys: fName, lName, messages, time, tenTime, viewingTime, messageTime
		 * 			messages is an array of objects with keys: message, fromFName, fromLName
		 * @param	container
		 * @param	tx
		 * @param	ty
		 */
		public function Message(message:Object, $container:DisplayObjectContainer, tx:int, ty:int, isMilitary:Boolean = false)
		{		
			var myFormat:TextFormat = new TextFormat();
			
			clip = new mcMessage(); //lib clip
			clip.x = tx;
			clip.y = ty;
			
			var bg:MovieClip;
			if(!isMilitary){
				var r:Number = Math.random();
				if (r > .84) {
					bg = new boxPurple();
					bg.y = 11;
				}else if (r > .68) {
					bg = new boxPurple2();
					bg.y = 11;
				}else if (r > .52) {
					bg = new boxGreen1();
				}else if (r > .36) {
					bg = new boxGreen2();
				}else if (r > .2) {
					bg = new boxGray1();
				}else {
					bg = new boxGray2();
				}
				myFormat.align = TextFormatAlign.LEFT;
			}else {
				bg = new boxMilitary();
				myFormat.align = TextFormatAlign.CENTER;
			}
			
			clip.addChildAt(bg, 0);
			
			clip.runner.text = message.fName + " " + message.lName;
			
			messages = message.messages;
			curMessage = 0;
			clip.message.defaultTextFormat = myFormat;
			clip.message.text = messages[curMessage].message;
			clip.from.text = messages[curMessage].fromFName + " " + messages[curMessage].fromLName;			
			
			messageTimer = new Timer(message.messageTime * 1000);
			messageTimer.addEventListener(TimerEvent.TIMER, nextMessage);
			messageTimer.start();
			
			container = $container;
			container.addChild(clip);	//pub over the background image and under debug box
			
			clip.scaleX = clip.scaleY = .25;
			TweenMax.to(clip, .5, { scaleX:1, scaleY:1 } );
		}		
		
		private function nextMessage(e:TimerEvent):void
		{
			curMessage++;
			if (curMessage >= messages.length) {
				messageTimer.stop();
				dispatchEvent(new Event(MESSAGE_DISPLAYED));	//all messages to the runner have been shown			
			}else{
				clip.message.text = messages[curMessage].message;
				clip.from.text = messages[curMessage].fromFName + " " + messages[curMessage].fromLName;
				TweenMax.from(clip.message, .5, { alpha:0 } );
			}
		}
		
		public function getPoint():Array
		{
			return [clip.x, clip.y];
		}
		
		public function kill():void
		{
			messageTimer.stop();
			if (container.contains(clip)) {
				container.removeChild(clip);
				clip.removeChildAt(0);
			}
		}		
		
		
	}
	
}