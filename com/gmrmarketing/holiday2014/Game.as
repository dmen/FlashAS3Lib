package com.gmrmarketing.holiday2014
{	
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class Game extends Sprite
	{
		[Embed(source="p5.png")]
		private static const BlueCircle:Class;
		
		private var tex:Texture;
		private var im:Image;
		
		public function Game()
		{			
			tex = Texture.fromBitmap(new BlueCircle());
			im = new Image(tex);
			
			addChild(im);
			im.x = 300;
			im.y = 300;
		}
	}
	
}
