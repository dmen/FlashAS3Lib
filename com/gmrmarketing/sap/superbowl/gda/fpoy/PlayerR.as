package com.gmrmarketing.sap.superbowl.gda.fpoy
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class PlayerR extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		
		
		public function PlayerR(which:String):void
		{
			myClip = new mcPlayer(); //lib clip
			var pic:MovieClip;
			
			switch(which) {
				case "beckham":
					pic = new mcBeckham();
					myClip.theName.theText.text = "ODELL BECKHAM JR.";
					myClip.numberl.theText.text = "#5";
					myClip.numberr.theText.text = "#5";
					break;
				case "gronkowski":
					pic = new mcGronkowski();
					myClip.theName.theText.text = "ROB GRONKOWSKI";
					myClip.numberl.theText.text = "#6";
					myClip.numberr.theText.text = "#6";
					break;
				case "gostkowski":
					pic = new mcGostkowski();
					myClip.theName.theText.text = "STEPHEN GOSTKOWSKI";
					myClip.numberl.theText.text = "#7";
					myClip.numberr.theText.text = "#7";
					break;
				case "eagles":
					pic = new mcEagles();
					myClip.theName.theText.text = "PHILADELPHIA EAGLES";
					myClip.numberl.theText.text = "#8";
					myClip.numberr.theText.text = "#8";
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
		public function hideStats():void
		{
			myClip.numberl.x = -83;
			myClip.numberr.x = -48;
			myClip.theName.x = -256;
			myClip.position.x = -169;
			myClip.sentiment.x = -169;
			myClip.stat1.x = -196;
			myClip.stat2.x = -68;
			myClip.stat3.x = -68;
		}
		
		
		/**
		 * Shows just the player name and number
		 */
		public function showNameNumber():void
		{
			TweenMax.to(myClip.numberr, .25, { x:32 } );
			
			var tx:int = -256 + myClip.theName.theText.textWidth + 35;
			TweenMax.to(myClip.theName, .25, { x:tx } );
		}
		
	}
	
}