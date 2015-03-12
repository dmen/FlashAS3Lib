package com.gmrmarketing.comcast.nascar
{
	import com.gmrmarketing.utilities.Utility;
	import flash.display.*;
	import flash.events.*;
	
	public class Circley
	{
		private var myButton:MovieClip;
		private var sprites:Array;
		
		public function Circley()
		{
			sprites = [];			
		}
		public function pause():void
		{
			if(myButton){
				myButton.removeEventListener(Event.ENTER_FRAME, update);
			}
		}
		public function resume():void
		{
			if(myButton){
				myButton.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			}
		}
		public function setButton(b:MovieClip = null):void
		{
			var i:int;
			//clear old button
			if(myButton){
				myButton.removeEventListener(Event.ENTER_FRAME, update);
			}
			
			for (i = 0; i < sprites.length; i++ ) {
				var s:Sprite = sprites[i][0];
				if (myButton) {
					if (myButton.contains(s)) {
						myButton.removeChild(s);
					}
				}
			}
			
			sprites = [];
			for (i = 2; i < 36; i += 4) {
				var aSprite:Sprite = new Sprite();
				aSprite.x = 44;
				aSprite.y = 44;
				var gap:int = 10 + Math.round(Math.random() * 50);
				var st:int = Math.round(Math.random() * 360);
				Utility.drawArc(aSprite.graphics, 0, 0, i, st, 360 + st - gap, 2, 0x0099d7, 1);
				var r:Number = .3 + Math.random() * 3;
				if (Math.random() < .5) {
					r *= -1;
				}
				sprites.push([aSprite, r]);
			}
			
			if (b != null) {				
				myButton = b;
				for (i = 0; i < sprites.length; i++ ) {
					myButton.addChild(sprites[i][0]);
				}
				myButton.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			}			
		}
		
		
		
		
		private function update(e:Event):void
		{			
			for (var i:int = 0; i < sprites.length; i++ ) {
				sprites[i][0].rotation += sprites[i][1];
			}
		}
		
		
	}
	
}