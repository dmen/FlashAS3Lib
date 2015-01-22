/**
 * Single instance of a tweet - 
 * uses mcTweet clip from the library
 */
package com.gmrmarketing.sap.superbowl.gda.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.utilities.Strings;
	import com.gmrmarketing.utilities.SwearFilter;
	
	
	public class Tweet extends EventDispatcher
	{
		public static const COMPLETE:String = "tweetComplete";
		
		private var clip:MovieClip;//from lib - the two text containers theUser, theText
		private var rectContainer:Sprite; //contains the two angled text backgrounds
		private var lineContainer:Sprite; //for shooting the ray to the lat/lon loc
		private var container:DisplayObjectContainer;//container for this tweet
		private var dot:MovieClip;
		private var vx:Number;
		private var vy:Number;
		private var drawToX:int;
		private var drawToY:int;
		private var lineAlpha:Number;
		private var myWidth:int;
		private var dotDrawn:Boolean;
		private var angleX:int;
		
		//lib clip - 'clip' contains rectContainer on layer 0 - behind text already in the clip
		//rectContainer contains outlineContainer
		public function Tweet()
		{
			lineContainer = new Sprite();
			lineContainer.blendMode = BlendMode.ADD;
			
			rectContainer = new Sprite();			
			
			vx = 0;
			vy = 0;		
			
			dot = new mapDot(); //lib clip - animated expanding circle at lat/lon
			dotDrawn = false;
			
			clip = new mcTweet();//lib clip - contains text fields
			clip.addChildAt(rectContainer, 0); //add rectContainer behind text already in the clip	
			clip.addChild(lineContainer); //will be placed under the text once text is set - in drawTweetBox()
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function getWidth():int
		{
			return clip.theText.textWidth;
		}
		
		
		/**
		 * Shows this tweet message
		 * 
		 * @param	message up to 140 char message - no checks prevent > 140 though		
		 * @param	toX Where to shoot the line to - the lat/lon spot
		 * @param	toY 
		 * @param	quadrant which quadrant the message goes in 0 - 1
		 */
		public function show(userName:String, message:String, toX:int, toY:int, startX:int):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			
			clip.x = startX;
			clip.y = 75;
			
			message = message.replace(/&lt;/g, "<");
			message = message.replace(/&gt;/g, "<");
			message = message.replace(/&amp;/g, "&");
			while (message.indexOf("http://") != -1){
				message = Strings.removeChunk(message, "http://");
			}
			while (message.indexOf("https://") != -1){
				message = Strings.removeChunk(message, "https://");
			}
			message = SwearFilter.cleanString(message); //remove any major swears			
			
			clip.theUser.text = userName;
			clip.theText.autoSize = TextFieldAutoSize.LEFT;
			clip.theText.text = message;
			
			drawToX = toX;
			drawToY = toY;
			
			drawTweetBox();
			lineAlpha = .5;
			
			container.addEventListener(Event.ENTER_FRAME, update);		
		}
		
		
		private function drawTweetBox():void
		{			
			var g:Graphics = rectContainer.graphics;
			g.beginFill(0x0d254c, 1);
			g.moveTo(0, 22);
			g.lineTo(clip.theUser.textWidth + 30, 22);
			g.lineTo(clip.theUser.textWidth + 45, 0);
			g.lineTo(15, 0);
			g.lineTo(0, 22);
			g.endFill();
			
			var yPos:int = 25;//under the user text
			g.beginFill(0x6c5d8d, 1);
			g.moveTo(0, yPos);
			
			if (clip.theText.textHeight > 20) {
				//two lines
				g.lineTo(clip.theText.textWidth + 38, yPos);
				g.lineTo(clip.theText.textWidth + 10, yPos + clip.theText.textHeight + 10);
				g.lineTo( -28, yPos + clip.theText.textHeight + 10);
				angleX = -28;
			}else {
				//one line
				g.lineTo(clip.theText.textWidth + 27, yPos);
				g.lineTo(clip.theText.textWidth + 10, yPos + clip.theText.textHeight + 10);
				g.lineTo( -17, yPos + clip.theText.textHeight + 10);
				angleX = -17;
			}			
			
			g.lineTo(0, yPos);
			g.endFill();
			
			lineContainer.x = 0;
			lineContainer.y = yPos + clip.theText.textHeight + 10;
		}
		
		
		private function drawLine():void
		{
			var dtx:int = drawToX - clip.x;
			var dty:int = drawToY - clip.y - lineContainer.y;		
			var g:Graphics = lineContainer.graphics;
			g.clear();
			g.beginFill(0xFFFFFF, lineAlpha);
			g.moveTo(angleX, 0);
			g.lineTo(angleX + 40, 0);
			g.lineTo(dtx, dty);
			g.lineTo(angleX, 0);
		}
		
		
		private function update(e:Event):void
		{
			clip.x -= 2;
			
			if (clip.x < 80) {
				lineAlpha -= .05;
				if (lineAlpha < 0) {
					lineAlpha = 0;
				}
			}
			if (clip.x < -(getWidth() * .5)) {
				//fade the clip out
				clip.alpha -= .01;
				if (clip.alpha <= 0) {
					container.removeEventListener(Event.ENTER_FRAME, update);
					dispatchEvent(new Event(COMPLETE));
					return;
				}
			}
			
			if(clip.x < 630){
				drawLine();
				
				if (!dotDrawn) {
					//animated dot
					dot.x = drawToX;
					dot.y = drawToY;
					dot.scaleX = dot.scaleY = .01;
					dot.alpha = 1;
					container.addChildAt(dot, 0);
					
					TweenMax.to(dot, .5, { scaleX:.2, scaleY:.2, ease:Elastic.easeOut} );
					TweenMax.to(dot, .5, { alpha:0, delay:.5 } );			
					
					dotDrawn = true;
				}
			}
			/*
			if (clip.x < -clip.theText.textWidth - 20) {
				container.removeEventListener(Event.ENTER_FRAME, update);
				dispatchEvent(new Event(COMPLETE));
			}
			*/
		}		
		
		
		public function dispose():void
		{			
			lineContainer.graphics.clear();			
			
			if (clip.contains(rectContainer)) {
				clip.removeChild(rectContainer);
			}
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
			if (container.contains(dot)) {
				container.removeChild(dot);
			}
			
			lineContainer = null;
			rectContainer = null;
			clip = null;
			dot = null;	
		}
	}
	
}