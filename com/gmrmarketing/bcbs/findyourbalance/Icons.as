package com.gmrmarketing.bcbs.findyourbalance
{		
	import flash.utils.getDefinitionByName;
	import flash.display.MovieClip;
	
	public class Icons	
	{	
		private const L1ICONS:int = 6;
		private const L2ICONS:int = 1;
		private const L3ICONS:int = 1;
		
		public function Icons(){}
		
		public function getIcon(level:int):MovieClip
		{		
			var i:int;
			var classRef:Class;
			var clip:MovieClip;
			
			switch(level) {
				case 1:
					i = Math.floor(Math.random() * L1ICONS);
					classRef = getDefinitionByName( "mcIcon_med" + i ) as Class;
					clip = new classRef();
					break;
				case 2:
					i = Math.floor(Math.random() * L2ICONS);
					classRef = getDefinitionByName( "mcIcon_work" + i ) as Class;
					clip = new classRef();
					break;
				case 3:
					i = Math.floor(Math.random() * L3ICONS);
					classRef = getDefinitionByName( "mcIcon_extra" + i ) as Class;
					clip = new classRef();
					break;
			}
			return clip;
		}
	}
	
}