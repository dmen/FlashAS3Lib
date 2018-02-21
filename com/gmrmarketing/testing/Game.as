package com.gmrmarketing.testing
{
	import flash.display.BitmapData;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.text.TextField;
	import starling.display.Image;
	import starling.textures.Texture;
	import com.greensock.TweenMax;
	import flash.events.* ;
	
	public class Game extends Sprite
	{
		private var textField:TextField;
		
		 public function Game()
		{			
			addEventListener(EnterFrameEvent.ENTER_FRAME, update);
		}
		
		
		private function update(e:EnterFrameEvent):void
		{
			
			
		}
	}
	
}