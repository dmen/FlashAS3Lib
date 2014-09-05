package com.gmrmarketing.sap.metlife
{
	import com.gmrmarketing.sap.metlife.Flare;
	import flash.display.DisplayObjectContainer;
	
	public class FlareManager
	{
		private var container:DisplayObjectContainer;
		
		
		public function FlareManager()
		{
			
		}
		
		public function setContainer($container:DisplayObjectContainer):void
		{
			container = $container;
		}
		
		
		public function newFlare(sx:int, sy:int, ex:int, delay:Number):void
		{
			var f:Flare = new Flare();
			f.setContainer(container);
			f.show(sx, sy, ex, delay);
		}
		
	}
	
}