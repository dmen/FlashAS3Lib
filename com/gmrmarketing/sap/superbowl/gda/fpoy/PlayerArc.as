package com.gmrmarketing.sap.superbowl.gda.fpoy
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class PlayerArc extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var left:Boolean;
		private var pic:MovieClip; //player image from lib
		
		
		public function PlayerArc(which:String, isLeft:Boolean):void
		{			
			left = isLeft;			
			
			if (left) {
				myClip = new arcPlayerL(); //lib clip
			}else {
				myClip = new arcPlayerR(); //lib clip					
			}
			
			switch(which) {				
				case "luck":					
					pic = new mcLuck();
					myClip.theName.theText.text = "ANDREW LUCK";
					break;
				case "bell":
					pic = new mcBell();
					myClip.theName.theText.text = "LE'VEON BELL";
					break;
				case "murray":
					pic = new mcMurray();
					myClip.theName.theText.text = "DEMARCO MURRAY";
					break;
				case "brown":
					pic = new mcBrown();
					myClip.theName.theText.text = "ANTONIO BROWN";
					break;
					
					
				case "beckham":
					pic = new mcBeckham();
					myClip.theName.theText.text = "ODELL BECKHAM JR.";
					break;
				case "gronkowski":
					pic = new mcGronkowski();
					myClip.theName.theText.text = "ROB GRONKOWSKI";
					break;
				case "gostkowski":
					pic = new mcGostkowski();
					myClip.theName.theText.text = "STEPHEN GOSTKOWSKI";
					break;
				case "eagles":
					pic = new mcEagles();
					myClip.theName.theText.text = "PHILADELPHIA EAGLES";
					break;
			}
			
			myClip.addChild(pic);
			pic.x = 0; pic.y = 0;
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function set number(n:String):void
		{
			myClip.theNumber.theText.text = n;					
		}
		
		
		/**
		 * use for setting x,y
		 */
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		
		public function get circ():Graphics
		{
			return pic.circ.graphics;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
		}
		
		public function hide():void
		{
			if (myClip.contains(pic)) {
				myClip.removeChild(pic);
			}
			if (myContainer.contains(myClip)) {
				myContainer.removeChild(myClip);
			}
			circ.clear();
		}
		
		
		/**
		 * Hides name/number to show just the player pic
		 */
		public function hideStats():void
		{
			if (left) {
				myClip.theNumber.x = -81;
				myClip.theName.x = -76;
			}else {
				myClip.theNumber.x = -47;
				myClip.theName.x = -256;
			}
		}
		
		
		/**
		 * Shows just the player name and number
		 */
		public function showNameNumber():void
		{
			var tx:int;
			
			if (left) {
				TweenMax.to(myClip.theNumber, .25, { x:-160 } );				
				tx = -76 - (myClip.theName.theText.textWidth + 55);
				TweenMax.to(myClip.theName, .25, { x:tx } );
			}else{
				TweenMax.to(myClip.theNumber, .25, { x:32 } );				
				tx = -256 + myClip.theName.theText.textWidth + 35;
				TweenMax.to(myClip.theName, .25, { x:tx } );
			}
		}
		
	}
	
}