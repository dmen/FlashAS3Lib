package com.gmrmarketing.sap.superbowl.gda.fotd
{
	import flash.display.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	
	public class UserArc extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var left:Boolean;
		private var pic:MovieClip; //player image from lib
		
		
		public function UserArc():void
		{			
			myClip = new userClip(); //lib clip			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function set name(n:String):void
		{
			myClip.nameLeft.theText.text = n;					
			myClip.nameRight.theText.text = n;					
		}
		
		
		/**
		 * use for setting x,y
		 */
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		
		/**
		 * used for drawing into
		 */
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
		 * Hides name/number to show just the user pic
		 */
		public function hideStats():void
		{
			myClip.nameRight.x = -260;
			myClip.nameLeft.x = -35;
			myClip.message.x = -23;
		}		
		
		
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