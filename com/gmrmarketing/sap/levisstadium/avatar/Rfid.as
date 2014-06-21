package com.gmrmarketing.sap.levisstadium.avatar
{
	import flash.display.*;	
	import flash.events.*;
	import com.gmrmarketing.sap.boulevard.FishUtils;
	import com.greensock.TweenMax;
	import com.gmrmarketing.website.VPlayer;
	
	
	public class Rfid extends EventDispatcher
	{
		public static const RFID:String = "gotVisitorJSONFile";
		public static const SHOWING:String = "RFIDclipShowing";		
		public static const JSON_ERROR:String = "JSONError";
		
		private var container:DisplayObjectContainer;
		private var fish:FishUtils;
		private var vid:VPlayer;		
		
		
		public function Rfid()
		{
			vid = new VPlayer();
			/*
			fish = new FishUtils();
			fish.addEventListener(FishUtils.NEW_VISITOR, gotVisitorJSON, false, 0, true);			
			fish.addEventListener(FishUtils.VISITOR_ERROR, visitorError, false, 0, true);			
			fish.init(); //writes initial session.json and begins watching for visitor.json
			*/
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
			vid.showVideo(container);
		}
		
		
		public function show():void
		{
			if (container) {	
				vid.showVideo(container);
				vid.playVideo("assets/attract_1.f4v");
				vid.addEventListener(VPlayer.CUE_RECEIVED, checkCue, false, 0, true);				
			}
			TweenMax.delayedCall(.5, showing);
		}		
		
		
		private function checkCue(e:Event):void
		{			
			vid.replay();	
		}
		
		
		private function showing():void
		{			
			dispatchEvent(new Event(SHOWING));
			//RASCH MEETING
			container.addEventListener(MouseEvent.MOUSE_DOWN, bypassRFID, false, 0, true);
		}
		//RASCH MEETING
		private function bypassRFID(e:MouseEvent):void
		{
			container.removeEventListener(MouseEvent.MOUSE_DOWN, bypassRFID);
			dispatchEvent(new Event(RFID));
		}
		
		
		public function hide():void
		{
			vid.simpleHide();
			vid.removeEventListener(VPlayer.CUE_RECEIVED, checkCue);
		}	
		
		/**
		 * Wrapper for the fish utils method. 
		 * Gets the tag id of the rfid card
		 * @return
		 */
		public function getVisitorID():String
		{
			return fish.getVisitorID();
		}
		
		
		/**
		 * Called by Main.userError() when a bad rfid is detected
		 * ie the JSON returned from the web service has null or
		 * empty strings
		 */
		public function resetVisitor():void
		{
			//Fish wants epoch time in seconds - not ms
			var epochSeconds:int = Math.floor(new Date().valueOf() / 60);			
			//write initial session.json at app start to start Fish software
			fish.writeSession( {"timestamp":epochSeconds, "session_id":"avatar_error"} );
		}
		
		
		/**
		 * wrapper for fish.utils writeSession so it 
		 * can be called from Main
		 * @param	ob
		 */
		public function writeSession(ob:Object):void
		{
			fish.writeSession(ob);
		}
		
		
		/**
		 * called by listener on the fish object when visitor.json has been
		 * written to the watched folder
		 * @param	e
		 */
		private function gotVisitorJSON(e:Event):void
		{
			dispatchEvent(new Event(RFID));
		}
		
		
		/**
		 * Called by listener on the fish object if the visitor.json file contains 
		 * an error string - ie tag_id starts with 'A PROBLEM'
		 * @param	e
		 */
		private function visitorError(e:Event):void
		{		
			dispatchEvent(new Event(JSON_ERROR));
		}
		
	}
	
}