package com.gmrmarketing.holiday2014
{
	import flash.display.Sprite;
	import starling.core.Starling;

	public class Main extends Sprite
	{
		private var _starling:Starling;

		public function Startup()
		{
			_starling = new Starling(Game, stage);
			_starling.start();
		}
	}
}