package com.gmrmarketing.testing
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import starling.core.Starling;
	
	public class StarlingTest extends MovieClip
	{
		private var starling:Starling;
		
		public function StarlingTest()		
		{
			starling = new Starling(Game, stage);
			starling.start();
			starling.showStats = true;
		}
	}
	
}