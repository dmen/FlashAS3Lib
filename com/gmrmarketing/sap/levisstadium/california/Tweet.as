package com.gmrmarketing.sap.levisstadium.california
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	
	
	public class Tweet extends EventDispatcher
	{
		public static const COMPLETE:String = "tweetComplete";
		
		private var clip:MovieClip;//from lib - contains text field at 6,6 - contains rectContainer
		private var rectContainer:Sprite; //for drawing bg gradient rect - contains lineContainer
		private var lineContainer:Sprite;//so we can make a shadowed line above the bg rect
		private var container:DisplayObjectContainer;
		private var tweenOb:Object;
		private var dot:MovieClip;
		private var permDot:MovieClip;
		private var myQuadrant:int;
		
		
		//lib clip - 'clip' contains rectContainer on layer 0 - behind text already in the clip
		//rectContainer contains lineContainer
		public function Tweet()
		{
			lineContainer = new Sprite();//foreground outline and line to gps spot on map
			lineContainer.filters = [new DropShadowFilter(0, 0, 0x000000, .8, 7, 7)];
			
			rectContainer = new Sprite();//for drawing bg shape into
			rectContainer.addChild(lineContainer);
			
			tweenOb = new Object();//just a holder of tweening properties
			
			dot = new mapDot(); //lib clip	
			permDot = new mapDotInner();
			
			clip = new mcTweet();//lib clip - contains text field	
			clip.addChildAt(rectContainer, 0); //add behind text already in the clip			
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
		 * @param	quadrant which quadrant the message goes in 1 - 4
		 */
		public function show(userName:String, message:String, toX:int, toY:int, quadrant:int):void
		{
			clip.theUser.text = userName;
			clip.theText.text = message;		
			
			switch(quadrant) {
				case 1:
					clip.x = 8 + Math.random() * 10;
					clip.y = 235 + Math.random() * 10;
					break;
				case 2:
					clip.x = 40 + Math.random() * 10;
					clip.y = 380 + Math.random() * 10;
					break;
				case 3:
					clip.x = 400 + Math.random() * 50;
					clip.y = 45 + Math.random() * 10;
					break;
				case 4:
					clip.x = 510 + Math.random() * 10;
					clip.y = 200 + Math.random() * 10;
					break;
			}
			
			myQuadrant = quadrant;
			
			//outline rect
			lineContainer.graphics.lineStyle(1, 0xffffff, 1, true);
			lineContainer.graphics.drawRoundRect(0, 0, clip.theText.textWidth + 12, clip.theText.textHeight + 15, 18, 18);
			
			var g:Graphics = rectContainer.graphics;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(clip.theText.textWidth + 12, clip.theText.textHeight + 15, 1.5707963);//the 1.57...PI/2 radians - 90º
			g.beginGradientFill(GradientType.LINEAR, [0xffffff, 0x555555], [.4, .6], [0, 255], m);
			g.drawRoundRect(0, 0, clip.theText.textWidth + 12, clip.theText.textHeight + 15, 18, 18);
			g.endFill()
			
			if (!container.contains(clip)) {
				container.addChild(clip);
			}
			
			clip.scaleX = clip.scaleY = .25;
			clip.alpha = 0;
						
			TweenMax.to(clip, 1, { alpha:1, scaleX:1, scaleY:1, ease:Back.easeOut } );			
			
			//animated line			
			lineContainer.graphics.lineStyle(1, 0xFFFFFF, .7);			
			
			if (toX < clip.x) {
				//point on the left of the tweet
				if(toY < clip.y){
					lineContainer.graphics.moveTo(0, 12);					
					tweenOb.y = 12;
				}else {
					lineContainer.graphics.moveTo(0, clip.theText.textHeight);//+ 15 per rect - but remove to come above rounded corner
					tweenOb.y = clip.theText.textHeight;
				}
				tweenOb.x = 0;
			}else {
				//point on the right of the tweet
				trace(toY, clip.y);
				if (toY < clip.y) {
					lineContainer.graphics.moveTo(clip.theText.textWidth + 12, 12);
					tweenOb.y = 12;
				}else {
					lineContainer.graphics.moveTo(clip.theText.textWidth + 12, clip.theText.textHeight);
					tweenOb.y = clip.theText.textHeight;
				}
				tweenOb.x = clip.theText.textWidth + 12;
			}
			
			var r:Number = Math.random();
			if (r < .33) {
				TweenMax.to(clip.userBG, 0, { colorTransform: { tint:0xeeb400, tintAmount:1 }} );
			}else if (r < .66 ) {
				TweenMax.to(clip.userBG, 0, { colorTransform: { tint:0x008fd3, tintAmount:1 }} );
			}else {
				TweenMax.to(clip.userBG, 0, { colorTransform: { tint:0xa19a92, tintAmount:1 }} );
			}
			clip.userBG.width = rectContainer.width;
			
			//change toX,toY to screen coords, instead of lineContainer coords
			toX = toX - clip.x;
			toY = toY - clip.y;
			TweenMax.to(tweenOb, .5, { x:toX, y:toY, onUpdate:drawLine, delay:.75, ease:Linear.easeNone, onComplete:drawDone} );
		}
		
		
		private function drawLine():void
		{
			lineContainer.graphics.lineTo(tweenOb.x, tweenOb.y);
		}
		
		
		//called when line is done drawing - places a hit circle
		//at tweenOb.x,y
		private function drawDone():void
		{
			dot.x = tweenOb.x + clip.x;
			dot.y = tweenOb.y + clip.y;
			dot.scaleX = dot.scaleY = .1;
			dot.alpha = 1;
			container.addChild(dot);
			var sc:Number = .75 + Math.random();
			TweenMax.to(dot, 1, { alpha:0, scaleX:sc, scaleY:sc, rotation:45 + Math.random() * 90, onComplete:killDot } );
			
			permDot.x = dot.x;
			permDot.y = dot.y;
			permDot.alpha = 0;
			container.addChild(permDot);
			TweenMax.to(permDot, 1, { alpha:.7, delay:.5, onComplete:startEndTimer } );
		}
		
		
		private function killDot():void
		{
			if (container.contains(dot)) {
				container.removeChild(dot);
			}
		}
		
		
		private function startEndTimer():void
		{
			trace("text len:",clip.theText.text.length);
			var tLen:int = Math.max(3, String(clip.theText.text).length / 12);
			trace("timeout in", tLen);
			
			var end:Timer = new Timer(tLen * 1000, 1);
			end.addEventListener(TimerEvent.TIMER, tweetComplete);
			end.start();
		}
		
		
		public function getQuadrant():int
		{
			return myQuadrant;
		}
		
		
		private function tweetComplete(e:TimerEvent):void
		{			
			TweenMax.to(clip, 1, { alpha:0 } );
			TweenMax.to(permDot, 1, { alpha:0, onComplete:sendComplete } );
		}
		
		
		private function sendComplete():void
		{
			if (rectContainer.contains(lineContainer)) {
				rectContainer.removeChild(lineContainer);
			}
			if (clip.contains(rectContainer)) {
				clip.removeChild(rectContainer);
			}
			if (container.contains(clip)) {
				container.removeChild(clip);
			}
			killDot();
			
			dispatchEvent(new Event(COMPLETE));
		}
	}
	
}