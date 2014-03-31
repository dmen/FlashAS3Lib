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
	
	public class Main extends MovieClip
	{
		private var json:JSONReader;
		private var queue:MessageQueue;
		private var screenLocs:Array;
		
		private var bgContainer:Sprite;		
		private var messageContainer:Sprite;		
		
		private var mTot:int;
		
		
		public function Main()
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			stage.scaleMode = StageScaleMode.EXACT_FIT;
			Mouse.hide();

			screenLocs = new Array([8, 2], [431, 316], [854, 2], [8, 316], [431, 2], [854, 316]);			
			
			queue = new MessageQueue();			
			queue.addEventListener(MessageQueue.RUNNERS_ADDED, runnersAdded);
			
			json = new JSONReader();
			json.addEventListener(JSONReader.DATA_READY, gotNewRunners);			
			
			messageContainer = new Sprite();
			addChild(messageContainer);
			
			mTot = 0;
			getRunners();
		}
		
		
		private function getRunners():void
		{			
			json.getRunners();
		}
		
		
		/**
		 * called once json.getRunners() completes
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
					mTot++;
					p.addEventListener(Message.MESSAGE_DISPLAYED, removeMessage);
				}
			}
			if (screenLocs.length < 6) {				
				TweenMax.to(logo, 2, { alpha:0 } );
			}
			//missed.text = String(queue.getMissed());
		}
		
		
		/**
		 *  called by listener on the Message object
		 * @param	e
		 */
		private function removeMessage(e:Event):void
		{			
			screenLocs.push(e.currentTarget.getPoint());//screen loc available
			e.currentTarget.kill();//call kill in message object
			
			if (screenLocs.length == 6) {
				TweenMax.to(logo, 2, { alpha:1 } );
				logo.gotoAndPlay(1);
			}
		}
	}
	
}