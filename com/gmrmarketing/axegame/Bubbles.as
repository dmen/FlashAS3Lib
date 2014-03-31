package com.gmrmarketing.axegame
{
	
	import flash.display.Sprite;	
	import gs.TweenLite;
	import gs.plugins.*;
	import flash.events.Event;
	import flash.display.MovieClip;	


	public class Bubbles extends Sprite
	{		
		private var bubX:uint;
		private var bubY:uint;		
		private var theGame:Sprite;
		private var bubbles:Array;
		
		
		public function Bubbles(gameRef:Sprite, tx:uint, ty:uint)
		{
			TweenPlugin.activate([GlowFilterPlugin]);
			
			bubbles = new Array();
			theGame = gameRef;
			bubX = tx;
			bubY = ty;			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function getBubbles():Array
		{
			removeEventListener(Event.ENTER_FRAME, loop);
			return bubbles;
		}
		
		public function killBubbles()
		{	
			removeEventListener(Event.ENTER_FRAME, loop);
			for (var i:uint = 0; i < bubbles.length; i++) {
				var whichBubble:MovieClip = bubbles[i];
				TweenLite.killTweensOf(whichBubble);
				if (theGame.contains(whichBubble)) { theGame.removeChild(whichBubble);}				
			}
			//bubbles = new Array();
		}
		
		private function loop(e:Event) 
		{			
			if (Math.random() < .7)
			{
				var newBub:MovieClip = new Bubble();
				var ind:uint = bubbles.push(newBub);				
				
				var xPos = Math.random() * 10;
				if (Math.random() < .5) {
					xPos *= -1;
				}
				var yPos = Math.random() * 10;
				if (Math.random() < .5) {
					yPos *= -1;
				}
				newBub.x = bubX + xPos;
				newBub.y = bubY + yPos;
				
				newBub.scaleX = .1 * Math.random();
				newBub.scaleY = .1 * Math.random();
				
				theGame.addChildAt(newBub, 1); //images are added to game at index 0 - add bubbles at 1
				
				var newScale = .2 + (Math.random() / 3);
				TweenLite.to(newBub, .5 + Math.random(), {glowFilter:{color:0xFF0000, alpha:1, blurX:10, blurY:10, quality:1, strength:1}, scaleX:newScale, scaleY:newScale, onComplete:remove});
			}			
		}
		
		
		private function remove()
		{
			var whichBubble:MovieClip = bubbles.splice(0, 1)[0];			
			if (theGame.contains(whichBubble)) { theGame.removeChild(whichBubble);}
		}
	}
	
}