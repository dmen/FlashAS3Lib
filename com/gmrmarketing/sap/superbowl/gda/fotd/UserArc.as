package com.gmrmarketing.sap.superbowl.gda.fotd
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	public class UserArc extends EventDispatcher
	{
		private var myClip:MovieClip;
		private var myContainer:DisplayObjectContainer;
		private var left:Boolean;
		private var pic:MovieClip; //player image from lib
		private var myLoader:Loader;
		private var fanImage:Bitmap;
		
		
		public function UserArc():void
		{			
			myClip = new userClip(); //lib clip			
		}
		
		
		public function set container(c:DisplayObjectContainer):void
		{
			myContainer = c;
		}
		
		
		public function set image(url:String):void
		{
			var myLoader:Loader = new Loader();
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imLoaded, false, 0, true);			
			myLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imError, false, 0, true);			
			myLoader.load(new URLRequest(url));
		}
		
		private function imLoaded(e:Event):void
		{	
			//remove old image from clip
			if(fanImage){
				if (myClip.contains(fanImage)) {
					myClip.removeChild(fanImage);
				}
			}			
			
			fanImage = Bitmap(e.target.content);
			fanImage.smoothing = true;
			fanImage.width = fanImage.height = 140;
			fanImage.x = -70; fanImage.y = -70;
			myClip.addChildAt(fanImage, myClip.numChildren-1); //adds image to the fan clip	
			fanImage.mask = myClip.picMask;
		}
		
		private function imError(e:IOErrorEvent = null):void
		{
			//remove old image from clip
			if(fanImage){
				if (myClip.contains(fanImage)) {
					myClip.removeChild(fanImage);
				}
			}
			
			fanImage = new Bitmap(new noPic());
			fanImage.smoothing = true;
			fanImage.x = -60; fanImage.y = -60;
			myClip.addChildAt(fanImage, myClip.numChildren-1); //adds image to the fan clip	
			fanImage.mask = myClip.picMask;	
		}
		
		/**
		 * use for setting x,y
		 */
		public function get clip():MovieClip
		{
			return myClip;
		}
		
		
		/**
		 * used for drawing arc into
		 */
		public function get circ():Graphics
		{
			return myClip.circ.graphics;
		}
		
		
		public function show():void
		{
			if (!myContainer.contains(myClip)) {
				myContainer.addChild(myClip);
			}
		}
		
		
		public function hide():void
		{
			if(pic){
				if (myClip.contains(pic)) {
					myClip.removeChild(pic);
				}
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
		
		
		public function showHandle():void
		{					
			var tx:int = -260 + myClip.nameRight.theText.textWidth + 58;
			TweenMax.to(myClip.nameRight, .25, { x:tx } );			
		}
		
		public function hideHandle():void
		{
			TweenMax.to(myClip.nameRight, .25, { x:-260} );
		}
		
		
		public function showMessage():void
		{
			TweenMax.to(myClip, .5, { scaleX:1, scaleY:1, ease:Back.easeOut } );
			
			var tx:int = -35 - myClip.nameLeft.theText.textWidth - 65;
			TweenMax.to(myClip.nameLeft, .5, { x:tx, ease:Back.easeOut, delay:.5 } ); 
			TweenMax.to(myClip.message, .5, { x: -298, ease:Back.easeOut, delay:.5 } );	
			
			//displayed for 8 seconds
			//scroll text if necessary
			var mh:Number = myClip.message.theMask.height;
			var delt:Number = myClip.message.theText.textHeight - mh;
			
			if(delt > 0){
				TweenMax.to(myClip.message.theText, 7, {y:myClip.message.theMask.y - delt - 5, ease:Linear.easeNone, delay:2});
			}
		}
		
		public function smallAgain():void
		{
			TweenMax.to(myClip, .5, { scaleX:.5, scaleY:.5, ease:Back.easeIn, delay:.25 } );
			TweenMax.to(myClip.nameLeft, .5, { x:-35, ease:Back.easeIn } ); 
			TweenMax.to(myClip.message, .5, { x: -23, ease:Back.easeIn } );
			TweenMax.to(myClip, .5, { alpha:0, delay:.6 } );
		}
		
	}
	
}