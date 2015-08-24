package com.gmrmarketing.humana.rockandroll
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	import com.greensock.TweenMax;
	import com.gmrmarketing.utilities.AIRXML;
	
	public class Main extends MovieClip
	{
		private var json:JSONReader;
		private var queue:MessageQueue;
		private var screenLocs:Array;//array of x,y positions for message boxes
		
		private var bgContainer:Sprite;		
		private var messageContainer:Sprite;		
		
		private var config:AIRXML;
		
		private var militaryCheers:Array;
		private var militaryIndex:int;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();

			screenLocs = new Array([8, 2], [431, 316], [854, 2], [8, 316], [431, 2], [854, 316]);			
			
			//queue = new MessageQueue();			
			//queue.addEventListener(MessageQueue.RUNNERS_ADDED, runnersAdded);
			
			json = new JSONReader();
			json.addEventListener(JSONReader.DATA_READY, gotNewRunners);			
			
			messageContainer = new Sprite();
			addChild(messageContainer);
			
			config = new AIRXML();
			config.addEventListener(Event.COMPLETE, xmlReady);
			config.readXML();
		}
		
		
		/**
		 * Config.xml loaded
		 * @param	e
		 */
		private function xmlReady(e:Event):void
		{			
			queue = new MessageQueue(config.getXML().defaultStartTime, config.getXML().startToMatDistanceInMiles, config.getXML().matToSignDistanceInMiles);
			
			queue.addEventListener(MessageQueue.RUNNERS_ADDED, runnersAdded);
			
			militaryCheers = [];
			militaryIndex = 0;
			if (config.getXML().militaryCheers.@on == "true") {
				var ch:XMLList = config.getXML().militaryCheers.cheer;
				for (var i:int = 0; i < ch.length(); i++) {
					militaryCheers.push(ch[i]);
				}
			}			
			
			getRunners();
		}
		
		
		private function getRunners():void
		{			
			json.getRunners();
		}
		
		
		/**
		 * callback for json.getRunners()
		 * @param	e
		 */
		private function gotNewRunners(e:Event):void
		{			
			queue.addRunners(json.getData());
		}
		
		
		/**
		 * Called once queue.addRunners() completes
		 * @param	e
		 */
		private function runnersAdded(e:Event):void
		{			
			updateScreen();
			getRunners();
		}
		
		
		/**
		 * Called from runnersAdded()		
		 */
		private function updateScreen():void
		{			
			while (queue.pastViewingTime() && screenLocs.length) {				
				//returns -1 if no messages in queue			
				var m:Object = queue.getMessage();//removes message from queue				
				if (m != -1) {					
					var sl:Array = screenLocs.shift();
					var p:Message = new Message(m, messageContainer, sl[0], sl[1]);					
					p.addEventListener(Message.MESSAGE_DISPLAYED, removeMessage);
				}
			}
			
			//see if there's a spot open for a military cheer
			if (screenLocs.length > 0 && militaryCheers.length > 0) {
				var sl:Array = screenLocs.shift();
				
				//fName, lName, messages, time, tenTime, viewingTime, messageTime
				//messages is an array of objects with keys: message, fromFName, fromLName
				var milMessage:Object = { fName:"", lName:"", messageTime:5, messages:[ { message:militaryCheers[militaryIndex], fromFName:"", fromLName:"" } ] };
				
				militaryIndex++;
				if (militaryIndex >= militaryCheers.length) {
					militaryIndex = 0;
				}
				
				var p:Message = new Message(milMessage, messageContainer, sl[0], sl[1]);					
				p.addEventListener(Message.MESSAGE_DISPLAYED, removeMessage);
			}
			
			if (screenLocs.length < 6) {				
				TweenMax.to(logo, 2, { alpha:0 } );
			}
		}
		
		
		/**
		 *  called by listener on the Message object
		 * @param	e
		 */
		private function removeMessage(e:Event):void
		{			
			screenLocs.push(e.currentTarget.getPoint());//screen loc available
			e.currentTarget.kill();//call kill in message object
			
			//if screen is empty show the logo animation
			if (screenLocs.length == 6) {
				TweenMax.to(logo, 2, { alpha:1 } );
				logo.gotoAndPlay(1);
			}
		}
	}
	
}