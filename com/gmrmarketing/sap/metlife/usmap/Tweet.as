/**
 * Single instance of a tweet - 
 * uses mcTweet clip from the library
 */
package com.gmrmarketing.sap.metlife.usmap
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.text.TextFieldAutoSize;
	import com.gmrmarketing.utilities.Strings;
	
	
	public class Tweet extends EventDispatcher
	{
		public static const COMPLETE:String = "tweetComplete";
		
		private var clip:MovieClip;//from lib - contains text field at 6,6 - contains rectContainer
		private var rectContainer:Sprite; //for drawing bg gradient rect - contains outlineContainer
		private var outlineContainer:Sprite;//so we can make a shadowed outline rect above the gradient bg rect
		private var lineContainer:Sprite; //for shooting the ray to the lat/lon loc
		private var container:DisplayObjectContainer;
		private var tweenOb:Object;
		private var dot:MovieClip;
		private var myQuadrant:int; // 1 or 2 set in show()
		private var vx:Number;
		private var vy:Number;
		private var drawToX:int;
		private var drawToY:int;
		private var endTimer:Timer;
		
		
		//lib clip - 'clip' contains rectContainer on layer 0 - behind text already in the clip
		//rectContainer contains outlineContainer
		public function Tweet()
		{
			outlineContainer = new Sprite();//foreground outline and line to gps spot on map
			//outlineContainer.filters = [new DropShadowFilter(0, 0, 0x000000, .8, 7, 7)];
			
			lineContainer = new Sprite();
			lineContainer.blendMode = BlendMode.ADD;
			//lineContainer.filters = [new DropShadowFilter(0, 0, 0x000000, .8, 7, 7)];
			
			rectContainer = new Sprite();//for drawing bg shape into
			//rectContainer.filters = [new DropShadowFilter(0, 0, 0x000000, .8, 7, 7)]
			
			rectContainer.addChildAt(lineContainer,0);
			rectContainer.addChild(outlineContainer);	
			
			vx = 0;
			vy = 0;
			
			tweenOb = new Object();//just a holder of tweening properties
			
			dot = new mapDot(); //lib clip - animated expanding circle at lat/lon
			
			clip = new mcTweet();//lib clip - contains text fields
			clip.addChildAt(rectContainer, 0); //add rectContainer behind text already in the clip			
		}
		
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		/**
		 * Shows this tweet message
		 * 
		 * @param	message up to 140 char message - no checks prevent > 140 though		
		 * @param	toX Where to shoot the line to - the lat/lon spot
		 * @param	toY 
		 * @param	quadrant which quadrant the message goes in 0 - 1
		 */
		public function show(userName:String, message:String, toX:int, toY:int, quadrant:int):void
		{
			if (!container.contains(clip)) {
				container.addChild(clip);
			}			
			
			message = message.replace(/&lt;/g, "<");
			message = message.replace(/&gt;/g, "<");
			message = message.replace(/&amp;/g, "&");
			message = Strings.removeChunk(message, "http://");
			
			clip.userBG.alpha = 0;
			clip.theText.alpha = 0; //contains the two text fields
			clip.theText.theUser.text = userName;
			clip.theText.theText.autoSize = TextFieldAutoSize.LEFT;
			clip.theText.theText.text = message;
			
			var rectWidth:int = Math.max(200, clip.theText.theText.textWidth + 12);
			
			drawToX = toX;
			drawToY = toY;
			
			myQuadrant = quadrant;			
			
			//animated dot
			dot.x = drawToX;
			dot.y = drawToY;
			dot.scaleX = dot.scaleY = .1;
			dot.alpha = 1;
			container.addChild(dot);
			//var sc:Number = .7 + 2 * Math.random();			
			TweenMax.to(dot, .5, { scaleX:.5, scaleY:.5, ease:Elastic.easeOut} );
			TweenMax.to(dot, .5, { alpha:0, delay:1.25 } );
			
			switch(quadrant) {
				case 0:
					clip.x = 40 + Math.random() * 10;
					clip.y = 150 + Math.random() * 50;
					break;
				case 1:
					clip.x = 745 + Math.random() * 10;
					clip.y = 140 + Math.random() * 10;
					break;
			}			
			
			//animated line			
			lineContainer.graphics.lineStyle(2, 0xffffff, 1);			
			
			//change toX,toY to screen coords, instead of outlineContainer coords
			drawToX = toX - clip.x;
			drawToY = toY - clip.y;
			
			lineContainer.graphics.moveTo(drawToX, drawToY);
			tweenOb.x = drawToX;
			tweenOb.y = drawToY;
			
			//if (myQuadrant == 2) {
				//point on the left of the tweet	
				TweenMax.to(tweenOb, .25, { x:0, y:-22, onUpdate:drawLine, delay:.5, ease:Linear.easeNone, onComplete:drawTweetBox} );						
			//}else {			
				//TweenMax.to(tweenOb, .25, { x:rectWidth, y: -22, onUpdate:drawLine, delay:.75, ease:Linear.easeNone, onComplete:drawTweetBox } );			
			//}	
		}
		
		
		private function drawLine():void
		{
			lineContainer.graphics.lineTo(tweenOb.x, tweenOb.y);
		}
		
		
		private function drawTweetBox():void
		{			
			TweenMax.to(lineContainer, 1, { alpha:0 } );
			
			var rectWidth:int = Math.max(200, clip.theText.theText.textWidth + 12);			
			
			var g:Graphics = rectContainer.graphics;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(rectWidth, clip.theText.theText.textHeight + 15, 1.5707963);//the 1.57...PI/2 radians - 90º
			g.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xc8c8c8], [.88,.88], [20, 255], m);
			g.drawRoundRect(0, 0, rectWidth, clip.theText.theText.textHeight + 15, 18, 18);
			g.endFill()			
			
			//user name bg
			var u:Graphics = clip.userBG.graphics;
			u.beginFill(0x0b3126, 1);
			u.drawRoundRect(0, 0, rectWidth, 36, 18, 18);
			u.endFill();
			u.lineStyle(2, 0xffffff);
			u.drawRoundRect(0, 0, rectWidth, 36, 18, 18);
			
			TweenMax.to(clip.theText, 1, { alpha:1 } );
			TweenMax.to(clip.userBG, 1, { alpha:1, onComplete:startEndTimer } );
		}
		
		
		private function startEndTimer():void
		{			
			var tLen:int = Math.max(1, clip.theText.theText.length / 14);			
			
			endTimer = new Timer(tLen * 1000, 1);
			endTimer.addEventListener(TimerEvent.TIMER, tweetComplete);
			endTimer.start();
		}
		
		
		public function getQuadrant():int
		{
			return myQuadrant;
		}
		
		
		private function tweetComplete(e:TimerEvent):void
		{			
			endTimer.removeEventListener(TimerEvent.TIMER, tweetComplete);			
			TweenMax.to(clip, 1, { alpha:0, onComplete:complete } );
		}
		
		
		private function complete():void
		{
			dispatchEvent(new Event(COMPLETE));
		}
		
		
		/**
		 * Called from TweetManager.reycleQuadrant once it receives the 
		 * COMPLETE event
		 */
		public function dispose():void
		{
			lineContainer.graphics.clear();
			clip.userBG.graphics.clear();			
			
			if (rectContainer.contains(outlineContainer)) {
				rectContainer.removeChild(outlineContainer);
			}
			if (rectContainer.contains(lineContainer)) {
				rectContainer.removeChild(lineContainer);
			}
			if (clip.contains(rectContainer)) {
				clip.removeChild(rectContainer);
			}
			if (container.contains(clip)) {
				container.removeChild(clip);
			}			
			if (container.contains(dot)) {
				container.removeChild(dot);
			}
			
			outlineContainer = null;
			lineContainer = null;
			rectContainer = null;
			clip = null;
			dot = null;
			myQuadrant = -1;			
		}
	}
	
}