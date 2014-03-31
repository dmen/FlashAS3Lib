package com.gmrmarketing.comcast.mlb
{	
	import flash.display.MovieClip;	
	import com.greensock.TweenLite;	
	
	
	public class Scoreboard extends MovieClip
	{
		private var speedStrings:Array;
		
		public function Scoreboard()
		{
			x = 204;
			y = 19;
			
			speedStrings = new Array();
			//speedStrings.push("Pirates Fans<br/>Step up to the plate and help Pirate Parrot take batting practice.<br/>Press the Space Bar to hit the baseball.");
			speedStrings.push("White Sox Fans, step up to the plate and help Southpaw take batting practice.<br/>Press the Swing Button<br/>to help Southpaw hit the baseball.");
			speedStrings.push("Dial up is slow.<br/>You may be able to hit the ball,<br/>but you’re not going to do much on the Internet.<br/><br/>Upgrade to XFINITY if you want to play for Comcast.");
			speedStrings.push("Now you’re a player!<br/><br/>Email and surfing with speeds up to 25 Mbps.");
			speedStrings.push("How does it feel to be in the big leagues? <br/><br/>Too bad DSL from the phone company<br/>can’t compete with you.");
			speedStrings.push("You’re an All-Star now!<br/><br/>You have the fastest Internet.<br/>Download anything and everything;<br/>faster than anyone.");
		}
		
		
		public function showLevelText(theLevel:int):void
		{
			theText.htmlText = speedStrings[theLevel];
			theText.alpha = 0;
			theText.y = ((203 - theText.textHeight) * .5) - 15;
			TweenLite.to(theText, 1, { alpha:1 } );
		}
		
		
		public function showScore(score:int):void
		{
			theHits.text = String(score);
		}
		
		
		public function showStrikes(strikes:int):void
		{
			theStrikes.text = String(strikes);
		}
		
		
	}
	
}