
package com.gmrmarketing.morris
{ 
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.text.TextField;
	import gs.TweenLite;
	import gs.easing.*	
	
	public class QuickMessage extends Sprite
	{		
		private var theGame:Sprite;
		
		public function QuickMessage(gameRef:Sprite, mess:String):void
		{
			theGame = gameRef;
			theText.text = mess;
			scaleX = scaleY = .75;
			TweenLite.to(this, .8, { alpha:0, scaleX:1.6, scaleY:1.6, onComplete:removeSelf } );
		}
		
		public function removeSelf() : void 
		{ 
			if (theGame.contains(this)){
				theGame.removeChild(this);
			}
		} 
	} 
}