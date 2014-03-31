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
	
	public class Chrome extends Image
	{
		private static var tex:Texture
		
		public function Chrome()
		{			
			if (!tex){
				tex = Texture.fromBitmapData(new chrome(), true, true);
			}
			
			super(tex);
			
			x = Math.random() * 600;
			y = Math.random() * 900;
		}
	}
	
}