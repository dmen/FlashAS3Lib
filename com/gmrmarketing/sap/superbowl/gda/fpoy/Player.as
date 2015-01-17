package com.gmrmarketing.sap.superbowl.gda.fpoy
{
	import flash.display.*;
	import flash.events.*;
	
	public class Player extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function Player(which:String):void
		{
			myClip = new mcPlayer(); //lib clip
			var pic:MovieClip;
			
			switch(which) {
				case "beckham":
					pic = new mcBeckham();
					break;
				case "bell":
					pic = new mcBell();
					break;
			}
			
			myClip.addChild(pic);
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		/**
		 * use for setting x,y
		 */
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
		}
		
		
		/**
		 * Hides everything to show just the player pic
		 */
		public function showPic():void
		{
			myClip.numberl.x = -83;
			myClip.numberr.x = -48;
			myClip.theName.x = -169;
			myClip.position.x = -169;
			myClip.sentiment.x = -169;
			myClip.stat1.x = -196;
			myClip.stat2.x = -68;
			myClip.stat3.x = -68;
		}
		
		
	}
	
}